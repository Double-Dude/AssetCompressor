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

    private let gridItemLayout = [
        GridItem(spacing: 16),
        GridItem(),
    ]
    
    var body: some View {
        if(selectedID != nil) {
            ZStack {
                Color.fromHex(0xF2F3F8)
                    .matchedGeometryEffect(id: selectedID!, in: namespace)
                    .rotationEffect(.degrees(rotate ? 0 : -180))
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(Animation.easeIn(duration: 0.3)) {
                        self.rotate.toggle()
                    }
            }
//            createa(id: selectedID!)
        } else {
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
                    ImagePicker(onImagePicked: { url in
                    onVideoSelected(videoURL: url) })
                    #endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.fromHex(0xFF48C6EF), .fromHex(0xFF6F86D6)]), startPoint: .leading, endPoint: .trailing))
            .ignoresSafeArea()
        }
    }

    private func createa(id: String) -> some View {
        ZStack {
            Color.green
                .matchedGeometryEffect(id: id, in: namespace)
                .frame(width: 500, height: 500, alignment: .leading)
                .rotationEffect(.degrees(rotate ? 360 : 0))

//                Text("Test1")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(width: 500, height: 500, alignment: .center)
//                    .rotationEffect(.degrees(rotate ? 180 : 0))
//                    .background(
//                        Color.red
//                    )
//                    .animation(.easeInOut(duration: 3).delay(3), value: rotate)
        }
        .onAppear {
            debugPrint(String(selectedID!))

            withAnimation(Animation.easeOut(duration: 0.5)) {
                    self.rotate.toggle()
                }
        }
    }
    
    private func createMenuItem(_ id: String) -> some View {
        return MainMenuItem(
            id: id,
            namespace: namespace,
            title: "Quick Play",
            image: Image(systemName: "video"),
            onTapped: {
                withAnimation(Animation.linear(duration: 0.5)) {
                    selectedID = id
                }
            }
        )
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        
    }
    
    private func onVideoSelected(videoURL: URL) {
        
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("Test.mp4")
        debugPrint(tmpURL)
        let request = VideoCompressionRequest(
            bitRate: 1096,
            playbackSpeed: 2,
            outputFps: 17,
            outputWidth: 640,
            outputHeight: 360,
            inputFilePaths: [videoURL],
            outputFilePath: tmpURL)
        Task.init {
            let result = await FFmpegVideoCompressor(ffmpegCommandFactory: FFmpegCommandFactory()).execute(videoCompressionRequest: request)
            switch result {
               case .success(let url):
                debugPrint("Completed \(url.path)")
               case .failure(let error):
                    debugPrint("Failed \(error.localizedDescription)")
               }
        }
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
