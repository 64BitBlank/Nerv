//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI

struct test: View {
    @StateObject var carouselModel = CarouselModel()
    var body: some View {
        Text("Testing Carousel System")
        Carousel(items: 5) { item in
            RoundedRectangle(cornerRadius: 5)
                 .fill(Color.gray)
                 .overlay(Text(String(item)).font(.title).foregroundColor(.white))
                 .carouselItem()
        }
        .padding(.top)
    }
}

#Preview {
    test()
}
