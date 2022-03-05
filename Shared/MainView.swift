//
//  MainView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import SwiftUI

struct MainView: View {
    @Namespace private var namespace
    @State private var isShowingPhotoLibrary = false
    @State private var selectedID: String?
    @State private var rotate = false
    @State private var inputURL: URL = URL.init(fileURLWithPath: "")

    private let gridItemLayout = [
        GridItem(spacing: 16),
        GridItem(),
    ]
    
    var body: some View {
        if(selectedID != nil) {
            VideoCompressionView()
                .matchedGeometryEffect(id: "1", in: namespace)
                .transition(.fly)
        }
        
        if(selectedID == nil) {
            createMainView()
        }
    }
    
    private func createMainView() -> some View {
        VStack {
            LazyVGrid(columns: gridItemLayout, spacing: 16, content: {
                createMenuItem("1")
                createMenuItem("2")
                createMenuItem("3")
                createMenuItem("4")
            })
            .padding()
            .sheet(isPresented: $isShowingPhotoLibrary) {
                #if os(iOS)
                ImagePicker{ url in
                    isShowingPhotoLibrary = false
                    if let url = url {
                        onVideoSelected(videoURL: url)
                    }
                }
                #endif
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [.fromHex(0xFF48C6EF), .fromHex(0xFF6F86D6)]), startPoint: .leading, endPoint: .trailing))
        .ignoresSafeArea()
    }
    
    private func createMenuItem(_ id: String) -> some View {
        return MainMenuItem(
            id: id,
            namespace: namespace,
            title: "Quick Play",
            image: Image(systemName: "video"),
            onTapped: {
//                isShowingPhotoLibrary = true
                withAnimation(Animation.easeInOut(duration: 0.8)) {
                    selectedID = id
                }
            }
        )

    }
    
    private func onVideoSelected(videoURL: URL) {
        inputURL = videoURL
        withAnimation(Animation.easeOut(duration: 0.5)) {
            selectedID = "1"
        }
//        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("Test.mp4")
//        debugPrint(tmpURL)
//        let request = VideoCompressionRequest(
//            bitRate: 1096,
//            playbackSpeed: 2,
//            outputFps: 17,
//            outputWidth: 640,
//            outputHeight: 360,
//            inputFilePaths: [videoURL],
//            outputFilePath: tmpURL)
//        Task.init {
//            let result = await FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory()).execute(videoCompressionRequest: request)
//            switch result {
//               case .success(let url):
//                debugPrint("Completed \(url.path)")
//               case .failure(let error):
//                    debugPrint("Failed \(error.localizedDescription)")
//               }
//        }
    }
    
    private func onselectPhotoFromMacOS() {
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


//Color
//                    .white
//                    .aspectRatio(1, contentMode: .fit)
//                    //.frame(height: 100)
//                    .overlay(
//                        Button("Compress") { isShowingPhotoLibrary = true }
//                    )
//                    .cornerRadius(30)
//                    //.contentShape(RoundedRectangle(cornerRadius: 10.0))
//                Button("Compress") { isShowingPhotoLibrary = true }.padding()
//                Button("Compress") { isShowingPhotoLibrary = true }.padding()
//                HStack {
//                    Button("Compress") { isShowingPhotoLibrary = true }
//                }
//                //.frame(minWidth: .infinity, minHeight: .infinity)
//                .background(Color.white)
//
//                Button(action: {
//                           print("Round Action")
//                           }) {
//                           Text("Press")
//                               .foregroundColor(Color.green)
//                               .background(Color.white)
//                               .clipShape(Circle())
////                               .aspectRatio(1, contentMode: .fill)
//                           }
////                           .aspectRatio(1, contentMode: .fill)
//                           .frame(maxWidth: .infinity)
//
//                Button("even longer Text") {
//                    print("x")
//                }
//                .frame(maxWidth: .infinity)
//
//                Button(action: { print("") }) {
//                    VStack {
//                        Image(systemName: "video")
//                            .frame()
//                    Text("item")
//                    }
//                               }    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .contentShape(Rectangle())
//                    .aspectRatio(1, contentMode: .fill)
//                    .background(Color.white)
//
//                let tap = DragGesture(minimumDistance: 0).onChanged { _ in
//                    print("onPressed")
//
//                }
