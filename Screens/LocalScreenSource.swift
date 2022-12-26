//
//  LocalScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation
import SwiftUI

class LocalScreenSource: ScreenSource {
    init(screenCommand: String = "screen") {
        self.screenCommand = screenCommand
    }
    
    let screenCommand: String
    let title: LocalizedStringKey = "Local"

    func update() async throws -> [Screen] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async { [self] in
                let proc = Process()
                proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
                proc.arguments = ["-c", "\(screenCommand) -list"]
                let pipe = Pipe()
                proc.standardOutput = pipe.fileHandleForWriting
                proc.terminationHandler = { proc in
                    do {
                        try pipe.fileHandleForWriting.close()
                        let data = pipe.fileHandleForReading.availableData
                        if ![0, 1].contains(proc.terminationStatus) {
                            throw ScreenError.exit(status: proc.terminationStatus, output: data)
                        }
                        if let string = String(data: data, encoding: .utf8),
                           let screens = [Screen](source: self, screenOutput: string) {
                            DispatchQueue.main.async {
                                continuation.resume(returning: screens)
                            }
                        } else {
                            throw ScreenError.invalidContent(data)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            continuation.resume(throwing: error)
                        }
                    }
                }
                do {
                    try proc.run()
                } catch {
                    DispatchQueue.main.async {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func command(for screen: Screen) -> String {
        screen.baseCommand
    }
    
    static func == (lhs: LocalScreenSource, rhs: LocalScreenSource) -> Bool {
        lhs.screenCommand == rhs.screenCommand
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(screenCommand)
    }
}
