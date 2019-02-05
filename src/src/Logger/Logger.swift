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
var shouldFetchAllData = false

class Logger: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var myTableView: UITableView!
    var cells = [UITableViewCell]()
    let instructionsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldFetchAllData {
            shifts.removeAll()
            getShifts(fromCloud: false)
            shouldFetchAllData = false
        }
        
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
            
            let shiftToDelete = LocalStorage.organizedValues[indexPath.section][indexPath.row]
            context.delete(shiftToDelete)
            
            
            do {
                try context.save()
                
            } catch {
                
            }
            
            // Removes the shift from in memory 'database'
            shifts[indexPath.section].remove(at: indexPath.row)
            LocalStorage.organizedValues[indexPath.section].remove(at: indexPath.row)
            
            // Cleans the arrays of empty sub arrays
            var i = 0
            while i < shifts.count {
                if shifts[i].count == 0 {
                    shifts.remove(at: i)
                    LocalStorage.organizedValues.remove(at: i)
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
        cell.noteLbl.text = shiftForRow.note
        cell.dateLbl.text = Time.dateToCellString(date: shiftForRow.date)
        cell.accessoryLbl.text = shiftForRow.durationToString()
        cell.timeLbl.text = Time.dateToTimeString(date: shiftForRow.startingTime) + " - " + Time.dateToTimeString(date: shiftForRow.endingTime)
        cell.lunchLbl.text = shiftForRow.lunchTime + "m break"
        
        cell.timeLbl.sizeToFit()
        cell.accessoryLbl.sizeToFit()
        cell.noteLbl.center.x = cell.timeLbl.frame.width + cell.noteLbl.frame.width/2 + 15
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = (Time.dateToString(date: shifts[section][shifts[section].count-1].date, withDayName: false) + " - " +  Time.dateToString(date: shifts[section][0].date, withDayName: false)).uppercased()
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
}
