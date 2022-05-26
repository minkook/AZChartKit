//
//  AZAutoCounting.swift
//  AZChartKit
//
//  Created by minkook yoo on 2022/05/26.
//

import Foundation

/// durating에 따른 시간 동안 자동으로 count까지 숫자를 0부터 증가시켜준다.
final class AZAutoCounting {
    
    // MARK: - emulate
    public func emulate(count: Int,
                        duration: Double,
                        valueHandler: @escaping (_ countValue: Double) -> Void) {
        self.count = count
        self.duration = duration
        self.valueActionHandler = valueHandler
        start()
    }
    
    
    // MARK: - private
    private var count: Int = 0
    private var duration: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var startDate = Date()
    
    private var valueActionHandler: ((_ countValue: Double) -> Void)?
}

fileprivate extension AZAutoCounting {
    
    func start() {
        startDate = Date()
        let displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink.add(to: .main, forMode: .commonModes)
        self.displayLink = displayLink
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func handleUpdate() {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(startDate)
        
        if elapsedTime > duration {
            stop()
            valueActionHandler?(Double(count))
        } else {
            let percentage = elapsedTime / duration
            let value = percentage * Double(count)
            valueActionHandler?(value)
        }
    }
}
