//
//  Wallet.swift
//  laveha
//
//  Created by Марина Селезнева on 16.10.2020.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var isExpense: Bool = false
    init(id: String, name: String, isExpense: Bool) {
        self.id = id
        self.name = name
        self.isExpense = isExpense
    }
    
    override required init() {
        
    }
    
}
class Organizer {
    
    private static var instance: Organizer? = nil
    private var categories: [Category] = []
    
    // singleton
    //internal required override init() {}
    
    public static func get() -> Organizer {
        if instance == nil {
            instance = Organizer()
        }
        return instance!
    }
    
    
    
    public func getCategories() -> [Category] {
        return self.categories
    }
    
    public func addCategory(category: Category) {
        self.categories.append(category)
    }
    
    public func removeCategory(id: String) {
        guard self.categoryExists(id: id) else {
            return
        }
        
        var searchIndex = 0
        for i in 0...categories.count {
            if categories[i].id == id {
                searchIndex = i
            }
        }
        
        self.categories.remove(at: searchIndex)
        
    }

    public func categoryExists(id: String) -> Bool {
        if self.getCategoryById(id: id) != nil {
            return true
        }
        else { return false }
    }
    
    public func getCategoryById(id: String) -> Category? {
        var searchIndex: Int = -1
        
        for i in 0...categories.count {
            if categories[i].id == id {
                searchIndex = i
            }
        }
        
        if searchIndex != -1 {
            return categories[searchIndex]
        }
        else {
            return nil
        }
    }
    
    public func updateCategoryName(id: String, name: String) {
        guard self.categoryExists(id: id) else {
            return
        }
        for i in 0...categories.count {
            if categories[i].id == id {
                self.categories[i].name = name
                return
            }
        }
    
    }
    
    public func addDefaultCategs() {
        let realm = try! Realm()
        var categ: Category
        categ = Category(id: UUID().uuidString, name: "Зарплата", isExpense: false)

        try! realm.write {
            realm.add(categ)
        }
        categ = Category(id: UUID().uuidString, name: "Инвестиционный доход", isExpense: false)

        try! realm.write {
            realm.add(categ)
        }
        categ = Category(id: UUID().uuidString, name: "Вклады", isExpense: false)

        try! realm.write {
            realm.add(categ)
        }
        categ = Category(id: UUID().uuidString, name: "Подарки", isExpense: false)

        try! realm.write {
            realm.add(categ)
        }
        
        categ = Category(id: UUID().uuidString, name: "Продукты", isExpense: true)

        try! realm.write {
            realm.add(categ)
        }
        
        categ = Category(id: UUID().uuidString, name: "Рестораны и кафе", isExpense: true)

        try! realm.write {
            realm.add(categ)
        }
        
        categ = Category(id: UUID().uuidString, name: "Здоровье", isExpense: true)

        try! realm.write {
            realm.add(categ)
        }
        
        categ = Category(id: UUID().uuidString, name: "Транспорт", isExpense: true)

        try! realm.write {
            realm.add(categ)
        }
        
        categ = Category(id: UUID().uuidString, name: "Отдых и развлечения", isExpense: true)

        try! realm.write {
            realm.add(categ)
        }
        
    }
}
    
    
    


class Wallet {
    
    private static var instance: Wallet? = nil
    
    public static func get() -> Wallet {
        if instance == nil {
            instance = Wallet()
        }
        else { instance!.loadRealm() }
        return instance!
        
    }
    
    var incomes: [Income] = []
    var expenses: [Expense] = []
    init(incomes: [Income], expenses: [Expense]) {
        self.incomes = incomes
        self.expenses = expenses
    }
    
    func loadRealm() {
        let realm = try! Realm()
        let inc = realm.objects(Income.self)
        let exp = realm.objects(Expense.self)
        
        
        self.incomes = []
        self.expenses = []
        for income in inc {
            self.incomes.append(Income(descript: income.getDescript(), category: income.getCategory(), amount: income.getAmount(), date: income.getDate(), loadedFromRealm: true))
        }
        for expense in exp {
            self.expenses.append(Expense(descript: expense.getDescript(), category: expense.getCategory(), amount: expense.getAmount(), date: expense.getDate(), loadedFromRealm: true))
        }
    }
    
    init() {
        loadRealm()
    }
    
    struct ByCategory {
        var date: Date
        var summ: Double
    }
    
    struct ByDate {
        var date: Date
        var summ: Double
        var category: Int
    }
    
