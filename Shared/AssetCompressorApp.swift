//
//  AssetCompressorApp.swift
//  Shared
//
//  Created by Ray Qu on 17/02/22.
//

import SwiftUI


@main
struct AssetCompressorApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    let tempFolder = FileManager.default.temporaryDirectory
                        .appendingPathComponent("cleanup-on-launch")
                    try! FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
                }
        }
    }
}
