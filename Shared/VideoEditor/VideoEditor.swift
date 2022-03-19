//
//  VideoCompressor.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import Foundation
import SwiftUI

struct VideoCompressionRequest : Equatable {
    let bitRate: Int
    let playbackSpeed: Double
    let outputFps: Int
    let outputWidth: Int
    let outputHeight: Int
    let isAudioEnabled: Bool
    let inputFilePaths: [URL]
    let outputFilePath: URL
    let trimStart: Double?
    let trimEnd: Double?
    let progress: Progress?
}

enum FFmpegVideoCompressorError: Error {
    case unexpectedError(String)
}

protocol VideoEditor {
    func getMetadata(_ url: URL) async throws -> VideoMetadata
    func execute(_ request: VideoCompressionRequest) async throws -> URL
}

class VideoProcessProgress {
    private var valueChangeCallback: ((Double) -> Void)? = nil
    private var updateInterval: Double = 0.5
    private var lastUpdateDate = Date()
    
    var value: Double = 0.0 {
        didSet {
            debugPrint("VideoProcessProgress value set")
            valueChangeCallback?(value)
        }
    }
    
    func onValueChanged(_ callback:  @escaping(Double) -> Void) {
        let now = Date()
        debugPrint("timeDiff1: \(now.timeIntervalSince(self.lastUpdateDate))")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let now = Date()
            debugPrint("timeDiff: \(now.timeIntervalSince(self.lastUpdateDate))")
            if now.timeIntervalSince(self.lastUpdateDate) >= self.updateInterval {
                self.lastUpdateDate = now
                self.valueChangeCallback = callback
            }
        }
    }
}
