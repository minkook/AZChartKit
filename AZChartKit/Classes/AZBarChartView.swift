//
//  AZBarChartView.swift
//  AZChartKit
//
//  Created by minkook yoo on 2022/05/25.
//

import Foundation
import UIKit

@IBDesignable
public class AZBarChartView: AZView {
    
    // MARK: - Design
    
    /// 바 가로크기
    @IBInspectable public var barWidth: CGFloat = 20.0
    
    /// 바와 바 사이 간격
    @IBInspectable public var spacing: CGFloat = 30.0
    
    /// 바 상단 corner radius
    @IBInspectable public var barCornerRadius: CGFloat = 4.0
    
    /// 이름에 사용할 높이
    @IBInspectable public var nameLabelHeight: CGFloat = 24.0
    
    /// 이름과 바 사이의 간격
    @IBInspectable public var nameLineSpacing: CGFloat = 6.0
    
    /// 값과 바 사이의 간격
    @IBInspectable public var valueLineSpacing: CGFloat = 5.0
    
    /// 이름 색상
    @IBInspectable public var nameColor: UIColor = .gray
    
    /// 바 색상
    @IBInspectable public var barColor: UIColor = .gray
    
    /// 바 (하이라이트) 색상
    @IBInspectable public var barHighlightColor: UIColor = .blue
    
    /// 값 색상
    @IBInspectable public var valueColor: UIColor = .gray
    
    /// 값 (하이라이트) 색상
    @IBInspectable public var valueHighlightColor: UIColor = .blue
    
    /// 애니메이션 시간
    @IBInspectable public var animationDuration = 0.4
    
    /// 이름 폰트
    public var nameFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    
    /// 값 폰트
    public var valueFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    
    /// 값 (하이라이트) 폰트
    public var valueHighlightFont: UIFont = UIFont.boldSystemFont(ofSize: 15.0)
    
    
    
    // MARK: - Data
    
    public var barValues: [Int] = [20, 52, 14, 9, 3, 0]
    public var barNames: [String] = ["이름1", "이름2", "이름3", "이름4", "이름5", "이름6"]
    
    
    
    // MARK: - Private
    private var maxValue = 0
    private var barLayers = [CAShapeLayer]()
    private var nameLabels = [UILabel]()
    private var valueLabels = [UILabel]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
#if !TARGET_INTERFACE_BUILDER
        setNeedsShowAction = { [weak self] in
            guard let self = self else { return }
            self.show()
        }
#else
        setNeedsShowAction = { [weak self] in
            guard let self = self else { return }
            self.show(false)
        }
#endif
    }
    
    public func show(_ animated: Bool = true) {
        guard availableDatas() else { fatalError("no data equals to count.") }
        guard availableWidth() else { fatalError("no available width.") }
        if !isLayoutLoaded { return }
        
        removeAll()
        
        maxValue = barValues.max() ?? 0
        
        adjustBars()
        adjustNameLabels()
        
        if animated && animationDuration > 0.0 {
            animate()
        }
    }
}

fileprivate extension AZBarChartView {
    
    func availableDatas() -> Bool {
        return barValues.count == barNames.count
    }
    
    func availableWidth() -> Bool {
        return contentWidth() < self.bounds.width
    }
    
    func removeAll() {
        maxValue = 0
        for layer in barLayers {
            layer.removeFromSuperlayer()
        }
        barLayers = [CAShapeLayer]()
        
        for label in nameLabels {
            label.removeFromSuperview()
        }
        nameLabels = [UILabel]()
        
        for label in valueLabels {
            label.removeFromSuperview()
        }
        valueLabels = [UILabel]()
    }
    
    func createBarLayer(_ isHighlight: Bool) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = isHighlight ? barHighlightColor.cgColor : barColor.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.frame = bounds
        return layer
    }
    
    func createBarPath(rect: CGRect) -> UIBezierPath {
        let cornerRadius = CGSize(width: barCornerRadius, height: barCornerRadius)
        return UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: cornerRadius)
    }
    
    func createValueLabel(_ isHighlight: Bool) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = isHighlight ? valueHighlightFont : valueFont
        label.textColor = isHighlight ? valueHighlightColor : valueColor
        return label
    }
    
    func adjustBars() {
        for (index, element) in barValues.enumerated() {
            let isHighlight = element == maxValue
            var rect = barStartRect(index: index)
            let barHeight = barHeight(value: element)
            rect.origin.y -= barHeight
            rect.size.height = barHeight
            
            let layer = createBarLayer(isHighlight)
            let path = createBarPath(rect: rect)
            layer.path = path.cgPath
            self.layer.addSublayer(layer)
            
            self.barLayers.append(layer)
            
            // Value Label
            let valueLabel = createValueLabel(isHighlight)
            self.addSubview(valueLabel)
            
            valueLabel.text = "\(element)%"
            valueLabel.sizeToFit()
            
            let centerX = rect.midX
            let centerY = rect.minY - valueLineSpacing - (valueLabel.bounds.height / 2)
            valueLabel.center = CGPoint(x: centerX, y: centerY)
            self.valueLabels.append(valueLabel)
        }
    }
    
    func createNameLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = nameFont
        label.textColor = nameColor
        return label
    }
    
    func adjustNameLabels() {
        for (index, element) in barNames.enumerated() {
            let label = createNameLabel()
            self.addSubview(label)
            label.text = element
            label.sizeToFit()
            
            let rect = barStartRect(index: index)
            let centerX = rect.midX
            let centerY = rect.maxY + nameLineSpacing + (label.bounds.height / 2)
            label.center = CGPoint(x: centerX, y: centerY)
        }
    }
}

fileprivate extension AZBarChartView {
    
    func contentWidth() -> CGFloat {
        return (barWidth * CGFloat(barValues.count)) + (spacing * CGFloat(barValues.count - 1))
    }
    
    func contentHeight() -> CGFloat {
        return self.bounds.height - nameLabelHeight
    }
    
    func barContentHeight() -> CGFloat {
        return self.bounds.height - nameLabelHeight
    }
    
    func contentLeft() -> CGFloat {
        return (self.bounds.width - contentWidth()) / 2
    }
    
    func barCenterX(_ contentLeft: CGFloat, index: Int) -> CGFloat {
        return contentLeft + (barWidth / 2) + ((barWidth + spacing) * CGFloat(index))
    }
    
    func barStartRect(index: Int) -> CGRect {
        let contentHeight = contentHeight()
        let contentLeft = contentLeft()
        let x = barCenterX(contentLeft, index: index) - (barWidth / 2)
        return CGRect(x: x, y: contentHeight, width: barWidth, height: 0)
    }
    
    func barHeight(value: Int) -> CGFloat {
        return contentHeight() * CGFloat(value) * 0.01
    }
    
    func animate() {
        func pathAnimation() -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = animationDuration
            animation.fillMode = kCAFillModeBoth
            animation.delegate = self
            return animation
        }
        
        for (index, layer) in barLayers.enumerated() {
            let rect = barStartRect(index: index)
            let path = createBarPath(rect: rect)
            
            let animation = pathAnimation()
            animation.fromValue = path.cgPath
            animation.setValue(index, forKey: "INDEX:")
            layer.add(animation, forKey: nil)
            
            let label = valueLabels[index]
            label.alpha = 0.0
        }
    }
}

extension AZBarChartView: CAAnimationDelegate {
    private func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let index = anim.value(forKey: "INDEX:") as? Int, index < valueLabels.count {
            let label = valueLabels[index]
            UIView.animate(withDuration: 0.2) {
                label.alpha = 1.0
            }
        }
    }
}
