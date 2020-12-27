//
//  GeneralAnalyticsViewController.swift
//  laveha
//
//  Created by Марина Селезнева on 05.12.2020.
//

import UIKit
import Charts

class GeneralAnalyticsViewController: UIViewController, ChartViewDelegate {
    var incomes: [Income] = []
    var expenses: [Expense] = []
    struct MonthStats{
        var month: Int
        var year: Int
        var incAmount: Double
        var expAmount: Double
    }
    private var monthStats: [MonthStats] = []
    private var chartEntries: [ChartDataEntry] = []
    private var chartLabels: [String] = []
    
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    private func dateExists(_ mS: [MonthStats], _ m: Int, _ y: Int) -> Bool {
        for ms in mS {
            if ms.month == m && ms.year == y {
                return true
            }
        }
        
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.incomes = []
        self.expenses = []
        
        self.incomes = RealmManager.get().getIncomesFromRealm()
        self.incomes  = self.incomes.sorted(by: { $0.getDate().compare($1.getDate()) == .orderedAscending })
        self.expenses = RealmManager.get().getExpensesFromRealm()
        self.expenses  = self.expenses.sorted(by: { $0.getDate().compare($1.getDate()) == .orderedAscending })
        let calendar = Calendar.current
        

        for inc in self.incomes {
            let components = calendar.dateComponents([.day, .month, .year], from: inc.getDate())
            let incMonth = components.month!
            let incYear = components.year!
            if !dateExists(monthStats, incMonth, incYear) {
                monthStats.append(MonthStats(month: incMonth, year: incYear, incAmount: inc.getAmount(), expAmount: 0))
            }
            else {
                for i in 0 ..< monthStats.count {
                    let components = calendar.dateComponents([.day, .month, .year], from: inc.getDate())
                    let incMonth = components.month!
                    let incYear = components.year!
                    if monthStats[i].year != incYear || monthStats[i].month != incMonth {
                        continue
                    }
                    monthStats[i].incAmount += inc.getAmount()
                    break
                }
            }
        }
        
        for exp in self.expenses {
            let components = calendar.dateComponents([.day, .month, .year], from: exp.getDate())
            let incMonth = components.month!
            let incYear = components.year!
            if !dateExists(monthStats, incMonth, incYear) {
                monthStats.append(MonthStats(month: incMonth, year: incYear, incAmount: 0, expAmount: exp.getAmount()))
            }
            else {
                for i in 0 ..< monthStats.count {
                    let components = calendar.dateComponents([.day, .month, .year], from: exp.getDate())
                    let incMonth = components.month!
                    let incYear = components.year!
                    if monthStats[i].year != incYear || monthStats[i].month != incMonth {
                        continue
                    }
                    monthStats[i].expAmount += exp.getAmount()
                    break
                }
            }
        }
        
        var chartDataSets = [BarChartDataSet]()
        
        var labels: [String] = []
        
        var labelsAdded: Bool = false
        
        for i in 0 ..< monthStats.count {
            chartEntries = []
            let label: String = "\(monthStats[i].month)/\(monthStats[i].year)"
            var entry = BarChartDataEntry(x: Double(2 * i), y: monthStats[i].incAmount, data: label)
            
            chartEntries.append(entry)
            chartEntries.append(BarChartDataEntry(x: Double(2 * i + 1), y: monthStats[i].expAmount, data: label))
            
            labels.append(label)
            labels.append(" ")
            let chartDataSet: BarChartDataSet
            chartDataSet = BarChartDataSet(entries: chartEntries)

            chartDataSet.colors = [.blue, .red]
          
            chartDataSets.append(chartDataSet)
            
        }
        let chartData = BarChartData(dataSets: chartDataSets)
       
        barChartView.xAxis.axisMaximum = Double(monthStats.count * 2 + 1)
        barChartView.xAxis.axisMinimum = 0.0
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.animate(yAxisDuration: 1.5, easingOption:.easeInOutQuart)
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.rightAxis.enabled = false

        let incLegend = LegendEntry(label: "Incomes", form: .circle, formSize: CGFloat(10), formLineWidth: CGFloat(10), formLineDashPhase: CGFloat(10), formLineDashLengths: nil, formColor: .blue)
        let expLegend = LegendEntry(label: "Expenses", form: .circle, formSize: CGFloat(10), formLineWidth: CGFloat(10), formLineDashPhase: CGFloat(10), formLineDashLengths: nil, formColor: .red)
        
        barChartView.legend.setCustom(entries: [incLegend, expLegend])
        barChartView.legend.verticalAlignment = .top
        barChartView.legend.horizontalAlignment = .right
        barChartView.data = chartData
    }
    
}

