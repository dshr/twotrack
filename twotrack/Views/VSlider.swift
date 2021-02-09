// based on https://github.com/john-mueller/SwiftUI-Examples/blob/master/SwiftUI-Examples/VSlider/VSlider.swift
import SwiftUI

struct VSlider<Label, V: BinaryFloatingPoint>: View where Label: View {
    var value: Binding<V>
    var range: ClosedRange<V> = 0...1
    var onEditingChanged: (Bool) -> Void = { _ in }
    var label: Label

    private let radius: CGFloat = 25

    @State private var validDrag = false

    init(value: Binding<V>,
         in range: ClosedRange<V> = 0...1,
         onEditingChanged: @escaping (Bool) -> Void = { _ in },
         @ViewBuilder label: () -> Label) {
        
        self.value = value
        self.range = range
        self.onEditingChanged = onEditingChanged
        self.label = label()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Rectangle()
                        .foregroundColor(Color(.controlAccentColor))
                        .frame(height: geometry.size.height - getPoint(in: geometry).y)
                    
                    label.foregroundColor(.primary)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: radius / 4, trailing: 0))
                }
                .frame(width: radius, height: geometry.size.height, alignment: .bottom)
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: radius))
                
                Rectangle()
                    .frame(minWidth: radius)
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
        }
    }
}

extension VSlider {
    private func getPoint(in geometry: GeometryProxy) -> CGPoint {
        let x = geometry.size.width / 2
        let location = value.wrappedValue - range.lowerBound
        let scale = V(geometry.size.height) / (range.lowerBound - range.upperBound)
        let y = CGFloat(location * scale) + geometry.size.height
        return CGPoint(x: x, y: y)
    }

    private func handleDragged(in geometry: GeometryProxy) -> (DragGesture.Value) -> Void {
        return { drag in
            if drag.startLocation.distance(to: getPoint(in: geometry)) < radius && !validDrag {
                validDrag = true
                onEditingChanged(true)
            }

            if validDrag {
                let location = drag.location.y - geometry.size.height
                let scale = CGFloat(range.lowerBound - range.upperBound) / geometry.size.height
                let scaledValue = V(location * scale) + range.lowerBound
                value.wrappedValue = max(min(scaledValue, range.upperBound), range.lowerBound)
            }
        }
    }
}

struct VSlider_Previews: PreviewProvider {
    @State static var value = 0.7
    
    static var previews: some View {
        VSlider(value: $value, in: 0...1.0) {
            Text("A")
        }
        .padding()
    }
}
