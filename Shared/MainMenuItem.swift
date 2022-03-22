//
//  MainMenuButton.swift
//  AssetCompressor
//
//  Created by Ray Qu on 21/02/22.
//

import SwiftUI

struct MainMenuItem: View {
    let id: String
    let namespace: Namespace.ID
    let title: String
    let image: Image
    @State private var isPressed = false
    var onTapped: (() -> Void)?
    
    var body: some View {

        CircularContainerView(id: id, namespace: namespace, onTapped: onTapped) {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Color.fromHex(0x305ED6))
                    .font(Font.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.fromHex(0xF2A35D))
                    .frame(width: 50, height: 50, alignment: .leading)
            }
        }
    }
}
