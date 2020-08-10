//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

protocol FeatureCollector: class {
    var isCollectingFeatures: Bool { get set }
    var featureCollectionCount: Int { get }

    func trainModel(withConfirmation: Bool)
    func addCollectedFeatures(completion: ((Error) -> Void)?)
    func scoreCollectedFeatures(withConfirmation: Bool)
}
