//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import Lottie

class ErrorViewController: UIViewController {
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var errorAnimationView: Lottie.AnimationView!

    internal var errorMessage: String = "" {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            messageLabel?.text = errorMessage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorAnimationView.animationSpeed = 0.75
        errorAnimationView.loopMode = .loop
        errorAnimationView.animating = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageLabel.text = errorMessage
    }
}
