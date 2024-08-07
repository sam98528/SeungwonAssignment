//
//  BaseViewControllerExtension.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//

import UIKit

extension BaseViewController {
    func configureBackButton() {
        let closeButton = UIBarButtonItem(image: UIImage.chevronLeft, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func configureCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage.x, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func isValidText(_ nickname: String) -> Bool {
        let regex = "^[a-z0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
    func isOnlyNumber(_ nickname: String) -> Bool {
        let regexNumber = "^[0-9]*$"
        let predicateNumber = NSPredicate(format: "SELF MATCHES %@", regexNumber)
        return predicateNumber.evaluate(with: nickname)
    }
    func isOnlyLetter(_ nickname: String) -> Bool {
        let regexNumber = "^[a-z]*$"
        let predicateNumber = NSPredicate(format: "SELF MATCHES %@", regexNumber)
        return predicateNumber.evaluate(with: nickname)
    }
    
    func shakeTextField(_ textfield : UITextField) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.values = [
            NSValue(cgPoint: CGPoint(x: textfield.center.x, y: textfield.center.y-5)),
            NSValue(cgPoint: CGPoint(x: textfield.center.x, y: textfield.center.y+5))
        ]
        animation.autoreverses = true
        animation.repeatCount = 1
        textfield.layer.add(animation, forKey: "position")
    }
    
    func clearLoginInfo(completion: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "userPassword")
        defaults.removeObject(forKey: "userNickName")
        completion()
    }
    
    func saveLoginInfo(user: User , completion: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: "userId")
        defaults.set(user.password, forKey: "userPassword")
        defaults.set(user.nickName, forKey: "userNickName")
        completion()
    }
}
