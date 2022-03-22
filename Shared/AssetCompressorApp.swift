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
//                var url = FileLocation.getOrCreateCleanOnLaunchURL()
//                url.appendPathComponent("test.txt")
//                debugPrint("url: \(url)")
//                debugPrint(url.lastPathComponent)
//                FileManager.default.createFile(atPath: url.path, contents: nil)
                
            }
        }
    }
}
