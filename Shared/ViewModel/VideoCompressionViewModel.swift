//
//  VideoCompressionViewModel.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 5/03/22.
//

import SwiftUI
import Combine
import Foundation

@MainActor class VideoCompressionViewModel: ObservableObject {
    @Published var frameRate: String = "0"
    @Published var width: String = "0"
    @Published var height: String = "0"
    @Published var bitrate: String = "0"
    @Published var playbackSpeed: Float = 1
    @Published var estimateFileSize: String = "0.0"
    @Published var isAudioEnabled: Bool = true
    @Published var progress: Double = 0.0
    @Published var compressing: Bool = false
    @Published var hasCompleted = false
    
    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?
    private lazy var outputURL: URL = {
        return FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent("Test.mp4")
    }()
    private var metadata: VideoMetadata?
    private var subscribers: Set<AnyCancellable> = []
    private var compressionProgress = Progress()
    private var progressObservation: NSKeyValueObservation?
    
    init() {
        $bitrate.sink {[weak self] value in
            guard let self = self else { return }
            self.calculateVideoSize(bitrate: value, playback: self.playbackSpeed, isAudioEnabled: self.isAudioEnabled)
        }.store(in: &subscribers)
        $playbackSpeed.sink {[weak self] value in
            guard let self = self else { return }
            self.calculateVideoSize(bitrate: self.bitrate, playback: value, isAudioEnabled: self.isAudioEnabled)
        }.store(in: &subscribers)
        $isAudioEnabled.sink {[weak self] value in
            guard let self = self else { return }
            self.calculateVideoSize(bitrate: self.bitrate, playback: self.playbackSpeed, isAudioEnabled: value)
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
        compressing = true
        compressionProgress = Progress()
        progressObservation = compressionProgress.observe(\Progress.fractionCompleted, options: .new) { progress, change in
            DispatchQueue.main.async {  [weak self] in
                self?.progress = progress.fractionCompleted
            }
        }

        let request = VideoCompressionRequest(
             bitRate: Int(bitrate)!,
             playbackSpeed: Double(playbackSpeed),
             outputFps: Int(frameRate)!,
             outputWidth: Int(width)!,
             outputHeight: Int(height)!,
             isAudioEnabled: isAudioEnabled,
             inputFilePaths: [selectedVideoURL!],
             outputFilePath: outputURL,
             progress: compressionProgress
        )
        
         Task.init {
             do {
                 let url = try await FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory()).execute(videoCompressionRequest: request)
                 debugPrint("Completed \(url.path)")
                 UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
                 
                 self.progress = 1
                 try await Task.sleep(seconds: 1.5)
                 compressing = false
                 self.progress = 0
                 hasCompleted = false
             } catch {
                 debugPrint("Failed \(error.localizedDescription)")
                 compressing = false
                 self.progress = 0
             }
         }
    }
    
    private func calculateVideoSize(bitrate: String, playback: Float, isAudioEnabled: Bool) {
        if(metadata == nil || bitrate.isEmpty) { return }
        let duration = metadata!.duration / Double(playbackSpeed)
        let sizeInBytes = Double(bitrate)! / 8 * duration
        var sizeInMB = sizeInBytes / 1000 / 1000
        sizeInMB = isAudioEnabled ? sizeInMB * 2 : sizeInMB
        estimateFileSize = String(format: "%.1f", sizeInMB)
    }
    
    deinit {
        subscribers.forEach { disposable in
            disposable.cancel()
        }
    }
}
