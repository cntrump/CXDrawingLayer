//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import QuartzCore

public enum CXDrawingMode {
    case sync
    case async
    case auto
}

public protocol CXDrawingLayerDelegate {

    var drawingParameter: Any? { get } // Always run on main thread.

    func draw(rect: CGRect, in ctx: CGContext, scale: CGFloat, isFlipped: Bool, parameter: Any?, asynchronous: Bool)
}

open class CXDrawingLayer: CALayer {

    open var drawingMode: CXDrawingMode = .auto

    @AtomicInt private var counter = 0

    open override class func needsDisplay(forKey key: String) -> Bool {
        guard key.compare("bounds") == .orderedSame else {
            return super.needsDisplay(forKey: key)
        }

        return true
    }

    open override func display() {
        cancelDrawing()
        var asynchronous = true
        let drawingMode = drawingMode
        if drawingMode == .sync {
            asynchronous = false
        } else if drawingMode == .auto {
            if let superlayer = superlayer as? CXDrawingLayer {
                asynchronous = superlayer.drawingMode == .sync
            }
        }

        // Synchronous drawing, `draw(in:)` called.
        guard asynchronous else {
            super.display()
            return
        }

        // `super.contents` not `self.contents`, unset `contents` directly.
        super.contents = nil

        let transactionGroup = self.transactionGroup
        let drawingParameter = (delegate as? CXDrawingLayerDelegate)?.drawingParameter
        let scale = contentsScale
        let boundingBox = CGRect(origin: .zero, size: bounds.size)
        let isFlipped = isGeometryFlipped
        let drawingCount = _counter.getValue()

        transactionGroup.add(transaction: CXTransaction(handler: { [weak self] () -> Any? in
            guard let self = self else {
                return nil
            }

            var currentDrawingCount = self._counter.getValue()
            guard currentDrawingCount == drawingCount else {
                return nil
            }

            #if os(macOS)
            let image = NSImage(size: boundingBox.size, flipped: isFlipped) { (_) -> Bool in
                if let ctx = NSGraphicsContext.current?.cgContext {
                    (self.delegate as? CXDrawingLayerDelegate)?.draw(rect: boundingBox,
                                                                      in: ctx,
                                                                      scale: scale,
                                                                      isFlipped: isFlipped,
                                                                      parameter: drawingParameter,
                                                                      asynchronous: true)
                }

                return true
            }
            #else
            UIGraphicsBeginImageContextWithOptions(boundingBox.size, false, scale)
            defer { UIGraphicsEndImageContext() }

            if let ctx = UIGraphicsGetCurrentContext() {
                (self.delegate as? CXDrawingLayerDelegate)?.draw(rect: boundingBox,
                                                                  in: ctx,
                                                                  scale: scale,
                                                                  isFlipped: isFlipped,
                                                                  parameter: drawingParameter,
                                                                  asynchronous: true)
            }

            let image = UIGraphicsGetImageFromCurrentImageContext()
            #endif

            currentDrawingCount = self._counter.getValue()
            guard currentDrawingCount == drawingCount else {
                return nil
            }

            return image
        }, completion: { [weak self] (value) in
            #if os(macOS)
            self?.contents = (value as? NSImage)
            #else
            self?.contents = (value as? UIImage)?.cgImage
            #endif
        }))
    }

    open override func draw(in ctx: CGContext) {
        #if os(macOS)
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: isGeometryFlipped)
        NSGraphicsContext.current?.saveGraphicsState()
        #else
        UIGraphicsPushContext(ctx)
        #endif

        let delegate = delegate as? CXDrawingLayerDelegate
        let scale = contentsScale
        let boundingBox = ctx.boundingBoxOfClipPath
        delegate?.draw(rect: boundingBox,
                       in: ctx,
                       scale: scale,
                       isFlipped: isGeometryFlipped,
                       parameter: delegate?.drawingParameter,
                       asynchronous: false)

        #if os(macOS)
        NSGraphicsContext.current?.restoreGraphicsState()
        #else
        UIGraphicsPopContext()
        #endif
    }

    open override func setNeedsDisplay(_ r: CGRect) {
        cancelDrawing()
        super.setNeedsDisplay(r)
    }
}

extension CXDrawingLayer {

    private var transactionGroup: CXTransactionGroup {
        var targetLayer = superlayer
        while targetLayer != nil {
            if let container = targetLayer?._cx_transactionGroup {
                return container
            }

            targetLayer = targetLayer?.superlayer
        }

        targetLayer = superlayer

        let container = CXTransactionGroup.main
        (targetLayer ?? self)._cx_transactionGroup = container

        return container
    }

    private func cancelDrawing() {
        _counter.inc()
    }
}
