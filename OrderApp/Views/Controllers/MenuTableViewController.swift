//
//  MenuTableViewController.swift
//  OrderApp
//
//  Created by Samuel Gao on 2022-05-17.
//

import UIKit

@MainActor
class MenuTableViewController: UITableViewController {
    let category: String
    let menuController = MenuController.shared
    var menuItems = [MenuItem]()
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category.capitalized
        
        Task {
            do {
                let menuItems = try await menuController.fetchMenuItems(forCategory: category)
                updateUI(with: menuItems)
            } catch {
                displayError(error, title: "Failed to Fetch Menu Items for \(self.category)")
            }
        }
    }

    func updateUI(with menuItems: [MenuItem]) {
        self.menuItems = menuItems
        self.tableView.reloadData()
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
    }
    
    
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: Any?) -> MenuItemViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return nil }
        
        let menuItem = menuItems[indexPath.row]
        return MenuItemViewController(coder: coder, menuItem: menuItem)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath)

        configureCell(cell, forMenuItemAt: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forMenuItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = menuItems[indexPath.row]
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
//        var content = cell.defaultContentConfiguration()
//        content.text = menuItem.name
//        content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
//        content.image = UIImage(systemName: "photo.on.rectangle")
//        cell.contentConfiguration = content
        
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
//                    var content =  cell.defaultContentConfiguration()
                    cell.image = image
//                    content.text = menuItem.name
//                    content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
//                    content.image = image
//                    cell.contentConfiguration = content
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        imageLoadTasks.forEach { key, value in
            value.cancel()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}