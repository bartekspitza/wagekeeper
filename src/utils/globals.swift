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
var shifts = [[Shift]]()
var shiftsNeedsReOrganizing = false
var periodsSeperatedByYear = [[[Shift]]]()
var period: Period?
var loginListener: AuthStateDidChangeListenerHandle!
var indexForChosenPeriod = [0,0]
let EMPTY_PROFILE_PICTURE_URL = "https://avatars.mds.yandex.net/get-pdb/938499/43932b0d-b15b-4962-ab61-cc93e0b1b5ed/orig"
let appName = "WageKeeper"
let appBuild = "2.2.1"
var loginViewShouldAnimate = true
