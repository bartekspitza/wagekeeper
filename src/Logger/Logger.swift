//
//  ViewController.swift
//  adding shifts
//
//  Created by Bartek  on 2017-10-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import CoreData

var shiftToEdit = [0,0]
var shifts = [[ShiftModel]]()
var shouldFetchAllData = false
var usingLocalStorage = false
var shiftsNeedsReOrganizing = false

class Logger: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let instructionsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shiftsNeedsReOrganizing {
            Periods.reOrganize()
            shiftsNeedsReOrganizing = false
            print("reorganized shifts")
        }
        
        hideTableIfEmpty()
        myTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete")   { (_ rowAction: UITableViewRowAction, _ indexPath: IndexPath) in
            
            if usingLocalStorage {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let shiftToDelete = LocalStorage.organizedValues[indexPath.section][indexPath.row]
                context.delete(shiftToDelete)
                
                
                do {
                    try context.save()
                    
                } catch {
                    
                }
                LocalStorage.organizedValues[indexPath.section].remove(at: indexPath.row)
            } else {
                let shiftToDelete = shifts[indexPath.section][indexPath.row]
                
                CloudStorage.deleteShift(fromUser: user.uid, shift: shiftToDelete)
            }
            
            
            // Removes the shift from the in memory database
            shifts[indexPath.section].remove(at: indexPath.row)
            // Cleans the arrays of empty sub arrays
            var i = 0
            while i < shifts.count {
                if shifts[i].count == 0 {
                    shifts.remove(at: i)
                    if usingLocalStorage {
                        LocalStorage.organizedValues.remove(at: i)
                    }
                } else {
                    i += 1
                }
            }
            
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
        cell.noteLbl.text = shiftForRow.title
        cell.dateLbl.text = Time.dateToCellString(date: shiftForRow.date)
        cell.accessoryLbl.text = String(shiftForRow.breakTime) + "m break"
        cell.timeLbl.text = Time.dateToTimeString(date: shiftForRow.startingTime) + " - " + Time.dateToTimeString(date: shiftForRow.endingTime)
        cell.lunchLbl.text = shiftForRow.durationToString()
        
        cell.noteLbl.font = UIFont.systemFont(ofSize: 17, weight: .light)
        cell.dateLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.timeLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.lunchLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        cell.accessoryLbl.font = UIFont.systemFont(ofSize: 11, weight: .light)
        
        cell.dateLbl.textColor = Colors.get(red: 60, green: 60, blue: 60, alpha: 1)
        cell.timeLbl.textColor = Colors.get(red: 60, green: 60, blue: 60, alpha: 1)
        cell.lunchLbl.textColor = Colors.get(red: 60, green: 60, blue: 60, alpha: 1)
        cell.accessoryLbl.textColor = Colors.get(red: 60, green: 60, blue: 60, alpha: 1)
        
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
        view.backgroundColor = .gray
        
        let periodLabel = UILabel(frame: CGRect(x: 15, y: 10, width:
            tableView.bounds.size.width, height: 30))
        periodLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
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
