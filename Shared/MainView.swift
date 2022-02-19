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
//        let imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = sourceType
//        imagePicker.mediaTypes =  [kUTTypeMovie as String]
//        imagePicker.delegate = context.coordinator
//        return imagePicker
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
            
            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                debugPrint("URL: \(url?.path)")
                let temp = FileManager.default.temporaryDirectory.appendingPathComponent("picked_video.mp4")
                if(FileManager.default.fileExists(atPath: temp.path)) {
                    try! FileManager.default.removeItem(at: temp)
                }
                try! FileManager.default.moveItem(at: url!, to: temp)
                self?.parent.onImagePicked(temp)
            }
                    
        }
        
        deinit {
            debugPrint("Deinit")
        }
    }
    
//    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//        var parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//            let imageURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
//            debugPrint("Image picked: \(imageURL.path)")
//
//            parent.onImagePicked(imageURL)
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//        deinit {
//            debugPrint("Deinit")
//        }
//    }
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
