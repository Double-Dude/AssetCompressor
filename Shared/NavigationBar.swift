//
//  NavigationBar.swift
//  AssetCompressor
//
//  Created by Ray Qu on 23/02/22.
//

import SwiftUI

struct NavigationBar: View {
    var onBackButtonTapped: (() -> Void)?
    
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
                        .foregroundColor(Color.black)
                        .frame(width: 25, height: 25, alignment: .leading)
//
//                        .frame(width: 50, height: 50, alignment: .leading)
//                        .foregroundColor(Color.black)
                }
                
                
                Text("NavigationBar")
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
        NavigationBar()
    }
}
