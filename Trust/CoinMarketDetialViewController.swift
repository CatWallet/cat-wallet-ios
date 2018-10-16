// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Charts

class CoinMarketDetialViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    var getPricechange = 0.0
    var getName: String?
    var getPrice: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setChartValue()
        // Do any additional setup after loading the view.
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
    }
    
    func setChartValue() {
        let values = (0..<20).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(20)))
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "DataSet 1")
        let data = LineChartData(dataSet: set1)
        (data.getDataSetByIndex(0) as! LineChartDataSet).circleHoleColor = UIColor(red: 89/255, green: 199/255, blue: 250/255, alpha: 1)
        
        chartView.backgroundColor = UIColor(red: 89/255, green: 199/255, blue: 250/255, alpha: 1)
        
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.setViewPortOffsets(left: 10, top: 0, right: 10, bottom: 0)
        
        chartView.legend.enabled = false
        
        chartView.leftAxis.enabled = false
        chartView.leftAxis.spaceTop = 0.4
        chartView.leftAxis.spaceBottom = 0.4
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        self.chartView.data = data
        
        chartView.animate(xAxisDuration: 2.5)
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
