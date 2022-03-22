//
//  URL+Extensions.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 18/03/22.
//

import Foundation

extension URL {
    func appendingToFileName(_ name: String) -> URL {
        let pathExtension = self.pathExtension
        let url = self.deletingPathExtension()
        let outputPath = url.path + name + "." + pathExtension
        return URL.init(fileURLWithPath: outputPath)
    }
    
    func replaceExtension(_ extensionName: String) -> URL {
        let newURL = self.deletingPathExtension().appendingPathExtension(extensionName)
        return newURL
    }
}
