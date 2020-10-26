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
    enum LocationAuthorization: String {
        case authorizedAlwaysFullAccuracy
        case authorizedAlwaysReducedAccuracy
        case authorizedWhenInUse
        case unauthorized
        case notDetermined
    }

    /// Update the current location collection state to match the desired data collection state.
    func updateLocationCollection() {
        dispatchPrecondition(condition: .onQueue(.main))
        if isCollectingFeatures {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
        }
    }

    /// Subscribe to location updates, first requesting permissions if necessary.
    ///
    /// The check for the current authorization status will happen asynchronously and then call this function
    /// again if it returns, is authorized and `isCollectingLocation` indicates that the app should
    /// be collecting location information.
        dispatchPrecondition(condition: .onQueue(.main))
        switch locationAuthorization {
        case .notDetermined:
            isCollectingLocation = true
            locationManager.requestAlwaysAuthorization()
            return
        case .unauthorized:
            print("failed authorizing location updates")
            isCollectingLocation = false
            return
        case .authorizedWhenInUse:
            // try upgrading permissions to always.
            isCollectingLocation = true
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlwaysFullAccuracy, .authorizedAlwaysReducedAccuracy:
            isCollectingLocation = true
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    private func stopLocationUpdates() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard isCollectingLocation else { return }
        defer { isCollectingLocation = false }
        locationManager.stopUpdatingLocation()
    }

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
}

private extension UnifyIDManager.LocationAuthorization {
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
