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
    
    private var compressionSession: FFmpegSession?
    
    init(ffmpegCommandFactory: FFmpegCommandFactory) {
        self.ffmpegCommandFactory = ffmpegCommandFactory
    }
    
    func getMetadata(_ url: URL) async throws -> VideoMetadata {
        let command = "-loglevel 0 -print_format json -show_format -show_streams \(url.path)"
        let result = FFprobeKit.execute(command)
        let jsonDict = JSONSerialization.convertToDictionary(result!.getOutput())
        if jsonDict == nil || jsonDict!.isEmpty {
            throw FFmpegVideoCompressorError.unexpectedError("Unable to parse json: \(String(describing: jsonDict))")
        }
 
        let metadata = VideoMetadata.fromDict(jsonDict!)
        guard let metadata = metadata else {
            throw FFmpegVideoCompressorError.unexpectedError("Unable to parse json: \(jsonDict!)")
        }
        
        return metadata
    }
    
//    private func createMetadata(mediaInformation: MediaInformation) -> VideoMetadata {
//        return VideoMetadata(
//            bitrate = Int(mediaInformation.getBitrate())!,
//            width = Int(mediaInformation.get)!,
//            let height: Int
//            let fps: Int
//            let duration: Double
//            let size: Int64 // bytes
//        )
//    }
    
    func execute(_ request: VideoCompressionRequest) async throws -> URL {
        let command = FFmpegCommandFactory().createVideoCompressionCommand(request)
        debugPrint("Compress Video Command: \(command)")
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                var totalDuration = 0.0
                for url in request.inputFilePaths {
                    totalDuration += try await getMetadata(url).duration
                }
                request.progress?.totalUnitCount = Int64(totalDuration/request.playbackSpeed)

                debugPrint("totalDuration: \(totalDuration)")

                FFmpegKit.executeAsync(command) { [weak self] session in
                    self?.compressionSession?.cancel()
                    self?.compressionSession = session
                    if(ReturnCode.isSuccess(session!.getReturnCode())) {
                        continuation.resume(with: .success(request.outputFilePath))
                    } else {
                        continuation.resume(with: .failure(FFmpegVideoCompressorError.unexpectedError(session!.getAllLogsAsString())))
                    }
                } withLogCallback: { log in
                    log?.getMessage()
                    debugPrint("Log: \( log!.getMessage())")
                } withStatisticsCallback: { stats in
                    if let currentTime = stats?.getTime() {
                        request.progress?.completedUnitCount = Int64(currentTime) / 1000
                        debugPrint("currentTime: \(currentTime)")
                        debugPrint("percentage: \(request.progress?.fractionCompleted)")
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
