//
//  ScreenError.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-26.
//

import Foundation

enum ScreenError: LocalizedError {
    case exit(status: Int32, output: Content)
    static func exit(status: Int32, output string: String) -> Self { .exit(status: status, output: .string(string)) }
    static func exit(status: Int32, output data: Data) -> Self { .exit(status: status, output: .data(data)) }
    
    case invalidContent(Content)
    static func invalidContent(_ string: String) -> Self { .invalidContent(.string(string)) }
    static func invalidContent(_ data: Data) -> Self { .invalidContent(.data(data)) }
    
    enum Content: CustomStringConvertible {
        case string(String)
        case data(Data)
        
        var description: String {
            switch self {
            case .string(let string): return string
            case .data(let data): return String(data: data, encoding: .utf8) ?? "[base64] " + data.base64EncodedString(options: .lineLength64Characters)
            }
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .exit(let status, let output):
            return "Screen command exited with unexpected status \(status). Output:\n\(output)"
        case .invalidContent(let content):
            return "Unable to parse output from screen command:\n\(content)"
        }
    }
}
