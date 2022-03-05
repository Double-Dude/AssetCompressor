//
//  VideoCompressionViewModel.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 5/03/22.
//

import SwiftUI

@MainActor class VideoCompressionViewModel: ObservableObject {
    @Published var frameRate: String = "0"
    @Published var width: String = "0"
    @Published var height: String = "0"
    @Published var bitrate: String = "0"
    @Published var playbackSpeed: Float = 1
    
    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?
    private lazy var outputURL: URL = {
        return FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent("Test.mp4")
    }()
    
    func onVideoSelected(_ url: URL) {
        Task {
            selectedVideoURL = url
            let metadata = await videoEditor.getMetadata(url)
            frameRate = String(metadata.fps)
            width = String(metadata.width)
            height = String(metadata.height)
            bitrate = String(metadata.bitrate)
        }
    }
    
    func compress() {
        let request = VideoCompressionRequest(
             bitRate: Int(bitrate)!,
             playbackSpeed: Double(playbackSpeed),
             outputFps: Int(frameRate)!,
             outputWidth: Int(width)!,
             outputHeight: Int(height)!,
             inputFilePaths: [selectedVideoURL!],
             outputFilePath: outputURL)
         Task.init {
             let result = await FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory()).execute(videoCompressionRequest: request)
             switch result {
                case .success(let url):
                 debugPrint("Completed \(url.path)")
                 UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
 
                case .failure(let error):
                     debugPrint("Failed \(error.localizedDescription)")
                }
         }
    }
}
