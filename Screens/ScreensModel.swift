//
//  ScreensModel.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import Foundation

class ScreensProvider: ObservableObject {
    private var timer: Timer?
    
    @Published var screens = [Screen]()

    init() {
        let timer = Timer(fire: .now, interval: 5, repeats: true) { [weak self] _ in
            self?.update()
        }
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func update() {
        do {
            let screens = try FileManager.default.contentsOfDirectory(
//                at: URL(fileURLWithPath: ProcessInfo.processInfo.environment["TMPDIR"]!, isDirectory: true).appendingPathComponent(".screen"),
                at: URL(fileURLWithPath: "/tmp/uscreens/S-\(NSUserName())"),
                includingPropertiesForKeys: []
            )
            self.screens = screens.map(Screen.init)
//            let proc = Process()
//            proc.executableURL = URL(fileURLWithPath: "/bin/bash")
//            proc.arguments = ["-c", "screen -list"]
//            let pipe = Pipe()
//            proc.standardOutput = pipe.fileHandleForWriting
//            proc.terminationHandler = { proc in
//                do {
//                    try pipe.fileHandleForWriting.close()
//                    if let string = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
//                        print(ScreenOutput.parse(string))
//                    } else {
//                        print("Invalid data: \(pipe.fileHandleForReading.availableData)")
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//            try proc.run()
        } catch {
            print(error)
        }
    }
    
    struct Screen: Identifiable {
        let url: URL
        let pid: Int
        let name: String

        fileprivate init(_ url: URL) {
            self.url = url
            let splits = url.lastPathComponent.split(maxSplits: 1, omittingEmptySubsequences: false, whereSeparator: { $0 == "." })
            self.pid = Int(splits[0])!
            self.name = String(splits[1])
        }
        
        var id: URL {
            url
        }
    }

    deinit {
        timer?.invalidate()
    }
}
