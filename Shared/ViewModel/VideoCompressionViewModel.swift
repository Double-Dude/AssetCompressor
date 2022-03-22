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
    @Published var hasAudioStream: Bool = true
    var onCompletion: (() -> Void)?

    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?
    private var metadata: VideoMetadata?
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
            isAudioEnabled = metadata.hasAudio
            hasAudioStream = metadata.hasAudio
            estimateFileSize = convertBytesToFormattedString(Double(metadata.size))
        }
    }
    
    func compress() {
        delayToCalculateEstimateSizeTask?.cancel()

        compressing = true
        compressionProgress = Progress()
        progressObservation = compressionProgress.observe(\Progress.fractionCompleted, options: .new) { progress, change in
            DispatchQueue.main.async {  [weak self] in
                self?.progress = progress.fractionCompleted
            }
        }

        let name = selectedVideoURL!.appendingToFileName("_compressed").lastPathComponent
        let outputURL = FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent(name)
        let request = VideoCompressionRequest(
             bitRate: Int(bitrate)!,
             playbackSpeed: Double(playbackSpeed),
             outputFps: Int(frameRate)!,
             outputWidth: Int(width)!,
             outputHeight: Int(height)!,
             isAudioEnabled: isAudioEnabled,
             inputFilePaths: [selectedVideoURL!],
             outputFilePath: outputURL,
             trimStart: nil,
             trimEnd: nil,
             progress: compressionProgress
        )
        
         Task.init {
             do {
                 let url = try await videoEditor.execute(request)
                 debugPrint("Completed \(url.path)")
                 self.progress = 1
                 try! await Task.sleep(seconds: 1.5)
                 saveVideo(url)
                 compressing = false
                 self.progress = 0
             } catch {
                 debugPrint("Failed \(error.localizedDescription)")
                 compressing = false
                 self.progress = 0
             }
         }
    }
    
    private func saveVideo(_ videoURL: URL) {
        #if os(iOS)
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, nil, nil)
        onCompletion?()
        #else
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            let savePanel = NSSavePanel()
            let name = weakSelf.selectedVideoURL!.appendingToFileName("_compressed").replaceExtension("mp4").lastPathComponent
            savePanel.nameFieldStringValue = name
            savePanel.canCreateDirectories = true
            
            savePanel.begin { [weak self] result in
                if result == NSApplication.ModalResponse.OK {
                    debugPrint("Result: \(result)")
                    FileManager.default.createFile(atPath: savePanel.url!.path, contents: try! Data(contentsOf: videoURL))
                    self?.onCompletion?()
                } else {
                    debugPrint("Result Failed: \(result)")
                }
            }

        }
        #endif
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
        guard let orginalMetadata = metadata, let bitrate = Int(bitrate), let frameRate = Int(frameRate), let width = Int(width), let height = Int(height), let selectedVideoURL = selectedVideoURL else {
            return
        }
        
        if width == 0 || height == 0 || width % 2 == 1 || height % 2 == 1 {
            return
        }
        
        let name = selectedVideoURL.appendingToFileName("_estimate").lastPathComponent
        let outputURL = FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent(name)
        let trimEnd = orginalMetadata.duration < 15.0 ? orginalMetadata.duration : 15.0
        let request = VideoCompressionRequest(
             bitRate: bitrate,
             playbackSpeed: Double(playbackSpeed),
             outputFps: frameRate,
             outputWidth: width,
             outputHeight: height,
             isAudioEnabled: isAudioEnabled,
             inputFilePaths: [selectedVideoURL],
             outputFilePath: outputURL,
             trimStart: 0,
             trimEnd: trimEnd,
             progress: nil
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
        delayToCalculateEstimateSizeTask?.cancel()
    }
}
