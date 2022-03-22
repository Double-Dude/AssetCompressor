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
    @State private var showVideoCompressionView = false
    @State private var showImageCompressionView = false
    @State private var rotate = false
    @State private var inputURL: URL = URL.init(fileURLWithPath: "")

    private let gridItemLayout = [
        GridItem(spacing: 16),
        GridItem(),
    ]
    
    var body: some View {
        if(showVideoCompressionView) {
            VideoCompressionView(isActive: $showVideoCompressionView)
                .matchedGeometryEffect(id: "1", in: namespace)
                .transition(.fly)
        }
        
        if showImageCompressionView {
            
        }
        
        if(showVideoCompressionView == false && showImageCompressionView == false) {
            createMainView()
        }
    }
    
    private func createMainView() -> some View {
        VStack {
            LazyVGrid(columns: gridItemLayout, spacing: 16, content: {
                createVideoCompressionMenuItem()
                createImageCompressionMenuItem()
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
    
    private func createVideoCompressionMenuItem() -> some View {
        let id = "1"
        return MainMenuItem(
            id: id,
            namespace: namespace,
            title: "Video",
            image: Image(systemName: "video"),
            onTapped: {
                withAnimation(Animation.easeInOut(duration: 0.8)) {
                    selectedID = id
                    showVideoCompressionView = true
                }
            }
        )
    }
    
    private func createImageCompressionMenuItem() -> some View {
        let id = "2"
        return MainMenuItem(
            id: id,
            namespace: namespace,
            title: "Image",
            image: Image(systemName: "photo"),
            onTapped: {
                withAnimation(Animation.easeInOut(duration: 0.8)) {
                    selectedID = id
                    showVideoCompressionView = true
                }
            }
        )
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
                    showVideoCompressionView = true
                }
            }
        )

    }
    
    private func onVideoSelected(videoURL: URL) {
        inputURL = videoURL
        withAnimation(Animation.easeOut(duration: 0.5)) {
            selectedID = "1"
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}