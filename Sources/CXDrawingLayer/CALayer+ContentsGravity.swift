//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

import QuartzCore

public extension CALayer {

    var drawingContentsGravity: CXDrawingContentsGravity {
        switch contentsGravity {
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        case .resizeAspect: return .resizeAspect
        case .resizeAspectFill: return .resizeAspectFill
        default: return .resize
        }
    }
}

public func CXMakeRect(aspectRatio: CGSize,
                       insideRect boundingRect: CGRect,
                       contentsGravity: CXDrawingContentsGravity) -> CGRect {
    if contentsGravity == .resize {
        return boundingRect
    }

    var x: CGFloat = 0
    var y: CGFloat = 0
    var w: CGFloat = 0
    var h: CGFloat = 0

    if contentsGravity == .resizeAspect {
        let scale: CGFloat = aspectRatio.width < aspectRatio.height ?
                                boundingRect.height / aspectRatio.height :
                                boundingRect.width / aspectRatio.width

        if aspectRatio.width < aspectRatio.height {
            y = 0
            h = boundingRect.height
            w = aspectRatio.width * scale
            x = (boundingRect.width - w) * 0.5
        } else {
            x = 0
            w = boundingRect.width
            h = aspectRatio.height * scale
            y = (boundingRect.height - h) * 0.5
        }

        return CGRect(x: x, y: y, width: w, height: h)
    }

    if contentsGravity == .resizeAspectFill {
        let scale: CGFloat = max(boundingRect.height / aspectRatio.height,
                                boundingRect.width / aspectRatio.width)

        w = aspectRatio.width * scale
        h = aspectRatio.height * scale

        x = (boundingRect.width - w) * 0.5
        y = (boundingRect.height - h) * 0.5

        return CGRect(x: x, y: y, width: w, height: h)
    }

    x = boundingRect.width - aspectRatio.width
    y = boundingRect.height - aspectRatio.height
    w = aspectRatio.width
    h = aspectRatio.height

    switch contentsGravity {
    case .center: x *= 0.5; y *= 0.5
    case .top: y = 0; x *= 0.5
    case .bottom: x *= 0.5
    case .left: x = 0; y *= 0.5
    case .right: y *= 0.5
    case .topLeft: x = 0; y = 0
    case .topRight: y = 0
    case .bottomLeft: x = 0
    case .bottomRight: break
    default: break
    }

    return CGRect(x: x, y: y, width: w, height: h)
}
