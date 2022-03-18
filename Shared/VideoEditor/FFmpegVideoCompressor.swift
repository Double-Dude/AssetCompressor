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
    
    func execute(videoCompressionRequest: VideoCompressionRequest) async throws -> URL {
        let command = FFmpegCommandFactory().createVideoCompressionCommand(videoCompressionRequest)
        debugPrint("Compress Video Command: \(command)")
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                var totalDuration = 0.0
                for url in videoCompressionRequest.inputFilePaths {
                    totalDuration += await getMetadata(url).duration
                }
                videoCompressionRequest.progress?.totalUnitCount = Int64(totalDuration)

                debugPrint("totalDuration: \(totalDuration)")

                FFmpegKit.executeAsync(command) { session in
                    
                    if(ReturnCode.isSuccess(session!.getReturnCode())) {
                        continuation.resume(with: .success(videoCompressionRequest.outputFilePath))
                    } else {
                        continuation.resume(with: .failure(FFmpegVideoCompressorError.unexpectedError(session!.getAllLogsAsString())))
                    }
                } withLogCallback: { log in
                    log?.getMessage()
                    debugPrint("Log: \( log!.getMessage())")
                } withStatisticsCallback: { stats in
                    if let currentTime = stats?.getTime() {
                        videoCompressionRequest.progress?.completedUnitCount = Int64(currentTime) / 1000
                        debugPrint("currentTime: \(currentTime)")
                        debugPrint("percentage: \(videoCompressionRequest.progress?.fractionCompleted)")
                    }
                }
            }
            
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
