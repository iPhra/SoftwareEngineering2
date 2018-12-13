//
//  MyHealth.swift
//  Data4Help
//
//  Created by Virginia Negri on 02/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Charts
import HealthKit
import CoreData

class MyHealth: UIViewController {
    
    //MARK: Properties
    
    var xvals: [String]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var bubbleChartView: BubbleChartView!
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load all stored data
        /*
        let results = StorageManager.sharedInstance.getAllData(entityName: "Data")
        for data in results{
            print(data.value(forKey: "type") as! String)
            print(data.value(forKey: "timestamp") as! String)
        }*/
        
        //Setup scroll view
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 50)
        
        //Setup charts
        
        axisFormatDelegate = (self as IAxisValueFormatter)
        xvals = ["Min BPM", "Avg BPM","Max BPM"]
        let bpmValues = [70.0, 90.0, 110.0]
        
        setChart(dataEntryX: xvals, dataEntryY: bpmValues)
        
        setChartBubble(dataPoints: xvals, values1: bpmValues, values2: bpmValues, values3: bpmValues, sortIndex: 3)
        
        /*
         let dataManager:DataManager = DataManager()
         dataManager.authorizeHKinApp()
         dataManager.enableBackgroundData(input: HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)*/
        
    }
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: xvals as AnyObject?)
            //print(dataEntry)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Measured BPM")
        //chartDataSet.colors = [UIColor(red: 233/255, green: 105/255, blue: 103/255, alpha: 1)]
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let xAxisValue = barChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartView.xAxis.granularityEnabled = true
        barChartView.xAxis.granularity = 1.0
        barChartView.xAxis.labelPosition = .bottom
        
    }
    
    func setChartBubble(dataPoints: [String], values1: [Double],values2: [Double],values3: [Double],sortIndex:Int) {
        
        var dataEntries1: [BubbleChartDataEntry] = []
        var dataEntries2: [BubbleChartDataEntry] = []
        var dataEntries3: [BubbleChartDataEntry] = []
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values1[i], size: CGFloat(values1[i])*10)
            dataEntries1.append(dataEntry)
        }
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values2[i], size: CGFloat(values2[i])*10)
            dataEntries2.append(dataEntry)
        }
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values3[i], size: CGFloat(values3[i])*10)
            dataEntries3.append(dataEntry)
        }
        
        let chartData1 = BubbleChartDataSet(values: dataEntries1,label: dataPoints[0] )
        
        let chartData2 = BubbleChartDataSet(values: dataEntries2,label: dataPoints[1] )
        
        let chartData3 = BubbleChartDataSet(values: dataEntries3,label: dataPoints[2] )
        
        chartData1.colors =  [UIColor(red: 33/255, green: 150/255, blue: 254/255, alpha: 1)]
        chartData2.colors =  [UIColor(red: 62/255, green: 89/255, blue: 254/255, alpha: 1)]
        chartData3.colors =  [UIColor(red: 255/255, green: 70/255, blue: 48/255, alpha: 1)]
        
        let dataSets: [BubbleChartDataSet] = [chartData1,chartData2,chartData3]
        
        let data = BubbleChartData(dataSets: dataSets)
        bubbleChartView.data = data
        
        let xAxisValue = bubbleChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        bubbleChartView.xAxis.granularityEnabled = true
        bubbleChartView.xAxis.granularity = 1.0
        bubbleChartView.xAxis.labelPosition = .bottom
        
        //bubbleChartView!.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
    }
    
    
    @IBAction func toggleAutomatedSOSON(_ sender: Any) {
        DataManager.sharedInstance.toggleAutomatedSOS();
    }
    
    
}

extension MyHealth: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}

