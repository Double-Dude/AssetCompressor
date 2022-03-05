//
//  FileLocation.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 5/03/22.
//

import Foundation

struct FileLocation {
    static func getOrCreateCleanOnLaunchURL() -> URL {
        let tempFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent("cleanup-on-launch")
        try! FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        return tempFolder
    }
}
