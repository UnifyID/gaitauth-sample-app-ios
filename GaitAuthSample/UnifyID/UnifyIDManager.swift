//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import UnifyID
import GaitAuth
import CoreLocation

class UnifyIDManager: NSObject {
    init(sdkKey: String? = nil) {
        super.init()
        core = try? UnifyID(sdkKey: sdkKey ?? Self.defaultSDKKey)
    }

    weak internal var interactor: Interactor?
    internal var core: UnifyID?
    internal var gaitAuth: GaitAuth? { core?.gaitAuth }
    internal var model: GaitModel?

    /// Keep track of the most recently loaded model identifier in user-defaults so that it can be persisted
    /// and automatically loaded after the app is launched next.
    internal var modelID: String? {
        get { UserDefaults.standard.string(forKey: "modelId") }
        set {
            guard let modelID = newValue else {
                UserDefaults.standard.removeObject(forKey: "modelId")
                return
            }
            UserDefaults.standard.setValue(modelID, forKey: "modelId")
        }
    }

    internal var featureBuffer = FeatureBuffer()

    /// Initialize a location manager so that the app can use background location permissions
    /// to stay alive in the background. Other techniques may be used to help collect data more
    /// efficiently in the background, but location is the easiest to demonstrate in a sample application.
    internal lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        return manager
    }()

    // Keep track of the most recent location authorization for convenience.
    internal var locationAuthorization: LocationAuthorization = .notDetermined

    /// A flag to keep track of whether or not the app is or should be collecting location.
    /// If the app requires prompting the user to grant permissions, this flag is set and then used
    /// to try starting location collection after the permissions are granted.
    internal private(set) var isCollectingLocation: Bool = false

    /// Must be modified on the main thread.
    internal var isCollectingFeatures = false {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            updateLocationCollection()
            updateFeatureCollection()
            NotificationCenter.default.post(
                CollectionStateDidChangeNotification(sender: self, isCollecting: isCollectingFeatures)
            )
        }
    }

    static private var defaultSDKKey: String {
        Bundle.main.infoDictionary?["UnifyIDSDKKey"] as? String ?? ""
    }

    /// Reset the application state.
    func reset() {
        dispatchPrecondition(condition: .onQueue(.main))
        isCollectingFeatures = false
        featureCollectionCount = 0
        featureBuffer.removeAll()
        NotificationCenter.default.post(DidResetModelNotification(sender: self))
    }

    var featureCollectionCount: Int = 0 {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            NotificationCenter.default.post(
                CollectionStateDidChangeNotification(sender: self, isCollecting: isCollectingFeatures)
            )
        }
    }

    // MARK: Simulate Model Refreshing

    internal var refreshCount: Int = 0 {
        didSet {
            guard refreshCount >= 3 else { return }
            interactor?.presentTerminalError(message: "Model training failed:\nInsufficient features")
            refreshCount = 0
        }
    }

    // MARK: Simulate Collection

    private var collector: AnyHashable?

    private func updateFeatureCollection() {
        let featureCallback = { (result: Result<[GaitFeature], GaitAuthError>) -> Void in
            switch result {
            case .failure(let error):
                self.interactor?.presentErrorAlert(
                    title: "Failed Collecting Features",
                    message: error.localizedDescription,
                    completion: nil
                )
            case .success(let features):
                self.featureBuffer.write(features)
                self.featureCollectionCount += features.count
            }
        }
        #if targetEnvironment(simulator)
        if isCollectingFeatures {
            guard collector == nil else { return }
            collector = FakeFeatureGenerator(to: .main, callback: featureCallback)
        } else {
            collector = nil
        }

        #else
        if isCollectingFeatures {
            guard collector == nil else { return }
            collector = gaitAuth?.startFeatureUpdates(to: .main, with: featureCallback)
        } else {
            guard let collector = collector else { return }
            gaitAuth?.stopFeatureUpdates(collector)
            self.collector = nil
        }
        #endif
    }
}
