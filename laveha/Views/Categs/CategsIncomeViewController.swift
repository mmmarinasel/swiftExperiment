//
//  CategsIncomeViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 19.11.2020.
//

import UIKit
//import RealmSwift
class CategsIncomeViewController: UIViewController {

    var incomes: [Income] = []
    static var selectedCategoryId: String = ""
    static var selectedCategoryName: String = ""
    var sortedIncomes: [SortedIncs] = []
    
    
    @IBOutlet weak var categNameLabel: UILabel!
    @IBOutlet weak var incByCategsTableView: UITableView!
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func analyticsButton(_ sender: Any) {
        let vc: AnalyticsViewController = AnalyticsViewController()
        self.present(vc, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.incomes = []
        self.incomes = RealmManager.get().getIncomesFromRealm()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        categNameLabel.text = CategsIncomeViewController.selectedCategoryName
        let dates = getCategDates()
        var incs: [Income] = []
        self.incomes = Wallet.get().getIncomesByCategory(CategsIncomeViewController.selectedCategoryId)
        for d in dates {
            incs = []
            for i in self.incomes {
                if d == i.getDate() {
                    incs.append(i)
                }
            }
            if incs.count > 0 {
                self.sortedIncomes.append(SortedIncs(date: d, incomes: incs))
            }
        }
        
        self.incByCategsTableView.reloadData()
    }
    
    func getCategDates() -> [Date] {
        var dates: [Date] = []
        var count: Int = 0
        let sortedIncomesByDate = self.incomes.sorted(by: { $0.getDate().compare($1.getDate()) == .orderedDescending })
        for i in sortedIncomesByDate {
            count = 0
            for d in dates {
                if d == i.getDate() {
                    count += 1
                }
            }
            if count == 0 { dates.append(i.getDate())}
        }
        return dates
    }
    

}

extension CategsIncomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteIncome = self.incomes[indexPath.row]
        
        let deleteButton = UITableViewRowAction(style: .default, title: "Удалить") {_, _ in
            RealmManager.get().removeIncomeFromRealm(income: deleteIncome)
            self.incByCategsTableView.reloadData()
        }
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CategsIncomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedIncomes[section].incomes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = incByCategsTableView.dequeueReusableCell(withIdentifier: "incsCell") as! CategsIncomeTableViewCell
        cell.descriptionLabel.text = sortedIncomes[indexPath.section].incomes[indexPath.row].getDescript()
        cell.amountLabel.text = "\(sortedIncomes[indexPath.section].incomes[indexPath.row].getAmount()) ₽"
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return getCategDates().count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: sortedIncomes[section].date)
    }

}

struct SortedIncs {
    var date: Date
    var incomes: [Income]
}
