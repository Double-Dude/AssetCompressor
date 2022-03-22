//
//  ImagePicker.swift
//  AssetCompressor
//
//  Created by Ray Qu on 21/02/22.
//
#if os(iOS)

import MobileCoreServices
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    let filterType: PHPickerFilter
    let onCompletion: (URL?) -> Void
    @Environment(\.presentationMode) var presentationMode
     
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = filterType
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
            guard let provider = results.first?.itemProvider else {
                Task {
                    self.parent.presentationMode.wrappedValue.dismiss()
                    try! await Task.sleep(seconds: 0.5)
                    self.parent.onCompletion(nil)
                }
                return
            }
            
            provider.loadFileRepresentation(forTypeIdentifier: createIdentifier()) { [weak self] url, error in
                guard let url = url else {
                    self?.parent.onCompletion(nil)
                    return
                }
                debugPrint("Start: \(Date.init())")
                let temp = FileLocation.getOrCreateCleanOnLaunchURL()
                let fileUrl = temp.appendingPathComponent(UUID.init().uuidString + "." + url.pathExtension)
                try! FileManager.default.moveItem(at: url, to: fileUrl)
                debugPrint("Stop: \(Date.init())")
                self?.parent.onCompletion(fileUrl)
//                self?.parent.presentationMode.wrappedValue.dismiss()
//                DispatchQueue.main.async { [weak self] in
//
//                }
//                provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _, _ in
//                    provider.loadPreviewImage() { (data, error) in
//                        if let image = data as? UIImage {
//                            debugPrint(image)
//                        }
//                    }
//                    DispatchQueue.main.async { [weak self] in
//                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("cleanup-on-launch")
//                        try! FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true, attributes: nil)
//                        let fileUrl = temp.appendingPathComponent(UUID.init().uuidString+".mp4")
//                        try! FileManager.default.moveItem(at: url!, to: fileUrl)
//                        self?.parent.onCompletion(fileUrl)
//                        self?.parent.presentationMode.wrappedValue.dismiss()
//                    }
//                }
                    
            }
        }
        
        private func createIdentifier() -> String {
            switch parent.filterType {
            case .videos:
                return UTType.movie.identifier
            case .images:
                return UTType.image.identifier
            default:
                return UTType.video.identifier
            }
        }
        
     
    }
}
#endif
