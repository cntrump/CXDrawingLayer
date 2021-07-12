//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import Foundation

class CXTransactionGroup {

    private var transactions = [CXTransaction]()
    private var observer: CXRunLoopObserver!

    private init(activities: CFRunLoopActivity) {
        self.observer = CXRunLoopObserver(activities: activities, handler: { [weak self] (_) in
            self?.commit()
        })
    }

    private func commit() {
        transactions.forEach { transaction in
            transaction.commit()
        }

        transactions.removeAll()
    }

    func add(transaction: CXTransaction) {
        transactions.append(transaction)
    }
}

extension CXTransactionGroup {

    static let main = CXTransactionGroup(activities: [.beforeWaiting, .exit])
}
