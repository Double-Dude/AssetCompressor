//
//  Task+Extensions.swift
//  AssetCompressor
//
//  Created by Ray Qu on 17/03/22.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let nanoseconds = seconds * 1e+9
        try await Task.sleep(nanoseconds: UInt64(nanoseconds))
    }
}
