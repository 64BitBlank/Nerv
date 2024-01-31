//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI

struct test: View {
    var body: some View {
        VStack{
            Carousel(items: 5) { item in
                RoundedRectangle(cornerRadius: 15)
                    .fill(.gray)
                    .opacity(0.5)
                    .shadow(radius: 10.0)
                    .padding()
                    .overlay(Text(String(item)).font(.title).foregroundColor(.white))
                    .carouselItem()
            }
            .padding(.top)
        }
    }
}

#Preview {
    test()
}