    struct Result {
        var incs: [Income]
        var exps: [Expense]
    }
    
    public func addExpense(expense: Expense) {
        expenses.append(expense)
    }
    
    public func addIncome(income: Income) {
        incomes.append(income)
    }
    
    public func getBalance() -> Double {
        var summ: Double = 0
        for income in incomes {
            summ += income.getAmount()
        }
        for expense in expenses {
            summ -= expense.getAmount()
        }
        return summ
    }
    
    public func getExpensesByCategory(_ category: String) -> [Expense] {
        var expList: [Expense] = []
        for expense in self.expenses {
            if expense.getCategory() == category {
                expList.append(expense)
            }
        }
        return expList
    }
    
    public func getExpensesByCategory(_ categories: [String]) -> [Expense] {
        var expList: [Expense] = []
        for cat in categories {
            expList.append(contentsOf: getExpensesByCategory(cat))
        }
        return expList
    }
    
    public func getStatistics(category: String) -> Result {
        var result = Result(incs: [], exps: [])
        //let date = Date()
    
        for income in self.incomes {
            if income.getCategory() == category {
                result.incs.append(income)
            }
        }
        for expense in self.expenses {
            if expense.getCategory() == category {
                result.exps.append(expense)
            }
        }
        return result
    }
    
    public func getStatistics(date: Date) -> Result {
        var result = Result(incs: [], exps: [])
        var startDay = Calendar.current.startOfDay(for: date)
        
        for income in self.incomes {
            if startDay.compare(Calendar.current.startOfDay(for: income.getDate())) == ComparisonResult.orderedSame {
                result.incs.append(income)
            }
        }
        
        for expense in self.expenses {
            if startDay.compare(Calendar.current.startOfDay(for: expense.getDate())) == ComparisonResult.orderedSame {
                result.exps.append(expense)
            }
        }
        return result
    }
    
    public func getStatistics(dstart: Date, dend: Date) -> Result {
        var result = Result(incs: [], exps: [])
        var startDay = Calendar.current.startOfDay(for: dstart)
        var endDay = Calendar.current.startOfDay(for: dend)
        
        while   Calendar.current.compare(startDay, to: dend, toGranularity: .day) == .orderedAscending ||
                Calendar.current.compare(startDay, to: dend, toGranularity: .day) == .orderedSame {
            var res: Result
            res = self.getStatistics(date: startDay)
            
            for day in res.incs {
                result.incs.append(day)
            }
            
            for day in res.exps {
                result.exps.append(day)
            }
            
            startDay = Calendar.current.date(byAdding: .day, value: 1, to: startDay)!
        }
        return result
    }
    
    public func getIncomesByCategory(_ category: String) -> [Income] {
        var incList: [Income] = []
        for income in self.incomes {
            if income.getCategory() == category {
                incList.append(income)
            }
        }
        return incList
    }

    public func getIncomesByCategories(_ categories: [String]) -> [Income] {

        var incList: [Income] = []
        for cat in categories {
            incList.append(contentsOf: getIncomesByCategory(cat))
        }
        return incList
    }

}

class Transaction: Object {
    
    @objc dynamic private var date: Date
    @objc dynamic private var inputTime: TimeInterval
    @objc dynamic private var amount: Double
    @objc dynamic private var currency: Int
    @objc dynamic private var category: String
    @objc dynamic internal var descript: String
    var loadedFromRealm: Bool = false
    init(descript: String, category: String, amount: Double, date: Date, loadedFromRealm: Bool) {
        self.descript = descript
        self.category = category
        self.amount = amount
        self.date = date
        self.loadedFromRealm = loadedFromRealm
        
        self.inputTime = 0
        self.currency = 640
    }
    
    init(amount: Double, category: String) {
        self.amount = amount
        self.category = category
        
        self.date = NSDate.now
        self.inputTime = 0
        self.currency = 640
        self.descript = ""
        
    }
    
    override required init() {
        //fatalError("init() has not been implemented")
        self.date = Date()
        self.inputTime = 0
        self.amount = 0
        self.currency = 640
        self.category = ""
        self.descript = ""
    }
    
    public func getAmount() -> Double {
        return self.amount
    }
    
    public func getCategory() -> String {
        return self.category
    }
    
    public func getDescript() -> String {
        return self.descript
    }
    
    public func getDate() -> Date {
        return self.date
    }
    
}

class Income: Transaction {
    
}

class Expense: Transaction {
    
}

