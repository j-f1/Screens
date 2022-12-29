//
//  ViewModel.swift
//  Screens
//
//  Created by Jed Fox on 2022-12-22.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject, Identifiable {
    private var timer: Timer?
    
    @Published var source: AnyScreenSource
    @Published var customTitle: String = ""
    var title: String {
        customTitle.isEmpty ? source.title : customTitle
    }
    @Published var screens = [Screen]()
    @Published var error: Error?

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
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
