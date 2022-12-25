//
//  ViewModel.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import Foundation

class ViewModel: ObservableObject {
    private var timer: Timer?
    
    @Published var source: AnyScreenSource {
        didSet {
            self.update()
        }
    }
    @Published var screens = [Screen]()

    init(source: some ScreenSource) {
        self.source = AnyScreenSource(source)

        let timer = Timer(fire: .now, interval: 1, repeats: true) { [weak self] _ in
            self?.update()
        }
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func update() {
        Task {
            do {
                let screens = try await source.update()
                await MainActor.run {
                    self.screens = screens
                }
            } catch {
                print(error)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
