//  LaunchCalc.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import KTLoadingLabel
import StoreKit

class Calculator: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var statsDescriptions = ["Total work-time", "Average shift length", "Total shifts", "Total days worked", "Overtime worked", "Money from overtime (gross)", "Money from overtime (net)"]
    
    var periodLbl = UILabel()
    var btn: UIButton!
    var btnImage: UIImageView!
    @IBOutlet weak var grossLbl: CountingLabel!
    @IBOutlet weak var salaryLbl: CountingLabel!
    var statsTable = UITableView()
    var menuTable = UITableView()
    
    var pulldownMenuIsShowing = false
    var loadingLabel: KTLoadingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayout()
        loadingAnimation(withTitle: "Syncing")
        // Adds a listener that gets called each time users state changes
        loginListener = Auth.auth().addStateDidChangeListener { (auth, currentUser) in
            if currentUser != nil {

                CloudStorage.getSettings(toUser: currentUser!.uid, completionHandler: { () in
                    CloudStorage.getAllShifts(fromUser: currentUser!.uid) { (data) in
                        Periods.organizeShiftsIntoPeriods(ar: data, successHandler: {
                            Periods.organizePeriodsByYear(periods: shifts, successHandler: {
                                Periods.makePeriod(yearIndex: 0, monthIndex: 0, successHandler: {
                                    self.stopLoadingAnimation()
                                    self.refreshDataAndAnimations()
                                })
                            })
                        })
                    }
                })
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshDataAndAnimations()
        
        if Periods.totalShifts() > 10 {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        resetLabels()
        btn.transform = .identity // resets button to its original position
        if pulldownMenuIsShowing {
            menuTable.frame = CGRect(x: 0, y: (btn.center.y + btn.frame.height/2), width: self.view.frame.width, height: 0)
            pulldownMenuIsShowing = false
        }
    }
    
    func loadingAnimation(withTitle: String) {
        grossLbl.layer.opacity = 0
        salaryLbl.layer.opacity = 0
        loadingLabel.layer.opacity = 1
        loadingLabel.staticText = withTitle
        loadingLabel.animate()
        for cell in statsTable.visibleCells {
            let cell = cell as! LaunchCell
            
            cell.statsInfo.animate()
            cell.statsInfo.staticText = ""
            cell.statsInfo.animateText = "..."
        }
    }
    
    func stopLoadingAnimation() {
        loadingLabel.layer.opacity = 0
        grossLbl.layer.opacity = 1
        salaryLbl.layer.opacity = 1
        loadingLabel.stopAnimate()
        
        for cell in statsTable.visibleCells {
            let cell = cell as! LaunchCell
            
            cell.statsInfo.stopAnimate()
            cell.statsInfo.staticText = ""
            cell.statsInfo.animateText = ""
        }
    }
    
    
    func createLayout() {
        makeGradient()
        makeMenuBtn()
        designLabels()
        configureStatsTable()
        configureMenuTable()
        createLoadingLabel()
    }
    
    func refreshDataAndAnimations() {
        periodLbl.text = (period == nil) ? "" : period!.duration
        startCountingLabels()
        menuTable.reloadData()
        statsTable.reloadData()
    }
    
    func makeMenuBtn() {
        btn = UIButton()
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        let imageWidth = Int(gradientMaxY-(horizontalY + gradientMaxY*0.25))/2
        
        let image = UIImage(named: "pulldown_icon.png")
        btn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: CGFloat(imageWidth*2))
        btn.frame.origin.y = gradientMaxY-btn.frame.height
        btn.addTarget(self, action: #selector(btnPressed(sender:)), for: UIControl.Event.touchUpInside)
        
        btnImage = UIImageView(image: image)
        btnImage.setImageColor(color: Colors.detailColor)
        btnImage.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)
        btnImage.center = CGPoint(x: self.view.center.x, y: btn.center.y)
        
        self.view.addSubview(btnImage)
        self.view.addSubview(btn)
    }
    
    @objc func btnPressed(sender: UIButton) {
        if shifts.count > 0 {
            
            if pulldownMenuIsShowing {
                UIView.animate(withDuration: 0.3, animations: {
                    self.menuTable.frame = CGRect(x: 0, y: (sender.center.y + sender.frame.height/2), width: self.view.frame.width, height: 0)
                })
                UIView.animate(withDuration: 0.3, animations: {
                    self.btnImage.transform = .identity
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
                    self.menuTable.frame = CGRect(x: 0, y: (sender.center.y + sender.frame.height/2), width: self.view.frame.width, height: self.view.frame.height*0.4)
                }, completion: nil)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.btnImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
            }
            pulldownMenuIsShowing = !pulldownMenuIsShowing
        } else {
            self.btnImage.shake(direction: "vertical", swings: 1)
        }
    }
    
    func resetLabels() {
        salaryLbl.text = 0.currencyString()
        grossLbl.text = "Gross: " + 0.currencyString()
        periodLbl.text = ""
    }
    func configureMenuTable() {
        menuTable.backgroundColor = Colors.calculatorGradientBottom
        menuTable.separatorColor = UIColor.white.withAlphaComponent(0.2)
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.tag = 2
        menuTable.frame = CGRect(x: 0, y: (btn.center.y + btn.frame.height/2), width: self.view.frame.width, height: 0)
        menuTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        menuTable.separatorStyle = .singleLine
        self.view.addSubview(menuTable)
    }
    func configureStatsTable() {
        statsTable.delegate = self
        statsTable.dataSource = self
        statsTable.tag = 1
        statsTable.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.6)
        statsTable.center = CGPoint(x: self.view.frame.width/2, y: (self.view.frame.height*0.4) + statsTable.frame.height/2)
        statsTable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        statsTable.separatorColor = UIColor.black.withAlphaComponent(0.2)
        statsTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        statsTable.register(LaunchCell.self, forCellReuseIdentifier: "cell")
        statsTable.isScrollEnabled = true
        self.view.addSubview(statsTable)
    }
    func createLoadingLabel() {
        loadingLabel = KTLoadingLabel(staticString: "Retrieving shifts", animateString: "...")
        loadingLabel.timerInterval = 0.5
        loadingLabel.font = UIFont.systemFont(ofSize: 25, weight: .thin)
        loadingLabel.textColor = .white
        loadingLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.4)
        loadingLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.height/5)
        self.view.addSubview(loadingLabel)
    }
    func makeGradient() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [Colors.calculatorGradientTop.cgColor, Colors.calculatorGradientBottom.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.4)
        let startingLocation = NSNumber(floatLiteral: Double(Double(66)/Double(gradientLayer.frame.height)))
        gradientLayer.locations = [startingLocation, 1.0]
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.layer.insertSublayer(gradientLayer, at: UInt32(0))
    }
    
    func designLabels() {
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        
        salaryLbl.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: Int(gradientMaxY/3))
        salaryLbl.font = UIFont.systemFont(ofSize: 40)
        salaryLbl.text = salaryLbl.text
        salaryLbl.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.2 * 0.9))
        salaryLbl.textColor = .white
        salaryLbl.textAlignment = .center
        salaryLbl.layer.opacity = 0
        
        grossLbl.frame = CGRect(x: 0, y: 0, width: Int((self.view.frame.width/2) * 0.66), height: Int((gradientMaxY-horizontalY) * 0.66))
        grossLbl.font = UIFont.systemFont(ofSize: 13, weight: .light)
        grossLbl.center = CGPoint(x: Int(self.view.center.x), y: Int(salaryLbl.center.y + grossLbl.frame.height/2))
        grossLbl.textAlignment = .center
        grossLbl.textColor = .white
        grossLbl.layer.opacity = 0
        
        periodLbl.textColor = .white
        periodLbl.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        periodLbl.text = ""
        periodLbl.frame = CGRect(x: self.view.frame.width/20, y: 0, width: self.view.frame.width/3, height: 50)
        periodLbl.center.y = btn.center.y
        
        resetLabels()
        self.view.addSubview(periodLbl)
    }
    
    func startCountingLabels() {
        if period != nil {
            if Int(period!.grossSalary) > 0 {
                grossLbl.count(fromValue: 0, to: Float(period!.grossSalary), withDuration: 1.5, andAnimationtype: .EaseOut, andCounterType: .Int, preString: "Gross: ", afterString: "")
                salaryLbl.count(fromValue: 0, to: Float(period!.netSalary), withDuration: TimeInterval(1.5 * (Float(period!.netSalary)/Float(period!.grossSalary))), andAnimationtype: .EaseOut, andCounterType: .Int, preString: "", afterString: "")
            }
        }
    }
    
    func fillLabelsWithStats() {
        if period != nil {
            salaryLbl.text = "test" // StringFormatter.addCurrencyToNumber(amount: period.salary)
            periodLbl.text = period!.duration
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 2 {
            let startingString = String(Array(periodsSeperatedByYear[section][0][periodsSeperatedByYear[section][0].count-1].date.description)[0..<4])
            let headerView = UIView()
            
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 28, width:
                tableView.bounds.size.width, height: tableView.bounds.size.height))
            headerLabel.textColor = .white
            headerLabel.text = startingString
            headerLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            headerLabel.sizeToFit()
            headerLabel.textAlignment = .center
            headerView.addSubview(headerLabel)
            
            return headerView
        } else {
            return UIView()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 2 {
            return 40
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 2 {
            pulldownMenuIsShowing = false
            UIView.animate(withDuration: 0.3, animations: {
                self.menuTable.frame = CGRect(x: 0, y: (self.btn.center.y + self.btn.frame.height/2), width: self.view.frame.width, height: 0)
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.btn.transform = .identity
            })
            
            let prevCell = menuTable.cellForRow(at: IndexPath(row: indexForChosenPeriod[1], section: indexForChosenPeriod[0]))
            prevCell?.accessoryType = .none
            let cellPressed = menuTable.cellForRow(at: indexPath)!
            cellPressed.accessoryType = .checkmark
            cellPressed.tintColor = .white
            if indexPath.section != indexForChosenPeriod[0] || indexPath.row != indexForChosenPeriod[1] {
                indexForChosenPeriod = [indexPath.section, indexPath.row]
    
                let year = indexForChosenPeriod[0]
                let month = indexForChosenPeriod[1]
                loadingAnimation(withTitle: "Calculating")
                Periods.makePeriod(yearIndex: year, monthIndex: month, successHandler: {
                    self.periodLbl.text = period?.duration
                    self.stopLoadingAnimation()
                    self.statsTable.reloadData()
                    self.startCountingLabels()
                })
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Stats Table
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LaunchCell
            
            cell.insertStatsDesc(width: (self.view.frame.width), text: statsDescriptions[indexPath.row])
            if period != nil {
                cell.insertStatsInfo(width: self.view.frame.width, text: period!.statsForDisplay[indexPath.row])
            } else {
                cell.insertStatsInfo(width: self.view.frame.width, text: "0")
            }
            
            return cell
            
            // Periods table
        } else {
            let cell = UITableViewCell()
            let section = periodsSeperatedByYear[indexPath.section][indexPath.row]
            let end = String(Array(Time.dateToString(date: section[0].date, withDayName: false))[0..<Time.dateToString(date: section[0].date, withDayName: false).count-4])
            let start = String(Array(Time.dateToString(date: section[section.count-1].date, withDayName: false))[0..<Time.dateToString(date: section[section.count-1].date, withDayName: false).count-4])
            cell.textLabel?.text = start + " - " + end
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.black.withAlphaComponent(0)
            if indexPath.section == indexForChosenPeriod[0] && indexPath.row == indexForChosenPeriod[1] {
                cell.tintColor = .white
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return 1
        } else {
            return periodsSeperatedByYear.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return statsDescriptions.count
        } else {
            return periodsSeperatedByYear[section].count
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuTable.endEditing(true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
