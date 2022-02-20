//
//  MainView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 19/02/22.
//

import SwiftUI
import MobileCoreServices
import PhotosUI


struct ImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (URL) -> Void
    @Environment(\.presentationMode) var presentationMode
     
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
 
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .videos
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else { return }

            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _, _ in

                    DispatchQueue.main.async { [weak self] in
                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("cleanup-on-launch")
                        try! FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true, attributes: nil)
                        let fileUrl = temp.appendingPathComponent(UUID.init().uuidString+".mp4")
                        try! FileManager.default.moveItem(at: url!, to: fileUrl)
                        self?.parent.onImagePicked(fileUrl)
                        self?.parent.presentationMode.wrappedValue.dismiss()
                    }
                   
                }
                    
            }
        }

        private var url1: URL?
        private var time: Timer?
        
        deinit {
            debugPrint("Deinit")
        }
        
    }
}
struct MainView: View {
    
    @State private var isShowingPhotoLibrary = false
    
    var body: some View {
        VStack {
            Button("Compress") { isShowingPhotoLibrary = true }.padding()
        }
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePicker(onImagePicked: { url in
                onVideoSelected(videoURL: url) })
        }
       
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

class TestClass {
    func test() async {
        Task.init() {
            debugPrint("Is MainThread3: \(Thread.isMainThread)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
