//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

open class EmbeddingViewController: UIViewController {
    @IBOutlet private var containerView: UIView!

    override open func viewDidLoad() {
        super.viewDidLoad()

        // if the container view is not set up in IB, initialize it here
        if containerView == nil {
            containerView = view
        }
    }

    var embeddedVC: UIViewController? {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            if let old = oldValue {
                old.willMove(toParent: nil)
                old.view.removeFromSuperview()
                old.removeFromParent()
            }
            guard let controller = self.embeddedVC else {
                return
            }
            self.addChild(controller)
            self.containerView.addSubview(controller.view)
            controller.view.frame = self.containerView.bounds
            controller.view.backgroundColor = UIColor.clear
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controller.didMove(toParent: self)
            title = controller.title
        }
    }
}
