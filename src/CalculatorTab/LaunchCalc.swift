// BUILD 1.1
//  LaunchCalc.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import Foundation
var calcIndex = [0,0]

class LaunchCalc: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct Period {
        var date: String
        var salary: String
        var grossSalary: String
        var totalHours: String
        var shiftsWorked: String
        var avgShift: String
        var currency: String
    }
    
    var totalHoursLbl = CountingLabel()
    var totalMinutesLbl = CountingLabel()
    var periodLbl = UILabel()
    var menuisShowing = false
    var btn: UIButton!
    @IBOutlet weak var grossLbl: CountingLabel!
    @IBOutlet weak var salaryLbl: CountingLabel!
    
    let statsDescs = ["TOTAL WORK-TIME", "AVERAGE SHIFT LENGTH", "TOTAL SHIFTS", "TOTAL DAYS WORKED", "OVERTIME WORKED"]
    var statsInfo = [String]()
    // Other variables
    var period = Period(date: "", salary: "", grossSalary: "0", totalHours: "", shiftsWorked: "", avgShift: "", currency: "")
    let color = UIColor(displayP3Red: 28/255, green: 112/255, blue: 127/255, alpha: 0.7)
    var seperatorLineHorizontal = UIView()
    var seperatorLineVertical = UIView()
    var seperatorLineVertical1 = UIView()
    var statsTable = UITableView()
    var menuTable = UITableView()
    
    var appStarted = true
    override func viewDidLoad() {
        super.viewDidLoad()
        initiateUserDefaultsForNewUser()
        makeDesign()
        makeMenuBtn()
        designLabels()
        designLines()
        grossLbl.text = "PRE-TAX: 0"
        if appStarted {
            getShifts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        period = Period(date: "", salary: "0", grossSalary: "0", totalHours: "", shiftsWorked: "", avgShift: "", currency: "")
        appStarted = false
        statsInfo.removeAll()
        fillTable()
        insertExampleShift()
        makePeriod()
        fillLabelsWithStats()
        startCountingLabels()
        designLabels()
        configureStatsTable()
        configureMenuTable()
        labelsForNoShifts()
        menuTable.reloadData()
        statsTable.reloadData()
        centerTotalTimeLabels()
        
    }
    
    func insertExampleShift() {
        if !tableList.isEmpty && UserDefaults().value(forKey: "FirstTime") == nil {
            UserDefaults().set("Visited", forKey: "FirstTime")
        }
        
        if UserDefaults().value(forKey: "FirstTime") == nil {
            UserDefaults().set("Visited", forKey: "FirstTime")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let shift = Shift(context: context)
            shift.date = Date()
            shift.endingTime = createDefaultET()
            shift.startingTime = createDefaultST()
            shift.lunchTime = "60"
            shift.note = "Example (Delete this)"
            shift.newMonth = Int16(0)
            
            shifts.append([shift])
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            fillTable()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        salaryLbl.text = "0"
        btn.transform = .identity
        if menuisShowing {
            menuTable.frame = CGRect(x: 0, y: (btn.center.y + btn.frame.height/2), width: self.view.frame.width, height: 0)
            menuisShowing = false
        }
        calcIndex = [0, 0]
    }
    
    func centerTotalTimeLabels() {
        let centerPoint = self.view.frame.width * 0.75
        
        let totalHoursLblPoint = ((centerPoint - 4) - totalHoursLbl.frame.width/2) - 5
        let totalMinutesLblPoint = ((centerPoint + 4) + totalMinutesLbl.frame.width/2) - 5
        
        totalHoursLbl.center.x = totalHoursLblPoint
        totalMinutesLbl.center.x = totalMinutesLblPoint
    }
    
    func initiateUserDefaultsForNewUser() {
        // Tax
        if UserDefaults().value(forKey: "taxRate") == nil {
            UserDefaults().set("0.0", forKey: "taxRate")
        }
        // WAGE
        if UserDefaults().value(forKey: "wageRate") == nil {
            UserDefaults().set("10", forKey: "wageRate")
        }
        // CURRENCY
        if UserDefaults().value(forKey: "currency") == nil {
            UserDefaults().set("USD", forKey: "currency")
        }
        // Closing Date
        if UserDefaults().value(forKey: "manuallyNewMonth") == nil {
            UserDefaults().set(false, forKey: "manuallyNewMonth")
            UserDefaults().set("1", forKey: "newMonth")
        }
        
        // Mininum hours
        if UserDefaults().value(forKey: "minHours") == nil {
            UserDefaults().set("0", forKey: "minHours")
        }
        // Starting time
        if UserDefaults().value(forKey: "defaultST") == nil {
            UserDefaults().set(createDefaultST(), forKey: "defaultST")
        }
        // Ending time
        if UserDefaults().value(forKey: "defaultET") == nil {
            UserDefaults().set(createDefaultET(), forKey: "defaultET")
        }
        // Note
        if UserDefaults().value(forKey: "defaultNote") == nil {
            UserDefaults().set("Example (Delete this)", forKey: "defaultNote")
        }
        // Lunch
        if UserDefaults().value(forKey: "defaultLunch") == nil {
            UserDefaults().set("0", forKey: "defaultLunch")
        }
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
        //        btn.backgroundColor = .blue
        self.view.addSubview(btn)
    }
    
    @objc func btnPressed(sender: UIButton) {
        if shifts.count > 0 {
            menuisShowing = !menuisShowing
            if menuisShowing {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 2 {
            let startingString = String(Array(tableList[section][0][tableList[section][0].count-1].date!.description)[0..<4])
            let headerView = UIView()
            headerView.backgroundColor = headerColor
            
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 28, width:
                tableView.bounds.size.width, height: tableView.bounds.size.height))
            headerLabel.font = UIFont.boldSystemFont(ofSize: 10)
            headerLabel.textColor = .white
            headerLabel.text = startingString
            headerLabel.font = UIFont.systemFont(ofSize: 12)
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
            menuisShowing = false
            UIView.animate(withDuration: 0.3, animations: {
                self.menuTable.frame = CGRect(x: 0, y: (self.btn.center.y + self.btn.frame.height/2), width: self.view.frame.width, height: 0)
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.btn.transform = .identity
            })
            
            let prevCell = menuTable.cellForRow(at: IndexPath(row: calcIndex[1], section: calcIndex[0]))
            prevCell?.accessoryType = .none
            let cellPressed = menuTable.cellForRow(at: indexPath)!
            cellPressed.accessoryType = .checkmark
            cellPressed.tintColor = .white
            if indexPath.section != calcIndex[0] || indexPath.row != calcIndex[1] {
                calcIndex = [indexPath.section, indexPath.row]
                statsInfo.removeAll()
                makePeriod()
                statsTable.reloadData()
                startCountingLabels()
                periodLbl.text = period.date.uppercased()
            }
        }
    }
    
    func labelsForNoShifts() {
        if let currency = UserDefaults().string(forKey: "currency") {
            let symbol = currencies[currency]!
            if salaryLbl.text == "0" {
                if symbol == "kr" {
                    salaryLbl.text = "0KR"
                    grossLbl.text = "PRE-TAX: 0KR"
                } else {
                    salaryLbl.text = symbol + "0"
                    grossLbl.text = "PRE-TAX: " + symbol + "0"
                }
            }
        }
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
        statsTable.separatorColor = navColor.withAlphaComponent(0.25)
        statsTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        statsTable.register(LaunchCell.self, forCellReuseIdentifier: "cell")
        statsTable.isScrollEnabled = false
        self.view.addSubview(statsTable)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Stats Table
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LaunchCell
            
            cell.insertStatsDesc(width: (self.view.frame.width), text: statsDescs[indexPath.row].uppercased())
            if statsInfo.count > 0 {
                cell.insertStatsInfo(width: self.view.frame.width, text: statsInfo[indexPath.row].uppercased())
            } else {
                cell.insertStatsInfo(width: self.view.frame.width, text: "0")
            }

            return cell
            
            // Periods table
        } else {
            let cell = UITableViewCell()
            let section = tableList[indexPath.section][indexPath.row]
            let end = String(Array(createDateString(Date: section[0].date!))[0..<createDateString(Date: section[0].date!).count-4])
            let start = String(Array(createDateString(Date: section[section.count-1].date!))[0..<createDateString(Date: section[section.count-1].date!).count-4])
            cell.textLabel?.text = start + " - " + end
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.selectionStyle = .none
            cell.backgroundColor = headerColor
            if indexPath.section == calcIndex[0] && indexPath.row == calcIndex[1] {
                cell.tintColor = .white
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return statsDescs.count
        } else {
            return tableList[section].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return 1
        } else {
            return tableList.count
        }
    }
    
    func makeDesign() {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [navColor.cgColor, headerColor.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height*0.4)
        let startingLocation = NSNumber(floatLiteral: Double(Double(66)/Double(gradientLayer.frame.height)))
        gradientLayer.locations = [startingLocation, 1.0]
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.layer.insertSublayer(gradientLayer, at: UInt32(0))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func designLines() {
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        seperatorLineHorizontal.frame = CGRect(x: self.view.frame.width/2, y: 0, width: 1, height: gradientMaxY * 0.25)
        seperatorLineHorizontal.center.y = horizontalY + seperatorLineHorizontal.frame.height/2
        seperatorLineHorizontal.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        seperatorLineVertical.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        seperatorLineVertical.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        seperatorLineVertical.center.x = self.view.frame.width/2
        seperatorLineVertical.center.y = (self.view.frame.height * 0.4) * 0.60
        seperatorLineVertical1.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        seperatorLineVertical1.center.y = seperatorLineHorizontal.center.y + seperatorLineHorizontal.frame.height/2
        seperatorLineVertical1.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        self.view.addSubview(seperatorLineVertical1)
    }
    
    func designLabels() {
        let gradientMaxY = (self.view.frame.height*0.4)
        let horizontalY = gradientMaxY * 0.60
        
        totalHoursLbl.clipsToBounds = true
        totalMinutesLbl.clipsToBounds = true
        
        salaryLbl.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/2), height: Int(gradientMaxY/3))
        salaryLbl.font = UIFont.systemFont(ofSize: 40)
        salaryLbl.text = salaryLbl.text?.uppercased()
        salaryLbl.center = CGPoint(x: Int(self.view.frame.width/2), y: Int(self.view.frame.height*0.2 * 0.9))
        salaryLbl.textColor = .white
        salaryLbl.textAlignment = .center
        
        grossLbl.frame = CGRect(x: 0, y: 0, width: Int((self.view.frame.width/2) * 0.66), height: Int((gradientMaxY-horizontalY) * 0.66))
        grossLbl.font = UIFont.systemFont(ofSize: 13)
        grossLbl.center = CGPoint(x: Int(self.view.center.x), y: Int(salaryLbl.center.y + grossLbl.frame.height/2))
        grossLbl.textAlignment = .center
        grossLbl.textColor = .white
        
        totalHoursLbl.frame = CGRect(x: 0, y: 0, width: Int((self.view.frame.width/2) * 0.66), height: Int((gradientMaxY-horizontalY) * 0.66))
        totalHoursLbl.textColor = .white
        totalHoursLbl.text = "0 HOURS"
        totalHoursLbl.textAlignment = .right
        var x = Int(self.view.frame.width/2)
        x -= Int(totalHoursLbl.frame.width/2) + 82
        
        let y = Int(seperatorLineHorizontal.center.y)
        totalHoursLbl.center = CGPoint(x: x, y: y)
        totalHoursLbl.font = UIFont.systemFont(ofSize: 13)
        
        totalMinutesLbl.frame = CGRect(x: 0, y: 0, width: Int((self.view.frame.width/2) * 0.66), height: Int((gradientMaxY-horizontalY) * 0.66))
        totalMinutesLbl.text = "0 MINUTES"
        totalMinutesLbl.textColor = .white
        var xx = Int(self.view.frame.width/2)
        
        xx += Int(totalMinutesLbl.frame.width/2) + 3 + 85
        
        totalMinutesLbl.center = CGPoint(x: xx, y: y)
        totalMinutesLbl.font = UIFont.systemFont(ofSize: 13)
        
        
        periodLbl.textColor = .white
        periodLbl.font = UIFont.systemFont(ofSize: 11)
        periodLbl.text = period.date.uppercased()
        periodLbl.textAlignment = .right
        periodLbl.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/3), height: Int(30))
        periodLbl.center = CGPoint(x: Int(self.view.frame.width*0.95 - periodLbl.frame.width/2), y: Int(btn.center.y))
        
        self.view.addSubview(periodLbl)
    }
    
    func startCountingLabels() {
        if shifts.count > 0 {
            if Int(period.grossSalary)! > 0 {
                grossLbl.count(fromValue: 0, to: Float(period.grossSalary)!, withDuration: 1.5, andAnimationtype: .EaseOut, andCounterType: .Int, currency: period.currency, preString: "PRE-TAX: ", afterString: "")
                salaryLbl.count(fromValue: 0, to: Float(period.salary)!, withDuration: TimeInterval(1.5 * (Float(period.salary)!/Float(period.grossSalary)!)), andAnimationtype: .EaseOut, andCounterType: .Int, currency: period.currency, preString: "", afterString: "")
            }
        }
        
    }
    
    var tableList = [[[Shift]]]()
    func fillTable() {
        tableList.removeAll()
        var year = 4000
        for section in shifts {
            let decider = Int(String(Array(section[section.count-1].date!.description)[0..<4]))
            
            if year == decider! {
                tableList[tableList.count-1].append(section)
            } else {
                tableList.append([section])
                year = decider!
            }
        }
    }
    
    func makePeriod() {
        if shifts.count > 0 {
            let chosenPeriod = tableList[calcIndex[0]][calcIndex[1]]
            let salaryInfo = calculateSalary(month: chosenPeriod)
            
            period.date = calculateDate(month: chosenPeriod)
            period.salary = (salaryInfo[1] as! Int).description
            period.grossSalary = (salaryInfo[0] as! Int).description
            period.totalHours = calculateTotalHours(month: chosenPeriod)
            period.currency = salaryInfo[2] as! String
            period.shiftsWorked = shiftsWorked(month: chosenPeriod)
            period.avgShift = calculateAvg(month: chosenPeriod)
            
            statsInfo.append(period.totalHours)
            statsInfo.append(period.avgShift)
            statsInfo.append(chosenPeriod.count.description)
            statsInfo.append((salaryInfo[5] as! Int).description)
            statsInfo.append(formatTime(minutes: salaryInfo[3] as! Int))
            statsInfo.append(formatMoneyInOT(amount: salaryInfo[4] as! Int))
        }
    }
    
    func fillLabelsWithStats() {
        totalHoursLbl.text = "HOURS: 0"
        totalMinutesLbl.text = "MINUTES: 0"
        salaryLbl.text = period.salary
    }
    
    func formatMoneyInOT(amount: Int) -> String {
        if period.currency == "kr" {
            return amount.description + "kr"
        } else {
            return period.currency + amount.description
        }
    }
    
    func formatTime(minutes: Int) -> String {
        var totalHours = ""
        var hoursWorked = 0
        var minutesWorked = 0
        
        minutesWorked = minutes
        
        hoursWorked = Int(minutes/60)
        minutesWorked -= Int(minutes/60) * 60
        
        if hoursWorked == 0 {
            if minutesWorked == 1 {
                totalHours = "\(minutesWorked)M"
            } else {
                totalHours = "\(minutesWorked)M"
            }
            
        } else if minutesWorked == 0 {
            if hoursWorked == 1 {
                totalHours = "\(hoursWorked)H"
            } else {
                totalHours = "\(hoursWorked)H"
            }
            
        } else {
            if hoursWorked == 1 && minutesWorked != 1 {
                totalHours = "\(hoursWorked)H \(minutesWorked)M"
            } else if hoursWorked != 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)H \(minutesWorked)M"
            } else if hoursWorked == 1 && minutesWorked == 1 {
                totalHours = "\(hoursWorked)H \(minutesWorked)M"
            } else {
                totalHours = "\(hoursWorked)H \(minutesWorked)M"
            }
        }
        
        if minutesWorked == 0 && hoursWorked == 0 {
            totalHours = "0"
        }
        
        return totalHours
    }
    
    func calculateAvg(month: [Shift]) -> String {
        var totalHours = ""
        var hoursWorked = 0
        var minutesWorked = 0
        
        
        for day in month {
            hoursWorked += calcHours(day: day)[0]
            minutesWorked += calcHours(day: day)[1]
        }
        
        minutesWorked += hoursWorked * 60
        
        minutesWorked /= month.count
        
        hoursWorked = Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        
        if minutesWorked == 0 {
            totalHours = String(hoursWorked) + "H"
        } else {
            totalHours = "\(hoursWorked)H \(minutesWorked)M"
        }
        
        return totalHours
    }
    
    func calculateSalary(month: [Shift]) -> [Any] {
        var grossSalary = 0
        var salary = 0
        var symbol = ""
        var taxRate: Float = 1.0
        var minutesInOT = 0
        var moneyInOT = 0
        var daysWorked = 0
        
        // Loads taxrate
        if UserDefaults().string(forKey: "baseTaxRate") != nil {
            taxRate -= Float(UserDefaults().string(forKey: "baseTaxRate")!)! / 100
        }
        
        // Computes month gross salary
        var prevDay = 100
        for shift in month {
            let calendar = Calendar.current
            let currentDayComp = calendar.dateComponents([.day], from: shift.date!)
            let currentDay = currentDayComp.day!
            
            if currentDay != prevDay {
                daysWorked += 1
            }
            let shiftSalaryInfo = calcShiftSalary(shift: shift)
            grossSalary += shiftSalaryInfo[0]
            minutesInOT += shiftSalaryInfo[1]
            moneyInOT += shiftSalaryInfo[2]
            let prevDayComp = calendar.dateComponents([.day], from: shift.date!)
            prevDay = prevDayComp.day!
        }
        
        // Computes month salary after taxes
        salary = Int(Float(grossSalary) * taxRate)
        
        // Loads the currency and sets appropriate symbol
        if UserDefaults().string(forKey: "currency") != nil && UserDefaults().string(forKey: "currency") != "" {
            symbol = currencies[UserDefaults().string(forKey: "currency")!]!
        }
        
        return [grossSalary, salary, symbol, minutesInOT, moneyInOT, daysWorked]
    }
    
    func calcShiftSalary(shift: Shift) -> [Int] {
        var remainingMinutes: Float = 0.0
        var minutesWorked: Float = 0.0
        var minutesInOT: Float = 0.0
        var moneyInOT: Float = 0.0
        var salary: Float = 0.0
        var baseRate: Float = 0.0
        var lunchMinutes: Float = 0.0
        var weekDayInt: Int
        var weekDay: String
        var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var starts = [[Any]]()
        var ends = [[Any]]()
        var rateFields = [myTextField]()
        var starts1 = [[Any]]()
        var ends1 = [[Any]]()
        var rateFields1 = [myTextField]()
        var extendsOver2Days = false
        var shouldSubstractLunch = true
        let calendar = Calendar.current
        var fakeStartingTime = Date(timeIntervalSinceReferenceDate: 0)
        var fakeEndingTime = Date(timeIntervalSinceReferenceDate: 0)
        let fakeStartingTimeComponents = calendar.dateComponents([.hour, .minute], from: shift.startingTime!)
        fakeStartingTime = calendar.date(byAdding: fakeStartingTimeComponents, to: fakeStartingTime)!
        
        // Computes total minutes in shift
        let timeWorked = calcHours(day: shift)
        remainingMinutes = (Float(timeWorked[1])) + (Float(timeWorked[0]) * 60)
        minutesWorked = calculateMinutes(from: shift.startingTime!, to: shift.endingTime!)
        
        // Computes day of the week
        let myCalendar = Calendar(identifier: .gregorian)
        weekDayInt = (myCalendar.component(.weekday, from: shift.date!)) - 1
        weekDay = weekDays[weekDayInt]
        
        // Loads baseRate
        if UserDefaults().string(forKey: "wageRate") != nil {
            baseRate = Float(UserDefaults().string(forKey: "wageRate")!)! / 60
        }
        
        // Loads rules arrays
        let rules1 = OTRulesForDay(day: weekDay)
        starts = rules1[0] as! [[Any]]
        ends = rules1[1] as! [[Any]]
        rateFields = rules1[2] as! [myTextField]
        
        if UserDefaults().string(forKey: "minHours") != nil && UserDefaults().string(forKey: "minHours") != "" {
            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
            if (minimum) >= (minutesWorked) {
                shouldSubstractLunch = false
                minutesWorked = Float(minimum)
                var tempDate: Date
                tempDate = calendar.date(byAdding: .hour, value: Int(minimum/60), to: shift.startingTime!)!
                
                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: tempDate)
                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
                
            } else {
                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: shift.endingTime!)
                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
            }
        } else {
            let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: shift.endingTime!)
            fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
        }
        
        
        var shiftEnd = Date()
        var shiftStart1 = Date()
        var shiftEnd1 = Date()
        let startOfDay = Date(timeIntervalSinceReferenceDate: 0)
        var endOfDay = Date(timeIntervalSinceReferenceDate: 0)
        var componentsForEndOfDay = DateComponents()
        componentsForEndOfDay.hour = 23
        componentsForEndOfDay.minute = 59
        endOfDay = calendar.date(byAdding: componentsForEndOfDay, to: endOfDay)!
        
        // Loads rules arrays for the next day if the shift extends over 2 days
        if fakeEndingTime < fakeStartingTime {
            extendsOver2Days = true
            let rules2 = OTRulesForDay(day: weekDays[weekDayInt+1])
            starts1 = rules2[0] as! [[Any]]
            ends1 = rules2[1] as! [[Any]]
            rateFields1 = rules2[2] as! [myTextField]
        }
        
        
        let shiftStart = fakeStartingTime
        if extendsOver2Days {
            shiftEnd = endOfDay
            shiftStart1 = startOfDay
            shiftEnd1 = fakeEndingTime
        } else {
            shiftEnd = fakeEndingTime
        }
        
        for i in 0..<starts.count {
            var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
            var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
            
            let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts[i][1] as! Date)
            let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends[i][1] as! Date)
            
            intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
            intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
            
            var endTime: Date
            var startTime: Date
            
            if shiftStart > intervalStart {
                if intervalEnd > shiftStart {
                    startTime = shiftStart
                    
                    if intervalEnd >= shiftEnd {
                        endTime = shiftEnd
                    } else {
                        endTime = intervalEnd
                    }
                    
                    let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
                    remainingMinutes -= minutesInThisInterval
                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
                }
                
            } else {
                if intervalStart < shiftEnd {
                    startTime = intervalStart
                    if intervalEnd < shiftEnd {
                        endTime = intervalEnd
                    } else {
                        endTime = shiftEnd
                        
                    }
                    
                    let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
                    remainingMinutes -= minutesInThisInterval
                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
                }
            }
        }
        if extendsOver2Days {
            for i in 0..<starts1.count {
                var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
                var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
                
                let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts1[i][1] as! Date)
                let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends1[i][1] as! Date)
                
                intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
                intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
                
                var endTime: Date
                var startTime: Date
                
                if shiftStart1 > intervalStart {
                    if intervalEnd > shiftStart1 {
                        startTime = shiftStart1
                        
                        if intervalEnd >= shiftEnd1 {
                            endTime = shiftEnd1
                        } else {
                            endTime = intervalEnd
                        }
                        
                        let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
                        remainingMinutes -= minutesInThisInterval
                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
                    }
                    
                } else {
                    if intervalStart < shiftEnd1 {
                        startTime = intervalStart
                        if intervalEnd < shiftEnd1 {
                            endTime = intervalEnd
                        } else {
                            endTime = shiftEnd1
                            
                        }
                        
                        let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
                        remainingMinutes -= minutesInThisInterval
                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
                    }
                }
            }
        }
        moneyInOT = salary
        salary += remainingMinutes * baseRate
        minutesInOT = minutesWorked - remainingMinutes
        
        // Substracts lunchTime with the average money/minute rate
        if shift.lunchTime != "" && shouldSubstractLunch {
            lunchMinutes = Float(Int(shift.lunchTime!)!)
            salary -= (lunchMinutes * (salary/minutesWorked))
            moneyInOT -= (lunchMinutes * (salary/minutesWorked))
        }
        
        return [Int(roundf(salary)), Int(minutesInOT), Int(moneyInOT) ]
    }
    
    func calculateMinutes(from: Date, to: Date) -> Float {
        var minutesWorked = 0
        var hoursWorked = 0
        
        let startingHour = Int(String(Array(from.description)[11...12]))
        let startingMin = Int(String(Array(from.description)[14...15]))
        let endingHour = Int(String(Array(to.description)[11...12]))
        let endingMin = Int(String(Array(to.description)[14...15]))
        
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
        
        minutesWorked += (hoursWorked * 60)
        
        return Float(minutesWorked)
    }
    
    func OTRulesForDay(day: String) -> [Any] {
        if UserDefaults().value(forKey: day) != nil {
            let instanceEncoded: [NSData] = UserDefaults().object(forKey: day) as! [NSData]
            let startsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[0] as Data)
            let endsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[1] as Data)
            let rateFieldsUnpacked = NSKeyedUnarchiver.unarchiveObject(with: instanceEncoded[2] as Data)
            
            return [startsUnpacked!, endsUnpacked!, rateFieldsUnpacked!]
        } else {
            return [[], [], []]
        }
    }
    
    func shiftsWorked(month: [Shift]) -> String {
        return String(tableList[calcIndex[0]][calcIndex[1]].count)
    }
    
    func calculateDate(month: [Shift]) -> String {
        var date = ""
        
        //        if month.count == 1 {
        //            date = String(Array(createDateString(Date: month[0].date!))[0..<createDateString(Date: month[0].date!).count-5])
        //        } else {
        //            let firstDate = String(Array(createDateString(Date: month[0].date!))[0..<createDateString(Date: month[0].date!).count-5])
        //            let secondDate = String(Array(createDateString(Date: (month.last?.date)!))[0..<createDateString(Date: (month.last?.date)!).count-5])
        //            date = secondDate + " - " + firstDate
        //        }
        
        let firstDate = String(Array(createDateString(Date: month[0].date!))[0..<createDateString(Date: month[0].date!).count-5])
        let secondDate = String(Array(createDateString(Date: (month.last?.date)!))[0..<createDateString(Date: (month.last?.date)!).count-5])
        date = secondDate + " - " + firstDate
        
        return date
    }
    
    func calculateTotalHours(month: [Shift]) -> String {
        var returnString = ""
        var hoursWorked = 0
        var minutesWorked = 0
        
        
        for day in month {
            hoursWorked += calcHours(day: day)[0]
            minutesWorked += calcHours(day: day)[1]
        }
        
        hoursWorked += Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        if minutesWorked == 0 {
            returnString = String(hoursWorked) + "H"
        } else {
            returnString = "\(hoursWorked)H \(minutesWorked)M"
        }
        
        return returnString
    }
    
    func calcHours(day: Shift) -> [Int] {
        var hoursWorked = 0
        var minutesWorked = 0
        
        let startingHour = Int(String(Array(day.startingTime!.description)[11...12]))
        let startingMin = Int(String(Array(day.startingTime!.description)[14...15]))
        let endingHour = Int(String(Array(day.endingTime!.description)[11...12]))
        let endingMin = Int(String(Array(day.endingTime!.description)[14...15]))
        
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
        
        minutesWorked += (hoursWorked * 60)
        if UserDefaults().string(forKey: "minHours") != nil {
            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
            if Int(minimum) > minutesWorked {
                minutesWorked = Int(minimum)
            }
        }
        hoursWorked = Int(minutesWorked/60)
        minutesWorked -= Int(minutesWorked/60) * 60
        
        return [hoursWorked, minutesWorked]
    }
    
    func createDateString(Date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: Date)
        return dateString.replacingOccurrences(of: ",", with: "")
    }
    
    func getShifts() {
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuTable.endEditing(true)
    }
    
    func createDefaultST() -> Date {
        let calendar = Calendar.current
        
        var date = Date(timeIntervalSinceReferenceDate: 0)
        date = calendar.date(byAdding: .hour, value: 7, to: date)!
        
        return date
    }
    func createDefaultET() -> Date {
        let calendar = Calendar.current
        
        var date = Date(timeIntervalSinceReferenceDate: 0)
        date = calendar.date(byAdding: .hour, value: 15, to: date)!
        
        return date
    }
}


