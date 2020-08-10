//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth
import UIKit

class FakeFeatureGenerator {
    let interval: TimeInterval
    let count: ClosedRange<Int>
    let callback: (([GaitFeature]) -> Void)?

    struct FakeFeature: GaitFeature {
        let date: Date = { Date() }()
    }

    init(interval: TimeInterval = 1.0, count: ClosedRange<Int> = 1...2, callback: @escaping ([GaitFeature]) -> Void) {
        self.interval = interval
        self.count = count
        self.callback = callback

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.ensureTimer()
        }
        ensureTimer()
    }

    private var timer: Timer?

    private func ensureTimer() {
        if let timer = timer, timer.isValid {
            return
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let featureCount = self.count.randomElement() ?? 1
            let features: [GaitFeature] = (0..<featureCount).map { _ in FakeFeature() as GaitFeature }
            self.callback?(features)
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
}
