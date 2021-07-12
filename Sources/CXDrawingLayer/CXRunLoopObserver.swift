//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import CoreFoundation

typealias CXRunLoopHandler = (_ activities: CFRunLoopActivity) -> Void

class CXRunLoopObserver {
    var observer: CFRunLoopObserver!
    var handler: CXRunLoopHandler?

    deinit {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, .commonModes)
    }

    init(activities: CFRunLoopActivity, handler: CXRunLoopHandler?) {
        self.handler = handler
        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activities.rawValue, true, .max) { [weak self] (observer, activities) in
            self?.commit(activities: activities)
        }

        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .commonModes)
    }

    private func commit(activities: CFRunLoopActivity) {
        handler?(activities)
    }
}
