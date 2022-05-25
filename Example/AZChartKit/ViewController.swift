//
//  ViewController.swift
//  AZChartKit
//
//  Created by minkook on 05/25/2022.
//  Copyright (c) 2022 minkook. All rights reserved.
//

import UIKit
import AZChartKit

class ViewController: UIViewController {
    
    @IBOutlet weak var doubleDonutChartView: AZDoubleDonutChartView!
    @IBOutlet weak var barChartView: AZBarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configDoubleDonutChartView()
        configBarChartView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - DoubleDonut Chart
    func configDoubleDonutChartView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.doubleDonutChartView.leftValue = 22
            self.doubleDonutChartView.rightValue = 78
            self.doubleDonutChartView.show()
        }
    }
    
    // MARK: - Bar Chart
    func configBarChartView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.barChartView.barValues = [7, 17, 53, 10, 2, 11]
            self.barChartView.show()
        }
    }
}

