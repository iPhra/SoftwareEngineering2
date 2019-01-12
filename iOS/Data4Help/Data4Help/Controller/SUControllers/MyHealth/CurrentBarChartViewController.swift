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
                                      dataType.diastolic_pressure.rawValue,
                                      dataType.systolic_pressure.rawValue,
                                      dataType.distanceWalkingRunning.rawValue,
                                      dataType.heartrate.rawValue,
                                      dataType.height.rawValue,
                                      dataType.sleepingHours.rawValue,
                                      dataType.standingHours.rawValue,
                                      dataType.steps.rawValue,
                                      dataType.weight.rawValue]
    
    var currentValues: [String: Double] = [
        dataType.activeEnergyBurned.rawValue : 0,
        dataType.diastolic_pressure.rawValue : 0,
        dataType.systolic_pressure.rawValue : 0,
        dataType.distanceWalkingRunning.rawValue : 0,
        dataType.heartrate.rawValue : 0,
        dataType.height.rawValue : 0,
        dataType.sleepingHours.rawValue : 0,
        dataType.standingHours.rawValue : 0,
        dataType.steps.rawValue : 0,
        dataType.weight.rawValue : 0,
    ]
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    // Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = (self as IAxisValueFormatter)

        
        for dataType in self.dataTypesToShow {
            let current: Double = DataManager.sharedInstance.currentValues[dataType]!
            self.currentValues.updateValue(current, forKey: dataType)
        }
                
        setCurrentValuesChart(dataEntryX: dataTypesToShow, dataEntryY: self.currentValues.map({$0.value}) )
        
    }
    
    
    @IBAction func reloadChart(_ sender: Any) {
        self.barChartCurrentValues.clearValues()
        loadData()
        self.barChartCurrentValues.notifyDataSetChanged()
        setCurrentValuesChart(dataEntryX: dataTypesToShow, dataEntryY: self.currentValues.map({$0.value}) )
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
        
        barChartCurrentValues.scaleXEnabled = false
        barChartCurrentValues.scaleYEnabled = false
        barChartCurrentValues.doubleTapToZoomEnabled = false
        
        barChartCurrentValues.leftAxis.enabled = false
        barChartCurrentValues.rightAxis.enabled = false
        
        let xAxisValue = barChartCurrentValues.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChartCurrentValues.xAxis.granularityEnabled = true
        barChartCurrentValues.xAxis.granularity = 1.0
        barChartCurrentValues.xAxis.labelPosition = .bottom
        
        barChartCurrentValues.xAxis.setLabelCount(10, force: true)
        
        barChartCurrentValues.xAxis.labelRotationAngle = -45.0
        
    }
    
    /*Load current values of each dataType to show*/
    func loadData(){
        
        for dataType in dataTypesToShow {
            let current: Double = DataManager.sharedInstance.currentValues[dataType]!
            self.currentValues.updateValue(current, forKey: dataType)
        }
    }
    
    
    
}

extension CurrentBarChartViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      return dataTypesToShow[Int(value)]
    }
    
    
}

