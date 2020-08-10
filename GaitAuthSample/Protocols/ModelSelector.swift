//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

protocol ModelSelector: class {
    func createModel()
    func loadModel(_ id: String)
}
