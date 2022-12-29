//
//  ScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

protocol ScreenSource: AnyObject, Hashable, Codable {
    func update() async throws -> [Screen]
    func command(for screen: Screen) -> String
    var screenCommand: String { get }
    var title: String { get }
}
