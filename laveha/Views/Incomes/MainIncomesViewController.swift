//
//  MainIncomesViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 29.10.2020.
//

import UIKit
//import RealmSwift

class MainIncomesViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    let datePicker = UIDatePicker()
    let categoryPicker = UIPickerView()
    var categories: [Category] = []
    var incomes: [Income] = []
    var categId: String = ""
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func saveButton(_ sender: Any) {
        if !descriptionTextField.text!.isEmpty && !amountTextField.text!.isEmpty && !categoryTextField.text!.isEmpty && !dateTextField.text!.isEmpty {
            if let amount = Double(amountTextField.text!) {
                let descript = descriptionTextField.text!
                let category = self.categId /*categoryTextField.text*/
                let date = datePicker.date
                let inc = Income(descript: descript, category: category, amount: amount, date: date, loadedFromRealm: true)
                RealmManager.get().addIncomeToRealm(income: inc)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else { errorAlert() }
    }
    
    func errorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Проверьте введенные поля", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ок", style: .destructive, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        showDatePicker()
        
       
        
// ПОПЫТОЧКА
        
        showCategoriesPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categories = []
        incomes = []
        for category in RealmManager.get().getCategoriesFromRealm() {
            if !category.isExpense {
                categories.append(category)
            }
        }
        incomes = RealmManager.get().getIncomesFromRealm()
    }

    func showDatePicker() {
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.sizeToFit()
        dateTextField.inputView = datePicker
    }
    
    func showCategoriesPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(doneCategPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelCategPicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
        categoryPicker.sizeToFit()
        categoryTextField.inputView = categoryPicker
    }
    
    @objc func doneCategPicker() {
        self.view.endEditing(true)
    }
    
    @objc func doneDatePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
   
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func cancelCategPicker() {
        self.view.endEditing(true)
    }
}
    
extension MainIncomesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

}

extension MainIncomesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let result = categories[row].name
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categories[row].name
        self.categId = categories[row].id
    }
}
