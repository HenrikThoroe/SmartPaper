//
//  DocumentReader.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 28.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import SwiftUI
import VisionKit

struct DocumentReader: UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    
    let inputSource: InputSource
    
    let action: ([UIImage]) -> Void
    
    init(isShown: Binding<Bool>, _ source: InputSource, _ action: @escaping ([UIImage]) -> Void) {
        self._isShown = isShown
        self.inputSource = source
        self.action = action
    }
    
    func makeCoordinator() -> DocumentReaderCoordinator {
        DocumentReaderCoordinator(onCancel: dismiss, onFinish: finish(with:))
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller: UIViewController
        
        switch inputSource {
        case .scanner:
            controller = VNDocumentCameraViewController()
            (controller as! VNDocumentCameraViewController).delegate = context.coordinator
        case .library:
            controller = UIImagePickerController()
            
            with(controller as! UIImagePickerController) {
                $0.sourceType = .photoLibrary
                $0.delegate = context.coordinator
            }
        case .camera:
            controller = UIImagePickerController()
            
            with(controller as! UIImagePickerController) {
                $0.sourceType = .camera
                $0.delegate = context.coordinator
                $0.showsCameraControls = true
                $0.cameraDevice = .rear
            }
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func dismiss() {
        isShown = false
    }
    
    func finish(with images: [UIImage]) {
        action(images)
        dismiss()
    }
    
    static func actionSheet(showReader: Binding<Bool>, readerInput: Binding<InputSource>) -> ActionSheet {
        ActionSheet(title: Text("Add Document"),
                    buttons: [
                        .cancel(),
                        .default(Text("Camera")) {
                            readerInput.wrappedValue = .camera
                            showReader.wrappedValue = true
                        },
                        .default(Text("Scanner")) {
                            readerInput.wrappedValue = .scanner
                            showReader.wrappedValue = true
                        },
                        .default(Text("Photo Library")) {
                            readerInput.wrappedValue = .library
                            showReader.wrappedValue = true
                        }
            ]
        )
    }
    
}

extension DocumentReader {
    
    enum InputSource {
        case scanner, library, camera
    }
    
}

struct DocumentReader_Previews: PreviewProvider {
    @State private static var showPicker = true
    
    static var previews: some View {
        DocumentReader(isShown: $showPicker, .camera) { images in
            
        }
    }
}

final class DocumentReaderCoordinator: NSObject {
    
    private let onFinish: ([UIImage]) -> Void
    
    private let onCancel: () -> Void
    
    init(onCancel: @escaping () -> Void, onFinish: @escaping ([UIImage]) -> Void) {
        self.onFinish = onFinish
        self.onCancel = onCancel
    }
    
}

extension DocumentReaderCoordinator: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        onCancel()
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
        onFinish(images)
    }
    
}

extension DocumentReaderCoordinator: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        onFinish([image])
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onCancel()
    }
    
}
