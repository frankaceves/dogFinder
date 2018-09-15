//: [Previous](@previous)
import Foundation

let breedURLArray = [
    "https://images.dog.ceo/breeds/hound-afghan/n02088094_988.jpg",
    "https://images.dog.ceo/breeds/hound-basset/n02088238_10005.jpg",
    "https://images.dog.ceo/breeds/hound-blood/n02088466_9983.jpg",
    "https://images.dog.ceo/breeds/hound-english/n02089973_1.jpg",
    "https://images.dog.ceo/breeds/hound-ibizan/n02091244_966.jpg",
    "https://images.dog.ceo/breeds/hound-walker/n02089867_1029.jpg",
    "https://images.dog.ceo/breeds/akita/512px-Akita_inu.jpeg"
]

let dogBreed = breedURLArray[6]

func getBreedAndSubBreed(urlString: String) -> [String] {
    var stringArray = [String]()
    var breed: String!
    var subBreed: String!
    var fullBreed = urlString.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "").capitalized
    if let slashIndex = fullBreed.index(of: "/") {
        fullBreed = String(fullBreed[..<slashIndex])
    }
    
    
    let splitDogBreed = fullBreed.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
    if splitDogBreed.count <= 1 {
        let breed = String(splitDogBreed[0])
        stringArray.append(breed)
    } else {
        breed = String(splitDogBreed[0])
        subBreed = String(splitDogBreed[1])
        stringArray.append(breed)
        stringArray.append(subBreed)
    }
    
    return stringArray
}

getBreedAndSubBreed(urlString: dogBreed)

//: [Next](@next)
