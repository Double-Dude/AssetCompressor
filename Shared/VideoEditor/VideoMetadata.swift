//
//  VideoMetadata.swift
//  AssetCompressor
//
//  Created by Ray Qu on 4/03/22.
//

import Foundation

struct VideoMetadata {
    let bitrate: Int
    let width: Int
    let height: Int
    let fps: Int
    let duration: Double
    let size: Int64 // bytes

    static func fromDict(_ dict:[String: Any]) -> Self? {
        let videoStream = getVideoStream(dict)
        let format = getformat(dict)
        guard let videoStream = videoStream, let format = format else {
            return nil
        }
        
        let bitrate = format["bit_rate"] as? String
        let fpsString = videoStream["avg_frame_rate"] as? String
        let duration = format["duration"] as? String
        let size = format["size"] as? String
        let width = videoStream["width"] as? Int
        let height = videoStream["height"] as? Int
        
        guard let bitrate = bitrate, let fpsString = fpsString, let duration = duration, let size = size, let width = width, let height = height else {
            return nil
        }

        let fpsValues = fpsString.split(separator: "/")
        let fpsDividend = Int(String(fpsValues.first!))!
        let fpsDivisor = Int(String(fpsValues.last!))!
        
        let metadata = VideoMetadata(
            bitrate: Int(bitrate)!,
            width: width,
            height: height,
            fps: fpsDividend/fpsDivisor,
            duration: Double(duration)!,
            size: Int64(size)!
        )
        
        return metadata
    }
    
    static func getVideoStream(_ dict:[String: Any]) -> [String: Any]? {
        let streams = dict["streams"] as? [[String: Any]]
        return streams?.first { dict in
            dict["codec_type"] as? String == "video"
        }!
    }
    
    static func getformat(_ dict:[String: Any]) -> [String: Any]? {
        let format = dict["format"] as? [String: Any]
        return format
    }
}
