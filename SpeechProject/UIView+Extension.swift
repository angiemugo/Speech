//
//  UIView+Extension.swift
//  SpeechProject
//
//  Created by Angie Mugo on 31/01/2021.
//

import UIKit

extension UIButton {
    func styleButton(_ textColor: UIColor = #colorLiteral(red: 0.9894880652, green: 0.9932282567, blue: 1, alpha: 1), _ backgroundColor: UIColor = #colorLiteral(red: 0.2295188308, green: 0.3824364543, blue: 0.9958578944, alpha: 1), cornerRadius: CGFloat = 0) {
        self.setTitleColor(textColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = self.frame.size.height / 2
    }
}

extension UITextView {
    func style() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
