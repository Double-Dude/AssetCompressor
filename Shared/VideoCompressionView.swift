//
//  VideoCompressConfigView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 22/02/22.
//

import SwiftUI

struct VideoCompressionView: View {
    private let textFieldTopPadding = 8.0
    
    @State private var inputURLs : URL?
    var id: String = UUID().uuidString
    var namespace: Namespace.ID?
    @State var value: Float = 50.0
    @Namespace private var defaultNameSpace
    @State private var rotate = false
   
    @State private var frameRate: String = "0"
    @State private var width: String = "0"
    @State private var height: String = "0"
    @State private var bitrate: String = "0"
    @State private var playbackSpeed: Float = 1
    @State private var scrollOffset: Float = 60

    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var isShowingPhotoLibrary = false
    
    private var videoEditor = FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory())
    
    var body: some View {
        ScrollView {
            ZStack {
                createBody()
            }
        }

        .offset(y: 50)
        .overlay(NavigationBar())
        .background(
            Color
                .fromHex(0xF2F3F8)
                .edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $isShowingPhotoLibrary) {
            #if os(iOS)
            ImagePicker{ url in
                isShowingPhotoLibrary = false
                inputURLs = url
                guard let url = url else { return }
                onVideoSelected(url)
            }
            #endif
        }
        .onAppear {
            Task {
                try! await Task.sleep(nanoseconds: 1000000000)
                isShowingPhotoLibrary = true
            }
        }
    }
    
    func onVideoSelected(_ url: URL) {
        Task {
            let metadata = await videoEditor.getMetadata(url)
            frameRate = String(metadata.fps)
            width = String(metadata.width)
            height = String(metadata.height)
            bitrate = String(metadata.bitrate)
        }
    }
    
    func createBody() -> some View {
        return  VStack(spacing: 16) {
            createFrameRateItem()
            createResolutionItem()
            createBitrateItem()
            createPlaybackSpeedItem()
            
            Button("Compress") {
                
            }
            .frame(height: 45)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [.fromHex(0xFF48C6EF), .fromHex(0xFF6F86D6)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(30)
            .contentShape(Rectangle())
            .shadow(color: Color.black.opacity(0.4), radius: 3, x: 2, y: 2)


            //                    .aspectRatio(1, contentMode: .fill)
                
                
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
  
    private func createFrameRateItem() -> VideoCompressionTextFieldItem {
        VideoCompressionTextFieldItem(title: "Frame Rate", subtitle: "The higher the frame rate, the smoother the video is.", value: $frameRate)
    }
    
    private func createResolutionItem() -> some View {
        
        VideoCompressionCustomListItem(
            title: "Resolution",
            subtitle: "The width and height have to be even numbers.",
            valueString: String("\(width)x\(height)")
        ) {
            HStack {
                createResolutionItemTextField(placeholder: "Width", text: $width)
                createResolutionItemTextField(placeholder: "Height", text: $height)
            }
            .padding(.top, textFieldTopPadding)
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
        .keyboardType(.numberPad)
    }
    
    private func createBitrateItem() -> VideoCompressionTextFieldItem {
        VideoCompressionTextFieldItem(title: "Bitrate", subtitle: "The higher the bitrate, the larger the video size is.", value: $bitrate)
    }
    
    private func createPlaybackSpeedItem() -> some View {
        VideoCompressionSliderItem(
            title: "Playback Speed",
            value: $playbackSpeed,
            valueString: String(format: "%.1fx", playbackSpeed),
            range: 0.1...7,
            step: 0.1
        )
    }
    
    private func compressVideo() {
//        let request = VideoCompressionRequest(
//            bitRate: ,
//            playbackSpeed: 2,
//            outputFps: 17,
//            outputWidth: 640,
//            outputHeight: 360,
//            inputFilePaths: inputURLs,
//            outputFilePath: outputURL)
//        Task.init {
//            let result = await FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory()).execute(videoCompressionRequest: request)
//            switch result {
//               case .success(let url):
//                debugPrint("Completed \(url.path)")
//                UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
//
//               case .failure(let error):
//                    debugPrint("Failed \(error.localizedDescription)")
//               }
//        }
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
        .keyboardType(.numberPad)
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
        VideoCompressionView()
    }
}
