//
//  File.swift
//  File
//
//  Created by Simon Schöpke on 19.08.21.
//

import Foundation

extension Int {
    init?<D: DataProtocol>(_ data: D) {
        guard let text = String(data: Data(data), encoding: .utf8) else {
            return nil
        }
        
        guard let value = Int(text) else {
            return nil
        }
        
        self = value
    }
}
