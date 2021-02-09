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
        
        engine.powerLevelPublisher
            .collect(.byTime(DispatchQueue.global(), .seconds(1/60)))
            .compactMap({ values  in
                return values.reduce(0, +) / Float(values.count)
            })
            .receive(on: DispatchQueue.main)
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
            HStack(alignment: .bottom) {
                VSlider(value: $viewModel.trackAVolume, in: 0...5) {
                    Text("A")
                }
                VStack {
                    VUMeter(level: viewModel.powerLevel)
                    MixSlider(
                        value: $viewModel.crossFade,
                        in: -1...1,
                        leadingLabel: Text("A"),
                        trailingLabel: Text("B")
                    ) {
                        Text("Mix")
                    }
                }.padding([.leading, .trailing], 20)
                VSlider(value: $viewModel.trackBVolume, in: 0...5) {
                    Text("B")
                }
            }.font(.system(.body, design: .monospaced))
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
