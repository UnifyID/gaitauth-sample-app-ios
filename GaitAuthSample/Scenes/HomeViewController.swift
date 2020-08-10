//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import UIKit
import GaitAuth

class HomeViewController: EmbeddingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        unifyid.interactor = self
        modelStatusDidChange(unifyid.model?.status)

        NotificationCenter.default.addObserver(
            for: ActiveModelDidChangeNotification.self,
            queue: .main,
            using: modelDidChange
        )
        NotificationCenter.default.addObserver(
            for: DidResetModelNotification.self,
            queue: .main,
            using: modelDidReset
        )
    }

    private func modelDidChange(_ notification: ActiveModelDidChangeNotification) {
        modelStatusDidChange(notification.status)
    }

    private func modelDidReset(_ notification: DidResetModelNotification) {
        showSelectModelVC()
    }

    private func modelStatusDidChange(_ status: GaitModel.Status?) {
        guard let status = status else {
            showSelectModelVC()
            return
        }
        switch status {
        case .created:
            showTrainingVC()
        case .training:
            showPendingVC()
        case .ready:
            showTestingVC()
        case .failed(let reason):
            presentTerminalError(message: reason ?? "unknown failure")
        }
    }

    @IBAction private func resetButtonPressed() {
        presentConfirmation(
            title: "Reset",
            message: "Are you sure you would like to reset your model? " +
                " The training process will be restarted and all progress will be lost.",
            actionTitle: "Reset"
        ) { confirmed in
            guard confirmed else { return }
            unifyid.reset()
        }
    }
}

// MARK: Embedded View Controller Transitions
extension HomeViewController {
    private func showSelectModelVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let trainingVC = UIStoryboard.main.instantiateViewController(SelectModelViewController.self)
        trainingVC.delegate = unifyid
        self.embeddedVC = trainingVC
    }

    private func showTrainingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let trainingVC = UIStoryboard.main.instantiateViewController(FeatureCollectionViewController.self)
        trainingVC.manager = unifyid
        self.embeddedVC = trainingVC
    }

    func showPendingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let pendingVC = UIStoryboard.main.instantiateViewController(PendingViewController.self)
        pendingVC.delegate = unifyid
        self.embeddedVC = pendingVC
    }

    internal func showTestingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let testingVC = UIStoryboard.main.instantiateViewController(TestingViewController.self)
        testingVC.manager = unifyid
        self.embeddedVC = testingVC
    }

    internal func showScoresVC(_ scores: [(date: Date, score: Double)]) {
        dispatchPrecondition(condition: .onQueue(.main))
        let scoresVC = UIStoryboard.main.instantiateViewController(ScoresViewController.self)
        scoresVC.scores = scores.map { ($0.date, $0.score) }

        let navigationVC = UINavigationController(rootViewController: scoresVC)
        if #available(iOS 11.0, *) {
            navigationVC.navigationBar.prefersLargeTitles = false
        }
        present(navigationVC, animated: true)
    }

    internal func showErrorVC(message: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        let errorVC = UIStoryboard.main.instantiateViewController(ModelErrorViewController.self)
        errorVC.errorMessage = message
        self.embeddedVC = errorVC
    }
}

extension HomeViewController: Interactor {
    func presentTraining(confirm: Bool = true) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard confirm else {
            self.showPendingVC()
            return
        }

        presentConfirmation(
            title: "Train Model",
            message: "Are you sure you would like to begin training your model? This action cannot be reversed.",
            actionTitle: "Confirm"
        ) { confirmed in
            dispatchPrecondition(condition: .onQueue(.main))
            guard confirmed else { return }
            self.showPendingVC()
            return
        }
    }

    func presentScores(_ scores: [(date: Date, score: Double)]) {
        dispatchPrecondition(condition: .onQueue(.main))
        showScoresVC(scores)
    }

    func presentErrorAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        dispatchPrecondition(condition: .onQueue(.main))
        presentAlert(title: title, message: message, completion: completion)
    }

    func presentTerminalError(message: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        showErrorVC(message: message)
    }
}
