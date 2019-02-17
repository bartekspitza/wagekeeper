//  LaunchCalc.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth

class Calculator: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var periodLbl = UILabel()
    var btn: UIButton!
    @IBOutlet weak var grossLbl: CountingLabel!
    @IBOutlet weak var salaryLbl: CountingLabel!
    var seperatorLineHorizontal = UIView()
    var upperLineOfArrowButton = UIView()
    var statsTable = UITableView()
    var menuTable = UITableView()
    
    
    var periodsSeperatedByYear = [[[ShiftModel]]]()
    var period: Period!
    var pulldownMenuIsShowing = false
    var indexForChosenPeriod = [0,0]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        makeGradient()
        makeMenuBtn()
        designLabels()
        configureStatsTable()
        configureMenuTable()
        
        // Called when user logs in
        Auth.auth().addStateDidChangeListener { (auth, currentUser) in
            if currentUser != nil {
                user = User(ID: currentUser!.uid, email: currentUser!.email!)
                CloudStorage.getAllShifts(fromUser: user.ID) { (data) in
                    var tmp = data
                    shifts = Periods.organizeShiftsIntoPeriods(ar: &tmp)
                    self.refreshDataAndAnimations()
                }
            }
        }
        if usingLocalStorage {
            print("Fetched data from local storage")
            LocalStorage.values = LocalStorage.getAllShifts()
            LocalStorage.organizedValues = Periods.organizeShiftsIntoPeriods(ar: &LocalStorage.values)
            shifts = Periods.convertShiftsFromCoreDataToModels(arr: LocalStorage.organizedValues)
        
        }
        shouldFetchAllData = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshDataAndAnimations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        resetLabels()
        btn.transform = .identity // resets button to its original position
        if pulldownMenuIsShowing {
            menuTable.frame = CGRect(x: 0, y: (btn.center.y + btn.frame.height/2), width: self.view.frame.width, height: 0)
            pulldownMenuIsShowing = false
        }
        period = nil
        indexForChosenPeriod = [0, 0]
    }
    
    func refreshDataAndAnimations() {
        makePeriodsSeperatedByYear()
        makePeriod()
        startCountingLabels()
        menuTable.reloadData()
        statsTable.reloadData()
    }
    
    func makeMenuBtn() {
        btn = UIButton()
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        
        let btnImage = UIImage(named: "downArrow.png")
        btn.setImage(btnImage, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: Int(gradientMaxY-(horizontalY + gradientMaxY*0.25)), height: Int(gradientMaxY-(horizontalY + gradientMaxY*0.25)))
        btn.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(gradientMaxY-btn.frame.height/2))
        btn.addTarget(self, action: #selector(btnPressed(sender:)), for: UIControl.Event.touchUpInside)
        btn.adjustsImageWhenHighlighted = false
        self.view.addSubview(btn)
    }
    
    @objc func btnPressed(sender: UIButton) {
        if shifts.count > 0 {
            pulldownMenuIsShowing = !pulldownMenuIsShowing
            if pulldownMenuIsShowing {
                UIView.animate(withDuration: 0.4, animations: {
                    self.menuTable.frame = CGRect(x: 0, y: (sender.center.y + sender.frame.height/2), width: self.view.frame.width, height: self.view.frame.height*0.4)
                })
                UIView.animate(withDuration: 0.4, animations: {
                    sender.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.menuTable.frame = CGRect(x: 0, y: (sender.center.y + sender.frame.height/2), width: self.view.frame.width, height: 0)
                })
                UIView.animate(withDuration: 0.3, animations: {
                    sender.transform = .identity
                })
            }
        } else {
            sender.shake(direction: "vertical", swings: 1)
        }
    }
    
    func resetLabels() {
        let currency = UserDefaults().string(forKey: "currency")!
        let symbol = currencies[currency]!
        
            if symbol == "kr" {
                salaryLbl.text = "0kr"
                grossLbl.text = "Gross: 0kr"
            } else {
                salaryLbl.text = symbol + "0"
                grossLbl.text = "Gross: " + symbol + "0"
            }
        periodLbl.text = ""
    }
    func configureMenuTable() {
        menuTable.backgroundColor = headerColor
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
        statsTable.isScrollEnabled = false
        self.view.addSubview(statsTable)
    }
    
    func makeGradient() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [navColor.cgColor, headerColor.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.4)
        let startingLocation = NSNumber(floatLiteral: Double(Double(66)/Double(gradientLayer.frame.height)))
        gradientLayer.locations = [startingLocation, 1.0]
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.layer.insertSublayer(gradientLayer, at: UInt32(0))
    }
    
    
    
    func addUpperLineOfArrowButtonSection() {
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        seperatorLineHorizontal.frame = CGRect(x: self.view.frame.width/2, y: 0, width: 1, height: gradientMaxY * 0.25)
        seperatorLineHorizontal.center.y = horizontalY + seperatorLineHorizontal.frame.height/2
        seperatorLineHorizontal.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        upperLineOfArrowButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        upperLineOfArrowButton.center.y = seperatorLineHorizontal.center.y + seperatorLineHorizontal.frame.height/2
        upperLineOfArrowButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        self.view.addSubview(upperLineOfArrowButton)
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
        
        grossLbl.frame = CGRect(x: 0, y: 0, width: Int((self.view.frame.width/2) * 0.66), height: Int((gradientMaxY-horizontalY) * 0.66))
        grossLbl.font = UIFont.systemFont(ofSize: 13, weight: .light)
        grossLbl.center = CGPoint(x: Int(self.view.center.x), y: Int(salaryLbl.center.y + grossLbl.frame.height/2))
        grossLbl.textAlignment = .center
        grossLbl.textColor = .white
        
        periodLbl.textColor = .white
        periodLbl.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        periodLbl.text = ""
        periodLbl.textAlignment = .right
        periodLbl.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/3), height: Int(30))
        periodLbl.center = CGPoint(x: Int(self.view.frame.width*0.95 - periodLbl.frame.width/2), y: Int(btn.center.y))
        
        resetLabels()
        self.view.addSubview(periodLbl)
    }
    
    func startCountingLabels() {
        if period != nil {
            if Int(period.grossSalary) > 0 {
                grossLbl.count(fromValue: 0, to: Float(period.grossSalary), withDuration: 1.5, andAnimationtype: .EaseOut, andCounterType: .Int, currency: UserSettings.getCurrencySymbol(), preString: "Gross: ", afterString: "")
                salaryLbl.count(fromValue: 0, to: Float(period.salary), withDuration: TimeInterval(1.5 * (Float(period.salary)/Float(period.grossSalary))), andAnimationtype: .EaseOut, andCounterType: .Int, currency: UserSettings.getCurrencySymbol(), preString: "", afterString: "")
            }
        }
    }
    
    func fillLabelsWithStats() {
        if period != nil {
            salaryLbl.text = "test" // StringFormatter.addCurrencyToNumber(amount: period.salary)
            periodLbl.text = period.duration
        }
    }
    
    func makePeriodsSeperatedByYear() {
        periodsSeperatedByYear.removeAll()
        var year = 4000
        for section in shifts {
            let decider = Int(String(Array(section[section.count-1].date.description)[0..<4]))
            
            if year == decider! {
                periodsSeperatedByYear[periodsSeperatedByYear.count-1].append(section)
            } else {
                periodsSeperatedByYear.append([section])
                year = decider!
            }
        }
    }
    
    func makePeriod() {
        if shifts.count > 0 {
            period = Period(month: periodsSeperatedByYear[indexForChosenPeriod[0]][indexForChosenPeriod[1]])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 2 {
            let startingString = String(Array(periodsSeperatedByYear[section][0][periodsSeperatedByYear[section][0].count-1].date.description)[0..<4])
            let headerView = UIView()
            headerView.backgroundColor = headerColor
            
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
                makePeriod()
                statsTable.reloadData()
                startCountingLabels()
                periodLbl.text = period.duration
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Stats Table
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LaunchCell
            
            cell.insertStatsDesc(width: (self.view.frame.width), text: Period.statsDescriptions[indexPath.row])
            if period != nil {
                cell.insertStatsInfo(width: self.view.frame.width, text: period.stats[indexPath.row])
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
            cell.backgroundColor = headerColor
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
            return Period.statsDescriptions.count
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
