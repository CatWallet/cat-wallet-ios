// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Charts

class CoinMarketDetialViewController: UIViewController, ChartViewDelegate{

    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var showPrice: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    var getPricechange = 0.0
    var getName: String?
    var getPrice: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        let data = dataWithCount(36, range: 100)
        let color = UIColor(hex: "5DB1E8")
        data.setValueFont(UIFont(name: "HelveticaNeue", size: 7)!)
        setupChart(chartView, data: data, color: color)
    }
    
    func setUI() {
        if getPricechange > 0 {
            priceChange.textColor = UIColor.blue
            price.textColor = UIColor.blue
        } else {
            priceChange.textColor = UIColor.red
            price.textColor = UIColor.red
        }
        priceChange.text = String(format: "%.3f", getPricechange)
        name.text = getName
        price.text = getPrice
        showPrice.text = R.string.localizable.showPriceLabelText()
    }
    
    func setupChart(_ chart: LineChartView, data: LineChartData, color: UIColor) {
        (data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = color
        chart.backgroundColor = color
        chart.chartDescription?.enabled = false
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        chart.setViewPortOffsets(left: 10, top: 0, right: 10, bottom: 0)
        chart.legend.enabled = false
        chart.leftAxis.enabled = false
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = false
        chart.delegate                  = self
        chart.pinchZoomEnabled          = false
        chart.doubleTapToZoomEnabled    = false
        chart.data = data
        chart.animate(xAxisDuration: 2.5)
    }
    
    func dataWithCount(_ count: Int, range: UInt32) -> LineChartData {
        let yVals = (0..<count).map { i -> ChartDataEntry in
            let val = Double(arc4random_uniform(range)) + 3
            return ChartDataEntry(x: Double(i), y: val)
        }
        let set1 = LineChartDataSet(values: yVals, label: "DataSet 1")
        set1.lineWidth = 1.75
        set1.circleRadius = 5.0
        set1.circleHoleRadius = 2.5
        set1.setColor(.white)
        set1.setCircleColor(.white)
        set1.highlightColor = .white
        set1.drawValuesEnabled = false
        return LineChartData(dataSet: set1)
    }
    
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        showPrice.text = "$" + String(entry.x)
    }
}
