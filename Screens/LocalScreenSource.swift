//
//  LocalScreenSource.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-25.
//

import Foundation

class LocalScreenSource: ScreenSource {
    var shell = "/opt/homebrew/bin/fish"
    var screenCommand = "screen"
    
    func update() async throws -> [Screen] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async { [self] in
                let proc = Process()
                proc.executableURL = URL(fileURLWithPath: shell)
                proc.arguments = ["-c", "\(screenCommand) -list"]
                let pipe = Pipe()
                proc.standardOutput = pipe.fileHandleForWriting
                proc.terminationHandler = { proc in
                    do {
                        try pipe.fileHandleForWriting.close()
                        if let string = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                            let screens = [Screen](source: self, screenOutput: string)
                            DispatchQueue.main.async {
                                continuation.resume(returning: screens)
                            }
                        } else {
                            print("Invalid data: \(pipe.fileHandleForReading.availableData)")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                do {
                    try proc.run()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func command(for screen: Screen) -> String {
        screen.command
    }
    
    static func == (lhs: LocalScreenSource, rhs: LocalScreenSource) -> Bool {
        lhs.shell == rhs.shell && lhs.screenCommand == rhs.screenCommand
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(shell)
        hasher.combine(screenCommand)
    }
}
