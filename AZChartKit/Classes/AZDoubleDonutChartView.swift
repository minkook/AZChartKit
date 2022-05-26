//
//  AZDoubleDonutChartView.swift
//  AZChartKit
//
//  Created by minkook yoo on 2022/05/25.
//

import Foundation
import UIKit

@IBDesignable
public class AZDoubleDonutChartView: AZView {
    
    // MARK: - Design
    
    /// 도넛 크기
    @IBInspectable public var donutWidth: CGFloat = 20.0
    
    /// 왼쪽과 오른쪽 사이 간격
    @IBInspectable public var spacing: CGFloat = 2.0
    
    /// 왼쪽 색상
    @IBInspectable public var leftColor: UIColor = .red
    
    /// 오른쪽 색상
    @IBInspectable public var rightColor: UIColor = .blue
    
    /// 애니메이션 시간
    @IBInspectable public var animationDuration: CGFloat = 4.4
    
    /// 값 표시 on/off
    @IBInspectable public var isHiddenValueText: Bool = false
    
    /// 값 표시 글자크기
    @IBInspectable public var valueTextSize: CGFloat = 18.0
    
    /// 값 표시 글자색상
    @IBInspectable public var valueTextColor: UIColor = .black
    
    
    
    // MARK: - Data
    
    @IBInspectable public var leftValue: CGFloat = 62.0
    @IBInspectable public var rightValue: CGFloat = 38.0
    
    
    
    // MARK: - Private
    private let leftLayer = CAShapeLayer()
    private let rightLayer = CAShapeLayer()
    private let valueLabel = UILabel()
    
    private let autoCounting = AZAutoCounting()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        leftLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(leftLayer)

        rightLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(rightLayer)
        
        valueLabel.textAlignment = .center
        self.addSubview(valueLabel)
        
#if !TARGET_INTERFACE_BUILDER
        setNeedsShowAction = { [weak self] in
            guard let self = self else { return }
            self.show()
        }
#else
        setNeedsShowAction = { [weak self] in
            guard let self = self else { return }
            self.show(false)
            self.valueLabel.text = "\(Int(self.leftValue))/\(Int(self.rightValue))"
        }
#endif
        
    }
    
    public func show(_ animated: Bool = true) {
        if !isLayoutLoaded { return }
        
        adjustLeft()
        adjustRight()
        adjustValueLabel()
        
        if animated && animationDuration > 0.0 {
            animate()
        }
    }
}

fileprivate extension AZDoubleDonutChartView {
    
    func adjustLeft() {
        let radius = radius()
        let center = centerPoint()
        let startAngle = startAngle(clockwise: false)
        let endAngle = endAngle(clockwise: false, value: leftValue)
        
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        leftLayer.path = path.cgPath
        leftLayer.lineWidth = donutWidth
        leftLayer.strokeColor = leftColor.cgColor
        leftLayer.frame = bounds
    }
    
    func adjustRight() {
        let radius = radius()
        let center = centerPoint()
        let startAngle = startAngle(clockwise: true)
        let endAngle = endAngle(clockwise: true, value: rightValue)
        
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        rightLayer.path = path.cgPath
        rightLayer.lineWidth = donutWidth
        rightLayer.strokeColor = rightColor.cgColor
        rightLayer.frame = bounds
    }
    
    func adjustValueLabel() {
        valueLabel.frame = bounds
        valueLabel.isHidden = isHiddenValueText
        valueLabel.font = UIFont.boldSystemFont(ofSize: valueTextSize)
        valueLabel.textColor = valueTextColor
    }
}

fileprivate extension AZDoubleDonutChartView {
    
    func centerPoint() -> CGPoint {
        return CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    func radius() -> CGFloat {
        return (min(self.bounds.width, self.bounds.height) - donutWidth) / 2
    }
    
    func startAngle(clockwise: Bool) -> CGFloat {
        let spacingAngle = spacingAngle()
        let defaultAngle = clockwise ? (270.0 + spacingAngle) : (270.0 - spacingAngle)
        return defaultAngle * Double.pi / 180.0
    }
    
    func endAngle(clockwise: Bool, value: CGFloat) -> CGFloat {
        let percent = clockwise ? value : (100.0 - value)
        let v = 360.0 * percent * 0.01
        let spacingAngle = spacingAngle()
        let defaultAngle = !clockwise ? (270.0 + spacingAngle) : (270.0 - spacingAngle)
        return (defaultAngle + v) * Double.pi / 180.0
    }
    
    func spacingAngle() -> CGFloat {
        let radius = radius()
        let cos = (pow(radius, 2) + pow(radius, 2) - pow(spacing, 2)) / (2 * radius * radius)
        return acos(cos) * 180.0 / Double.pi
    }
    
    func animate() {
        
        func strokeEndAnimation() -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = animationDuration
            return animation
        }
        
        let leftAnimation = strokeEndAnimation()
        leftLayer.add(leftAnimation, forKey: nil)
        
        let rightAnimation = strokeEndAnimation()
        rightLayer.add(rightAnimation, forKey: nil)
        
        autoCounting.emulate(count: Int(leftValue), duration: animationDuration) { [weak self] countValue in
            guard let self = self else { return }
            let rightValue = self.rightValue * countValue / self.leftValue
            self.valueLabel.text = "\(Int(countValue))/\(Int(rightValue))"
        }
    }
}
