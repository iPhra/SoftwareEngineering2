//
//  BubbleChartViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 23/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Charts

class BubbleChartViewController: UIViewController {
    
    // Mark: Properties
    
    @IBOutlet weak var bubbleChartView: BubbleChartView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
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
    
    var min: [String: Double] = [
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
    
    var max: [String: Double] = [
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
    
    var avg: [String: Double] = [
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
    
    // MArk: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)
        
        
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                for s in statistics {
                    if(s.observations.count>0){
                        self.avg.updateValue((s.observations.first?.avg)!, forKey: s.type.rawValue)
                        self.min.updateValue((s.observations.first?.min)!, forKey: s.type.rawValue)
                        self.max.updateValue((s.observations.first?.max)!, forKey: s.type.rawValue)
                    }
                }
                self.setChartBubble(dataPoints: self.xvals, values1: Array(self.min.values), values2: Array(self.avg.values), values3: Array(self.max.values), sortIndex: 3)
            }
            else if let error = error {
                print(error)
            }
        }
        
        self.setChartBubble(dataPoints: self.xvals, values1: Array(self.min.values), values2: Array(self.avg.values), values3: Array(self.max.values), sortIndex: 3)

    }
    
    func setChartBubble(dataPoints: [String], values1: [Double],values2: [Double],values3: [Double],sortIndex:Int) {
        
        var dataEntries1: [BubbleChartDataEntry] = []
        var dataEntries2: [BubbleChartDataEntry] = []
        var dataEntries3: [BubbleChartDataEntry] = []
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values1[i] , size: CGFloat(values1[i]))
            dataEntries1.append(dataEntry)
        }
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values2[i], size: CGFloat(values2[i]))
            dataEntries2.append(dataEntry)
        }
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values3[i], size: CGFloat(values3[i]))
            dataEntries3.append(dataEntry)
        }
        
        if(dataPoints.count > 0){
            
            let chartData1 = BubbleChartDataSet(values: dataEntries1,label: "min" )
            
            let chartData2 = BubbleChartDataSet(values: dataEntries2,label: "avg" )
            
            let chartData3 = BubbleChartDataSet(values: dataEntries3,label: "max" )
            
            chartData1.colors =  [UIColor(red: 33/255, green: 150/255, blue: 254/255, alpha: 1)]
            chartData2.colors =  [UIColor(red: 62/255, green: 89/255, blue: 254/255, alpha: 1)]
            chartData3.colors =  [UIColor(red: 255/255, green: 70/255, blue: 48/255, alpha: 1)]
            
            let dataSets: [BubbleChartDataSet] = [chartData1,chartData2,chartData3]
            
            let data = BubbleChartData(dataSets: dataSets)
            bubbleChartView.data = data
            
           
        }
        
        let xAxisValue = bubbleChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        bubbleChartView.xAxis.granularityEnabled = true
        bubbleChartView.xAxis.granularity = 1.0
        bubbleChartView.xAxis.labelPosition = .bottom
        
        bubbleChartView.scaleXEnabled = false
        bubbleChartView.scaleYEnabled = false
        
        bubbleChartView.xAxis.labelRotationAngle = -45.0
        
        bubbleChartView.xAxis.setLabelCount(10, force: true)
        bubbleChartView!.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
    }
    
    func loadData(){
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                for s in statistics {
                    if(s.observations.count>0){
                        self.avg.updateValue((s.observations.first?.avg)!, forKey: s.type.rawValue)
                        self.min.updateValue((s.observations.first?.min)!, forKey: s.type.rawValue)
                        self.max.updateValue((s.observations.first?.max)!, forKey: s.type.rawValue)
                    }
                }
                self.setChartBubble(dataPoints: self.xvals, values1: Array(self.min.values), values2: Array(self.avg.values), values3: Array(self.max.values), sortIndex: 3)
            }
            else if let error = error {
                print(error)
            }
        }
        
        self.setChartBubble(dataPoints: self.xvals, values1: Array(self.min.values), values2: Array(self.avg.values), values3: Array(self.max.values), sortIndex: 3)
    }
    
    @IBAction func reloadData(_ sender: Any) {
        self.bubbleChartView.clearValues()
        loadData()
        self.bubbleChartView.notifyDataSetChanged()
        self.setChartBubble(dataPoints: self.xvals, values1: Array(self.min.values), values2: Array(self.avg.values), values3: Array(self.max.values), sortIndex: 3)
    }
    
    
    

}

extension BubbleChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}
