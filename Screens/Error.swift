//
//  Error.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-29.
//

import Foundation
import Socket
import Shout

extension Socket.Error: LocalizedError {
    public var errorDescription: String? {
        description
    }
}

extension Shout.SSHError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}
