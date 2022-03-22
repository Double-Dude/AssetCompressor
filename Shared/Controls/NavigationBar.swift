//
//  NavigationBar.swift
//  AssetCompressor
//
//  Created by Ray Qu on 23/02/22.
//

import SwiftUI

struct NavigationBar: View {
    let title: String
    var onBackButtonTapped: (() -> Void)?
    @State private var isBackButtonPressed = false
    
    var body: some View {
        ZStack {
            Color.clear
            HStack(spacing: 16) {
                Button {
                    onBackButtonTapped?()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isBackButtonPressed ? Color.black.opacity(0.6) : Color.black)
                        .frame(width: 25, height: 25, alignment: .leading)
                }
                .onPressedGesture(callback: { isPressed in
                    isBackButtonPressed = isPressed
                })
                .buttonStyle(.plain)

                Text(title)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 20)
           
        }
        .frame(height: 40)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(title: "NavigationBar")
    }
}
