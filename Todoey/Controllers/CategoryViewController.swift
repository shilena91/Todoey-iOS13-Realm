//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hoang on 6.5.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(hexString: "0EBCEB")
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
    }
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { [weak self] (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.hexColorString = UIColor.randomFlat().hexValue()
            self?.saveCategory(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDelete = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDelete)
                }
            }
            catch {
                print("Error delete category: \(error)")
            }
        }

    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("save context error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        categoryArray = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TodoListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.category = categoryArray?[indexPath.row]
            }
        }
    }
    

}

// MARK: - Table view data source

extension CategoryViewController {
    
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.hexColorString) else {fatalError()}
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.backgroundColor = UIColor(hexString: category.hexColorString)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItem", sender: self)
    }
}
