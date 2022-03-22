//
//  ImageCompressionView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 23/03/22.
//

import SwiftUI

struct ImageCompressionView: View {
    var id: String = UUID().uuidString
    var isActive: Binding<Bool>
    @ObservedObject var viewModel: ImageCompressionViewModel
   
    @State private var isShowingPhotoLibrary = false
    @State private var isShowingBottomSheet = false

    init(isActive: Binding<Bool>) {
        self.isActive = isActive
        viewModel = ImageCompressionViewModel()
      
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
            
            if isShowingBottomSheet {
                createBottomSheet()
            }
        
            if(viewModel.compressing) {
                ProgressView(progress: viewModel.progress)
            }
        }
        .overlay(NavigationBar(title: "Image Compression") {
            dismiss()
        })
        .background(
            Color
                .fromHex(0xF2F3F8)
                .edgesIgnoringSafeArea(.all)
        )
#if os(iOS)
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePicker(filterType: .images){ url in
                isShowingPhotoLibrary = false
                guard let url = url else {
                    dismiss()
                    return
                }
                viewModel.onImageSelect(url)
//                viewModel.onVideoSelected(url)
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
                withAnimation(Animation.easeInOut(duration: 1)) {
                    isShowingBottomSheet = true
                }
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
            panel.allowedContentTypes = [.image]
            if panel.runModal() == .OK {
                debugPrint("Ok")
                viewModel.onImageSelect(panel.url!)
            } else {
                dismiss()
            }
        }
        #endif
    }

    private func createBody() -> some View {
        return  VStack(spacing: 16) {
            createResolutionItem()
            createImageQualityItem()
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
    
    private func createResolutionItem() -> some View {
        CompressionResolutionItem(width: $viewModel.width, height: $viewModel.height)
    }
    
    private func createImageQualityItem() -> some View {
        CompressionSliderItem(
            title: "Quality",
            value: $viewModel.quality,
            valueString: String(format: "%.0f%%", viewModel.quality * 100),
            range: 0.1...1,
            step: 0.1
        )
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

