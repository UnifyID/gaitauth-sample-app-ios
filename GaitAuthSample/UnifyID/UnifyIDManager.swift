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

    /// A main-thread accessible counter that keeps track of the number of features in the training buffer.
    internal var featureCollectionCount = 0

    /// A reference to the observer object that is subscribed to feature updates for training.
    internal var featureObserver: AnyHashable?

    /// Buffer of features for training.
    internal var featureBuffer = FeatureBuffer()

    /// Active Gait Authenticator for testing.
    private var gaitAuthenticator: Authenticator?

    /// Last result issued by the Gait Authenticator.
    internal private(set) var lastAuthenticatorResult: AuthenticationResult?

    /// Keep track of the most recently loaded model identifier in user-defaults so that it can be persisted
    /// and automatically loaded after the app is launched next.
    internal var modelID: String? {
        get {
            UserDefaults.standard.string(forKey: "modelId")
        }
        set {
            guard let modelID = newValue else {
                UserDefaults.standard.removeObject(forKey: "modelId")
                return
            }
            UserDefaults.standard.setValue(modelID, forKey: "modelId")
        }
    }

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
            guard isCollectingFeatures != oldValue else { return }

            if isCollectingFeatures {
                startFeatureCollection()
                isCollectingLocation = startLocationUpdates()
            } else {
                stopFeatureCollection()
                isCollectingLocation = stopLocationUpdates()
            }

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
        featureBuffer.removeAll()
        featureCollectionCount = 0
        modelID = nil
        model = nil
        NotificationCenter.default.post(DidResetModelNotification(sender: self))
    }

    private func startFeatureCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard featureObserver == nil else { return }

        let featureCallback = { [weak self] (result: Result<[GaitFeature], GaitAuthError>) -> Void in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.interactor?.presentErrorAlert(
                    title: "Failed Collecting Features",
                    message: error.localizedDescription
                )
            case .success(let features):
                self.featureCollectionCount += features.count
                self.featureBuffer.write(features)

                print("collected \(features.count) features")
                NotificationCenter.default.post(
                    DidCollectFeaturesNotification(
                        sender: self,
                        newFeatureCount: features.count,
                        totalFeaturesCollected: self.featureCollectionCount
                    )
                )
            }
        }

        #if targetEnvironment(simulator)
        featureObserver = FakeFeatureGenerator(to: .main, callback: featureCallback)
        #else
        featureObserver = gaitAuth?.startFeatureUpdates(to: .main, with: featureCallback)
        #endif
        isCollectingFeatures = true
    }

    private func stopFeatureCollection() {
        guard let featureObserver = featureObserver else {
            self.isCollectingFeatures = false
            return
        }

        defer {
            self.isCollectingFeatures = false
        }

        #if targetEnvironment(simulator)
        self.featureObserver = nil
        #else
        gaitAuth?.stopFeatureUpdates(featureObserver)
        self.featureObserver = nil
        #endif
    }

    internal func startAuthenticator() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard gaitAuthenticator == nil else { return }
        guard let gaitAuth = gaitAuth, let model = model else {
            self.interactor?.presentErrorAlert(
                title: "Failed Inititalizing Authenticator",
                message: "GaitAuth not initialized"
            )
            return
        }
        self.gaitAuthenticator = gaitAuth.authenticator(
            // swiftlint:disable:next force_unwrapping
            config: GaitQuantileConfig(threshold: 0.8)!,
            model: model
        )
        self.isCollectingLocation = self.startLocationUpdates()
    }

    func getAuthenticatorStatus(completion: @escaping (AuthenticationResult) -> Void) {
        dispatchPrecondition(condition: .onQueue(.main))
        gaitAuthenticator?.status { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.interactor?.presentErrorAlert(
                        title: "Authenticator Status Failed",
                        message: error.localizedDescription
                    )
                case .success(let authResult):
                    self?.lastAuthenticatorResult = authResult
                    completion(authResult)
                }
            }
        }
    }

    var isAuthenticatorActive: Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        return gaitAuthenticator != nil
    }

    func stopAuthenticator() {
        gaitAuthenticator = nil
    }
}
