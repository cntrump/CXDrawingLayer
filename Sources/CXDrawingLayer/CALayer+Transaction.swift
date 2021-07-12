//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import QuartzCore
import ObjectiveC.runtime

private var kCXTransactionGroupKey: UInt8 = 0

extension CALayer {

    var _cx_transactionGroup: CXTransactionGroup? {
        get {
            objc_getAssociatedObject(self, &kCXTransactionGroupKey) as? CXTransactionGroup
        }

        set {
            objc_setAssociatedObject(self, &kCXTransactionGroupKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
