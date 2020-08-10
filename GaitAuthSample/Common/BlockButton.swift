//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

@IBDesignable
class BlockButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialize()
    }

    private func didInitialize() {}

    @IBInspectable private var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable private var normalBackgroundColor: UIColor = .clear {
        didSet {
            setBackgroundImage(imageWithColor(color: normalBackgroundColor), for: .normal)
        }
    }

    @IBInspectable private var disabledBackgroundColor: UIColor = .clear {
        didSet {
            setBackgroundImage(imageWithColor(color: disabledBackgroundColor), for: .disabled)
        }
    }

    @IBInspectable private var disabledTextColor: UIColor = ColorCompatibility.tertiaryLabel {
        didSet {
            setTitleColor(disabledTextColor, for: .disabled)
        }
    }

    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}
