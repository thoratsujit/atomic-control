//
//  FanControllerView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import SwiftUI

struct Config {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
    let knobRadius: CGFloat
    let radius: CGFloat
}

struct FanControllerView: View {
    
    @Binding var speed: Double
    @Binding var isPoweredOn: Bool
    
    @State var indicatorAngle: CGFloat = 0.0
    @State private var phase = 0.0
    
    let config: Config
    let buttonTapped: () -> Void
    let onEditingChanged: (Bool) -> Void
    
    private var powerButtonIcon: String {
        return isPoweredOn ? "power.circle.fill" : "power.circle"
    }
    
    private var strokeColor: Color {
        switch speed {
            case 0:
                return .gray
            case 1:
                return .orange
            case 2:
                return .yellow
            case 3...4:
                return .green
            case 5...6:
                return .blue
            default:
                return .gray
        }
    }
    
    private let gradient = AngularGradient(colors: [.orange, .yellow, .green, .blue], center: .center)
    
    var body: some View {
        ZStack {
            // Dial marking
            ForEach(1..<7) { mark in
                Number(numberMark: mark)
                    .onTapGesture {
                        speed = CGFloat(mark)
                        indicatorAngle = CGFloat(mark * 60)
                        onEditingChanged(true)
                    }
            }
            .frame(width: config.radius * 3, height: config.radius * 3)
            
            regulatorDialView
            circularSliderView
            powerButton
        }
        .onAppear {
            indicatorAngle = CGFloat(speed * 60)
        }
        .onChange(of: speed) { value in
            indicatorAngle = CGFloat(speed * 60)
            if value.truncatingRemainder(dividingBy: 1) == .zero {
                hapticFeedback(.selection)
            }
        }
    }
    
    private var circularSliderView: some View {
        ZStack(alignment: .center) {
            Circle()
                .stroke(isPoweredOn ? strokeColor : .gray,
                        style: StrokeStyle(lineWidth: 10, lineCap: .butt, dash: [6, 30], dashPhase: phase))
                .scaleEffect(0.8)
                .rotationEffect(.degrees(indicatorAngle))
//                .dropShadow()
            //                .onChange(of: temperatureValue) { value in
            //                    if isPoweredOn {
            //                        withAnimation(.linear.repeatForever(autoreverses: false)) {
            //                            phase -= 30 * temperatureValue
            //                        }
            //                    } else {
            //                        withAnimation(.linear(duration: (temperatureValue * 0.3))) {
            //                            phase = 0 // Reset the phase to stop the moving effect
            //                        }
            //                    }
            //                }
                .onChange(of: isPoweredOn) { value in
                    if isPoweredOn {
                        withAnimation(.linear.repeatForever(autoreverses: false)) {
                            phase -= 30 * speed
                        }
                    } else {
                        withAnimation(.linear(duration: (speed * 0.3))) {
                            phase = 0 // Reset the phase to stop the moving effect
                        }
                    }
                }
            
            Circle()
                .trim(from: 0.01, to: (speed/config.totalValue) - 0.01)
                .stroke(gradient,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(90))
            
            Circle()
                .fill(.gray)
                .frame(width: config.knobRadius * 2, height: config.knobRadius * 2)
                .padding(10)
//                .offset(y: config.radius)
                .offset(y: config.radius - 10)
                .rotationEffect(.degrees(Double(indicatorAngle)))
                .dropShadow()
                .gesture(DragGesture(minimumDistance: 0.0)
                    .onChanged({ value in
                        onEditingChanged(true)
                        change(location: value.location)
                    })
                        .onEnded({ _ in
                            onEditingChanged(false)
                        })
                )
        }
        .frame(width: config.radius * 1.97, height: config.radius * 1.97)
    }
    
    private var regulatorDialView: some View {
        RegulatorDialView(outerDialSize: config.radius * 2.1,
                          innerDialSize: config.radius * 2 * 0.91)
        .rotationEffect(.degrees(indicatorAngle))
        .clipShape(Circle())
    }
    
    private var powerButton: some View {
        IconicButton(icon: powerButtonIcon,
                     size: .init(width: config.radius, height: config.radius),
                     imagePadding: 24) {
            isPoweredOn.toggle()
            buttonTapped()
        }
                     .clipShape(Circle())
                     .shadow(color: Color.black, radius: 10, x: 0, y: 0)
    }
    
    private func change(location: CGPoint) {
        // creating vector from location point
        let vector = CGVector(dx: location.x, dy: location.y)
        
        // geting angle in radian need to subtract the knob radius and padding from the dy and dx
        let angle = atan2(vector.dy - (config.knobRadius + 10) - .pi/2.0, vector.dx - (config.knobRadius + 10)) - .pi/2.0
        
        // convert angle range from (-pi to pi) to (0 to 2pi)
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        // convert angle value to temperature value
        let value = fixedAngle / (2.0 * .pi) * config.totalValue
        
        if value >= config.minimumValue && value <= config.maximumValue {
            indicatorAngle = fixedAngle * 180 / .pi // converting to degree
            
            //snap
            let rawValue = indicatorAngle / 360 * CGFloat(6)
            let snappedValue = (rawValue).rounded()
            speed = max(0, min(6, snappedValue))
            indicatorAngle = CGFloat(speed * 60)
        }
    }
}

struct Number: View {
    var numberMark: Int
    
    var rotationAngle: Double {
        return 360 / 6 * Double(numberMark) + 180
    }
    
    var body: some View {
        VStack {
            Text("\(numberMark)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .monospaced()
                .rotationEffect(.degrees(-rotationAngle))
                .foregroundStyle(.primary)
                .frame(maxWidth: 164, maxHeight: 48)
                .contentShape(Rectangle())
            Spacer()
        }
        .rotationEffect(.degrees(rotationAngle))
    }
}


#Preview {
    FanControllerView(speed: .constant(3),
                      isPoweredOn: .constant(true),
                      config: .init(minimumValue: 0.1,
                                    maximumValue: 6.0,
                                    totalValue: 5.9,
                                    knobRadius: 16,
                                    radius: UIApplication.shared.deviceWidth * 0.29),
                      buttonTapped: {
        
    }, onEditingChanged: { isEditing in
        print("UserInteraction: \(isEditing)")
    })
}

extension UIApplication {
    var deviceWidth: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return window?.frame.width ?? .zero
    }
}
