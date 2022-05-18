//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdateNotification, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return orders.menuItems.count
        print("a", MenuController.shared.order)
        return MenuController.shared.order.menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItem", for: indexPath)

        configureCell(cell, forMenuItemAt: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forMenuItemAt indexPath: IndexPath) {
        var orders = MenuController.shared.order
        print("b", MenuController.shared.order.menuItems)
        print("b", orders.menuItems)
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.name
        content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
        cell.contentConfiguration = content
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
}
