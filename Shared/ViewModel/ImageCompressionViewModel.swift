//
//  ImageCompressionViewModel.swift
//  AssetCompressor
//
//  Created by Ray Qu on 23/03/22.
//

import Foundation
import ffmpegkit
import SwiftUI

@MainActor class ImageCompressionViewModel: ObservableObject {
    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    private var selectedVideoURL: URL?

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
    
    @Published var quality: Float = 1 {
        didSet {
            delayToCalculateEstimateSize()
        }
    }
    @Published var isCalculatingEstimateSize: Bool = false
    @Published var estimateFileSize: String = "0.0"
    @Published var progress: Double = 0.0
    @Published var compressing: Bool = false

    var onCompletion: (() -> Void)?
    private var delayToCalculateEstimateSizeTask: Task<(), Never>?
    private var compressionSession: FFmpegSession?
    private var compressedURL: URL?

    func onImageSelect(_ url: URL) {
        selectedVideoURL = url
        Task {
            let media = try await videoEditor.getMetadata(url)
            width = String(media.width)
            height = String(media.height)
        }
    }
    
    private func delayToCalculateEstimateSize() {
        compressionSession?.cancel()
        delayToCalculateEstimateSizeTask?.cancel()
        delayToCalculateEstimateSizeTask = Task { [weak self] in
            do {
                self?.isCalculatingEstimateSize = true
                try await Task.sleep(seconds: 3)
                try await self?.calculateEstimateSize()
                self?.isCalculatingEstimateSize = false
                debugPrint("finished calculating")
            } catch is CancellationError {
                self?.isCalculatingEstimateSize = false
            } catch {
                self?.isCalculatingEstimateSize = false
                debugPrint("Failed \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateEstimateSize() async throws {
        let url = try await compressImage()
        let metadata = try await videoEditor.getMetadata(url)
        estimateFileSize = convertBytesToFormattedString(metadata.size)
        try FileManager.default.removeItem(at: url)
    }
    
    private func compressImage() async throws -> URL {
        let quality = 31 - quality * 31
        let roundedQuality = Int(quality)
        let outputURL = createEstimateURL()

        return try await withCheckedThrowingContinuation { continuation in
            compressionSession = FFmpegKit.execute("-y -i \(selectedVideoURL!.path) -vf \"scale=\(width):\(height)\" -qscale:v \(roundedQuality) \(outputURL)")
            
            if(ReturnCode.isSuccess(compressionSession!.getReturnCode())) {
                continuation.resume(with: .success(outputURL))
            } else {
                continuation.resume(with: .failure(FFmpegVideoCompressorError.unexpectedError(compressionSession!.getAllLogsAsString())))
            }
        }
 
       
    }
    
    private func convertBytesToFormattedString(_ size: Int64) -> String{
        let sizeInMB = Double(size) / 1000 / 1000
        return String(format: "%.2f", sizeInMB)
    }
    
    private func createEstimateURL() -> URL {
        let name = selectedVideoURL!.appendingToFileName("_estimate").deletingPathExtension().appendingPathExtension(".jpg").lastPathComponent
        let outputURL = FileLocation.getOrCreateCleanOnLaunchURL().appendingPathComponent(name)
        return outputURL
    }

    func compress() {
        progress = 0
        compressing = true
        compressionSession?.cancel()
        Task.init {
            do {
                let url = try await compressImage()
                compressedURL = url
                self.progress = 1
                try! await Task.sleep(seconds: 1.5)
                compressing = false
                self.progress = 0
                saveVideo(url)
            } catch {
                debugPrint("Compression error: \(error)")
                compressing = false
                self.progress = 0
            }
        }

    }
    
    private func saveVideo(_ videoURL: URL) {
        #if os(iOS)
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, nil, nil)
        #else
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let savePanel = NSSavePanel()
            let name = self.selectedVideoURL!.appendingToFileName("_compressed").replaceExtension("jpg").lastPathComponent
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

    deinit {
        delayToCalculateEstimateSizeTask?.cancel()
        if let compressedURL = compressedURL {
            do {
                try FileManager.default.removeItem(at: compressedURL)
            } catch {
                
            }
        }
    }
}
