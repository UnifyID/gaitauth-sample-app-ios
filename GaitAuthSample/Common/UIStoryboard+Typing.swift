//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        UIStoryboard(name: "Main", bundle: Bundle.main)
    }

    func instantiateViewController<Controller: UIViewController>(_ for: Controller.Type, identifier: String? = nil) -> Controller {
        let identifier = identifier ?? String(describing: Controller.self)
        guard let controller = instantiateViewController(withIdentifier: identifier) as? Controller else {
            preconditionFailure("Failed loading view controller with identifier \(identifier)")
        }
        return controller
    }
}
