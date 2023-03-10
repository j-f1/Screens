//
//  AppDelegate.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-31.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    override init() {
        super.init()
    }
    
    init(config: Config) {
        self.config = config
        super.init()
    }
    
    @Published var config = Config.load()
    var configBinding: Binding<Config> {
        Binding<Config>(
            get: { self.config },
            set: { self.config = $0 }
        )
    }
    
    var encodedConfig: Data? = try? Data(contentsOf: Config.configURL)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            var target = SuspendingClock.now
            while true {
                for source in config.sources {
                    source.update()
                }

                if let encoded = try? config.encoded {
                    if encodedConfig != encoded {
                        encodedConfig = encoded
                        try encoded.write(to: Config.configURL, options: .atomic)
                    }
                }

                repeat {
                    target += Duration(max(config.options.updateFrequency, 0.5))
                } while target < .now

                try await Task.sleep(until: target, tolerance: Duration(config.options.updateFrequency / 2), clock: .suspending)
            }
        }
    }
}

extension Duration {
    init(_ timeInterval: TimeInterval) {
        let seconds = timeInterval.rounded(.towardZero)
        let attoseconds = Int64((timeInterval - seconds) * 1e18)
        self.init(secondsComponent: Int64(seconds), attosecondsComponent: attoseconds)
    }
}
