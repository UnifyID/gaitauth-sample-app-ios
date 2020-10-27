//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import Lottie
import GaitAuth

@IBDesignable
class TestingViewController: UIViewController {
    unowned var manager: ModelTester = unifyid

    // MARK: - IB Properties

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var startTestButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var endTestButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.25
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func startTest() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager.startAuthenticator()
        refresh()
    }

    @IBAction func getStatus() {
        manager.getAuthenticatorStatus { [weak self] _ in
            guard let self = self else { return }
            self.refresh()
        }
    }

    @IBAction func endTest() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager.getAuthenticatorStatus { [weak self] result in
            guard let self = self else { return }
            self.manager.stopAuthenticator()
            self.manager.presentAuthenticationResult(result)
            self.refresh()
        }
    }

    private func refresh() {
        dispatchPrecondition(condition: .onQueue(.main))
        startTestButton.isHidden = manager.isAuthenticatorActive
        startTestButton.setTitle(!manager.isAuthenticatorActive ? "Start Test" : "Get Status", for: .normal)
        statusButton.isHidden = !manager.isAuthenticatorActive
        countLabel.text = manager.lastAuthenticatorResult?.status.description ?? "unknown"
        endTestButton.isHidden = !manager.isAuthenticatorActive
        animationView.animating = manager.isAuthenticatorActive
    }
}
