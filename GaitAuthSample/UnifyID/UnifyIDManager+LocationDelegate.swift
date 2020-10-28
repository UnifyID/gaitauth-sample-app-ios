//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import CoreLocation

/// Support subscribing to location updates.
///
/// The UnifyID SDK does not implement any kind of application backgrounding support, as the
/// strategy for keeping an app alive in the background is often best implemented by the app
/// itself. This sample application uses background location as the means of staying alive in
/// the background. Whenever data collection starts, the app will subscribe to location updates,
/// which, assuming the user grants location permissions, will allow the app to work in the background.
extension UnifyIDManager: CLLocationManagerDelegate {
    /// A custom enum that maps onto a combination of the location
    /// manager's authorization status and allowed precision.
    enum LocationAuthorization: String {
        /// Location permission may always be collected in the background.
        /// This lets the app stay alive continuously by receiving (and ignoring)
        /// a steady stream of location updates.
        case authorizedAlwaysFullAccuracy

        /// Only available in iOS 14.0+. Indicates that location permission has been permitted
        /// always, but only at reduced accuracy. While the SDK will still work under this condition,
        /// the performance will be degraded as the app will occasionally be paused.
        case authorizedAlwaysReducedAccuracy

        /// Location permissions are allowed only when the app is in use.
        case authorizedWhenInUse

        /// Location collection is never allowed. The app will be paused whenever the screen is locked.
        case unauthorized

        /// The app needs to request permissions before it can determine what the current authorization is.
        case notDetermined
    }

    /// Subscribe to location updates, first requesting permissions if necessary.
    ///
    /// The check for the current authorization status will happen asynchronously and then call this function
    /// again if it returns, is authorized and `isCollectingLocation` indicates that the app should
    /// be collecting location information.
    @discardableResult
    internal func startLocationUpdates() -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        switch locationAuthorization {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .unauthorized:
            return false
        case .authorizedWhenInUse:
            // try upgrading permissions to always.
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlwaysFullAccuracy, .authorizedAlwaysReducedAccuracy:
            break
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        return true
    }

    /// Stops receiving location updates, which allows the app to go to sleep
    /// if it transitions to the background.
    @discardableResult
    internal func stopLocationUpdates() -> Bool {
        dispatchPrecondition(condition: .onQueue(.main))
        locationManager.stopUpdatingLocation()
        return false
    }

    /// The CLLocationManagerDelegate callback to receive a change in authorization status.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationAuthorization = LocationAuthorization(manager, status)
            switch self.locationAuthorization {
            case .authorizedAlwaysFullAccuracy, .authorizedAlwaysReducedAccuracy, .authorizedWhenInUse, .notDetermined:
                guard self.isCollectingLocation else { return }
                self.startLocationUpdates()
            case .unauthorized:
                self.stopLocationUpdates()
            }
        }
    }

    /// The `CLLocationManagerDelegate` to receive location updates.
    /// Not implemented because we only care about location manager keeping our app alive.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
}

private extension UnifyIDManager.LocationAuthorization {
    /// Initialize the `LocationAuthorization` enum with a `CLLocationManager` and authorization status.
    init(_ manager: CLLocationManager, _ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if #available(iOS 14.0, *) {
                switch manager.accuracyAuthorization {
                case .fullAccuracy:
                    self = .authorizedAlwaysFullAccuracy
                default:
                    self = .authorizedAlwaysReducedAccuracy
                }
            } else {
                self = .authorizedAlwaysFullAccuracy
            }
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        case .denied, .restricted:
            self = .unauthorized
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            self = .notDetermined
        }
    }
}
