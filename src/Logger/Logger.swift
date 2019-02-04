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

class Logger: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var myTableView: UITableView!
    var cells = [UITableViewCell]()
    let instructionsLabel = UILabel()
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getShiftsFromLocal()
        if !(shifts.isEmpty) {
            myTableView.backgroundView = UIView()
        }
        myTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        layoutView()
    }
    
    func layoutView() {
        myTableView.reloadData()
        myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 1))
        myTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

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
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let shift = shifts[indexPath.section][indexPath.row]
            context.delete(shift)
            
            do {
                try context.save()
            } catch {
                
            }
            
            // Removing empty lists if there are any
            shifts[indexPath.section].remove(at: indexPath.row)
            var indexes = [Int]()
            for i in 0..<shifts.count {
                if shifts[i].count == 0 {
                    indexes.append(i)
                }
            }
            var count = 0
            for number in indexes {
                shifts.remove(at: number-count)
                count += 1
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
        cell.noteLbl.text = shiftForRow.note
        cell.dateLbl.text = createDateForCell(Date: shiftForRow.date!)
        cell.accessoryLbl.text = calcHours(shift: shiftForRow)
        cell.timeLbl.text = createTime(Date: shiftForRow.startingTime!) + " - " + createTime(Date: shiftForRow.endingTime!)
        cell.lunchLbl.text = shiftForRow.lunchTime! + "m break"
        
        cell.timeLbl.sizeToFit()
        cell.accessoryLbl.sizeToFit()
        cell.noteLbl.center.x = cell.timeLbl.frame.width + cell.noteLbl.frame.width/2 + 15
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = (createDateForHeader(Date: shifts[section][shifts[section].count-1].date!) + " - " +  createDateForHeader(Date: shifts[section][0].date!)).uppercased()
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

        let seperatorColor = myTableView.separatorColor
        
        let topSeperator = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        let bottomSeperator = UIView(frame: CGRect(x: 0, y: 40, width: self.view.frame.width, height: 0.5))
        topSeperator.backgroundColor = seperatorColor
        bottomSeperator.backgroundColor = seperatorColor
        
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 15, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.medium)
        headerLabel.textColor = UIColor(red: 0.265, green: 0.294, blue: 0.367, alpha: 1.0)
        headerLabel.text = text
        headerLabel.sizeToFit()
        headerLabel.center.x = self.view.frame.width/2
        headerLabel.textAlignment = .center
        
        headerView.addSubview(topSeperator)
        headerView.addSubview(bottomSeperator)
        headerView.addSubview(headerLabel)

        return headerView
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
    
    func getShiftsFromLocal() {
        shifts.removeAll()
        var tempList = [Shift]()
        var tempAppendList = [Shift]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            tempList = try context.fetch(Shift.fetchRequest())
        } catch {
            print("could not get the shift object")
        }
        tempList.sort(by: {$0.date! > $1.date!})
        
        
        if UserDefaults().bool(forKey: "manuallyNewMonth") {
            if tempList.count > 0 {
                for i in 0..<tempList.count {
                    
                    if i == (tempList.count-1) {
                        tempAppendList.append(tempList[i])
                        shifts.append(tempAppendList)
                        
                    } else if tempList[i].newMonth == Int16(1) {
                        tempAppendList.append(tempList[i])
                        shifts.append(tempAppendList)
                        tempAppendList.removeAll()
                        
                    } else {
                        tempAppendList.append(tempList[i])
                    }
                }
                
            }
        } else {
            if tempList.count > 0 {
                
                var compare = [4000, 12, 12]
                let seperator = Int(UserDefaults().string(forKey: "newMonth")!)!
                
                for shift in tempList {
                    let year = Int(String((Array(shift.date!.description))[0..<4]))!
                    let month = Int(String((Array(shift.date!.description))[5..<7]))!
                    let day = Int(String((Array(shift.date!.description))[8..<10]))!
                    
                    
                    if year >= compare[0] && ((month == compare[1] && day >= seperator) || (month == compare[1]+1 && day < seperator) || (month == 1 && compare[1] == 12 && day < seperator))  {
                        shifts[shifts.count-1].append(shift)
                    } else {
                        shifts.append([shift])
                        if day >= seperator {
                            compare = [year, month, seperator]
                        } else {
                            if month - 1 > 0 {
                                compare = [year, month - 1, seperator]
                            } else {
                                compare = [year - 1, 12, seperator]
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createTime(Date: Date) -> String {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date)
        
        return dateString
    }
    
    func createDateForHeader(Date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: Date)
        
        return dateString.replacingOccurrences(of: ",", with: "")
    }
    
    func createDateForCell(Date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        var dateString = formatter.string(from: Date)
        dateString = String(Array(formatter.string(from: Date))[0..<dateString.count-4])
        return dateString.replacingOccurrences(of: ",", with: "")
    }
    
    func calcHours(shift: Shift) -> String {
        var totalHours = ""
        var hoursWorked = 0
        var minutesWorked = 0
        var lunchBreak = 0
        
        if shift.lunchTime != "" {
            lunchBreak = Int(shift.lunchTime!)!
        }
        
        let startingHour = Int(String(Array(shift.startingTime!.description)[11...12]))
        let startingMin = Int(String(Array(shift.startingTime!.description)[14...15]))
        let endingHour = Int(String(Array(shift.endingTime!.description)[11...12]))
        let endingMin = Int(String(Array(shift.endingTime!.description)[14...15]))

        if endingHour! - startingHour! > 0 {
            hoursWorked = endingHour! - startingHour!
        } else if endingHour! - startingHour! < 0 {
            hoursWorked = 24 + (endingHour! - startingHour!)
        }

        if endingMin! - startingMin! < 0 {
            hoursWorked -= 1
            minutesWorked = 60 - (startingMin! - endingMin!)
        } else if endingMin! - startingMin! > 0 {
            minutesWorked = endingMin! - startingMin!
        }

        minutesWorked += (hoursWorked * 60) - lunchBreak
        if UserDefaults().string(forKey: "minHours") != nil && UserDefaults().string(forKey: "minHours") != "" {
            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
            if minimum > Float(minutesWorked) {
                minutesWorked = Int(minimum)
            }
        }
        hoursWorked = Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60

        if hoursWorked == 0 {
            if minutesWorked == 1 {
                totalHours = "\(minutesWorked)m"
            } else {
                totalHours = "\(minutesWorked)m"
            }

        } else if minutesWorked == 0 {
            if hoursWorked == 1 {
                totalHours = "\(hoursWorked)h"
            } else {
                totalHours = "\(hoursWorked)h"
            }

        } else {
            if hoursWorked == 1 && minutesWorked != 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else if hoursWorked != 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else if hoursWorked == 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            } else {
                totalHours = "\(hoursWorked)h \(minutesWorked)m"
            }
        }

        return totalHours
    }
}
