//
//  Category.swift
//  Todoey
//
//  Created by Hoang on 6.5.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var hexColorString: String = ""
    let items = List<Item>() // this syxtax is same with: let array: Array<Int> = []
    
}
