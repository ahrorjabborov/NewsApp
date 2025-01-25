//
//  UIColorExtensions.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit

// extension to use hex

extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        if hexString.count == 6 {
            hexString.append("FF")
        }
        
        guard hexString.count == 8 else {
            return nil
        }
        
        var rgbaValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbaValue) else {
            return nil
        }
        
        let red   = CGFloat((rgbaValue & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgbaValue & 0x00FF0000) >> 16) / 255.0
        let blue  = CGFloat((rgbaValue & 0x0000FF00) >> 8)  / 255.0
        let alpha = CGFloat(rgbaValue & 0x000000FF)        / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
