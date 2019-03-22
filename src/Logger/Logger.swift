//
//  ViewController.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit

class Logger: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let instructionsLabel = UILabel()
    var floatingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.barTintColor = Colors.navbarBG
        self.navigationController?.navigationBar.tintColor = Colors.navbarFG
        let textAttributes = [NSAttributedString.Key.foregroundColor: Colors.navbarFG]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        addFloatingButton()
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shiftsNeedsReOrganizing {
            Periods.reOrganize(successHandler: {
                Periods.organizePeriodsByYear(periods: shifts, successHandler: {
                    Periods.makePeriod(yearIndex: 0, monthIndex: 0, successHandler: {
                        shiftsNeedsReOrganizing = false
                        self.myTableView.reloadData()
                    })
                })
            })
        }
        hideTableIfEmpty()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        layoutView()
    }
    
    func hideTableIfEmpty() {
        if !(shifts.isEmpty) {
            myTableView.backgroundView = UIView()
        }
    }
    
    func layoutView() {
        myTableView.reloadData()
        myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 1))
        myTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        myTableView.separatorColor = UIColor.black.withAlphaComponent(0.2)

        if shifts.isEmpty {
            let view = UIView()
            let image = UIImage(named: "test instructor")
            let imageview = UIImageView()
            
            imageview.image = image
            imageview.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width*0.75), height: Int(self.view.frame.width*0.75))
            imageview.center = CGPoint(x: myTableView.center.x, y: myTableView.center.y - imageview.frame.height/4)

            view.addSubview(imageview)
            myTableView.backgroundView = view

        } else {
            myTableView.backgroundView = UIView()
        }
    }
    
    func showInstructions() {
        if shifts.isEmpty {
            let view = UIView()
            let image = UIImage(named: "test instructor")
            let imageview = UIImageView()
            imageview.image = image
            imageview.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width*0.75), height: Int(self.view.frame.width*0.75))
            imageview.center = CGPoint(x: myTableView.center.x, y: myTableView.center.y - imageview.frame.height/4)

            view.alpha = 0
            view.addSubview(imageview)
            myTableView.backgroundView = view
            
            UIViewPropertyAnimator(duration: 0.75, curve: .linear, animations: {
                view.alpha = 1
            }).startAnimation()

        } else {
            myTableView.backgroundView = UIView()
        }
    }

    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        
    }
    func addFloatingButton() {
        let tabBarY = self.tabBarController!.tabBar.frame.origin.y
        
        floatingButton = UIButton(type: .roundedRect)
        floatingButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width*0.15, height: self.view.frame.width*0.15)
        floatingButton.backgroundColor = Colors.theme
        floatingButton.layer.cornerRadius = floatingButton.frame.width/2
        floatingButton.setTitle("+", for: .normal)
        floatingButton.center = CGPoint(x: self.view.frame.width - floatingButton.frame.width/2 - 30, y: tabBarY - floatingButton.frame.height/2 - 30)
        floatingButton.setTitleColor(.white, for: .normal)
        floatingButton.titleLabel!.font = UIFont.systemFont(ofSize: 30, weight: .light)
        floatingButton.contentVerticalAlignment = .center
        floatingButton.addTarget(self, action: #selector(gotoadd), for: .touchUpInside)
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        floatingButton.layer.masksToBounds = false
        floatingButton.layer.shadowRadius = 1.0
        floatingButton.layer.shadowOpacity = 0.5
        floatingButton.layer.cornerRadius = floatingButton.frame.width / 2
        self.view.addSubview(floatingButton)
    }
    
    @objc func gotoadd() {
        performSegue(withIdentifier: "gotoadd", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete")   { (_ rowAction: UITableViewRowAction, _ indexPath: IndexPath) in
            
            let shiftToDelete = shifts[indexPath.section][indexPath.row]
            CloudStorage.deleteShift(fromUser: user.ID, shift: shiftToDelete)
            
            shifts[indexPath.section].remove(at: indexPath.row)
            // Cleans the arrays of empty sub arrays
            var i = 0
            while i < shifts.count {
                if shifts[i].count == 0 {
                    shifts.remove(at: i)
                } else {
                    i += 1
                }
            }
            
            // Reorganized the periods and makes the new period
            Periods.organizePeriodsByYear(periods: shifts, successHandler: {
                Periods.makePeriod(yearIndex: 0, monthIndex: 0, successHandler: {})
            })
            
            if self.myTableView.numberOfRows(inSection: indexPath.section) > 1 {
                self.myTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            } else {
                self.myTableView.deleteSections([indexPath.section], with: UITableView.RowAnimation.automatic)
            }
            self.showInstructions()
        }
        deleteAction.backgroundColor = UIColor.gray
        return [deleteAction]
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shiftToEdit[0] = indexPath.section
        shiftToEdit[1] = indexPath.row
        performSegue(withIdentifier: "gotoedit", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainCell
        let shiftForRow = shifts[indexPath.section][indexPath.row]
        let shiftStat = shiftForRow.computeStats()
        cell.noteLbl.text = shiftForRow.title
        cell.dateLbl.text = Time.dateToCellString(date: shiftForRow.date)
        cell.accessoryLbl.text = String(shiftForRow.breakTime) + "m break"
        cell.timeLbl.text = Time.dateToTimeString(date: shiftForRow.startingTime) + " - " + Time.dateToTimeString(date: shiftForRow.endingTime)
        cell.lunchLbl.text = shiftForRow.breakTime.description
        
        cell.noteLbl.font = UIFont.systemFont(ofSize: 17, weight: .light)
        cell.dateLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.timeLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.lunchLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.accessoryLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        
        cell.dateLbl.textColor = Colors.gray
        cell.timeLbl.textColor = Colors.gray
        cell.lunchLbl.textColor = Colors.gray
        cell.accessoryLbl.textColor = Colors.gray
        
        cell.timeLbl.sizeToFit()
        cell.accessoryLbl.sizeToFit()
        cell.noteLbl.center.x = self.view.center.x
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 31
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var startDate = Time.dateToString(date: shifts[section][shifts[section].count-1].date, withDayName: false)
        startDate = String(startDate.prefix(startDate.count - 5))
        var endDate = Time.dateToString(date: shifts[section][0].date, withDayName: false)
        endDate = String(endDate.prefix(endDate.count - 5))
        let text = startDate + " - " + endDate
        var year = Time.dateToString(date: shifts[section][shifts[section].count-1].date, withDayName: false)
        year = String(year.suffix(4))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.backgroundColor = Colors.theme //.gray
        
        let periodLabel = UILabel(frame: CGRect(x: 15, y: 10, width:
            tableView.bounds.size.width, height: 30))
        periodLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        periodLabel.textColor = .white
        periodLabel.text = text
        periodLabel.sizeToFit()
        periodLabel.center.x = self.view.frame.width/2
        periodLabel.center.y = 20
        periodLabel.textAlignment = .center
        
        let yearLabel = UILabel(frame: CGRect(x: 15, y: 16, width:
            tableView.bounds.size.width, height: 30))
        yearLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        yearLabel.textColor = .white
        yearLabel.text = year
        yearLabel.sizeToFit()
        yearLabel.frame.origin.x = periodLabel.frame.origin.x - yearLabel.frame.width - 5
        yearLabel.frame.origin.x = 5
        yearLabel.textAlignment = .center
        yearLabel.center.y = 21
    
        view.addSubview(periodLabel)
        view.addSubview(yearLabel)
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shifts.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts[section].count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
