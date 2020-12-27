//
//  ExpensesViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 02.12.2020.
//

import UIKit

class ExpensesViewController: UIViewController {

    public static var firstLaunch: Bool = false
    var expCategs: [Category] = []
    
    var selectedCategoryId: String = ""
    var selectedCategoryName: String = ""
    
    @IBOutlet weak var exspensesTableView: UITableView!
    
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Новая категория", message: "Введите название новой категории", preferredStyle: .alert)
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая категория"
        }
        
        let saveButton = UIAlertAction(title: "Сохранить", style: .default) { action in
            guard let text = alertTextField.text, !text.isEmpty else { return }
            
            let categ = Category(id: UUID().uuidString, name: text, isExpense: true)
            RealmManager.get().addCategoryToRealm(category: categ)
            self.expCategs.append(categ)
            self.exspensesTableView.insertRows(at: [IndexPath.init(row: self.expCategs.count - 1, section: 0)], with: .automatic)
        }
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
        self.exspensesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for category in RealmManager.get().getCategoriesFromRealm() {
            if category.isExpense {
                expCategs.append(category)
            }
        }
        self.exspensesTableView.reloadData()
    }
    

}

extension ExpensesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteCateg = expCategs[indexPath.row]
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") {_, _ in
            RealmManager.get().removeCategoryFromRealm(category: deleteCateg)
            if let index = self.expCategs.firstIndex(of: deleteCateg) {
                self.expCategs.remove(at: index)
            }
            self.exspensesTableView.reloadData()
        }
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expCategs.count >= indexPath.row {
            self.selectedCategoryId = expCategs[indexPath.row].id
            self.selectedCategoryName = expCategs[indexPath.row].name
            CategsExpenseViewController.selectedCategoryId = self.selectedCategoryId
            CategsExpenseViewController.selectedCategoryName = self.selectedCategoryName
            performSegue(withIdentifier: "toExpCategs", sender: self)
        }
        else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ExpensesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expCategs.count != 0 {
            return expCategs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = exspensesTableView.dequeueReusableCell(withIdentifier: "categsExpsCell") as! ExpenseTableViewCell
        let categ = expCategs[indexPath.row]
        cell.categLabel.text = categ.name
        return cell
    }
    
    
}
