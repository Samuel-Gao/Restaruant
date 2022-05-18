//
//  OrderResponse.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import Foundation

struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}
