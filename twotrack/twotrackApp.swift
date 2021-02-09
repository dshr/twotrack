import SwiftUI

@main
struct twotrackApp: App {
    
    let engine = MainAudioEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(engine: engine))
                .frame(minWidth: 250, minHeight: 200)
        }
    }
}
