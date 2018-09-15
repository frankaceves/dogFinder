//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct RandomDog: Decodable {
    let status: String
    let message: String
}

struct AllDogBreeds: Decodable {
    let status: String
    //let message: [Breed: [SubBreed]] // [breed: [subBreed]]
    let message: [String: [String]]
}

struct Breed: Decodable {
    let breed: String
}

struct SubBreed: Decodable {
    let subBreed: [String]
}


//RANDOM DOG JSON
let randomDogAPIString = "https://dog.ceo/api/breeds/image/random"
var url: URL!

if let testURL = URL(string: randomDogAPIString) {
    url = testURL
}

let request = URLRequest(url: url)

func showRandomDog() {
    let randomDogAPIString = "https://dog.ceo/api/breeds/image/random"
    let randomDogURL = URL(string: randomDogAPIString)!
    
    let request = URLRequest(url: randomDogURL)
    
    taskForGetMethod(urlRequest: request) { (randomDogData, error) in
        guard (error == nil) else {
            print("error in taskForGet: \(error)")
            return
        }
        
        guard let randomDogData = randomDogData else {
            print("no dog data from taskForGet")
            return
        }
        
        let randomDogURLString = randomDogData.message
        
        if let randomDogURL = URL(string: randomDogURLString), let dogData = try? Data(contentsOf: randomDogURL) {
            let dogImage = UIImage(data: dogData)
        }
        
    }
    
    
}

func taskForGetMethod(urlRequest: URLRequest, completionForGet: @escaping (_ result: RandomDog?, _ error: String?) -> Void) -> URLSessionDataTask{
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard (error == nil) else {
            print("there was an error: \(error!.localizedDescription)")
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 200 else {
            print("status code was not 200 or lower")
            return
        }
        
        guard let data = data else {
            print("no data returned")
            return
        }
        
        convertToJSONFrom(randomDogData: data, completionForJSONConversion: completionForGet)
        
    }
    task.resume()
    return task
}

func convertToJSONFrom(randomDogData: Data, completionForJSONConversion: @escaping (_ result: RandomDog?, _ error: String?) -> Void) {
    var decodedResults: RandomDog!
    
    do {
        decodedResults = try JSONDecoder().decode(RandomDog.self, from: randomDogData)
        completionForJSONConversion(decodedResults, nil)
    } catch {
        print("error decoding randomDog JSON: \(error.localizedDescription)")
        completionForJSONConversion(nil, error.localizedDescription)
    }
}

    
    


showRandomDog()
