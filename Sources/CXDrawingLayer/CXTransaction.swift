//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import Foundation

typealias CXTransactionHandler = () -> Any?
typealias CXTransactionCompletionHandler = (_ value: Any?) -> Void

private func concurrentQueue() -> DispatchQueue {
    struct once {
        static let queue = DispatchQueue(label: "queue.cx.transaction.concurrent",
                                         qos: .userInitiated,
                                         attributes: .concurrent)
    }

    return once.queue
}

class CXTransaction {
    private lazy var group = DispatchGroup()
    private var queue: DispatchQueue?

    private var value: Any?
    private var handler: CXTransactionHandler?
    private var completion: CXTransactionCompletionHandler?

    init(handler: CXTransactionHandler?, onQueue queue: DispatchQueue? = nil, completion: CXTransactionCompletionHandler?) {
        self.handler = handler

        if let queue = queue {
            self.queue = queue
        } else {
            self.queue = concurrentQueue()
        }

        self.completion = completion

        start()
    }

    func commit() {
        var _self: CXTransaction? = self
        group.notify(queue: .main) {
            _self?.finish()
            _self = nil
        }
    }

    private func start() {
        var _self: CXTransaction? = self
        group.enter()
        queue?.async(group: group) {
            _self?.value = _self?.handler?()
            _self?.group.leave()
            _self = nil
        }
    }

    private func finish() {
        completion?(value)
    }
}
