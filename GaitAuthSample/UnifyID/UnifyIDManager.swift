//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import UnifyID
import GaitAuth
import CoreLocation

/// `UnifyIDManager` is responsible for controlling interactions between view controllers
/// and the UnifyID SDK state. While it would be possible to move some of the logic into
/// individual view controllers, it can help to have an external object manage the state
/// in order to more easily support training and testing operations that could span multiple
/// scenes in the app.
class UnifyIDManager: NSObject {
    /// Initialize the SDK with an SDK Key.
    ///
    /// If not specified, in the initializer will attempt to read from the `UnifyIDSDKKey`
    /// entry in the application bundle's info dictionary. If the key is not provided
    /// in the code or in the info dictionary, all API operations will fail.
    init(sdkKey: String? = nil) {
        super.init()
        core = try? UnifyID(sdkKey: sdkKey ?? Self.defaultSDKKey)
    }

    /// Convenience static getter to retreive the default SDK key from the bundle dictionary.
    static private var defaultSDKKey: String { Bundle.main.infoDictionary?["UnifyIDSDKKey"] as? String ?? "" }

    /// The interactor implements an interface that allows the `UnifyIDManager` to present UI elements.
    ///
    /// The interactor should typically be implemented by a visible view controller.
    weak internal var interactor: Interactor?

    /// A reference to the UnifyID Core SDK. If the initializer fails, this will be nil and will cause
    /// errors while performing subsequent operations.
    internal var core: UnifyID?

    /// A convenience getter to allow easier access to the GaitAuth property.
    internal var gaitAuth: GaitAuth? { core?.gaitAuth }

    /// The currently loaded model.
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

    /// Reset the application state and post a notification when completed.
    ///
    /// This includes:
    ///     - Stopping training
    ///     - Clearing the training buffer and collection count
    ///     - Stopping any active authenticators
    ///     - clearing the last authentication result
    func reset() {
        dispatchPrecondition(condition: .onQueue(.main))
        isCollectingFeatures = false
        stopAuthenticator()
        lastAuthenticatorResult = nil
        featureBuffer.removeAll()
        featureCollectionCount = 0
        modelID = nil
        model = nil
        NotificationCenter.default.post(DidResetModelNotification(sender: self))
    }

    /// Starts feature collection for model training if it is not already running.
    /// If an error is encountered, it will present an error. If features are
    /// successfully collected, it will add the features to the training buffer and
    /// emit a `Notification` indicating that the collected feature count has changed.
    private func startFeatureCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard featureObserver == nil else { return }

        let featureCallback = { [weak self] (result: Result<[GaitFeature], GaitAuthError>) -> Void in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.interactor?.presentAlert(
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

    /// Stops feature collection for model training.
    /// Stopping feature collection will prevent new features from being
    /// collected, but will not empty the training buffer.
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

    /// Creates a `GaitAuth` authenticator object if one does not already exist to start
    /// evaluating the user's authentication status.
    ///
    /// After creating the authenticator, the current status must be regularly polled using
    /// `getAuthenticatorStatus(completion:)`.
    internal func startAuthenticator() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard gaitAuthenticator == nil else { return }
        guard let gaitAuth = gaitAuth, let model = model else {
            self.interactor?.presentAlert(
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

    /// Asynchronously retrieves the current status from the active authenticator.
    /// Presents an error if one occurs and updates the `lastAuthenticatorResult` property
    /// after a successful invocation.
    func getAuthenticatorStatus(completion: @escaping (AuthenticationResult) -> Void) {
        dispatchPrecondition(condition: .onQueue(.main))
        gaitAuthenticator?.status { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.interactor?.presentAlert(
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

    /// Helper variable that allows a consumer to see if the authenticator is actively running.
    var isAuthenticatorActive: Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        return gaitAuthenticator != nil
    }

    /// Stops and deletes the active authenticator.
    /// The last retrieved authentication result will still be persisted in
    /// the `lastAuthenticationResult` property.
    func stopAuthenticator() {
        gaitAuthenticator = nil
    }
}
