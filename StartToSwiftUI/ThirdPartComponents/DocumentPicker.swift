////
////  DocumentPicker.swift
////  StartToSwiftUI
////
////  Created by Andrey Efimov on 09.09.2025.
////
//
//import SwiftUI
////import UniformTypeIdentifiers
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    var onPick: (URL) -> Void
//    
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
//        picker.delegate = context.coordinator
//        picker.allowsMultipleSelection = false
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(onPick: onPick)
//    }
//    
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        var onPick: (URL) -> Void
//        init(onPick: @escaping (URL) -> Void) {
//            self.onPick = onPick
//        }
//        
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else { return }
//            onPick(url)
//        }
//    }
//}
