//
//  Copyright 2021 lvv.me
//
//  Use of this source code is governed by an MIT-style
//  license that can be found in the LICENSE file or at
//  https://opensource.org/licenses/MIT
//

#if os(macOS)
import AppKit
public typealias UIView = NSView
public typealias UIFont = NSFont
public typealias UIColor = NSColor
public typealias UIEdgeInsets = NSEdgeInsets

public extension UIEdgeInsets {
    static let zero = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}
#else
import UIKit
#endif

@available(macOS 10.10, iOS 7.0, tvOS 7.0, *)
open class UXLabel: UXDrawingView {

    private var _text: String?
    private var _attributedText: NSAttributedString?

    open var text: String? { // default is nil
        get { _text }
        set {
            _text = newValue
            _attributedText = nil
            invalidateDisplay()
        }
    }

    open var font: UIFont! = .systemFont(ofSize: 17) { // default is nil (system font 17 plain)
        didSet {
            invalidateDisplay()
        }
    }

    open var textColor: UIColor! = .black { // default is labelColor
        didSet {
            invalidateDisplay()
        }
    }

    open var shadowColor: UIColor? // default is nil (no shadow)

    open var shadowOffset: CGSize = CGSize(width: 0, height: -1) // default is CGSizeMake(0, -1) -- a top shadow

    open var textAlignment: NSTextAlignment = .natural {// default is NSTextAlignmentNatural (before iOS 9, the default was NSTextAlignmentLeft)
        didSet {
            invalidateDisplay()
        }
    }

    open var lineBreakMode: NSLineBreakMode = .byTruncatingTail {// default is NSLineBreakByTruncatingTail. used for single and multiple lines of text
        didSet {
            invalidateDisplay()
        }
    }

    open var attributedText: NSAttributedString? { // default is nil
        get { _attributedText }
        set {
            _attributedText = newValue?.copy() as? NSAttributedString
            _text = nil
            invalidateDisplay()
        }
    }

    open var numberOfLines: Int = 0 {
        didSet {
            invalidateDisplay()
        }
    }

    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            invalidateDisplay()
        }
    }

    // Support for constraint-based layout (auto layout)
    // If nonzero, this is used when determining -intrinsicContentSize for multiline labels
    private var preferredMaxLayoutWidth: CGFloat = UIView.noIntrinsicMetric

    open override var intrinsicContentSize: CGSize {
        guard let renderedAttributedText = renderedAttributedText else {
            return .zero
        }

        // first layout
        if preferredMaxLayoutWidth == UIView.noIntrinsicMetric {
            preferredMaxLayoutWidth = .greatestFiniteMagnitude
        }

        let width = preferredMaxLayoutWidth - contentInset.left - contentInset.right

        let context = UXTextKitContext(attributedText: renderedAttributedText,
                                       numberOfLines: numberOfLines,
                                       lineBreakMode: lineBreakMode,
                                       containerSize: CGSize(width: width, height: .greatestFiniteMagnitude))
        var boundingRect: CGRect = .zero
        context.perform { (layoutManager, _, textContainer) in
            _ = layoutManager.glyphRange(for: textContainer)
            boundingRect = layoutManager.usedRect(for: textContainer)
        }

        var size = boundingRect.integral.size
        size.width += contentInset.left + contentInset.right
        size.height += contentInset.top + contentInset.bottom

        preferredMaxLayoutWidth = size.width

        return size
    }

    open override var bounds: CGRect {
        didSet {
            let width = bounds.width
            if preferredMaxLayoutWidth != width {
                preferredMaxLayoutWidth = width
                invalidateDisplay()
            }
        }
    }

    #if !os(macOS)
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let renderedAttributedText = renderedAttributedText else {
            return .zero
        }

        let width = size.width - contentInset.left - contentInset.right

        let context = UXTextKitContext(attributedText: renderedAttributedText,
                                       numberOfLines: numberOfLines,
                                       lineBreakMode: lineBreakMode,
                                       containerSize: CGSize(width: width, height: size.height))
        var boundingRect: CGRect = .zero
        context.perform { (layoutManager, _, textContainer) in
            _ = layoutManager.glyphRange(for: textContainer)
            boundingRect = layoutManager.usedRect(for: textContainer)
        }

        var size = boundingRect.integral.size
        size.width += contentInset.left + contentInset.right
        size.height += contentInset.top + contentInset.bottom

        return size
    }
    #endif
}

private extension UXLabel {

    var renderedAttributedText: NSAttributedString? {
        if text == nil, attributedText == nil {
            return nil
        }

        if let _ = attributedText {
            return attributedText
        }

        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = font
        attributes[.foregroundColor] = textColor

        if let shadowColor = shadowColor {
            let shadow = NSShadow()
            shadow.shadowColor = shadowColor
            shadow.shadowOffset = shadowOffset
            shadow.shadowBlurRadius = layer?.cornerRadius ?? 0
            attributes[.shadow] = shadow
        }

        return NSAttributedString(string: text!, attributes: attributes)
    }
}

class UXLabelDrawingParameter {

    var topLeft: CGPoint
    var context: UXTextKitContext

    init(context: UXTextKitContext, topLeft: CGPoint) {
        self.context = context
        self.topLeft = topLeft
    }
}

extension UXLabel: CXDrawingLayerDelegate {

    public var drawingParameter: Any? {
        let topLeft = CGPoint(x: contentInset.left, y: contentInset.top)
        let width = preferredMaxLayoutWidth - contentInset.left - contentInset.right
        let context = UXTextKitContext(attributedText: renderedAttributedText,
                                       numberOfLines: numberOfLines,
                                       lineBreakMode: lineBreakMode,
                                       containerSize: CGSize(width: width, height: .greatestFiniteMagnitude))

        return UXLabelDrawingParameter(context: context, topLeft: topLeft)
    }

    public func draw(rect: CGRect, in ctx: CGContext, scale: CGFloat, isFlipped: Bool, parameter: Any?, asynchronous: Bool) {
        guard let drawingParameter = parameter as? UXLabelDrawingParameter else {
            return
        }

        let topLeft = drawingParameter.topLeft
        let context = drawingParameter.context

        context.perform { (layoutManager, _, textContainer) in
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            layoutManager.drawBackground(forGlyphRange: glyphRange, at: topLeft)
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: topLeft)
        }
    }
}
