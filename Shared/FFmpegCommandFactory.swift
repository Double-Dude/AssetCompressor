//
//  FFmpegRequestFactory.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import Foundation

struct FFmpegCommandFactory {
    func createVideoCompressionCommand(_ request: VideoCompressionRequest) -> String {        
        return try! FFmpegCommandBuilder()
            .buildBitRate(request.bitRate)
            .buildPlaybackSpeed(request.playbackSpeed)
            .buildOutputFps(request.outputFps)
            .buildResolution(width: request.outputWidth, height: request.outputHeight)
            .buildInputFilePaths(request.inputFilePaths)
            .buildOutputFilePath(request.outputFilePath)
            .build()
    }
}
