//
//  Platform.swift
//  AssetCompressor
//
//  Created by Ray Qu on 22/03/22.
//

import Foundation
func isIOS() -> Bool {
    #if os(iOS)
    return true
    #else
    return false
    #endif
}
