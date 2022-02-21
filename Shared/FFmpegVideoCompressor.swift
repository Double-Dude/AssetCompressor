//
//  FFmpegVideoCompressor.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import ffmpegkit

class FFmpegVideoCompressor : VideoCompressor {
    let ffmpegCommandFactory: FFmpegCommandFactory
    
    init(ffmpegCommandFactory: FFmpegCommandFactory) {
        self.ffmpegCommandFactory = ffmpegCommandFactory
    }
    
    func execute(videoCompressionRequest: VideoCompressionRequest) async -> Result<URL, FFmpegVideoCompressorError> {
        let command = FFmpegCommandFactory().createVideoCompressionCommand(videoCompressionRequest)
        debugPrint("Command: \(command)")
        let session = FFmpegKit.execute(command)
        
        if(ReturnCode.isSuccess(session!.getReturnCode())) {
            return .success(videoCompressionRequest.outputFilePath)
        } else {
            return .failure(FFmpegVideoCompressorError.unexpectedError(session!.getAllLogsAsString()))
        }
    }
}
