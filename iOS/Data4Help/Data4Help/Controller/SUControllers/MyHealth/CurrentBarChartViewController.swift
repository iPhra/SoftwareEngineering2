//
//  CurrentBarChartViewController.swift
//  Data4Help
//
//  Created by Virginia Negri on 23/12/2018.
//  Copyright © 2018 Lorenzo Molteni Negri. All rights reserved.
//

import UIKit
import Charts

class CurrentBarChartViewController: UIViewController {
    
    // Mark: Properties

    @IBOutlet weak var barChartCurrentValues: BarChartView!
    
    var dataTypesToShow: [String] = [ dataType.activeEnergyBurned.rawValue,
                                      dataType.bloodPressure.rawValue,
                                      dataType.distanceWalkingRunning.rawValue,
                                      dataType.heartrate.rawValue,
                                      dataType.height.rawValue,
                                      dataType.sleepingHours.rawValue,
                                      dataType.standingHours.rawValue,
                                      dataType.steps.rawValue,
                                      dataType.weight.rawValue]
    
    var currentValues : [Double] = []
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    // Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)

        for dataType in self.dataTypesToShow {
            let current: Double = DataManager.sharedInstance.currentValues[dataType]!
            self.currentValues.append(current)
        }
        
        setCurrentValuesChart(dataEntryX: dataTypesToShow, dataEntryY: self.currentValues )
        
    }
    
    
    func setCurrentValuesChart(dataEntryX forX:[String],dataEntryY: [Double]) {
        
        barChartCurrentValues.noDataText = "You need to provide data for the chart."
        
        var dataEntries:[BarChartDataEntry] = []
        
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: dataEntryY[i], data: forX as AnyObject?)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Current values")
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartCurrentValues.data = chartData
        
        
        barChartCurrentValues.drawGridBackgroundEnabled = false
        barChartCurrentValues.drawBarShadowEnabled = false
        barChartCurrentValues.drawBordersEnabled = false
        
        barChartCurrentValues.leftAxis.enabled = false
        barChartCurrentValues.rightAxis.enabled = false
        
        let xAxisValue = barChartCurrentValues.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartCurrentValues.xAxis.granularityEnabled = true
        barChartCurrentValues.xAxis.granularity = 1.0
        barChartCurrentValues.xAxis.labelPosition = .bottom
        
        barChartCurrentValues.xAxis.labelRotationAngle = -45.0
        
    }
    
    /*Load current values of each dataType to show*/
    func loadData(){
        for dataType in self.dataTypesToShow {
            let current: Double = DataManager.sharedInstance.currentValues[dataType]!
            self.currentValues.append(current)
        }
    }
    
    
    
}

extension CurrentBarChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dataTypesToShow[Int(value)]
    }
}

