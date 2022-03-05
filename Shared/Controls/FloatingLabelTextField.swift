//
//  FloatingLabelTextField.swift
//  AssetCompressor (iOS)
//
//  Created by Ray Qu on 4/03/22.
//

import SwiftUI

struct FloatingLabelTextField<V> : View {
    let placeholder: String
    var text: Binding<String>?
    var value: Binding<V>?
    var formatter: Formatter?
    var onEditingChanged: ((Bool) -> Void)?

    init(placeholder: V, text: Binding<String>, onEditingChanged: ((Bool) -> Void)? = nil) where V == String {
        self.placeholder = placeholder
        self.text = text
        self.onEditingChanged = onEditingChanged
    }
    
    init(placeholder: String, value: Binding<V>, formatter: Formatter, onEditingChanged: ((Bool) -> Void)? = nil) {
        self.placeholder = placeholder
        self.value = value
        self.formatter = formatter
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        if(text != nil) {
            createTextField(text!)
        } else {
            createTextField(value: value!, formatter: formatter!)
        }
    }
    
    private func createTextField(_ text: Binding<String>) -> some View {
        TextField("", text: text, onEditingChanged: { isFocused in
            onEditingChanged?(isFocused)
        })
            .textFieldStyle(TextFieldFloatingStyle(placeholder: placeholder, placeholderColor: .gray, placeholderBackgroundColor: .white, isEditing: !text.wrappedValue.isEmpty))
    }
    
    private func createTextField(value: Binding<V>, formatter: Formatter) -> some View {
        TextField("", value: value, formatter: formatter, onEditingChanged: { isFocused in
            onEditingChanged?(isFocused)
        })
            .textFieldStyle(TextFieldFloatingStyle(placeholder: placeholder, placeholderColor: .gray, placeholderBackgroundColor: .white, isEditing: true))
    }
}



struct FloatingLabelTextField_Previews: PreviewProvider {    
    static var previews: some View {
        FloatingLabelTextField(placeholder: "Placeholder", text: .constant(""))
    }
}


