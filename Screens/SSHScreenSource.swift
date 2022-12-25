//
//  SSHScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation
import Shout

final class SSHScreenSource: ScreenSource {
    internal init(screenCommand: String = "screen", username: String, host: String, port: Int32 = 22) {
        self.screenCommand = screenCommand
        self.username = username
        self.host = host
        self.port = port
    }

    public static func == (lhs: SSHScreenSource, rhs: SSHScreenSource) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(screenCommand)
        hasher.combine(username)
        hasher.combine(host)
        hasher.combine(port)
    }

    let screenCommand: String
    let username: String
    let host: String
    let port: Int32
    
    private enum Error: Swift.Error {
        case exit(status: Int32, output: String)
    }
    
    private var connection: SSH?
    private func currentConnection() throws -> SSH {
        if let connection {
            return connection
        }
        let connection = try SSH(host: host, port: port)
        try connection.authenticate(username: username, authMethod: SSHKey(privateKey: "/Users/\(NSUserName())/.ssh/id_ed25519"))
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
    
    func command(for screen: Screen) -> String {
        "ssh \(username)@\(host) -t \(screen.command)"
    }
    
    private func readScreens(from connection: SSH) throws -> [Screen] {
        let (status, output) = try connection.capture("\(screenCommand) -list")
        if status != 1 {
            throw Error.exit(status: status, output: output)
        }
        return .init(source: erased, screenOutput: output)
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
