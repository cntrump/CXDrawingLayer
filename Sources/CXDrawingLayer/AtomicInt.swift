//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import Darwin.os

@propertyWrapper
struct AtomicInt {

    lazy var lock = os_unfair_lock()

    var wrappedValue: Int

    init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }

    @discardableResult mutating func inc() -> Int {
        os_unfair_lock_lock(&lock)
        let oldValue = wrappedValue
        wrappedValue += 1
        os_unfair_lock_unlock(&lock)

        return oldValue
    }

    @discardableResult mutating func dec() -> Int {
        os_unfair_lock_lock(&lock)
        let oldValue = wrappedValue
        wrappedValue -= 1
        os_unfair_lock_unlock(&lock)

        return oldValue
    }

    mutating func getValue() -> Int {
        os_unfair_lock_lock(&lock)
        let oldValue = wrappedValue
        os_unfair_lock_unlock(&lock)

        return oldValue
    }
}
