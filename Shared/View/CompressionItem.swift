//
//  CompressionItem.swift
//  AssetCompressor
//
//  Created by Ray Qu on 23/03/22.
//

import SwiftUI

struct CompressionResolutionItem : View {
    @Binding var width: String
    @Binding var height: String

    var body: some View {
        CompressionCustomListItem(
            title: "Resolution",
            subtitle: "The width and height have to be even numbers.",
            valueString: String("\(width)x\(height)")
        ) {
            HStack {
                createResolutionItemTextField(placeholder: "Width", text: $width)
                createResolutionItemTextField(placeholder: "Height", text: $height)
            }
            .padding(.top, 8)
        }
    }
    
    private func createResolutionItemTextField(placeholder: String, text: Binding<String>) -> some View{
        FloatingLabelTextField(
            placeholder: placeholder,
            text: text,
            onEditingChanged: { isFocused in
                if(isFocused) { return }

                let value = text.wrappedValue.isEmpty ? 0 : Int(text.wrappedValue)!
                print("Test: \(Int(text.wrappedValue)! >> 2)")
                if(value == 0) {
                    text.wrappedValue = "2"
                } else if(value % 2 == 1 ) {
                    text.wrappedValue = String(value + 1)
                }
            }
        )
        .onChange(of: text.wrappedValue) { [oldValue = text.wrappedValue] newValue in
            let convertable = Int(newValue) != nil
            if convertable == false {
                text.wrappedValue = oldValue
            }
        }
        #if os(iOS)
        .keyboardType(.numberPad)
        #endif
    }
}

struct CompressionSliderItem : View{
    let title: String
    var subtitle: String?
    @Binding var value: Float
    var valueString: String
    let range: ClosedRange<Float>
    var step: Float = 1
    
    var body: some View {
        return CompressionCustomListItem(title: title, subtitle: subtitle, valueString: valueString) {
            Slider(value: $value, in: range, step: step) { _ in

            }
        }
    }
}

struct CompressionTextFieldItem : View {
    let title: String
    var subtitle: String?
    let value: Binding<String>
    
    var body: some View {
        CompressionCustomListItem(title: title, subtitle: subtitle, valueString: value.wrappedValue) {
            createMinimumValueTextField(placeholder: title, text: value)
                .padding(.top, 8)
        }
    }
    
    private func createMinimumValueTextField(placeholder: String, text: Binding<String>) -> some View {
        FloatingLabelTextField(
            placeholder: placeholder,
            text: text,
            onEditingChanged: { isFocused in
                if(isFocused) { return }
                    
                let value = text.wrappedValue.isEmpty ? 0 : Int(text.wrappedValue)!
                if(value == 0) {
                    text.wrappedValue = "1"
                }
            }
        )
        .onChange(of: text.wrappedValue) { [oldValue = text.wrappedValue] newValue in
            let convertable = Int(newValue) != nil
            if convertable == false {
                text.wrappedValue = oldValue
            }
        }
        #if os(iOS)
        .keyboardType(.numberPad)
        #endif
    }
}

struct CompressionCustomListItem<ContentView: View> : View{
    let title: String
    var subtitle: String?
    var valueString: String?
    var createContentView: () -> ContentView

    var body: some View {
        return CircularContainerView(backgroundColor: Color.white) {
            VStack(alignment: .leading, spacing: 8) {
                createTitleLine()
                
                if let subtitle = subtitle {
                   Text(subtitle)
                       .font(.subheadline)
                       .foregroundColor(.black.opacity(0.4))
                }
                
                createContentView()
            }
        }
    }
    
    private func createTitleLine() -> some View {
        HStack {
            Text("\(title):")
            if let valueString = valueString {
                Text(valueString)
            }
        }
        .font(.title2)
    }
}
