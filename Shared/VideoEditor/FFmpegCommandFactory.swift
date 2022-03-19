//
//  FFmpegRequestFactory.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import Foundation

struct FFmpegCommandFactory {
    func createVideoCompressionCommand(_ request: VideoCompressionRequest) -> String {        
        var builder = FFmpegCommandBuilder()
            .buildBitRate(request.bitRate)
            .buildPlaybackSpeed(request.playbackSpeed)
            .buildOutputFps(request.outputFps)
            .buildResolution(width: request.outputWidth, height: request.outputHeight)
            .buildEnabledAudio(request.isAudioEnabled)
            .buildInputFilePaths(request.inputFilePaths)
            .buildOutputFilePath(request.outputFilePath)
        if let trimStart = request.trimStart, let trimEnd = request.trimEnd {
            builder = builder
                .buildTrimStart(trimStart)
                .buildTrimEnd(trimEnd)
        }
           
        return try! builder.build()
    }
}
