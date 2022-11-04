//
//  UITextField+Extension.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 30.10.2022.
//

import UIKit

extension UITextField {

    func ident(size: CGFloat) {
        leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: self.frame.height)))
        leftViewMode = .always
    }
    
}
