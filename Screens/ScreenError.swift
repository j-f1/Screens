//
//  ScreenError.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-26.
//

import Foundation

enum ScreenError: Swift.Error {
    case exit(status: Int32, output: Content)
    static func exit(status: Int32, output string: String) -> Self { .exit(status: status, output: .string(string)) }
    static func exit(status: Int32, output data: Data) -> Self { .exit(status: status, output: .data(data)) }
    
    case invalidContent(Content)
    static func invalidContent(_ string: String) -> Self { .invalidContent(.string(string)) }
    static func invalidContent(_ data: Data) -> Self { .invalidContent(.data(data)) }
    
    enum Content {
        case string(String)
        case data(Data)
    }
}
