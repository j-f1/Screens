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
        let timer = Timer(fire: .now, interval: 1, repeats: true) { [weak self] _ in
            self?.update()
        }
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func update() {
        do {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/fish")
            proc.arguments = ["-c", "screen -list"]
            let pipe = Pipe()
            proc.standardOutput = pipe.fileHandleForWriting
            proc.terminationHandler = { proc in
                do {
                    try pipe.fileHandleForWriting.close()
                    if let string = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                        let screens = string
                            .split(separator: "\r\n")[1]
                            .split(separator: "\n")
                            .dropLast()
                            .map { $0.dropFirst().split(separator: "\t") }
                            .compactMap { Screen(name: $0[0], status: $0[1]) }
                        DispatchQueue.main.async {
                            self.screens = screens
                        }
                    } else {
                        print("Invalid data: \(pipe.fileHandleForReading.availableData)")
                    }
                } catch {
                    print(error)
                }
            }
            try proc.run()
        } catch {
            print(error)
        }
    }
    
    struct Screen: Identifiable {
//        let url: URL
        let pid: pid_t
        let name: String
        let status: Status
        
        enum Status: String {
            case detached = "(Detached)"
            case attached = "(Attached)"
            
            var label: String? {
                switch self {
                case .detached: return nil
                default: return rawValue
                }
            }
        }

        fileprivate init?(name: some StringProtocol, status: some StringProtocol) {
            let splits = name.split(maxSplits: 1, omittingEmptySubsequences: false, whereSeparator: { $0 == "." })
            guard splits.count == 2 else { return nil }
            guard let pid = pid_t(splits[0]) else { return nil }
            self.pid = pid
            self.name = String(splits[1])
            guard let status = Status(rawValue: String(status)) else { return nil }
            self.status = status
        }
        
        var id: pid_t {
            pid
        }
    }

    deinit {
        timer?.invalidate()
    }
}
