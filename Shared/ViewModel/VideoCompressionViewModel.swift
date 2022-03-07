//
//  VideoCompressionViewModel.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 5/03/22.
//

import SwiftUI
import Combine

@MainActor class VideoCompressionViewModel: ObservableObject {
    @Published var frameRate: String = "0"
    @Published var width: String = "0"
    @Published var height: String = "0"
    @Published var bitrate: String = "0"
    @Published var playbackSpeed: Float = 1
    @Published var estimateFileSize: String = "0.0"

    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?
    private lazy var outputURL: URL = {
        return FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent("Test.mp4")
    }()
    private var metadata: VideoMetadata?
    private var subscribers: Set<AnyCancellable> = []
    
    init() {
        $bitrate.sink {[weak self] _ in
            self?.calculateVideoSize()
        }.store(in: &subscribers)
        $playbackSpeed.sink {[weak self] _ in
            self?.calculateVideoSize()
        }.store(in: &subscribers)
    }
    
    func onVideoSelected(_ url: URL) {
        Task {
            selectedVideoURL = url
            let metadata = await videoEditor.getMetadata(url)
            self.metadata = metadata
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
    
    private func calculateVideoSize() {
        if(metadata == nil || bitrate.isEmpty) { return }
        let duration = metadata!.duration / Double(playbackSpeed)
        let sizeInBytes = Double(bitrate)! / 8 * duration
        let sizeInMB = sizeInBytes / 1000 / 1000
        estimateFileSize = String(format: "%.1f", sizeInMB)
    }
    
    deinit {
        subscribers.forEach { disposable in
            disposable.cancel()
        }
    }
}
