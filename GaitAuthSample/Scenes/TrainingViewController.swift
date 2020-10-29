//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import Lottie
import GaitAuth

// MARK: - FeatureCollectionViewController

@IBDesignable
class TrainingViewController: UIViewController {
    unowned var manager: ModelTrainer = unifyid

    var featureCollectionCount = 0 {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            countLabel.text = "\(manager.featureCollectionCount)"
        }
    }

    var isCollecting: Bool {
        get {
            manager.isCollectingFeatures
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            collectionButton.setTitle(!newValue ? "Start Collection" : "Pause Collection", for: .normal)
            animationView.animating = newValue
            manager.isCollectingFeatures = newValue
        }
    }

    // MARK: - IB Properties

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    private var featureCountObserver: NSObjectProtocol? {
        didSet {
            if let oldValue = oldValue, oldValue.hash != featureCountObserver?.hash {
                NotificationCenter.default.removeObserver(oldValue as Any)
            }
        }
    }

    private var appActiveObserver: NSObjectProtocol? {
        didSet {
            if let oldValue = oldValue, oldValue.hash != appActiveObserver?.hash {
                NotificationCenter.default.removeObserver(oldValue as Any)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.25
        isCollecting = manager.isCollectingFeatures
        featureCollectionCount = 0

        appActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.animationView.animating = self.isCollecting
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        featureCountObserver = NotificationCenter.default.addObserver(
            for: DidCollectFeaturesNotification.self,
            queue: .main
        ) { [weak self] in
            self?.featureCollectionCount = $0.totalFeaturesCollected
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        featureCountObserver = nil
    }

    @IBAction func toggleCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        isCollecting.toggle()
    }

    @IBAction func initiateModelTraining() {
        dispatchPrecondition(condition: .onQueue(.main))
        presentConfirmation(
            title: "Train Model",
            message: "Are you sure you would like to begin training your model? This action cannot be reversed.",
            cancelTitle: "Cancel",
            actionTitle: "Confirm"
        ) { [weak self] confirmed in
            dispatchPrecondition(condition: .onQueue(.main))
            guard let self = self, confirmed else { return }
            self.manager.trainModel()
        }
    }

    @IBAction func addCollectedFeatures() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager.addCollectedFeatures()
    }

    deinit {
        appActiveObserver = nil
        featureCountObserver = nil
    }
}
