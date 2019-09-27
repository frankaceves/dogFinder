//
//  DogModel.swift
//  dogFinder
//
//  Created by Frank Aceves on 5/17/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//
import Foundation

struct Dog {
    var urlString: String
    var breed: String = ""
    var subBreed: String = ""
    var imageData: Data?
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    mutating func getBreedAndSubBreed() {
        var fullBreed = urlString.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "").capitalized
        
        if let slashIndex = fullBreed.firstIndex(of: "/") {
            fullBreed = String(fullBreed[..<slashIndex])
        }
        
        let splitDogBreed = fullBreed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        if splitDogBreed.count <= 1 {
            breed = String(splitDogBreed[0])
            subBreed = ""
        } else {
            breed = String(splitDogBreed[0])
            subBreed = String(splitDogBreed[1])
            
        }
        
    } // GET BREED & SUBBREED
    
    mutating func getImageData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("can't get url")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("can't get data from url: \(urlString)")
            return
        }
        
        imageData = data
    }
}
