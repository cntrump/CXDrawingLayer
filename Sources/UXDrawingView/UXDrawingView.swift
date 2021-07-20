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

#if os(macOS)
open class UXDrawingView: NSView {

    open override var isFlipped: Bool { true }

    open override func makeBackingLayer() -> CALayer {
        CXDrawingLayer()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        layer?.contentsScale = NSScreen.main?.backingScaleFactor ?? 1
        layerContentsRedrawPolicy = .duringViewResize
    }

    open func invalidateDisplay() {
        layer?.setNeedsDisplay()
        invalidateIntrinsicContentSize()
        superview?.layoutSubtreeIfNeeded()
    }

    open override func setNeedsDisplay(_ invalidRect: NSRect) {
        super.setNeedsDisplay(invalidRect)
        layer?.setNeedsDisplay()
    }

    open func setNeedsDisplay() {
        setNeedsDisplay(bounds)
    }
}
#else
open class UXDrawingView: UIView {

    open override class var layerClass: AnyClass { CXDrawingLayer.self }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        layer.contentsScale = UIScreen.main.scale
        contentMode = .redraw
    }

    open func invalidateDisplay() {
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }

    open override func setNeedsDisplay(_ rect: CGRect) {
        super.setNeedsDisplay(rect)
        layer.setNeedsDisplay(rect)
    }

    open override func setNeedsDisplay() {
        super.setNeedsDisplay()
        layer.setNeedsDisplay(bounds)
    }
}
#endif
