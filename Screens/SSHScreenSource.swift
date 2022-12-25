//
//  SSHScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation
import Shout

final class SSHScreenSource: ScreenSource {
    internal init(shell: String = "/bin/bash", screenCommand: String = "screen", username: String, host: String, port: Int32 = 22) {
        self.shell = shell
        self.screenCommand = screenCommand
        self.username = username
        self.host = host
        self.port = port
    }

    public static func == (lhs: SSHScreenSource, rhs: SSHScreenSource) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shell)
        hasher.combine(screenCommand)
        hasher.combine(username)
        hasher.combine(host)
        hasher.combine(port)
    }

    let shell: String
    let screenCommand: String
    let username: String
    let host: String
    let port: Int32
    
    private enum Error: Swift.Error {
        case exit(status: Int32)
    }
    
    private var connection: SSH?
    private func currentConnection() throws -> SSH {
        if let connection {
            return connection
        }
        let connection = try SSH(host: host, port: port)
        try connection.authenticateByAgent(username: username)
        self.connection = connection
        return connection
    }

    func update() async throws -> [Screen] {
        let connection = try currentConnection()
        do {
            return try readScreens(from: connection)
        } catch {
            // reconnect
            self.connection = nil
            return try readScreens(from: try currentConnection())
        }
    }
    
    private func readScreens(from connection: SSH) throws -> [Screen] {
        let (status, output) = try connection.capture("\(shell) -c '\(screenCommand) -list")
        if status != 0 {
            throw Error.exit(status: status)
        }
        return .init(screenOutput: output)
    }
    
}

extension SSH: Hashable, Equatable {
    public static func == (lhs: Shout.SSH, rhs: Shout.SSH) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
}
