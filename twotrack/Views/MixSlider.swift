import SwiftUI

struct MixSlider<Label, V: BinaryFloatingPoint>: View where Label: View {
    var value: Binding<V>
    var range: ClosedRange<V> = -1...1
    var onEditingChanged: (Bool) -> Void = { _ in }
    var label: Label
    var leadingLabel: Label
    var trailingLabel: Label

    private let radius: CGFloat = 50

    @State private var validDrag = false

    init(value: Binding<V>,
         in range: ClosedRange<V> = -1...1,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         leadingLabel: Label,
         trailingLabel: Label,
         @ViewBuilder label: () -> Label) {
        
        self.value = value
        self.range = range
        self.onEditingChanged = onEditingChanged
        self.leadingLabel = leadingLabel
        self.trailingLabel = trailingLabel
        self.label = label()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    HStack(spacing: 0) {
                        HStack {
                            Spacer(minLength: 0)
                            Rectangle()
                                .foregroundColor(Color(.controlAccentColor))
                                .frame(width: max(0, -(getPoint(in: geometry).x - geometry.size.width * 0.5)))
                        }
                        HStack {
                            Rectangle()
                                .foregroundColor(Color(.controlAccentColor))
                                .frame(width: max(0, getPoint(in: geometry).x - geometry.size.width * 0.5))
                            Spacer(minLength: 0)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        leadingLabel
                        Spacer()
                        label
                        Spacer()
                        trailingLabel
                    }
                    .foregroundColor(.primary)
                    .padding([.leading, .trailing], radius * 0.5)
                }
                .frame(width: geometry.size.width, height: radius, alignment: .center)
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: radius))
                
                Rectangle()
                    .frame(minHeight: radius)
                    .foregroundColor(Color(.sRGB, white: 0, opacity: 0.001))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            validDrag = false
                            onEditingChanged(false)
                        }.onChanged(handleDragged(in: geometry)
                    )
                )
            }
        }.frame(height: radius)
    }
}

extension MixSlider {
    private func getPoint(in geometry: GeometryProxy) -> CGPoint {
        let y = geometry.size.height / 2
        let location = value.wrappedValue - range.lowerBound
        let scale = V(geometry.size.width) / (range.upperBound - range.lowerBound)
        let x = CGFloat(location * scale)
        return CGPoint(x: x, y: y)
    }

    private func handleDragged(in geometry: GeometryProxy) -> (DragGesture.Value) -> Void {
        return { drag in
            if drag.startLocation.distance(to: getPoint(in: geometry)) < radius && !validDrag {
                validDrag = true
                onEditingChanged(true)
            }

            if validDrag {
                let location = drag.location.x
                let scale = CGFloat(range.upperBound - range.lowerBound) / geometry.size.width
                let scaledValue = V(location * scale) + range.lowerBound
                value.wrappedValue = max(min(scaledValue, range.upperBound), range.lowerBound)
            }
        }
    }
}

struct MixSlider_Previews: PreviewProvider {
    @State static var value = 0.75
    
    static var previews: some View {
        MixSlider(
            value: $value,
            in: -1.0...1.0,
            leadingLabel: Text("A"),
            trailingLabel: Text("B")) {
            Text("Mix")
        }
        .padding()
    }
}
