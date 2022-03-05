//
//  VideoCompressor.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import Foundation
import SwiftUI

struct VideoCompressionRequest {
    let bitRate: Int
    let playbackSpeed: Double
    let outputFps: Int
    let outputWidth: Int
    let outputHeight: Int
    let inputFilePaths: [URL]
    let outputFilePath: URL
}

enum FFmpegVideoCompressorError: Error {
    case unexpectedError(String)
}

protocol VideoEditor {
    func getMetadata(_ url: URL) async -> VideoMetadata
    func execute(videoCompressionRequest: VideoCompressionRequest) async -> Result<URL, FFmpegVideoCompressorError>
}
