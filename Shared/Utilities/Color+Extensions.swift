//
//  Color+Extensions.swift
//  AssetCompressor
//
//  Created by Ray Qu on 20/02/22.
//

import Foundation
import SwiftUI

extension Color {
    static func fromHex(_ hex: Int) -> Color! {
        return Color(
            red: CGFloat((Float((hex & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((hex & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((hex & 0x0000ff) >> 0)) / 255.0)
        )
    }
}

//extension UIColor {
//}
