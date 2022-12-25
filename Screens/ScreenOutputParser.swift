//
//  ScreenOutput.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import Foundation

struct ScreenOutput {
    static func parse(_ input: String) -> Self {
        let lines = input.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n")
        print(lines)
        return ScreenOutput()
    }
}
