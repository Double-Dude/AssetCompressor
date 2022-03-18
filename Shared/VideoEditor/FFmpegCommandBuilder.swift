//
//  FFmpegRequestBuilder.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import Foundation

enum FFmpegRequestBuilderError : Error {
    case missingArgument(String)
}

class FFmpegCommandBuilder {
    private var playbackSpeed = 1.0
    private var width = 640
    private var height = 360
    private var outputFps = 14
    private var inputFilePaths: [URL]?
    private var outputFilePath: URL?
    private var bitRate: Int = 1096
    private var isAudioEnabled: Bool = true
    private var command: String = ""
    
    func buildPlaybackSpeed(_ playbackSpeed: Double) -> Self {
        self.playbackSpeed = playbackSpeed
        return self
    }
    
    func buildResolution(width: Int, height: Int) -> Self {
        self.width = width
        self.height = height
        return self
    }
    
    func buildOutputFps(_ outputFps: Int) -> Self {
        self.outputFps = outputFps
        return self
    }
    
    func buildInputFilePaths(_ filePaths: [URL]) -> Self {
        self.inputFilePaths = filePaths
        return self
    }

    
    func buildOutputFilePath(_ outputFilePath: URL) -> Self {
        self.outputFilePath = outputFilePath
        return self
    }
    
    
    func buildBitRate(_ bitRate: Int) -> Self {
        self.bitRate = bitRate
        return self
    }
    
    func buildEnabledAudio(_ isAudioEnabled: Bool) -> Self {
        self.isAudioEnabled = isAudioEnabled
        return self
    }
    
    func build() throws -> String {
        guard let inputFilePaths = inputFilePaths, let outputFilePath = outputFilePath else {
            throw FFmpegRequestBuilderError.missingArgument("Missing input or output file paths")
        }
        
        appendCommandOption("-y") // overwrite if there is a file with the same name
        for inputFilePath in inputFilePaths {
            appendCommandOption("-i", argument: inputFilePath.path)
        }
        
        appendCommandOption("-filter_complex", argument: buildFilterArgument(inputFilePaths: inputFilePaths, isAudioEnabled: isAudioEnabled))
        appendCommandOption("-b:v", argument: String(bitRate))
        appendCommandOption("-map", argument: "\"[v]\"")

        if(isAudioEnabled) {
            appendCommandOption("-b:a", argument: String(bitRate))
            appendCommandOption("-map", argument: "\"[a]\"")
        }
       
        appendOutput(outputFilePath.path)

        return command
    }
    
    private func buildFilterArgument(inputFilePaths: [URL], isAudioEnabled: Bool) -> String {
        if isAudioEnabled {
            return buildFilterArgumentWithAudio(inputFilePaths: inputFilePaths)
        } else {
            return buildFilterArgumentWithoutAudio(inputFilePaths: inputFilePaths)
        }
    }
    
    private func buildFilterArgumentWithAudio(inputFilePaths: [URL]) -> String {
        var filterArgument = "\""
        
        for (index, _) in inputFilePaths.enumerated() {
            filterArgument += "[\(index):v]scale=\(width)*\(height),setpts=\(1/playbackSpeed)*PTS,fps=\(outputFps)[v\(index)];"
            filterArgument += "[\(index):a]atempo=\(playbackSpeed)[a\(index)];"
        }
        
        for (index, _) in inputFilePaths.enumerated() {
            filterArgument += "[v\(index)][a\(index)]"
        }
        
        filterArgument += "concat=n=\(inputFilePaths.count):v=1:a=1[v][a]"
        filterArgument += "\""
       
        return filterArgument
    }
    
    private func buildFilterArgumentWithoutAudio(inputFilePaths: [URL]) -> String {
        var filterArgument = "\""
        
        for (index, _) in inputFilePaths.enumerated() {
            filterArgument += "[\(index):v]scale=\(width)*\(height),setpts=\(1/playbackSpeed)*PTS,fps=\(outputFps)[v\(index)];"
        }
        
        for (index, _) in inputFilePaths.enumerated() {
            filterArgument += "[v\(index)]"
        }
        
        filterArgument += "concat=n=\(inputFilePaths.count):v=1:a=0[v]"
        filterArgument += "\""
       
        return filterArgument
    }
    
    private func appendCommandOption(_ option: String) {
        command += "\(option)" + " "
    }

    private func appendCommandOption(_ option: String, argument: String) {
        command  += "\(option) \(argument)" + " "
    }
    
    private func appendOutput(_ outputPath: String) {
        command  += "\(outputPath)"
    }
}
