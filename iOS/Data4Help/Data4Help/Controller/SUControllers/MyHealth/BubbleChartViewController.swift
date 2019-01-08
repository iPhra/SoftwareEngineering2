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
    
    var countLabels: Int = 0
    
    var xvals : [String] = []
    
    var min : [Double] = []
    var max : [Double] = []
    var avg : [Double] = []
    
    // MArk: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)
        
        
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                var count: Int = 0
                for s in statistics {
                    if(s.observations.count>0){
                        count += 1
                        self.xvals.append(s.type.rawValue)
                        self.avg.append((s.observations.first?.avg ?? 0))
                        self.min.append((s.observations.first?.min ?? 0))
                        self.max.append((s.observations.first?.max ?? 0))
                    }
                }
                self.countLabels = count
                self.setChartBubble(dataPoints: self.xvals, values1: self.min, values2: self.avg, values3: self.max, sortIndex: 3)
            }
            else if let error = error {
                print(error)
            }
        }
        
        self.setChartBubble(dataPoints: self.xvals, values1: self.min, values2: self.avg, values3: self.max, sortIndex: 3)

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
            
            let chartData1 = BubbleChartDataSet(values: dataEntries1,label: dataPoints[0] )
            
            let chartData2 = BubbleChartDataSet(values: dataEntries2,label: dataPoints[1] )
            
            let chartData3 = BubbleChartDataSet(values: dataEntries3,label: dataPoints[2] )
            
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
        
        bubbleChartView.xAxis.setLabelCount(self.countLabels, force: true)
        bubbleChartView!.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
    }
    
    func loadData(){
        NetworkManager.sharedInstance.sendPostRequest(input: D4HStatisticsRequest(types: DataManager.sharedInstance.dataTypesToRead), endpoint: D4HEndpoint.statistics, headers: Properties.auth()) { (response, error) in
            if response != nil {
                let myres: D4HStatisticsResponse = D4HStatisticsResponse(fromJson: response!)
                let statistics: [D4HStatistic] = myres.statistics
                var count: Int = 0
                for s in statistics {
                    if(s.observations.count>0){
                        count += 1
                        self.xvals.append(s.type.rawValue)
                        self.avg.append((s.observations.first?.avg ?? 0))
                        self.min.append((s.observations.first?.min ?? 0))
                        self.max.append((s.observations.first?.max ?? 0))
                    }
                }
                self.countLabels = count
                self.setChartBubble(dataPoints: self.xvals, values1: self.min, values2: self.avg, values3: self.max, sortIndex: 3)
            }
            else if let error = error {
                print(error)
            }
        }
        
        self.setChartBubble(dataPoints: self.xvals, values1: self.min, values2: self.avg, values3: self.max, sortIndex: 3)
    }
    
    @IBAction func reloadData(_ sender: Any) {
        self.bubbleChartView.clearValues()
        loadData()
        self.bubbleChartView.notifyDataSetChanged()
        self.setChartBubble(dataPoints: self.xvals, values1: self.min, values2: self.avg, values3: self.max, sortIndex: 3)
    }
    
    
    

}

extension BubbleChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}
