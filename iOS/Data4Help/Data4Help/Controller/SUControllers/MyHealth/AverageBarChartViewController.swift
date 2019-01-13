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
    
    var xvals: [String] = [ dataType.heartrate.rawValue,
                            dataType.activeEnergyBurned.rawValue,
                            dataType.diastolic_pressure.rawValue,
                            dataType.systolic_pressure.rawValue,
                            dataType.distanceWalkingRunning.rawValue,
                            dataType.height.rawValue,
                            dataType.sleepingHours.rawValue,
                            dataType.standingHours.rawValue,
                            dataType.steps.rawValue,
                            dataType.weight.rawValue]
    
    var myAverageBPM: [String: Double] = [
        dataType.heartrate.rawValue : 0,
        dataType.activeEnergyBurned.rawValue : 0,
        dataType.diastolic_pressure.rawValue : 0,
        dataType.systolic_pressure.rawValue : 0,
        dataType.distanceWalkingRunning.rawValue : 0,
        dataType.height.rawValue : 0,
        dataType.sleepingHours.rawValue : 0,
        dataType.standingHours.rawValue : 0,
        dataType.steps.rawValue : 0,
        dataType.weight.rawValue : 0,
        ]
    
    var othersAverageBPM: [String: Double] = [
        dataType.heartrate.rawValue : 0,
        dataType.activeEnergyBurned.rawValue : 0,
        dataType.diastolic_pressure.rawValue : 0,
        dataType.systolic_pressure.rawValue : 0,
        dataType.distanceWalkingRunning.rawValue : 0,
        dataType.height.rawValue : 0,
        dataType.sleepingHours.rawValue : 0,
        dataType.standingHours.rawValue : 0,
        dataType.steps.rawValue : 0,
        dataType.weight.rawValue : 0,
        ]
    
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
                var count : Int = 0
                for s in statistics {
                    if(s.observations.count>0){
                        count += 1
                        self.othersAverageBPM.updateValue((s.others.first?.avg)!, forKey: s.type.rawValue)
                        self.myAverageBPM.updateValue((s.observations.first?.avg)!, forKey: s.type.rawValue)
                    }                    
                }
                self.setChart(dataEntryX: self.xvals, firstDataEntryY: Array(self.myAverageBPM.values), secondDataEntryY: Array(self.othersAverageBPM.values))
            }
            else if let error = error {
                print(error)
            }
        }
        self.setChart(dataEntryX: self.xvals, firstDataEntryY: Array(self.myAverageBPM.values), secondDataEntryY: Array(self.othersAverageBPM.values))
        
    }
    
    func setChart(dataEntryX forX:[String],firstDataEntryY: [Double], secondDataEntryY: [Double]) {
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [firstDataEntryY[i], secondDataEntryY[i]] , data: xvals as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "My Average values")
        //chartDataSet.colors = [UIColor(red: 233/255, green: 105/255, blue: 103/255, alpha: 1)]
        chartDataSet.colors = [UIColor(red: 191/255, green: 127/255, blue: 229/255, alpha: 1), UIColor(red: 102/255, green: 148/255, blue: 232/255, alpha: 1)]
        //chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = false
        
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.doubleTapToZoomEnabled = false
                
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
 
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.labelPosition = .bottom
        
        barChartView.xAxis.setLabelCount(10, force: true)
        
        barChartView.xAxis.labelRotationAngle = -45.0
        
    }
    
    func loadData(){
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                for s in statistics {
                    if(s.observations.count>0){
                        self.othersAverageBPM.updateValue((s.others.first?.avg)!, forKey: s.type.rawValue)
                        self.myAverageBPM.updateValue((s.observations.first?.avg)!, forKey: s.type.rawValue)
                    }
                }
                self.setChart(dataEntryX: self.xvals, firstDataEntryY: Array(self.myAverageBPM.values), secondDataEntryY: Array(self.othersAverageBPM.values))
            }
            else if let error = error {
                print(error)
            }
        }
        self.setChart(dataEntryX: self.xvals, firstDataEntryY: Array(self.myAverageBPM.values), secondDataEntryY: Array(self.othersAverageBPM.values))
    }
    
    @IBAction func reloadData(_ sender: Any) {
        self.barChartView.clearValues()
        loadData()
        self.barChartView.notifyDataSetChanged()
        self.setChart(dataEntryX: self.xvals, firstDataEntryY: Array(self.myAverageBPM.values), secondDataEntryY: Array(self.othersAverageBPM.values))
    }
    

}

extension AverageBarChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}

