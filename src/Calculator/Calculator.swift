//  LaunchCalc.swift
//  SalaryCalc
//
//  Created by Bartek  on 2017-11-24.
//  Copyright © 2017 Bartek . All rights reserved.
//

import UIKit
import Foundation

class Calculator: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var totalHoursLbl = CountingLabel()
    var totalMinutesLbl = CountingLabel()
    var periodLbl = UILabel()
    var btn: UIButton!
    @IBOutlet weak var grossLbl: CountingLabel!
    @IBOutlet weak var salaryLbl: CountingLabel!
    var seperatorLineHorizontal = UIView()
    var upperLineOfArrowButton = UIView()
    var statsTable = UITableView()
    var menuTable = UITableView()
    
    var stats = [String]()
    var periodsSeperatedByYear = [[[ShiftModel]]]()
    var period: Period!
    var menuisShowing = false
    var indexForChosenPeriod = [0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNewUser()
        getShifts(fromCloud: false)
        makePeriodsSeperatedByYear()
        makePeriod()
        makeDesign()
        makeMenuBtn()
        designLabels()
        addUpperLineOfArrowButtonSection()
        configureStatsTable()
        configureMenuTable()
        centerTotalTimeLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stats.removeAll()
        labelsForNoShifts()

        makePeriodsSeperatedByYear()
        makePeriod()
        fillLabelsWithStats()
        startCountingLabels()
        
        menuTable.reloadData()
        statsTable.reloadData()
        
        // centerTotalTimeLabels() might need this here
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        salaryLbl.text = "0"
        btn.transform = .identity
        if menuisShowing {
            menuTable.frame = CGRect(x: 0, y: (btn.center.y + btn.frame.height/2), width: self.view.frame.width, height: 0)
            menuisShowing = false
        }
        indexForChosenPeriod = [0, 0]
    }
    
    func configureNewUser() {
        if !periodsSeperatedByYear.isEmpty && UserDefaults().value(forKey: "FirstTime") == nil {
            UserDefaults().set("Visited", forKey: "FirstTime")
        }
        
        if UserDefaults().value(forKey: "FirstTime") == nil {
            insertExampleShift()
            initiateUserDefualts()
            UserDefaults().set("Visited", forKey: "FirstTime")
        }
    }
    
    func insertExampleShift() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shift = Shift(context: context)
        shift.date = Date()
        shift.endingTime = Time.createDefaultET()
        shift.startingTime = Time.createDefaultST()
        shift.lunchTime = "60"
        shift.note = "Example (Delete this)"
        shift.newMonth = Int16(0)
        
        shifts.append([ShiftModel.createFromCoreData(s: shift)])
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func initiateUserDefualts() {
        UserDefaults().set("0.0", forKey: "taxRate")
        UserDefaults().set("10", forKey: "wageRate")
        UserDefaults().set("USD", forKey: "currency")
        UserDefaults().set(false, forKey: "manuallyNewMonth")
        UserDefaults().set("1", forKey: "newMonth")
        UserDefaults().set("0", forKey: "minHours")
        UserDefaults().set(Time.createDefaultST(), forKey: "defaultST")
        UserDefaults().set(Time.createDefaultET(), forKey: "defaultET")
        UserDefaults().set("Example (Delete this)", forKey: "defaultNote")
        UserDefaults().set("0", forKey: "defaultLunch")
    }
    
    func centerTotalTimeLabels() {
        let centerPoint = self.view.frame.width * 0.75
        
        let totalHoursLblPoint = ((centerPoint - 4) - totalHoursLbl.frame.width/2) - 5
        let totalMinutesLblPoint = ((centerPoint + 4) + totalMinutesLbl.frame.width/2) - 5
        
        totalHoursLbl.center.x = totalHoursLblPoint
        totalMinutesLbl.center.x = totalMinutesLblPoint
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
            let startingString = String(Array(periodsSeperatedByYear[section][0][periodsSeperatedByYear[section][0].count-1].date.description)[0..<4])
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
            
            let prevCell = menuTable.cellForRow(at: IndexPath(row: indexForChosenPeriod[1], section: indexForChosenPeriod[0]))
            prevCell?.accessoryType = .none
            let cellPressed = menuTable.cellForRow(at: indexPath)!
            cellPressed.accessoryType = .checkmark
            cellPressed.tintColor = .white
            if indexPath.section != indexForChosenPeriod[0] || indexPath.row != indexForChosenPeriod[1] {
                indexForChosenPeriod = [indexPath.section, indexPath.row]
                stats.removeAll()
                makePeriod()
                statsTable.reloadData()
                startCountingLabels()
                periodLbl.text = period.duration
            }
        }
    }
    
    func labelsForNoShifts() {
        let currency = UserDefaults().string(forKey: "currency")!
        let symbol = currencies[currency]!
        
        
            if symbol == "kr" {
                salaryLbl.text = "0kr"
                grossLbl.text = "PRE-TAX: 0kr"
            } else {
                salaryLbl.text = symbol + "0"
                grossLbl.text = "PRE-TAX: " + symbol + "0"
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
            
            cell.insertStatsDesc(width: (self.view.frame.width), text: Stats.descriptions[indexPath.row].uppercased())
            if stats.count > 0 {
                cell.insertStatsInfo(width: self.view.frame.width, text: stats[indexPath.row].uppercased())
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
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.selectionStyle = .none
            cell.backgroundColor = headerColor
            if indexPath.section == indexForChosenPeriod[0] && indexPath.row == indexForChosenPeriod[1] {
                cell.tintColor = .white
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return Stats.descriptions.count
        } else {
            return periodsSeperatedByYear[section].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return 1
        } else {
            return periodsSeperatedByYear.count
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
        
        periodLbl.text = period.duration
        periodLbl.textAlignment = .right
        periodLbl.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width/3), height: Int(30))
        periodLbl.center = CGPoint(x: Int(self.view.frame.width*0.95 - periodLbl.frame.width/2), y: Int(btn.center.y))
        
        self.view.addSubview(periodLbl)
    }
    
    func startCountingLabels() {
        if shifts.count > 0 {
            if Int(period.grossSalary) > 0 {
                grossLbl.count(fromValue: 0, to: Float(period.grossSalary), withDuration: 1.5, andAnimationtype: .EaseOut, andCounterType: .Int, currency: UserSettings.getCurrencySymbol(), preString: "PRE-TAX: ", afterString: "")
                salaryLbl.count(fromValue: 0, to: Float(period.salary), withDuration: TimeInterval(1.5 * (Float(period.salary)/Float(period.grossSalary))), andAnimationtype: .EaseOut, andCounterType: .Int, currency: UserSettings.getCurrencySymbol(), preString: "", afterString: "")
            }
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
            
            stats.append(StringFormatter.stringFromHoursAndMinutes(a: period.amountHoursMinutesWorked))
            stats.append(StringFormatter.stringFromHoursAndMinutes(a: period.avgShift))
            stats.append(String(period.shiftsWorked))
            stats.append(String(period.daysWorked))
            stats.append(StringFormatter.stringFromHoursAndMinutes(a: Time.minutesToHoursAndMinutes(minutes: period.minutesInOvertime)))
            stats.append(StringFormatter.addCurrencyToNumber(amount: period.moneyFromOvertime))
        }
    }
    
    func fillLabelsWithStats() {
        totalHoursLbl.text = "HOURS: 0"
        totalMinutesLbl.text = "MINUTES: 0"
        salaryLbl.text = StringFormatter.addCurrencyToNumber(amount: period.salary)
    }
    
//    func formatTime(minutes: Int) -> String {
//        var totalHours = ""
//        var hoursWorked = 0
//        var minutesWorked = 0
//
//        minutesWorked = minutes
//
//        hoursWorked = Int(minutes/60)
//        minutesWorked -= Int(minutes/60) * 60
//
//        if hoursWorked == 0 {
//            if minutesWorked == 1 {
//                totalHours = "\(minutesWorked)M"
//            } else {
//                totalHours = "\(minutesWorked)M"
//            }
//
//        } else if minutesWorked == 0 {
//            if hoursWorked == 1 {
//                totalHours = "\(hoursWorked)H"
//            } else {
//                totalHours = "\(hoursWorked)H"
//            }
//
//        } else {
//            if hoursWorked == 1 && minutesWorked != 1 {
//                totalHours = "\(hoursWorked)H \(minutesWorked)M"
//            } else if hoursWorked != 1 && minutesWorked == 1 {
//                totalHours = "\(hoursWorked)H \(minutesWorked)M"
//            } else if hoursWorked == 1 && minutesWorked == 1 {
//                totalHours = "\(hoursWorked)H \(minutesWorked)M"
//            } else {
//                totalHours = "\(hoursWorked)H \(minutesWorked)M"
//            }
//        }
//
//        if minutesWorked == 0 && hoursWorked == 0 {
//            totalHours = "0"
//        }
//
//        return totalHours
//    }
//
//    func calculateAvg(month: [Shift]) -> String {
//        var totalHours = ""
//        var hoursWorked = 0
//        var minutesWorked = 0
//
//
//        for day in month {
//            hoursWorked += calcHours(day: day)[0]
//            minutesWorked += calcHours(day: day)[1]
//        }
//
//        minutesWorked += hoursWorked * 60
//
//        minutesWorked /= month.count
//
//        hoursWorked = Int(minutesWorked/60)
//        minutesWorked -= Int(minutesWorked/60) * 60
//
//        if minutesWorked == 0 {
//            totalHours = String(hoursWorked) + "H"
//        } else {
//            totalHours = "\(hoursWorked)H \(minutesWorked)M"
//        }
//
//        return totalHours
//    }
//
//    func calculateSalary(month: [Shift]) -> [Any] {
//        var grossSalary = 0
//        var salary = 0
//        var symbol = ""
//        var taxRate: Float = 1.0
//        var minutesInOT = 0
//        var moneyInOT = 0
//        var daysWorked = 0
//
//        // Loads taxrate
//        if UserDefaults().string(forKey: "baseTaxRate") != nil {
//            taxRate -= Float(UserDefaults().string(forKey: "baseTaxRate")!)! / 100
//        }
//
//        // Computes month gross salary
//        var prevDay = 100
//        for shift in month {
//            let calendar = Calendar.current
//            let currentDayComp = calendar.dateComponents([.day], from: shift.date!)
//            let currentDay = currentDayComp.day!
//
//            if currentDay != prevDay {
//                daysWorked += 1
//            }
//            let shiftSalaryInfo = calcShiftSalary(shift: shift)
//            grossSalary += shiftSalaryInfo[0]
//            minutesInOT += shiftSalaryInfo[1]
//            moneyInOT += shiftSalaryInfo[2]
//            let prevDayComp = calendar.dateComponents([.day], from: shift.date!)
//            prevDay = prevDayComp.day!
//        }
//
//        // Computes month salary after taxes
//        salary = Int(Float(grossSalary) * taxRate)
//
//        // Loads the currency and sets appropriate symbol
//        if UserDefaults().string(forKey: "currency") != nil && UserDefaults().string(forKey: "currency") != "" {
//            symbol = currencies[UserDefaults().string(forKey: "currency")!]!
//        }
//
//        return [grossSalary, salary, symbol, minutesInOT, moneyInOT, daysWorked]
//    }
    
//    func calcShiftSalary(shift: Shift) -> [Int] {
//        var remainingMinutes: Float = 0.0
//        var minutesWorked: Float = 0.0
//        var minutesInOT: Float = 0.0
//        var moneyInOT: Float = 0.0
//        var salary: Float = 0.0
//        var baseRate: Float = 0.0
//        var lunchMinutes: Float = 0.0
//        var weekDayInt: Int
//        var weekDay: String
//        var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
//        var starts = [[Any]]()
//        var ends = [[Any]]()
//        var rateFields = [myTextField]()
//        var starts1 = [[Any]]()
//        var ends1 = [[Any]]()
//        var rateFields1 = [myTextField]()
//        var extendsOver2Days = false
//        var shouldSubstractLunch = true
//        let calendar = Calendar.current
//        var fakeStartingTime = Date(timeIntervalSinceReferenceDate: 0)
//        var fakeEndingTime = Date(timeIntervalSinceReferenceDate: 0)
//        let fakeStartingTimeComponents = calendar.dateComponents([.hour, .minute], from: shift.startingTime!)
//        fakeStartingTime = calendar.date(byAdding: fakeStartingTimeComponents, to: fakeStartingTime)!
//
//        // Computes total minutes in shift
//        let timeWorked = calcHours(day: shift)
//        remainingMinutes = (Float(timeWorked[1])) + (Float(timeWorked[0]) * 60)
//        minutesWorked = calculateMinutes(from: shift.startingTime!, to: shift.endingTime!)
//
//        // Computes day of the week
//        let myCalendar = Calendar(identifier: .gregorian)
//        weekDayInt = (myCalendar.component(.weekday, from: shift.date!)) - 1
//        weekDay = weekDays[weekDayInt]
//
//        // Loads baseRate
//        if UserDefaults().string(forKey: "wageRate") != nil {
//            baseRate = Float(UserDefaults().string(forKey: "wageRate")!)! / 60
//        }
//
//        // Loads rules arrays
//        let rules1 = OTRulesForDay(day: weekDay)
//        starts = rules1[0] as! [[Any]]
//        ends = rules1[1] as! [[Any]]
//        rateFields = rules1[2] as! [myTextField]
//
//        if UserDefaults().string(forKey: "minHours") != nil && UserDefaults().string(forKey: "minHours") != "" {
//            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
//            if (minimum) >= (minutesWorked) {
//                shouldSubstractLunch = false
//                minutesWorked = Float(minimum)
//                var tempDate: Date
//                tempDate = calendar.date(byAdding: .hour, value: Int(minimum/60), to: shift.startingTime!)!
//
//                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: tempDate)
//                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
//
//            } else {
//                let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: shift.endingTime!)
//                fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
//            }
//        } else {
//            let fakeEndingComponents = calendar.dateComponents([.hour, .minute], from: shift.endingTime!)
//            fakeEndingTime = calendar.date(byAdding: fakeEndingComponents, to: fakeEndingTime)!
//        }
//
//
//        var shiftEnd = Date()
//        var shiftStart1 = Date()
//        var shiftEnd1 = Date()
//        let startOfDay = Date(timeIntervalSinceReferenceDate: 0)
//        var endOfDay = Date(timeIntervalSinceReferenceDate: 0)
//        var componentsForEndOfDay = DateComponents()
//        componentsForEndOfDay.hour = 23
//        componentsForEndOfDay.minute = 59
//        endOfDay = calendar.date(byAdding: componentsForEndOfDay, to: endOfDay)!
//
//        // Loads rules arrays for the next day if the shift extends over 2 days
//        if fakeEndingTime < fakeStartingTime {
//            extendsOver2Days = true
//            let rules2 = OTRulesForDay(day: weekDays[weekDayInt+1])
//            starts1 = rules2[0] as! [[Any]]
//            ends1 = rules2[1] as! [[Any]]
//            rateFields1 = rules2[2] as! [myTextField]
//        }
//
//
//        let shiftStart = fakeStartingTime
//        if extendsOver2Days {
//            shiftEnd = endOfDay
//            shiftStart1 = startOfDay
//            shiftEnd1 = fakeEndingTime
//        } else {
//            shiftEnd = fakeEndingTime
//        }
//
//        for i in 0..<starts.count {
//            var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
//            var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
//
//            let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts[i][1] as! Date)
//            let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends[i][1] as! Date)
//
//            intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
//            intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
//
//            var endTime: Date
//            var startTime: Date
//
//            if shiftStart > intervalStart {
//                if intervalEnd > shiftStart {
//                    startTime = shiftStart
//
//                    if intervalEnd >= shiftEnd {
//                        endTime = shiftEnd
//                    } else {
//                        endTime = intervalEnd
//                    }
//
//                    let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
//                    remainingMinutes -= minutesInThisInterval
//                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
//                }
//
//            } else {
//                if intervalStart < shiftEnd {
//                    startTime = intervalStart
//                    if intervalEnd < shiftEnd {
//                        endTime = intervalEnd
//                    } else {
//                        endTime = shiftEnd
//
//                    }
//
//                    let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
//                    remainingMinutes -= minutesInThisInterval
//                    salary += minutesInThisInterval * (Float(Int(rateFields[i].text!)!) / 60)
//                }
//            }
//        }
//        if extendsOver2Days {
//            for i in 0..<starts1.count {
//                var intervalStart = Date(timeIntervalSinceReferenceDate: 0) // 2001...
//                var intervalEnd = Date(timeIntervalSinceReferenceDate: 0) // 2001..
//
//                let intervalStartComponents = calendar.dateComponents([.hour, .minute], from: starts1[i][1] as! Date)
//                let intervalEndComponents = calendar.dateComponents([.hour, .minute], from: ends1[i][1] as! Date)
//
//                intervalStart = calendar.date(byAdding: intervalStartComponents, to: intervalStart)!
//                intervalEnd = calendar.date(byAdding: intervalEndComponents, to: intervalEnd)!
//
//                var endTime: Date
//                var startTime: Date
//
//                if shiftStart1 > intervalStart {
//                    if intervalEnd > shiftStart1 {
//                        startTime = shiftStart1
//
//                        if intervalEnd >= shiftEnd1 {
//                            endTime = shiftEnd1
//                        } else {
//                            endTime = intervalEnd
//                        }
//
//                        let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
//                        remainingMinutes -= minutesInThisInterval
//                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
//                    }
//
//                } else {
//                    if intervalStart < shiftEnd1 {
//                        startTime = intervalStart
//                        if intervalEnd < shiftEnd1 {
//                            endTime = intervalEnd
//                        } else {
//                            endTime = shiftEnd1
//
//                        }
//
//                        let minutesInThisInterval = calculateMinutes(from: startTime, to: endTime)
//                        remainingMinutes -= minutesInThisInterval
//                        salary += minutesInThisInterval * (Float(Int(rateFields1[i].text!)!) / 60)
//                    }
//                }
//            }
//        }
//        moneyInOT = salary
//        salary += remainingMinutes * baseRate
//        minutesInOT = minutesWorked - remainingMinutes
//
//        // Substracts lunchTime with the average money/minute rate
//        if shift.lunchTime != "" && shouldSubstractLunch {
//            lunchMinutes = Float(Int(shift.lunchTime!)!)
//            salary -= (lunchMinutes * (salary/minutesWorked))
//            moneyInOT -= (lunchMinutes * (salary/minutesWorked))
//        }
//
//        return [Int(roundf(salary)), Int(minutesInOT), Int(moneyInOT) ]
//    }
//
//    func calculateMinutes(from: Date, to: Date) -> Float {
//        var minutesWorked = 0
//        var hoursWorked = 0
//
//        let startingHour = Int(String(Array(from.description)[11...12]))
//        let startingMin = Int(String(Array(from.description)[14...15]))
//        let endingHour = Int(String(Array(to.description)[11...12]))
//        let endingMin = Int(String(Array(to.description)[14...15]))
//
//        if endingHour! - startingHour! > 0 {
//            hoursWorked = endingHour! - startingHour!
//        } else if endingHour! - startingHour! < 0 {
//            hoursWorked = 24 + (endingHour! - startingHour!)
//        }
//
//        if endingMin! - startingMin! < 0 {
//            hoursWorked -= 1
//            minutesWorked = 60 - (startingMin! - endingMin!)
//        } else if endingMin! - startingMin! > 0 {
//            minutesWorked = endingMin! - startingMin!
//        }
//
//        minutesWorked += (hoursWorked * 60)
//
//        return Float(minutesWorked)
//    }
//
//    func shiftsWorked(month: [Shift]) -> String {
//        return String(periodsSeperatedByYear[indexForChosenPeriod[0]][indexForChosenPeriod[1]].count)
//    }
//
//    func calculateDate(month: [Shift]) -> String {
//        var date = ""
//
//        let firstDate = String(Array(Time.dateToString(date: month[0].date!, withDayName: true))[0..<Time.dateToString(date: month[0].date!, withDayName: true).count-5])
//        let secondDate = String(Array(Time.dateToString(date: (month.last?.date)!, withDayName: true))[0..<Time.dateToString(date: (month.last?.date)!, withDayName: true).count-5])
//        date = secondDate + " - " + firstDate
//
//        return date
//    }
//
//    func calculateTotalHours(month: [Shift]) -> String {
//        var returnString = ""
//        var hoursWorked = 0
//        var minutesWorked = 0
//
//
//        for day in month {
//
//            hoursWorked += calcHours(day: day)[0]
//            minutesWorked += calcHours(day: day)[1]
//        }
//
//        hoursWorked += Int(minutesWorked/60)
//        minutesWorked -= Int(minutesWorked/60) * 60
//        if minutesWorked == 0 {
//            returnString = String(hoursWorked) + "H"
//        } else {
//            returnString = "\(hoursWorked)H \(minutesWorked)M"
//        }
//
//        return returnString
//    }
//
//    func calcHours(day: Shift) -> [Int] {
//        var hoursWorked = 0
//        var minutesWorked = 0
//
//        let startingHour = Int(String(Array(day.startingTime!.description)[11...12]))
//        let startingMin = Int(String(Array(day.startingTime!.description)[14...15]))
//        let endingHour = Int(String(Array(day.endingTime!.description)[11...12]))
//        let endingMin = Int(String(Array(day.endingTime!.description)[14...15]))
//
//        if endingHour! - startingHour! > 0 {
//            hoursWorked = endingHour! - startingHour!
//        } else if endingHour! - startingHour! < 0 {
//            hoursWorked = 24 + (endingHour! - startingHour!)
//        }
//
//        if endingMin! - startingMin! < 0 {
//            hoursWorked -= 1
//            minutesWorked = 60 - (startingMin! - endingMin!)
//        } else if endingMin! - startingMin! > 0 {
//            minutesWorked = endingMin! - startingMin!
//        }
//
//        minutesWorked += (hoursWorked * 60)
//        if UserDefaults().string(forKey: "minHours") != nil {
//            let minimum = Float(UserDefaults().string(forKey: "minHours")!)! * 60
//            if Int(minimum) > minutesWorked {
//                minutesWorked = Int(minimum)
//            }
//        }
//        hoursWorked = Int(minutesWorked/60)
//        minutesWorked -= Int(minutesWorked/60) * 60
//
//        return [hoursWorked, minutesWorked]
//    }
    
    func getShifts(fromCloud: Bool) {
        var tmp = [ShiftModel]()
        
        if fromCloud {
            // do something
        } else {
            tmp = Period.convertShiftsFromCoreDataToModels(arr: LocalStorage.getAllShifts())
        }
        shifts = Period.organizeShiftsIntoPeriods(ar: &tmp)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        menuTable.endEditing(true)
    }
}
