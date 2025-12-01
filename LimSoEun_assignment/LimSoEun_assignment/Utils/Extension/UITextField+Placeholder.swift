//
//  UITextField+Placeholder.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 12/1/25.
//

import UIKit

public extension UITextField {
    /// placeholder 텍스트 색상 설정
    func setPlaceholder(color: UIColor) {
        guard let string = self.placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [.foregroundColor: color]
        )
    }
}
