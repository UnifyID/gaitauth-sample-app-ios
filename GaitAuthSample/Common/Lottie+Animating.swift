//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import Lottie

extension Lottie.AnimationView {
    var animating: Bool {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return isAnimationPlaying
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            guard newValue != isAnimationPlaying else { return }

            if newValue {
                play()
            } else {
                pause()
            }
        }
    }
}
