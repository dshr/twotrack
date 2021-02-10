import SwiftUI

struct VUMeter: View {
    let peakLevel: Float
    let powerLevel: Float
    
    init(peakLevel: Float, powerLevel: Float) {
        self.peakLevel = peakLevel
        self.powerLevel = powerLevel
    }
    
    var color: Color {
        peakLevel > 0 ? Color(.systemRed) : Color(.controlAccentColor)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                Rectangle()
                    .foregroundColor(.white)
                    .colorMultiply(color)
                    .frame(height: scaledLevel(powerLevel) * geometry.size.height)
                    .animation(.linear)
               
                Text(String(format: "%.2f", powerLevel)).foregroundColor(.primary)
                    .padding(.bottom, 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func scaledLevel(_ level: Float) -> CGFloat {
        guard level.isFinite else { return 0.0 }
        let minLevel: Float = -160
        if level < minLevel {
            return 0.0
        } else if level >= 1.0 {
            return 1.0
        } else {
            return CGFloat((abs(minLevel) - abs(level)) / abs(minLevel))
        }
    }
}

struct VUMeter_Previews: PreviewProvider {
    
    static var previews: some View {
        VUMeter(peakLevel: -140, powerLevel: -140).padding()
    }
}
