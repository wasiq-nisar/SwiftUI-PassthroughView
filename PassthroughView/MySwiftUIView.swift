//
//  MySwiftUIView.swift
//  PassthroughView
//
//  Created by WasiqNisar on 23/10/2025.
//

import SwiftUI

struct MySwiftUIView: View {
    @State private var showSheet = true

    var body: some View {
        ZStack(alignment: .bottom) {
            // Transparent top area (pass-through region)
            Color.clear

            // Bottom sheet
            if showSheet {
                BottomSheetView {
                    VStack(spacing: 16) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.4))
                            .padding(.top, 8)

                        Text("This is a SwiftUI Bottom Sheet")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("Touches above this sheet will pass through to UIKit. "
                             + "This area (the sheet) will block touches as usual.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        
                        Button(action: {
                            print("Swift UI Button tapped")
                        }) {
                            Text("Tap Me")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                    }
                }
                .contentShape(Rectangle()) // Defines the tappable area
                .onTapGesture {}
            }
        }
    }
}

// MARK: - Bottom Sheet View
struct BottomSheetView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
        )
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.3), value: UUID())
    }
}

#Preview {
    MySwiftUIView()
}
