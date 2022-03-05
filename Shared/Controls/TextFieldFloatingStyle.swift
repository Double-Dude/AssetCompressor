//
//  TextFieldFloatingStyle.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 4/03/22.
//

import Foundation
import SwiftUI

struct TextFieldFloatingStyle: TextFieldStyle {
    let placeholder: String
    var placeholderColor: Color = Color.fromHex(0x9E9E9E)
    var textColor: Color = Color.black
    var borderColor: Color = Color.black//Color.fromHex(0xE0E0E0)
    var placeholderBackgroundColor: Color = Color.white
    var isEditing: Bool

    func _body (configuration: TextField<_Label>) -> some View {
        ZStack (alignment: .leading) {
            Text(placeholder)
                .font(.system(self.isEditing ? .caption : .body, design: .rounded))
                .foregroundColor(placeholderColor)
                .padding(.horizontal, self.isEditing ? 10 : 0)
                .background (placeholderBackgroundColor)
                .offset(y: self.isEditing ? -28 : 0)
                .scaleEffect(self.isEditing ? 0.9 : 1, anchor: .leading)
            
            configuration
                .font(.system(.title2, design: .rounded))
                .foregroundColor(textColor)
        }
        .animation(.easeOut)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle (cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}


struct TextFieldFloatingStyle_Previews: PreviewProvider {
    static var previews: some View {
        TextField("", text: .constant(""))
            .textFieldStyle(TextFieldFloatingStyle(placeholder: "Placeholder", isEditing: false))
    }
}

