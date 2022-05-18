//
//  MenuController.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import Foundation

class MenuController {
    static let shared = MenuController()
    static let orderUpdateNotification = Notification.Name("MenuController.orderUpdated")
    
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdateNotification, object: nil)
        }
    }
    
    let baseURL = URL(string: "http://localhost:8080")!
    
    func fetchCategories() async throws -> [String] {
        // Create URL
        let categoriesURL = baseURL.appendingPathComponent("categories")
        
        // Make request, check status code and throw error if status code is not 200
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw MenuControllerError.categoriesNotFound }
        
        // Decode response and return Categories
        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoryResponse.self, from: data)
        return categoriesResponse.categories
    }
    
    
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
        // Create URL and append query parameter
        let baseMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components.url!
        
        // Make request, check status code and throw error if status code is not 200
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw MenuControllerError.menuItemsNotFound }
        
        // Decode response and return MenuItems
        let decoder = JSONDecoder()
        let menuItemsResponse = try decoder.decode(MenuResponse.self, from: data)
        return menuItemsResponse.items
        
    }
    
    
    typealias MinutesToPrepare = Int
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        // Create URL and POST request, append json to body.
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let menuIDsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIDsDict)
        request.httpBody = jsonData
        
        // Make POST request and throw error if status code is not 200.
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw MenuControllerError.orderRequestFailed }
        
        // Decode response and return minutes needed to prepare order.
        let jsonDecoder = JSONDecoder()
        let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
        return orderResponse.prepTime
        
    }
}


enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case orderRequestFailed
}
