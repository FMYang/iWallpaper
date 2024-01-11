//
//  String+Extension.swift
//  iMusic
//
//  Created by yfm on 2023/11/23.
//

import Foundation
import UIKit

extension String {
    static func format(time: Float) -> String {
        let totalSeconds = time
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 计算字符串的宽高
    ///
    /// - Parameters:
    ///   - size: 目标字符串宽高，计算高度设置宽为MAXFLOAT，计算宽度设置高度为MAXFLOAT
    ///   - font: 目标字符串使用的字体
    /// - Returns: 目标字符串的Size结构体
    func sizeWithString(size: CGSize, font: UIFont) -> CGSize {
        
        return self.boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading, attributes: [NSAttributedString.Key.font: font], context: nil).size
        
    }
}
