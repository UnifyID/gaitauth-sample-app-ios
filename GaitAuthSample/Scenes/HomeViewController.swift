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

        NotificationCenter.default.addObserver(
            for: ActiveModelDidChangeNotification.self,
            queue: .main
        ) { [weak self] in self?.modelDidChange($0) }

        NotificationCenter.default.addObserver(
            for: DidResetModelNotification.self,
            queue: .main
        ) { [weak self] in self?.modelDidReset($0) }

        NotificationCenter.default.addObserver(
            for: ModelDidRefreshNotification.self,
            queue: .main
        ) { [weak self] in self?.modelDidChange($0) }

        if let modelID = unifyid.modelID, modelID != unifyid.model?.id {
            unifyid.loadModel(modelID)
        } else {
            modelStatusDidChange(unifyid.model?.status)
        }
    }

    private func modelDidChange(_ notification: ActiveModelDidChangeNotification) {
        dispatchPrecondition(condition: .onQueue(.main))
        modelStatusDidChange(notification.status)
    }

    private func modelDidChange(_ notification: ModelDidRefreshNotification) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard case .didChange = notification.changeType else { return }
        modelStatusDidChange(notification.status)
    }

    private func modelDidReset(_ notification: DidResetModelNotification) {
        dispatchPrecondition(condition: .onQueue(.main))
        modelStatusDidChange(nil)
    }

    private func modelStatusDidChange(_ status: GaitModel.Status?) {
        dispatchPrecondition(condition: .onQueue(.main))
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
            showErrorVC(message: reason ?? "unknown failure")
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
        trainingVC.manager = unifyid
        embeddedVC = trainingVC
    }

    private func showTrainingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let trainingVC = UIStoryboard.main.instantiateViewController(TrainingViewController.self)
        trainingVC.manager = unifyid
        embeddedVC = trainingVC
    }

    func showPendingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let pendingVC = UIStoryboard.main.instantiateViewController(PendingViewController.self)
        pendingVC.manager = unifyid
        embeddedVC = pendingVC
    }

    internal func showTestingVC() {
        dispatchPrecondition(condition: .onQueue(.main))
        let testingVC = UIStoryboard.main.instantiateViewController(TestingViewController.self)
        testingVC.manager = unifyid
        embeddedVC = testingVC
    }

    internal func showErrorVC(message: String) {
        dispatchPrecondition(condition: .onQueue(.main))
        let errorVC = UIStoryboard.main.instantiateViewController(ErrorViewController.self)
        errorVC.errorMessage = message
        embeddedVC = errorVC
    }
}
