//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

/// Protocol representing the interface required to test a model.
protocol ModelTester: class {
    /// Returns true if an authenticator is active.
    var isAuthenticatorActive: Bool { get }

    /// Returns the last retrieved authenticator result.
    var lastAuthenticatorResult: AuthenticationResult? { get }

    /// Starts an authenticator if one is not already active.
    func startAuthenticator()

    /// Stops the active authenticator if there is one active.
    func stopAuthenticator()

    /// Gets the the authentication status if there is an active authenticator.
    ///
    /// An error will be presented if there is no active authenticator.
    func getAuthenticatorStatus(completion: @escaping (AuthenticationResult) -> Void)
}
