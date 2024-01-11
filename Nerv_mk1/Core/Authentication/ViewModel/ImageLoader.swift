//
//  ImageLoader.swift
//  Nerv_mk1
//
//  Created by James Hallett on 11/01/2024.
//

import Foundation
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            } else {
                print("Error fetching the image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}
