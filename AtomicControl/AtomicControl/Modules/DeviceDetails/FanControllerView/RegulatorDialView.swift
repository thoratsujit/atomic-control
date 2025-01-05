//
//  RegulatorDialView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import SwiftUI

struct RegulatorDialView: View {
    
    let outerDialSize: CGFloat
    let innerDialSize: CGFloat
    let setpointSize: CGFloat = 45
    var degrees: CGFloat = .zero
    
    var indicatorAngle: CGFloat {
        return degrees * 60 + 180
    }
    
    var body: some View {
        ZStack {
            // MARK: Outer Dial
            Circle()
                .fill(Gradient(colors: [.outerDial1, .outerDial2]))
                .frame(width: outerDialSize, height: outerDialSize)
                .shadow(color: .black.opacity(0.2), radius: 60, x: 0, y: 30) // drop shadow 1
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8) // drop shadow 2
                .overlay {
                    // MARK: Outer Dial Border
                    Circle()
                        .stroke(Gradient(colors: [.white.opacity(0.2), .black.opacity(0.19)]), lineWidth: 1)
                }
                .overlay {
                    // MARK: Outer Dial Inner Shadow
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 4)
                        .blur(radius: 8)
                        .offset(x: 3, y: 3)
                        .mask {
                            Circle()
                                .fill(Gradient(colors: [.black, .clear]))
                        }
                }
            
            // MARK: Inner Dial
            Circle()
                .fill(Gradient(colors: [.innerDial1, .innerDial2]))
                .frame(width: innerDialSize, height: innerDialSize)
            
            // MARK: Temperature Setpoint
            Circle()
                .fill(Gradient(colors: [.innerDial2, .innerDial1]))
                .frame(width: setpointSize, height: setpointSize)
                .frame(width: innerDialSize, height: innerDialSize, alignment: .top)
                .offset(x: 0, y: -22.5)
                .rotationEffect(.degrees(degrees + 180))
        }
    }
}
