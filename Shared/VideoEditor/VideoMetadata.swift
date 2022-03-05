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
    
    static func fromDict(_ dict:[String: Any]) -> Self {
        let videoStream = getVideoStream(dict)
//        let format = getformat(dict)
        let bitrate = videoStream["bit_rate"] as! String
        let fpsString = videoStream["avg_frame_rate"] as! String
        let fpsValues = fpsString.split(separator: "/")
        let fpsDividend = Int(String(fpsValues.first!))!
        let fpsDivisor = Int(String(fpsValues.last!))!

        let metadata = VideoMetadata(
            bitrate: Int(bitrate)!,
            width: videoStream["width"] as! Int,
            height: videoStream["height"] as! Int,
            fps: fpsDividend/fpsDivisor
        )
        
        return metadata
    }
    
    static func getVideoStream(_ dict:[String: Any]) -> [String: Any] {
        let streams = dict["streams"] as! [[String: Any]]
        return streams.first { dict in
            dict["codec_type"] as! String == "video"
        }!
    }
    
    static func getformat(_ dict:[String: Any]) -> [String: Any] {
        let format = dict["format"] as! [String: Any]
        return format
    }
}
