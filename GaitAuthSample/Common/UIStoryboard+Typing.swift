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

    func instantiateViewController<Controller: UIViewController>(
        _ for: Controller.Type = Controller.self,
        identifier: String = String(describing: Controller.self)
    ) -> Controller {
        guard let controller = instantiateViewController(withIdentifier: identifier) as? Controller else {
            preconditionFailure("Failed loading view controller with identifier \(identifier)")
        }
        return controller
    }
}
