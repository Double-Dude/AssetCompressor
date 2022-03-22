//
//  AssetCompressorApp.swift
//  Shared
//
//  Created by Ray Qu on 17/02/22.
//

import SwiftUI

#if os(iOS)
let safeAreaInsets = getSafeAreaInsets()
#endif

@main
struct AssetCompressorApp: App {
    var body: some Scene {
        WindowGroup {
            MainView().onAppear {
                do {
                    let url = FileLocation.getOrCreateCleanOnLaunchURL()
                    try FileManager.default.removeItem(at: url)
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}
