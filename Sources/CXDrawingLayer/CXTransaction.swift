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

class CXTransaction {
    private lazy var group = DispatchGroup()
    private lazy var queue: DispatchQueue = {
        let queue = DispatchQueue(label: "queue.cx.transaction", qos: .userInitiated)

        return queue
    }()

    private var value: Any?
    private var handler: CXTransactionHandler?
    private var completion: CXTransactionCompletionHandler?

    init(handler: CXTransactionHandler?, completion: CXTransactionCompletionHandler?) {
        self.handler = handler
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
        queue.async(group: group) {
            _self?.value = _self?.handler?()
            _self?.group.leave()
            _self = nil
        }
    }

    private func finish() {
        completion?(value)
    }
}
