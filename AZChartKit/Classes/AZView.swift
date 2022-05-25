//
//  AZView.swift
//  AZChartKit
//
//  Created by minkook yoo on 2022/05/25.
//

import Foundation

public class AZView: UIView {
    public var isLayoutLoaded: Bool { __isLayoutLoaded }
    public var setNeedsShowAction: (() -> Void)? = nil
    
    private var __isLayoutLoaded = false
    
    open override func layoutSubviews() {
        __isLayoutLoaded = true
        if let action = setNeedsShowAction {
            action()
            setNeedsShowAction = nil
        }
    }
}
