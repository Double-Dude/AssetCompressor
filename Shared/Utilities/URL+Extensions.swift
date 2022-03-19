//
//  URL+Extensions.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 18/03/22.
//

import Foundation

extension URL {
    func appendingToPathBeforeExtension(_ name: String) -> URL {
        let pathExtension = self.pathExtension
        let url = self.deletingPathExtension()
        let outputPath = url.path + name + "." + pathExtension
        return URL.init(fileURLWithPath: outputPath)
    }
}
