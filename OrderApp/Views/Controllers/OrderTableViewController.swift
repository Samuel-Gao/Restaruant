//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    var minutesToPrepare = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdateNotification, object: nil)
    }

    @IBSegueAction func confirmOrder(_ coder: NSCoder, sender: Any?) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepare)
    }
    
    @IBAction func submitOrder(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { $0 + $1.price }
        
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        let alertController = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
        
        let submitAlertAction = UIAlertAction(title: "Submit", style: .default, handler: {_ in self.uploadOrder() })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(submitAlertAction)
        alertController.addAction(cancelAlertAction)
        
        self.present(alertController, animated: true)
    }
    
    func uploadOrder() {
        let menuIds = MenuController.shared.order.menuItems.map { $0.id
        }
        
        Task.init {
            do {
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuIDs: menuIds)
                self.minutesToPrepare = minutesToPrepare
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
    func displayError(_ error: Error, title: String){
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        if segue.identifier == "dismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
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
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
//        var content = cell.defaultContentConfiguration()
//        content.text = menuItem.name
//        content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
//        content.image = UIImage(systemName: "photo.on.rectangle")
//        cell.contentConfiguration = content
        
        Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.image = image
                }
            }
        }
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
