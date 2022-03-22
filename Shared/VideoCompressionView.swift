//
//  VideoCompressConfigView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 22/02/22.
//

import SwiftUI
import Combine

struct VideoCompressionView: View {
    var id: String = UUID().uuidString
    var namespace: Namespace.ID?
    var isActive: Binding<Bool>
    @ObservedObject var viewModel: VideoCompressionViewModel
    
    @Namespace private var defaultNameSpace
    @State private var rotate = false
   
    @State private var scrollOffset: Float = 60
    @State private var isShowingPhotoLibrary = false
    private var subscribers: Set<AnyCancellable> = []

    init(isActive: Binding<Bool>) {
        self.isActive = isActive
        viewModel = VideoCompressionViewModel()
      
    }
    
    var body: some View {
        ZStack {
            #if os(iOS)
            ScrollView {
                createBody()
            }
            .offset(y: 50)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 130)
            }
            #else
            createBody()
                .offset(y: 50)

            #endif
            

            createBottomSheet()
            
            if(viewModel.compressing) {
                ProgressView(progress: viewModel.progress)
            }
        }
        .overlay(NavigationBar(title: "Video Compression") {
            dismiss()
        })
        .background(
            Color
                .fromHex(0xF2F3F8)
                .edgesIgnoringSafeArea(.all)
        )
#if os(iOS)
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePicker{ url in
                isShowingPhotoLibrary = false
                guard let url = url else {
                    dismiss()
                    return
                }
                viewModel.onVideoSelected(url)
            }
        }
#endif
        .onAppear {
            viewModel.onCompletion = {
                dismiss()
            }
            Task {
                try! await Task.sleep(seconds: 1)
                showVideoPicker()
            }
        }
    }
    
    private func showVideoPicker() {
        #if os(iOS)
        showIOSPicker()
        #elseif os(macOS)
        showMacPicker()
        #endif
    }
    
    private func showIOSPicker() {
        isShowingPhotoLibrary = true
    }
    
    private func showMacPicker() {
        #if os(macOS)
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.allowedContentTypes = [.movie]
            if panel.runModal() == .OK {
                debugPrint("Ok")
                viewModel.onVideoSelected(panel.url!)
            } else {
                dismiss()
            }
        }
        #endif
    }

    private func createBody() -> some View {
        return  VStack(spacing: 16) {
            createFrameRateItem()
            createResolutionItem()
            createBitrateItem()
            createPlaybackSpeedItem()
            createEnableAudioItem()
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
    
    private func createBottomSheet() -> some View{    
        return VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Estimate Size:")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.4))
                if viewModel.isCalculatingEstimateSize {
                    SwiftUI.ProgressView()
                } else {
                    Text("\(viewModel.estimateFileSize) MB")
                }
                   
                createCompressButton()
                    .padding(.bottom, 30)
            }
            .padding()
            .padding(.bottom)
            .background(
                Color.white
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 2, y: 0)
            )
        }
        .offset(x: 0, y: 30)
        .ignoresSafeArea()
    }
    
    private func createBottomSheetContent(_ geometry: GeometryProxy) -> some View {
        print(geometry.size.width, geometry.size.height)

        
        return VStack {
            Text("Estimate Size:")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.4))
            Text("\(80) MB")
            createCompressButton()
        }
        .frame(alignment: .bottom)
        .padding()
        .padding(.bottom)
    }
    
    private func createCompressButton() -> some View{
        Button(action: {
            viewModel.compress()
        }) {
        
            Text("Compress")
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 50)
                .font(Font.subheadline.weight(.bold))
                .background(LinearGradient(gradient: Gradient(colors: [.fromHex(0xFF48C6EF), .fromHex(0xFF6F86D6)]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(Color.white)
                .cornerRadius(30)
                .contentShape(Rectangle())
        }
        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 2, y: 2)
        .buttonStyle(.plain)
    }
    
  
    private func createFrameRateItem() -> VideoCompressionTextFieldItem {
        VideoCompressionTextFieldItem(title: "Frame Rate", subtitle: "The higher the frame rate, the smoother the video is.", value: $viewModel.frameRate)
    }
    
    private func createResolutionItem() -> some View {
        
        VideoCompressionCustomListItem(
            title: "Resolution",
            subtitle: "The width and height have to be even numbers.",
            valueString: String("\(viewModel.width)x\(viewModel.height)")
        ) {
            HStack {
                createResolutionItemTextField(placeholder: "Width", text: $viewModel.width)
                createResolutionItemTextField(placeholder: "Height", text: $viewModel.height)
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
    
    private func createBitrateItem() -> VideoCompressionTextFieldItem {
        VideoCompressionTextFieldItem(title: "Bitrate", subtitle: "The higher the bitrate, the larger the video size is.", value: $viewModel.bitrate)
    }
    
    private func createPlaybackSpeedItem() -> some View {
        VideoCompressionSliderItem(
            title: "Playback Speed",
            value: $viewModel.playbackSpeed,
            valueString: String(format: "%.1fx", viewModel.playbackSpeed),
            range: 0.1...7,
            step: 0.1
        )
    }
    
    private func createEnableAudioItem() -> some View {
        CircularContainerView(backgroundColor: .white) {
            Toggle("Enable Audio", isOn: $viewModel.isAudioEnabled)
                .font(.title2)
                .disabled(!viewModel.hasAudioStream)
                .frame(maxWidth: .infinity)
        }
    }
    
    private func compressVideo() {
        #if os(macOS)
        NSApp.keyWindow?.makeFirstResponder(nil)
        #endif
        viewModel.compress()
    }
    
    private func dismiss() {
        withAnimation(Animation.easeInOut(duration: 0.8)) {
            isActive.wrappedValue = false
        }
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { (g) -> Path in
            print("width: \(g.size.width), height: \(g.size.height)")
            DispatchQueue.main.async { // avoids warning: 'Modifying state during view update.' Doesn't look very reliable, but works.
                self.rect = g.frame(in: .global)
            }
            return Path() // could be some other dummy view
        }
    }
}

struct VideoCompressionSliderItem : View{
    let title: String
    var subtitle: String?
    @Binding var value: Float
    var valueString: String
    let range: ClosedRange<Float>
    var step: Float = 1
    
    var body: some View {
        return VideoCompressionCustomListItem(title: title, subtitle: subtitle, valueString: valueString) {
            Slider(value: $value, in: range, step: step) { _ in

            }
        }
    }
}

struct VideoCompressionTextFieldItem : View {
    let title: String
    var subtitle: String?
    let value: Binding<String>
    
    var body: some View {
        VideoCompressionCustomListItem(title: title, subtitle: subtitle, valueString: value.wrappedValue) {
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

struct VideoCompressionCustomListItem<ContentView: View> : View{
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

struct VideoCompressionView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCompressionView(isActive: .constant(true))
    }
}
