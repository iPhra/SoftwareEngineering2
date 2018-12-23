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
    
    var xvals: [String]!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    // MArk: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)
        xvals = ["Min BPM", "Avg BPM","Max BPM"]
        let myAverageBPM = [70.0, 90.0, 110.0]
        let othersAverageBPM = [90.0, 100.0, 120.0]
        
        setChartBubble(dataPoints: xvals, values1: myAverageBPM, values2: myAverageBPM, values3: myAverageBPM, sortIndex: 3)

        // Do any additional setup after loading the view.
    }
    
    func setChartBubble(dataPoints: [String], values1: [Double],values2: [Double],values3: [Double],sortIndex:Int) {
        
        var dataEntries1: [BubbleChartDataEntry] = []
        var dataEntries2: [BubbleChartDataEntry] = []
        var dataEntries3: [BubbleChartDataEntry] = []
        
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BubbleChartDataEntry(x: Double(i), y: values1[i] , size: CGFloat(values1[i])*10)
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
    
    

}

extension BubbleChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xvals[Int(value)]
    }
}
