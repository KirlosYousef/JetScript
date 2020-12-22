//
//  ScriptTextView.swift
//  JetScript
//
//  Created by Kirlos Yousef on 20/12/2020.
//

import Combine
import SwiftUI

// MARK: - View
struct ScriptTextView: NSViewRepresentable {
    
    @Binding var input: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: input
        )
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.inputText = input
    }
}

struct ScriptTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScriptTextView(
                input: .constant("for i in 0…100000{ \n print(i) \n }")
            )
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
            
            ScriptTextView(
                input: .constant("for i in 0…100000{ \n print(i) \n }")
            )
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
        }
    }
}

// MARK: - Coordinator
extension ScriptTextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: ScriptTextView
        
        init(_ parent: ScriptTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.input = textView.string
        }
    }
}

// MARK: - CustomTextView
final class CustomTextView: NSView {
    weak var delegate: NSTextViewDelegate?
    private let keywords = Keywords()
    
    /**
     Sets the text color, font, for default text and keywords.
     
     - parameter for: the input text to style.
     - warning: this happens many times for every text change, so it's not efficient, but it's here for now.
     */
    func setTextStyle(for text: String) -> NSMutableAttributedString{
        
        // default font and color for the text
        let defaultAttributes = [ NSAttributedString.Key.foregroundColor: NSColor(Constants.labelColor),
                                  NSAttributedString.Key.font: Constants.font] as [NSAttributedString.Key : Any]
        
        let attributedString = NSMutableAttributedString.init(string: text, attributes: defaultAttributes as [NSAttributedString.Key : Any])
        
        // for each keyword call the `drawColor` function
        Keywords.all.allCases.forEach { (keyword) in
            highlightKeyword("\(keyword.rawValue)")
        }
        
        /**
         Change the keyword color to the proper one.
         
         - parameter word: the keyword to get a color change.
         */
        func highlightKeyword(_ word: String){
            (text as String).ranges(of: word, options: .literal).forEach { (r) in
                attributedString.addAttribute(
                    .foregroundColor, value: keywords.keywordColor(Keywords.all(rawValue: word) ?? .default),
                    range: NSRange(r, in: text))
            }
        }
        
        return attributedString
    }
    
    var inputText: String {
        didSet {
            textView.string = inputText
            textView.textStorage?.setAttributedString(setTextStyle(for: inputText))
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: .infinity
        )
        
        layoutManager.addTextContainer(textContainer)
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.backgroundColor = NSColor(Constants.backgroundColor)
        textView.isVerticallyResizable = true
        textView.autoresizingMask = .width
        textView.delegate = self.delegate
        textView.allowsUndo = true
        
        return textView
    }()
    
    // MARK: - Init
    init(text: String) {
        self.inputText = text
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
}

// MARK: - String Extension
extension String {
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
              let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
}
