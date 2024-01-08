//
//  CameraView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/01/2024.
//

import SwiftUI
import UIKit
import PhotosUI



struct CameraView: View {
    @StateObject private var viewModel_request = RequestAuthModel()
    @State private var title: String = ""
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    
    var body: some View {
        VStack {
            
            if let selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                
                Section(header: Text("Enter a photo title: ")){
                    TextEditor(text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                Button("Upload to database") {
                    viewModel_request.uploadImageToFirebase(imageData, withName: title) { result in
                        switch result {
                        case .success(let url):
                            print("Image uploaded successfully: \(url)")
                        case .failure(let error):
                            print("Error uploading image: \(error)")
                        }
                    }
                }
            }
                
            Spacer()
            
            Button("Open Camera") {
                self.showCamera.toggle()
            }
            .fullScreenCover(isPresented: self.$showCamera) {
                accessCameraView(selectedImage: self.$selectedImage)
            }
        }
    }
}

struct accessCameraView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: accessCameraView
    
    init(picker: accessCameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}

#Preview {
    CameraView()
}
