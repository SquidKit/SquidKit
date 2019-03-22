//
//  ProgressBar.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/22/19.
//  Copyright © 2019 Squid Store, LLC. All rights reserved.
//

import UIKit

open class ProgressBar: UIView {

    public enum Style: Int {
        case round
        case flat
    }
    
    public enum Direction: Int {
        case horizontal
        case vertical
    }
    
    open var style: Style = .round
    open var direction: Direction = .horizontal
    
    @IBInspectable open var styleAdapter: Int {
        get {
            return style.rawValue
        }
        set {
            style = Style(rawValue: newValue) ?? .round
        }
    }
    
    @IBInspectable open var directionAdapter: Int {
        get {
            return direction.rawValue
        }
        set {
            direction = Direction(rawValue: newValue) ?? .horizontal
        }
    }
    
    @IBInspectable open var startColor: UIColor = .blue {
        didSet {
            updateLayout()
        }
    }
    @IBInspectable open var endColor: UIColor = .red {
        didSet {
            updateLayout()
        }
    }
    @IBInspectable open var borderColor: UIColor? {
        didSet {
            updateLayout()
        }
    }
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            updateLayout()
        }
    }
    @IBInspectable open var value: CGFloat = 0 {
        didSet {
            value = max(0, value)
            value = min(value, 1)
            updateGradientStops()
        }
    }
    
    private var gradientLayer: CAGradientLayer?
    
    open override func awakeFromNib() {
        updateLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        switch style {
        case .round:
            layer.cornerRadius = direction == .horizontal ? bounds.height / 2 : bounds.width / 2
            layer.masksToBounds = true
        case .flat:
            layer.cornerRadius = 0
            layer.masksToBounds = true
        }
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        applyGradient()
    }

    private func applyGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = [startColor.cgColor, endColor.cgColor, backgroundColor?.cgColor ?? UIColor.white.cgColor]
        
        let startX: CGFloat = direction == .horizontal ? 0.0 : 0.5
        let startY: CGFloat = direction == .horizontal ? 0.5 : 0.0
        let endX: CGFloat = direction == .horizontal ? 1.0 : 0.5
        let endY: CGFloat = direction == .horizontal ? 0.5 : 1.0
        gradientLayer?.startPoint = CGPoint(x: startX, y: startY)
        gradientLayer?.endPoint = CGPoint(x: endX, y: endY)
        if direction == .vertical {
            gradientLayer?.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        }
        
        layer.insertSublayer(gradientLayer!, at: 0)
        
        updateGradientStops()
    }
    
    private func updateGradientStops() {
        let currentValue = NSNumber(value: Double(value))
        gradientLayer?.locations = [0.0, currentValue, currentValue, 1.0]
    }
}
