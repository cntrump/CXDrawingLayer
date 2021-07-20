//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

#if !os(macOS)
import UIKit

public extension CGRect {

    func with(orientation: UIImage.Orientation) -> Self {
        switch orientation {
        case .left: fallthrough
        case .leftMirrored: fallthrough
        case .right: fallthrough
        case .rightMirrored: return CGRect(origin: origin, size: CGSize(width: height, height: width))
        default:
            return self
        }
    }
}
#endif
