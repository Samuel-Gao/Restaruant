//
//  Order.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import Foundation

struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
