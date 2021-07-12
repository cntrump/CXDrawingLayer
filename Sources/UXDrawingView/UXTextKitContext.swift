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

@available(macOS 10.10, iOS 7.0, tvOS 9.0, *)
public class UXTextKitContext {

    private var textContainer: NSTextContainer
    private var layoutManager: NSLayoutManager
    private var textStorage: NSTextStorage

    public init(attributedText: NSAttributedString?,
               numberOfLines: Int = 0,
               lineBreakMode: NSLineBreakMode = .byTruncatingTail,
               containerSize: CGSize) {
        layoutManager = NSLayoutManager()
        layoutManager.usesFontLeading = false

        textContainer = NSTextContainer(size: containerSize)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        layoutManager.addTextContainer(textContainer)

        textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
        }
    }

    public func perform(block: ((NSLayoutManager, NSTextStorage, NSTextContainer) -> Void)?) {
        block?(layoutManager, textStorage, textContainer)
    }
}
