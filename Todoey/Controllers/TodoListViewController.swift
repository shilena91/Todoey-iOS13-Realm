//
//  ViewController.swift
//  Todoey
//
//  Created by Hoang Pham on 01/05/2020.

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var toDoItems: Results<Item>?
    let realm = try! Realm()
    
    var category: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let colorHex = category?.hexColorString {
            
            title = category!.name
            
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
            let navBarApperance = UINavigationBarAppearance()
            navBarApperance.configureWithOpaqueBackground()
            if let navBarColor = UIColor(hexString: colorHex) {
                
                navBarApperance.backgroundColor = navBarColor
                navBarApperance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.standardAppearance = navBarApperance
                navBar.scrollEdgeAppearance = navBarApperance
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = .white
            }
        }
        

    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] (action) in
            
            if let currentCategory = self?.category {
                do {
                    try self?.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print("Error saving new item: \(error)")
                }
            }
            
            self?.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Delete Item from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelete = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDelete)
                }
            }
            catch {
                print("Error delete item: \(error)")
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        toDoItems = category?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }
        }
    }
}

//MARK: - TableView delegates

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
    
            if let color = UIColor(hexString: category!.hexColorString)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count) ) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none

        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    
                    //realm.delete(item) to delete item
                    item.done = !item.done
                }
            }
            catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
