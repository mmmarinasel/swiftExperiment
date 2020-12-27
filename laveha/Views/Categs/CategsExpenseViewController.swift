//
//  CategsExpenseViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 03.12.2020.
//

import UIKit

class CategsExpenseViewController: UIViewController {

    var expenses: [Expense] = []
    static var selectedCategoryId: String = ""
    static var selectedCategoryName: String = ""
    var sortedExpenses: [SortedExps] = []
    
    @IBOutlet weak var expByCategsTableView: UITableView!
    @IBOutlet weak var categNameLabel: UILabel!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func analyticsButton(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.expenses = []
        self.expenses = RealmManager.get().getExpensesFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categNameLabel.text = CategsExpenseViewController.selectedCategoryName
        let dates = getCategDates()
        var exps: [Expense] = []
        self.expenses = Wallet.get().getExpensesByCategory(CategsExpenseViewController.selectedCategoryId)
        for d in dates {
            exps = []
            for exp in self.expenses {
                if d == exp.getDate() {
                    exps.append(exp)
                }
            }
            if exps.count > 0 {
                self.sortedExpenses.append(SortedExps(date: d, expenses: exps))
            }
        }
        
        self.expByCategsTableView.reloadData()
    }
    
    func getCategDates() -> [Date] {
        var dates: [Date] = []
        var count: Int = 0
        let sortedExpensesByDate = self.expenses.sorted(by: { $0.getDate().compare($1.getDate()) == .orderedDescending })
        for exp in sortedExpensesByDate {
            count = 0
            for d in dates {
                if d == exp.getDate() {
                    count += 1
                }
            }
            if count == 0 { dates.append(exp.getDate())}
        }
        return dates
    }

}

extension CategsExpenseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteExpense = self.expenses[indexPath.row]
        
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") {_, _ in
            RealmManager.get().removeExpenseFromRealm(expense: deleteExpense)
            self.expByCategsTableView.reloadData()
        }
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CategsExpenseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedExpenses[section].expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expByCategsTableView.dequeueReusableCell(withIdentifier: "expsCell") as! CategsExpenseTableViewCell
        cell.descriptionLabel.text = sortedExpenses[indexPath.section].expenses[indexPath.row].getDescript()
        cell.amountLabel.text = "\(sortedExpenses[indexPath.section].expenses[indexPath.row].getAmount()) ₽"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getCategDates().count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: sortedExpenses[section].date)
    }
    
}

struct SortedExps {
    var date: Date
    var expenses: [Expense]
}
