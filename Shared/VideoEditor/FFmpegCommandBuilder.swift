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
    private var trimStart: Double?
    private var trimEnd: Double?
    
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
    
    func buildTrimStart(_ trimStart: Double) -> Self {
        self.trimStart = trimStart
        return self
    }
    
    func buildTrimEnd(_ trimEnd: Double) -> Self {
        self.trimEnd = trimEnd
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
            filterArgument += buildVideoFilterLine(index: index)
            filterArgument += buildAudioFilterLine(index: index)
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
            filterArgument += buildVideoFilterLine(index: index)
        }
        
        for (index, _) in inputFilePaths.enumerated() {
            filterArgument += "[v\(index)]"
        }
        
        filterArgument += "concat=n=\(inputFilePaths.count):v=1:a=0[v]"
        filterArgument += "\""
       
        return filterArgument
    }
    
    private func buildVideoFilterLine(index: Int) -> String {
        let tagStart = "[\(index):v]"
        let tagEnd = "[v\(index)];"
        var trim: String?
        if let trimStart = trimStart, let trimEnd = trimEnd {
            trim = "trim=start=\(trimStart):end=\(trimEnd)"
        }
        let scale = "scale=\(width)*\(height)"
        let speed = "setpts=\(1/playbackSpeed)*PTS"
        let fps = "fps=\(outputFps)"
        
        var arguments = [String]()
        if let trim = trim {
            arguments.append(trim)
        }
        arguments.append(contentsOf: [scale, speed, fps])
        
        var filterLine = tagStart
        for argument in arguments {
            filterLine += argument + ","
        }
        filterLine.removeLast()
        filterLine += tagEnd
        
        return filterLine
    }
    
    private func buildAudioFilterLine(index: Int) -> String {
        if let trimStart = trimStart, let trimEnd = trimEnd {
            return "[\(index):a]atrim=start=\(trimStart):end=\(trimEnd),atempo=\(playbackSpeed)[a\(index)];"
        } else {
            return "[\(index):a]atempo=\(playbackSpeed)[a\(index)];"
        }
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
