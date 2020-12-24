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
    @EnvironmentObject var script: ScriptVM
    @Binding var input: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: input,
            errorLineIndex: script.errorLineIndex
        )
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.inputText = input
        view.errorLineIndex = script.errorLineIndex
        view.selectedRanges = context.coordinator.selectedRanges
    }
}

struct ScriptTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScriptTextView( input: .constant("for i in 0…100000{ \n print(i) \n }") )
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ScriptTextView( input: .constant("for i in 0…100000{ \n print(i) \n }") )
                .environmentObject(ScriptVM())
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}

// MARK: - Coordinator
extension ScriptTextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: ScriptTextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: ScriptTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            parent.input = textView.string
            selectedRanges = textView.selectedRanges
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
    func setTextStyle(for text: String, errorLine: Int = -1) -> NSMutableAttributedString{
        
        // default font and color for the text
        let defaultAttributes = [ NSAttributedString.Key.foregroundColor: NSColor(Constants.labelColor),
                                  NSAttributedString.Key.font: Constants.font] as [NSAttributedString.Key : Any]
        
        let attributedString = NSMutableAttributedString.init(string: text, attributes: defaultAttributes as [NSAttributedString.Key : Any])
        
        // for each keyword call the `drawColor` function
        Keywords.all.allCases.forEach { (keyword) in
            if text.contains(keyword.rawValue){
                highlightKeyword("\(keyword.rawValue)")
            }
        }
        
        /**
         Change the keyword color to the proper one.
         
         - parameter word: the keyword to get a color change.
         */
        func highlightKeyword(_ word: String){
            (text as String).ranges(of: word, options: .literal).forEach { (r) in
                let keywordColor = keywords.keywordColor(Keywords.all(rawValue: word) ?? .default)
                
                attributedString.addAttribute(.foregroundColor,
                                              value: keywordColor.withAlphaComponent(0.9),
                                              range: NSRange(r, in: text))
            }
        }
        
        // to set the error line background color, when choosing it from the output
        if errorLine != -1{
            let lines =  text.components(separatedBy:"\n")
            
            if (errorLine - 1) < lines.count{
                var errorLineString = lines[errorLine - 1]
                
                if lines.count != errorLine{ // if last line
                    errorLineString += "\n"
                }
                
                guard let range = (text as String).range(of: errorLineString, options: .literal) else { return attributedString }
                
                attributedString.addAttribute(.backgroundColor,
                                              value: NSColor.systemRed.withAlphaComponent(0.5),
                                              range: NSRange(range, in: errorLineString))
            }
        }
        
        return attributedString
    }
    
    var inputText: String {
        didSet {
            textView.textStorage?.setAttributedString(setTextStyle(for: inputText))
        }
    }
    
    var errorLineIndex: Int? {
        didSet{
            guard let line = errorLineIndex else { return }
            if line != -1{
                textView.textStorage?.setAttributedString(setTextStyle(for: inputText, errorLine: line))
            }
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
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
    init(text: String, errorLineIndex: Int?) {
        inputText = text
        
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
