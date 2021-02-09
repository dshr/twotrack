import SwiftUI

struct VUMeter: View {
    let level: Float
    
    init(level: Float) {
        self.level = level
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                Rectangle()
                    .foregroundColor(Color(.controlAccentColor))
                    .frame(height: scaledLevel(level) * geometry.size.height)
                    .animation(.linear)
               
                Text(String(format: "%.2f", level)).foregroundColor(.primary)
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
        VUMeter(level: -140).padding()
    }
}
