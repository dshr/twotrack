import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    
    @Published var trackAVolume: Float = 1
    @Published var trackBVolume: Float = 1
    @Published var crossFade: Float = 0
    @Published var powerLevel: Float = 0
    
    private var engine: AudioEngine
    private var cancellables = Set<AnyCancellable>()
    
    init(engine: AudioEngine) {
        self.engine = engine
        
        $crossFade.share().combineLatest($trackAVolume)
        .sink { mix, volume in
            engine.setTrackAVolume(value: volume * (mix - 1) * -0.5)
        }
        .store(in: &cancellables)
        
        $crossFade.share().combineLatest($trackBVolume)
        .sink { mix, volume in
            engine.setTrackBVolume(value: volume * (mix + 1) * 0.5)
        }
        .store(in: &cancellables)
        
        engine.powerLevelPublisher.receive(on: DispatchQueue.main)
            .assign(to: &$powerLevel)
    }
    
    func play() {
        engine.play()
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Text("\(viewModel.powerLevel)")
            Slider(value: $viewModel.trackAVolume, in: 0...5) {
                Text("Track A Volume")
            }
            Slider(value: $viewModel.trackBVolume, in: 0...5) {
                Text("Track B Volume")
            }
            Text("Mix")
            Slider(value: $viewModel.crossFade, in: -1...1)
        }.padding()
        .onAppear {
            viewModel.play()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    struct MockEngine: AudioEngine {
        func play() {}
        func setTrackAVolume(value: Float) {}
        func setTrackBVolume(value: Float) {}
        var powerLevelPublisher = CurrentValueSubject<Float, Never>(170)
    }
    
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(engine: MockEngine()))
    }
}
