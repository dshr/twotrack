import SwiftUI

@main
struct twotrackApp: App {
    
    let engine = MainAudioEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(engine: engine))
                .frame(minWidth: 400, minHeight: 200)
        }
    }
}
