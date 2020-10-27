//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

protocol ModelTester: class {
    var isAuthenticatorActive: Bool { get }
    var lastAuthenticatorResult: AuthenticationResult? { get }
    func startAuthenticator()
    func stopAuthenticator()
    func getAuthenticatorStatus(completion: @escaping (AuthenticationResult) -> Void)
    func presentAuthenticationResult(_ result: AuthenticationResult)
}
