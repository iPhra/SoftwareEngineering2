//
//  AverageBarChartViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 23/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Charts

class AverageBarChartViewController: UIViewController {
    
    // Mark: Properties
    
    var xvals: [String] = []
    
    var othersAverageBPM : [Double] = []
    
    var myAverageBPM : [Double] = []
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    @IBOutlet weak var barChartView: BarChartView!
    
    // Maark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)
                
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                for s in statistics {
                    if(s.observations.count>0){
                        //if let myValue = StorageManager.sharedInstance.getLastDataValue(ofType: "\(s.type.rawValue)"){
                        self.xvals.append(s.type.rawValue)
                        self.othersAverageBPM.append((s.others.first?.avg)!)
                        //self.myAverageBPM.append(myValue)
                        self.myAverageBPM.append((s.observations.first?.avg)!)
                        // }
                    }                    
                }
            }
            else if let error = error {
                print(error)
            }
        }
        
        setChart(dataEntryX: xvals, firstDataEntryY: myAverageBPM, secondDataEntryY: othersAverageBPM)
    }
    
    func setChart(dataEntryX forX:[String],firstDataEntryY: [Double], secondDataEntryY: [Double]) {
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [firstDataEntryY[i], secondDataEntryY[i]] , data: xvals as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Average BPM")
        //chartDataSet.colors = [UIColor(red: 233/255, green: 105/255, blue: 103/255, alpha: 1)]
        chartDataSet.colors = [UIColor(red: 191/255, green: 127/255, blue: 229/255, alpha: 1), UIColor(red: 102/255, green: 148/255, blue: 232/255, alpha: 1)]
        //chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = false
        
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.labelPosition = .bottom
        
    }

}

extension AverageBarChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}

