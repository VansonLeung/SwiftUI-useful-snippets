import SwiftUI

class KeyboardManager: ObservableObject {
    static let shared = KeyboardManager()
    
    @Published var estimatedKeyboardFrame: CGRect? = nil
    @Published var keyboardFrame: CGRect? = nil

    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboardOnDid), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    @objc func willHide() {
        self.estimatedKeyboardFrame = .zero
        self.keyboardFrame = .zero
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        self.estimatedKeyboardFrame = keyboardScreenEndFrame
    }
    
    @objc func adjustForKeyboardOnDid(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        self.keyboardFrame = keyboardScreenEndFrame
    }
}
