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
    @Published var frameRate: String = "0" {
       didSet {
           delayToCalculateEstimateSize()
       }
   }
    
    @Published var width: String = "0" {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    
    @Published var height: String = "0" {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    
    @Published var bitrate: String = "0" {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    
    @Published var playbackSpeed: Float = 1 {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    
    @Published var isAudioEnabled: Bool = true {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    
    @Published var estimateFileSize: String = "0.0"
    @Published var progress: Double = 0.0
    @Published var compressing: Bool = false
    @Published var isCalculatingEstimateSize: Bool = false
    var onCompletion: (() -> Void)?

    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?
    private var metadata: VideoMetadata?
//    private var subscribers: Set<AnyCancellable> = []
    private var compressionProgress = Progress()
    private var progressObservation: NSKeyValueObservation?
    private var delayToCalculateEstimateSizeTask: Task<(), Never>?
    private var calculateEstimateSizeRequest: VideoCompressionRequest?

    func onVideoSelected(_ url: URL) {
        Task {
            selectedVideoURL = url
            let metadata = try! await videoEditor.getMetadata(url)
            self.metadata = metadata
            frameRate = String(metadata.fps)
            width = String(metadata.width)
            height = String(metadata.height)
            bitrate = String(metadata.bitrate)
            estimateFileSize = convertBytesToFormattedString(Double(metadata.size))
            
            
//            subscribers.forEach { cancellable in
//                cancellable.cancel()
//            }
//            subscribers.removeAll()
            
//            $bitrate.sink {[weak self] value in
//                guard let self = self else { return }
//                if(value == self.bitrate) { return }
//
////                self.calculateEstimateSize()
//                self.delayToCalculateEstimateSize(bitrate: value, playback: self.playbackSpeed, isAudioEnabled: self.isAudioEnabled)
//            }
//            .store(in: &subscribers)
//            $playbackSpeed.sink {[weak self] value in
//                guard let self = self else { return }
//                if(value == self.playbackSpeed) { return }
//
//                self.delayToCalculateEstimateSize(bitrate: self.bitrate, playback: value, isAudioEnabled: self.isAudioEnabled)
//            }.store(in: &subscribers)
//            $isAudioEnabled.sink {[weak self] value in
//                guard let self = self else { return }
//                if(value == self.isAudioEnabled) { return }
//
//                self.delayToCalculateEstimateSize(bitrate: self.bitrate, playback: self.playbackSpeed, isAudioEnabled: value)
//            }.store(in: &subscribers)
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
             outputFilePath: selectedVideoURL!.appendingToPathBeforeExtension("_compressed"),
             trimStart: nil,
             trimEnd: nil,
             progress: compressionProgress
        )
        
         Task.init {
             do {
                 let url = try await videoEditor.execute(request)
                 debugPrint("Completed \(url.path)")
                 UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
//                 try FileManager.default.removeItem(at: url)
                 self.progress = 1
                 try! await Task.sleep(seconds: 1.5)
                 compressing = false
                 delayToCalculateEstimateSizeTask?.cancel()
                 self.progress = 0
                 onCompletion?()
             } catch {
                 debugPrint("Failed \(error.localizedDescription)")
                 compressing = false
                 self.progress = 0
             }
         }
    }
    
    func delayToCalculateEstimateSize() {
        delayToCalculateEstimateSizeTask?.cancel()
        delayToCalculateEstimateSizeTask = Task { [weak self] in
            do {
                isCalculatingEstimateSize = true
                try await Task.sleep(seconds: 3)
                try await self?.calculateEstimateSize()
                debugPrint("finished calculating")
                isCalculatingEstimateSize = false
            } catch is CancellationError {
                
            } catch {
                debugPrint("Failed \(error.localizedDescription)")
            }
        }
    }
    
    func calculateEstimateSize() async throws  {
        guard let orginalMetadata = metadata else {
            return
        }
        
        let trimEnd = orginalMetadata.duration < 10.0 ? orginalMetadata.duration : 10.0
        let request = VideoCompressionRequest(
             bitRate: Int(bitrate)!,
             playbackSpeed: Double(playbackSpeed),
             outputFps: Int(frameRate)!,
             outputWidth: Int(width)!,
             outputHeight: Int(height)!,
             isAudioEnabled: isAudioEnabled,
             inputFilePaths: [selectedVideoURL!],
             outputFilePath: selectedVideoURL!.appendingToPathBeforeExtension("_estimate"),
             trimStart: 0,
             trimEnd: trimEnd,
             progress: compressionProgress
        )
        
        if calculateEstimateSizeRequest == request { return }
       calculateEstimateSizeRequest = request
        
        let url = try await videoEditor.execute(request)
        defer {
            try! FileManager.default.removeItem(at: url)
        }
        let estimatedVideoMetadata = try await videoEditor.getMetadata(url)
        let ratio = orginalMetadata.duration / Double(playbackSpeed) / estimatedVideoMetadata.duration
        let sizeInBytes = Double(estimatedVideoMetadata.size) * ratio
        estimateFileSize = convertBytesToFormattedString(sizeInBytes)
        debugPrint("url: \(url) -- playback: \(playbackSpeed) -- estimate duration: \(estimatedVideoMetadata.duration)")
        debugPrint("estimate:\(estimatedVideoMetadata)")
    }
    
    private func convertBytesToFormattedString(_ size: Double) -> String{
        let sizeInMB = size / 1000 / 1000
        return String(format: "%.1f", sizeInMB)
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
//        subscribers.forEach { disposable in
//            disposable.cancel()
//        }
        delayToCalculateEstimateSizeTask?.cancel()
    }
}
