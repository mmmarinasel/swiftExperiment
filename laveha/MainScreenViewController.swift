//
//  MainScreenViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 14.10.2020.
//

import UIKit
//import RealmSwift

class MainScreenViewController: UIViewController {
    
    var transaction: [Transaction] = []
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerIncomesView: UIView!
    @IBOutlet weak var containerExpensesView: UIView!
    
    @IBAction func plusButton(_ sender: Any) {
        let offsetInc = CGPoint(x: -mainView.frame.maxX, y: 0)
        let offsetExp = CGPoint(x: mainView.frame.maxX, y: 0)
        let x: CGFloat = 0, y: CGFloat = 0
        containerIncomesView.transform = CGAffineTransform(translationX: offsetInc.x + x, y: offsetInc.y + y)
        containerExpensesView.transform = CGAffineTransform(translationX: offsetExp.x + x, y: offsetExp.y + y)
        containerIncomesView.isHidden = false
        containerExpensesView.isHidden = false
        UIView.animate(
            withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.74, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                self.containerIncomesView.transform = .identity
                self.containerExpensesView.transform = .identity
                self.containerIncomesView.alpha = 1
                self.containerExpensesView.alpha = 1
        })
    }
    
    @IBAction func incomesButton(_ sender: Any) {
        
    }
    
    @IBAction func expensesButton(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        transaction = []
        for income in RealmManager.get().getIncomesFromRealm() {
            transaction.append(income)
        }
        
        for expense in RealmManager.get().getExpensesFromRealm() {
            transaction.append(expense)
        }

        self.tableView.reloadData()
        balanceLabel.text = "\(Wallet.get().getBalance()) ₽"
        
    }
   


}

extension MainScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MainScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transaction.count > 0 {
            return transaction.count
        }
        return 0
        //else { return 2}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "mainScreenCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MainScreenTableViewCell
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        var date = formatter.string(from: transaction[indexPath.row].getDate())
        cell.descriptionLabel.text = transaction[indexPath.row].getDescript()
        cell.amountLabel.text = "\(transaction[indexPath.row].getAmount()) ₽"
        cell.dateLabel.text = date
        if transaction[indexPath.row] is Income {
            cell.isExpenseImage.image = UIImage(named: "plus")
        }
        else { cell.isExpenseImage.image = UIImage(named: "minus")}
        return cell
    }
    
}

