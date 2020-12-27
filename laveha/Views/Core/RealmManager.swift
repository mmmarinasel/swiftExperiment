//
//  RealmManager.swift
//  laveha
//
//  Created by Марина Селезнева on 17.12.2020.
//

import Foundation
import RealmSwift

class RealmManager {
    
    private static var instance: RealmManager? = nil
    private var realm: Realm? = nil
    
    init() {
        self.realm = try! Realm()
    }
    
    public static func get() -> RealmManager {
        if instance == nil {
            instance = RealmManager()
        }
        return instance!
    }
    
    func getIncomesFromRealm() -> [Income] {
        var realmIncomes: Results<Income>
        var incomes: [Income] = []
        realmIncomes = self.realm!.objects(Income.self)
        for inc in realmIncomes {
            incomes.append(inc)
        }
        return incomes
    }
    
    func getExpensesFromRealm() -> [Expense] {
        var realmExpenses: Results<Expense>
        var expenses: [Expense] = []
        realmExpenses = self.realm!.objects(Expense.self)
        for exp in realmExpenses {
            expenses.append(exp)
        }
        return expenses
    }
    
    func getCategoriesFromRealm() -> [Category] {
        var realmCategories: Results<Category>
        var categories: [Category] = []
        realmCategories = self.realm!.objects(Category.self)
        for category in realmCategories {
            categories.append(category)
        }
        return categories
    }
    
    func addCategoryToRealm(category: Category) {
        try! self.realm!.write {
            self.realm!.add(category)
        }
    }
    
    func addIncomeToRealm(income: Income) {
        try! self.realm!.write {
            self.realm!.add(income)
        }
    }
    
    func addExpenseToRealm(expense: Expense) {
        try! self.realm!.write {
            self.realm!.add(expense)
        }
    }
    
    func removeCategoryFromRealm(category: Category) {
        try! self.realm!.write {
            self.realm!.delete(category)
        }
    }
    
    func removeIncomeFromRealm(income: Income) {
        try! self.realm!.write {
            self.realm!.delete(income)
        }
    }
    
    func removeExpenseFromRealm(expense: Expense) {
        try! self.realm!.write {
            self.realm!.delete(expense)
        }
    }
}
