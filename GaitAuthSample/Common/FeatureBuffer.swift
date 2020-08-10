//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import GaitAuth

class FeatureBuffer {
    typealias Element = GaitFeature
    typealias FlushResult = (items: [Element], finish: (Bool) -> Void)
    typealias FlushCallback = (FlushResult) -> Void

    private var capacity: Int?
    private var maxAge: TimeInterval?
    private let queue: DispatchQueue

    init(queue: DispatchQueue? = nil, capacity: Int? = nil, maxAge: TimeInterval? = nil) {
        self.queue = queue ?? DispatchQueue(label: "id.unify.utils.FeatureBuffer.\(UUID().uuidString.lowercased())")
        self.capacity = capacity
        self.maxAge = maxAge
    }

    func getCount(_ completion: @escaping (Int) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { completion(0); return }
            completion(self.buffer.count)
        }
    }

    // MARK: - Private Buffer Attributes

    private var buffer = [Element]()

    func write(_ item: Element) {
        write([item])
    }

    func write(_ items: [Element]) {
        queue.async { [weak self] in
            guard let self = self else { return }

            // if we have too much data, drop the earliest
            if let capacity = self.capacity {
                let overflow = max(0, (self.buffer.count + items.count) - capacity)
                if overflow > 0 {
                    self.buffer.removeFirst(overflow)
                }
            }

            // next remove items that are older than maxAge
            if let maxAge = self.maxAge {
                var dropCount = 0
                for i in 0..<self.buffer.count {
                    let age = -self.buffer[i].date.timeIntervalSinceNow
                    guard age < maxAge else {
                        break
                    }
                    dropCount += 1
                }
                if dropCount > 0 {
                    self.buffer.removeFirst(dropCount)
                }
            }

            self.buffer.append(contentsOf: items)
        }
    }

    func removeAll() {
        queue.async {
            // retain capacity if it has been explicitly limited
            self.buffer.removeAll(keepingCapacity: (self.capacity ?? 0) > 0)
        }
    }

    func flush(to callbackQueue: DispatchQueue = DispatchQueue.global(), count: Int? = nil, handler: @escaping ([Element], ((Bool) -> Void)) -> Void) {
        queue.async {
            let flushCount = min(count ?? self.buffer.count, self.buffer.count)
            guard flushCount > 0 else {
                return
            }

            let data = Array(self.buffer[0..<flushCount])


            // use a semaphore to block the buffer queue while we do an async flush
            let sem = DispatchSemaphore(value: 0)
            var successful: Bool = false

            let callback = { (success: Bool) in
                successful = success
                sem.signal()
            }

            callbackQueue.async {
                handler(data, callback)
            }

            // block the queue until we finish flushing
            // this will block forever if the caller does not call the completion block
            sem.wait()

            if successful {
                self.buffer = Array(self.buffer.dropFirst(flushCount))
            }
        }
    }
}
