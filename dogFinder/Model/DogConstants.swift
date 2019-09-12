//
//  DogConstants.swift
//  dogFinder
//
//  Created by Frank Aceves on 10/1/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

extension DogClient {
    struct Constants {
        struct RandomDog: Decodable {
            let status: String
            let message: String
        }
        
        struct AllDogBreeds: Decodable {
            let status: String
            let message: [String: [String]]
        }
        
        struct Breed: Decodable {
            let breed: String
        }
        
        struct SubBreed: Decodable {
            let subBreed: [String]
        }
        
        
        //RANDOM DOG JSON
        struct APIUrls {
            static let randomDogAPIString = "https://dog.ceo/api/breeds/image/random"
            static let threeDogAPIString = "https://dog.ceo/api/breeds/image/random/3"
        }
        
    }
}
