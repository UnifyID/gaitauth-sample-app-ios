//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

/// Protocol for the operations needed to support a model loader/selector interface.
protocol ModelSelector: class {
    /// Creates a new model and sets it as the active model.
    func createModel()

    /// Loads an existing model by its ID and sets it as the active model.
    func loadModel(_ id: String)
}
