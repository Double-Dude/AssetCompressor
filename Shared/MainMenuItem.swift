//
//  MainMenuButton.swift
//  AssetCompressor
//
//  Created by Ray Qu on 21/02/22.
//

import SwiftUI

struct MainMenuItem: View {
    var id: String = UUID().uuidString
    var namespace: Namespace.ID?
    let title: String
    let image: Image
    var onTapped: (() -> Void)?
    @Namespace var defaultNameSpace
    
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Color.fromHex(0xF2F3F8)
                .matchedGeometryEffect(id: id, in: namespace ?? defaultNameSpace)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(30)
                .scaleEffect(isPressed ? 1.1 : 1)
                .onTapGesture {
                    onTapped?()
                }
                .onPressedGesture { pressed in
                    withAnimation {
                        isPressed = pressed
                    }
                }
            
            let edgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Color.fromHex(0x305ED6))
                    .font(Font.title)
                    .bold()
                    .padding(edgeInsets)

                image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.fromHex(0xF2A35D))
                    .frame(width: 50, height: 50, alignment: .leading)
                    .padding(edgeInsets)

            }
            
        }
        
      
    
        //.background(Color.fromHex(0xFBFAFA))

    }
}

struct MainMenuButton_Previews: PreviewProvider {
    @Namespace var namespace
    
    static var previews: some View {
        MainMenuItem(title: "", image: Image(systemName: "video"))
    }
}

//
//
//VStack(alignment: .leading) {
//    Text(title)
//        .foregroundColor(Color.fromHex(0x305ED6))
//        .font(Font.title)
//        .bold()
//        .padding(edgeInsets)
//
//    image
//        .resizable()
//        .scaledToFit()
//        .foregroundColor(Color.fromHex(0xF2A35D))
//        .frame(width: 50, height: 50, alignment: .leading)
//        .padding(edgeInsets)
//
//}
//.frame(maxWidth: 400, maxHeight: 300, alignment: .leading)
//.contentShape(Rectangle())
//.aspectRatio(1, contentMode: .fill)
//.background(
//    Color(UIColor.systemBackground)
////                .matchedGeometryEffect(id: id, in: namespace ?? defaultNameSpace)
//)
//.cornerRadius(30)
//.scaleEffect(isPressed ? 1.1 : 1)
//.onTapGesture {
//    onTapped?()
//}
//.onPressedGesture { pressed in
//    withAnimation {
//        isPressed = pressed
//    }
//}
