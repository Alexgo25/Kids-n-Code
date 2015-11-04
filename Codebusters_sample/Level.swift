//
//  Level.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import CoreData


class Level: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var finished: NSNumber
    @NSManaged var levelNumber: NSNumber
    @NSManaged var levelPackNumber: NSNumber
    @NSManaged var time: NSNumber
    @NSManaged var actions: NSSet
    @NSManaged var touches: NSSet

}
