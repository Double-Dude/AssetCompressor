//
//  String+Extensions.swift
//  AssetCompressor
//
//  Created by Ray Qu on 4/03/22.
//

import Foundation

extension JSONSerialization {
    static func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try self.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
