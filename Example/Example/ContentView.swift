//
//  ContentView.swift
//  Example
//
//  Created by Fumiya Tanaka on 2023/04/20.
//

import SwiftUI
import ToiletDetection

//let imageAddress = "https://ropping.tv-asahi.co.jp/images/common/1108490000CT.jpg"
let imageAddress = "https://kokubo.co.jp/wp/wp-content/uploads/km-011-img4.jpg"

struct ContentView: View {

    @State private var prob: Double = 0
    private let toiletDetection = ToiletDetection()

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageAddress), content: {
                $0.image?.resizable()
                    .frame(width: 120, height: 120)
            })
            Text("Toilet Seat existence: \(prob)%")
        }
        .padding()
        .task {
            let data = await Task.detached {
                let data = try! Data(contentsOf: URL(string: imageAddress)!)
                return data
            }.value
            prob = toiletDetection.perform(image: UIImage(data: data)!) * 100
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
