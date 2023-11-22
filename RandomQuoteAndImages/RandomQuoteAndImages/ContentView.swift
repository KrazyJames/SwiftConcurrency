//
//  ContentView.swift
//  RandomQuoteAndImages
//
//  Created by Mohammad Azam on 7/14/21.
//

import SwiftUI

struct ContentView: View {
    private var randomImageListVM = RandomImageListViewModel()
    var body: some View {
        List(randomImageListVM.images) { image in
            HStack {
                image.image.map {
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Text(image.quote)
            }
        }
        .task {
            await randomImageListVM.getRandomImages(ids: Array(100...120))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task {
                        await randomImageListVM.getRandomImages(ids: Array(100...120))
                    }
                }, label: {
                    Label("Reload", systemImage: "arrow.clockwise.circle")
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
