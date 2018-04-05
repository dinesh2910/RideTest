//
//  SingletonClass.swift
//  RideTest
//
//  Created by dinesh danda on 4/4/18.
//  Copyright © 2018 dinesh danda. All rights reserved.
//

import Foundation
import HealthKit
class SingltonClass {
    
    static let sharedManager = SingltonClass()

    func getCalariesExertes(distance : Double) -> Double {
        let weight = 175.0 // pounds
     return   0.57 * weight * distance
    }


}
