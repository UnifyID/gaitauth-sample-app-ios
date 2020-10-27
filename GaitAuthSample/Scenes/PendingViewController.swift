//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import UIKit
import Lottie

class PendingViewController: UIViewController {
    @IBOutlet weak var networkAnimation: AnimationView!
    @IBOutlet weak var refreshAnimation: AnimationView!
    @IBOutlet weak var spinnerContainerView: UIView!
    @IBOutlet weak var refreshedLabel: UILabel!
    @IBOutlet weak var refreshButton: BlockButton!

    unowned var delegate: ModelRefresher = unifyid

    lazy private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    var refreshDate: Date? = nil {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            guard let date = refreshDate else {
                refreshedLabel.text = "Refreshed:\nUnknown"
                return
            }
            refreshedLabel.text = "Refreshed:\n\(dateFormatter.string(from: date))"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        networkAnimation.animating = true
        networkAnimation.loopMode = .loop

        spinnerContainerView.isHidden = true
        refreshAnimation.stop()

        refreshDate = nil

        NotificationCenter.default.addObserver(
            for: ModelDidRefreshNotification.self,
            queue: OperationQueue.main
        ) { notification in
            self.refreshDate = notification.date

            UIView.animate(
                withDuration: 0.10,
                animations: {
                    self.spinnerContainerView.isHidden = true
                    self.refreshedLabel.isHidden = false
                    self.refreshButton.isEnabled = true
                },
                completion: { _ in
                    self.refreshAnimation.stop()
                }
            )
        }
    }

    @IBAction private func refreshPressed() {
        UIView.animate(
            withDuration: 0.10,
            animations: {
                self.spinnerContainerView.isHidden = false
                self.refreshedLabel.isHidden = true
                self.refreshButton.isEnabled = false
            },
            completion: { _ in
                self.refreshAnimation.play()
            }
        )
        delegate.refreshModel()
    }
}
