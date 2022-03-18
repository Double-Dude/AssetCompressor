//
//  WindowExtensions.swift
//  AssetCompressor
//
//  Created by Ray Qu on 6/03/22.
//

import Foundation
#if os(iOS)
import UIKit
import SwiftUI

func getSafeAreaInsets() -> UIEdgeInsets{
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first

    return keyWindow!.safeAreaInsets
}
#endif
