//
//  UIView+.swift
//  Base
//
//  Created by pineone on 2021/09/02.
//

import UIKit
import RxCocoa

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }

    func roundConers(corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners, radius: radius)
    }

    func roundConers(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners, radius: radius)
        addBorder(mask, borderColor: borderColor, borderWidth: borderWidth)
    }

    private func _round(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }

    func addBottomBorder(height: CGFloat = 1, color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) {
        let bottomBorder = CALayer()

        bottomBorder.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height) // CGRectMake(0.0f, 43.0f, toScrollView.frame.size.width, 1.0f);

        bottomBorder.backgroundColor = color.cgColor
        self.layer.addSublayer(bottomBorder)
    }

    private func addBorder(_ mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            layer.addSublayer(border)
        }
    }

    func addShadow(shadowColor: UIColor, offSet: CGSize = .zero, opacity: Float, shadowRadius: CGFloat) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
    }

    func addGradient(colors: [CGColor], locations: [NSNumber] = [0.0, 1.0]) {
        let gradient = CAGradientLayer()
        gradient.frame.size = self.frame.size
        gradient.colors = colors
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }

    func allLabelLetterSpacing(view: UIView, letterSpacing: Double = -0.4) {
        for insideView in view.subviews {
            if insideView.subviews.count > 0 {
                allLabelLetterSpacing(view: insideView)
            } else if insideView.isKind(of: UILabel.self) {
                let label = (insideView as! UILabel)

                if !label.isPartiallyAttributed {
                    label.setTextSpacingBy(value: letterSpacing)
                } else if let currentAttrString = label.attributedText {
                    let attributedString: NSMutableAttributedString!
                    attributedString = NSMutableAttributedString(attributedString: currentAttrString)
                    attributedString.addAttribute(.kern,
                                                  value: letterSpacing,
                                                  range: NSRange(location: 0, length: attributedString.length))
                    label.attributedText = attributedString
                }
            }
        }
    }
}

extension UIView {
    func rotate(withInterval duration: Double) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        rotation.timingFunction = .init(name: CAMediaTimingFunctionName.linear)
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

extension UIView {
    func deepCopy() -> UIView {
        let archive = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: archive) as! UIView
    }

    func addSubviews(_ views: [UIView]) {
        _ = views.map { self.addSubview($0) }
    }
    
    open func addSubview(_ view: UIView, with block: @escaping () -> Void) {
        self.addSubview(view)
        block()
    }
    
    public func tapGesture() -> ControlEvent<UITapGestureRecognizer> {
        let tapGesture = UITapGestureRecognizer()
        addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        return tapGesture.rx.event
    }
}

extension UIView {
    var realSafeAreaInsetTop: CGFloat {
        return UIApplication.shared.keyWindowInConnectedScenes?.safeAreaInsets.top ?? 0
    }
    var realSafeAreaInsetLeft: CGFloat {
        return UIApplication.shared.keyWindowInConnectedScenes?.safeAreaInsets.left ?? 0
    }
    var realSafeAreaInsetRight: CGFloat {
        return UIApplication.shared.keyWindowInConnectedScenes?.safeAreaInsets.right ?? 0
    }
    var realSafeAreaInsetBottom: CGFloat {
        return UIApplication.shared.keyWindowInConnectedScenes?.safeAreaInsets.bottom ?? 0
    }
}

extension UIView {
    func getSubviewsOf<T: UIView>(view: UIView) -> [T] {
        var subviews = [T]()
        for subview in view.subviews {
            subviews += getSubviewsOf(view: subview) as [T]
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }

    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        return nil
    }
}
