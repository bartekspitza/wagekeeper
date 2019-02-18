//
//  globals.swift
//  WageKeeper
//
//  Created by Maikzy on 2019-02-13.
//  Copyright © 2019 Bartek . All rights reserved.
//

import Foundation
import FirebaseAuth

var user: MyUser!
var shiftToEdit = [0,0]
var shifts = [[ShiftModel]]()
var shiftsNeedsReOrganizing = false
var periodsSeperatedByYear = [[[ShiftModel]]]()
var period: Period?
var loginListener: AuthStateDidChangeListenerHandle!
var indexForChosenPeriod = [0,0]
