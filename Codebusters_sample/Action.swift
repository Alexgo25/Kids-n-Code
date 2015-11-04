//
//  Action.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import Foundation
import CoreData


class Action: NSManagedObject {

    @NSManaged var actionType: String
    @NSManaged var level: Level

}
