//
//  SSHScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation
import Shout
import SwiftUI

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
    
    var title: LocalizedStringKey {
        "SSH: \(username)@\(host + (port == 22 ? "" : ":\(port)"))"
    }

    private var connection: SSH?
    private func currentConnection() throws -> SSH {
        if let connection {
            return connection
        }
        let connection = try SSH(host: host, port: port)
        try connection.authenticate(username: username, authMethod: SSHKey(privateKey: "/Users/\(NSUserName())/.ssh/id_ed25519", passphrase: ""))
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
        "ssh \(username)@\(host) -t \(screen.baseCommand)"
    }
    
    private func readScreens(from connection: SSH) throws -> [Screen] {
        let (status, output) = try connection.capture("\(screenCommand) -list")
        if status != 1 {
            throw ScreenError.exit(status: status, output: output)
        }
        if let screens = [Screen](source: self, screenOutput: output) {
            return screens
        }
        throw ScreenError.invalidContent(output)
    }
    
}
