//
//  Touch.swift
//  Kids'n'Code
//
//  Created by Alexander on 03/11/15.
//  Copyright © 2015 Kids'n'Code. All rights reserved.
//

import CoreData


class Touch: NSManagedObject {

    @NSManaged var touchedNode: String
    @NSManaged var level: Level

}
