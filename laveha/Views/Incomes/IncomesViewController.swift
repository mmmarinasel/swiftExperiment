//
//  IncomesViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 15.10.2020.
//

import UIKit

class IncomesViewController: UIViewController {
    
    public static var firstLaunch: Bool = false
    var incCategs: [Category] = []
    
    var selectedCategoryId: String = ""
    var selectedCategoryName: String = ""
    
    @IBOutlet weak var incomesTableView: UITableView!
    
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Новая категория", message: "Введите название новой категории", preferredStyle: .alert)
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая категория"
        }
        
        let saveButton = UIAlertAction(title: "Сохранить", style: .default) { action in
            
            guard let text = alertTextField.text, !text.isEmpty else { return }
         
            let categ = Category(id: UUID().uuidString, name: text, isExpense: false)
            RealmManager.get().addCategoryToRealm(category: categ)
            self.incCategs.append(categ)
            // items! заменила на incCategs
            self.incomesTableView.insertRows(at: [IndexPath.init(row: self.incCategs.count - 1, section: 0)], with: .automatic)
        
        }
        let cancelButton = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
        self.incomesTableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for category in RealmManager.get().getCategoriesFromRealm() {
            if !category.isExpense {
                incCategs.append(category)
            }
        }
        self.incomesTableView.reloadData()
    }
    
// ПОПЫТОЧКА
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CategsIncomeViewController, segue.identifier == "toIncCategs" {
            //vc.selectedCategoryId = self.selectedCategoryId
        }
    }

}

extension IncomesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteCateg = incCategs[indexPath.row]
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") {_, _ in
            RealmManager.get().removeCategoryFromRealm(category: deleteCateg)
            if let index = self.incCategs.firstIndex(of: deleteCateg) {
                self.incCategs.remove(at: index)
            }
            self.incomesTableView.reloadData()
        }
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // items! заменила на incCategs
        if incCategs.count >= indexPath.row {
            self.selectedCategoryId = incCategs[indexPath.row].id
            self.selectedCategoryName = incCategs[indexPath.row].name
            CategsIncomeViewController.selectedCategoryId = self.selectedCategoryId
            CategsIncomeViewController.selectedCategoryName = self.selectedCategoryName
            performSegue(withIdentifier: "toIncCategs", sender: self)
        }
        else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension IncomesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // items! заменила на incCategs
        if incCategs.count != 0 {
            return incCategs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = incomesTableView.dequeueReusableCell(withIdentifier: "incomeCell") as! IncomeTableViewCell
        // items! заменила на incCategs
        let categ = incCategs[indexPath.row]
        cell.categLabel.text = categ.name
        return cell
    }
}


