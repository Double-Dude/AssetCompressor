//
//  FFmpegVideoCompressor.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import ffmpegkit
import Foundation

class FFmpegVideoCompressor : VideoEditor {
    let ffmpegCommandFactory: FFmpegCommandFactory
    
    init(ffmpegCommandFactory: FFmpegCommandFactory) {
        self.ffmpegCommandFactory = ffmpegCommandFactory
    }
    
    func getMetadata(_ url: URL) async -> VideoMetadata {
        let command = "-loglevel 0 -print_format json -show_format -show_streams \(url.path)"
        let result = FFprobeKit.execute(command)
        let jsonDict = JSONSerialization.convertToDictionary(result!.getOutput())
        return VideoMetadata.fromDict(jsonDict!)
    }
    
    func execute(videoCompressionRequest: VideoCompressionRequest) async -> Result<URL, FFmpegVideoCompressorError> {
        let command = FFmpegCommandFactory().createVideoCompressionCommand(videoCompressionRequest)
        let session = FFmpegKit.execute(command)
        
        if(ReturnCode.isSuccess(session!.getReturnCode())) {
            return .success(videoCompressionRequest.outputFilePath)
        } else {
            return .failure(FFmpegVideoCompressorError.unexpectedError(session!.getAllLogsAsString()))
        }
    }
}

extension String {

    func slice(from: String, to: String) -> String? {

        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
