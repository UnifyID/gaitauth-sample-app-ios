//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import Lottie

// MARK: - FeatureCollectionViewController

@IBDesignable
class FeatureCollectionViewController: UIViewController {
    weak var manager: FeatureCollector?

    // MARK: - IB Properties

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    internal func refresh() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let manager = manager else { return }

        collectionButton.setTitle(!manager.isCollectingFeatures ? "Start Collection" : "Pause Collection", for: .normal)
        countLabel.text = "\(manager.featureCollectionCount)"
        animationView.animating = manager.isCollectingFeatures
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.25
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()

        NotificationCenter.default.addObserver(
            for: CollectionStateDidChangeNotification.self,
            queue: OperationQueue.main
        ) { _ in
            self.refresh()
        }
    }
}
// MARK: - TrainingViewController

class TrainingViewController: FeatureCollectionViewController {
    @IBAction func toggleCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager?.isCollectingFeatures.toggle()
    }

    @IBAction func initiateModelTraining() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager?.trainModel(withConfirmation: true)
    }

    @IBAction func addCollectedFeatures() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager?.addCollectedFeatures(completion: nil)
    }
}

// MARK: - TestingViewController

class TestingViewController: FeatureCollectionViewController {
    @IBAction func toggleCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager?.isCollectingFeatures.toggle()
    }

    @IBAction func scoreCollectedFeatures() {
        dispatchPrecondition(condition: .onQueue(.main))
        manager?.scoreCollectedFeatures(withConfirmation: true)
    }
}
