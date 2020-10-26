//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth
import UIKit

class FakeFeatureGenerator: Hashable, Equatable {
    let id = UUID().uuidString.lowercased()
    let interval: TimeInterval
    let count: ClosedRange<Int>
    let queue: DispatchQueue
    let callback: ((Result<[GaitFeature], GaitAuthError>) -> Void)?

    struct FakeFeature: GaitFeature {
        let date: Date = { Date() }()
    }

    init(interval: TimeInterval = 1.0, count: ClosedRange<Int> = 1...2, to: DispatchQueue = .global(), callback: @escaping (Result<[GaitFeature], GaitAuthError>) -> Void) {
        self.interval = interval
        self.count = count
        self.queue = to
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
            self.queue.async {
                self.callback?(.success(features))
            }
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FakeFeatureGenerator, rhs: FakeFeatureGenerator) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
}
