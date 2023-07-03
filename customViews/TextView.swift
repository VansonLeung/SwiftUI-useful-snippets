//
//  TextView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 7/2/2022.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var isResponder : Bool?
    
    let frame: CGRect
    var configuration = { (view: UITextView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let tv = UITextView(frame: frame)
        tv.delegate = context.coordinator
//        tv.layer.borderColor = UIColor.systemGray5.cgColor
//        tv.layer.borderWidth = 1
//        tv.layer.cornerRadius = 5
        tv.font = TP1App_UIFontFile_NotoSans_SemiBold(size: 16, style: .body)
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        return tv
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        uiView.text = text
        configuration(uiView)
    }
    
    func makeCoordinator() -> TextView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let textRange = textView.markedTextRange {
                
            } else {
                parent.text = textView.text
                textView.textViewDidChange(textView)
            }
        }
        
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.parent.isResponder = true
        }
      
        func textViewDidEndEditing(_ textView: UITextView) {
            self.parent.isResponder = false
        }
    }
}




extension UITextView : UITextViewDelegate
{
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top
//            let labelX = 0.0
//            let labelY = 0.0
//            let labelWidth = self.frame.width - (labelX * 2)
//            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: UIScreen.main.bounds.width, height: 240)
            placeholderLabel.sizeToFit()
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.systemGray4
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
}
