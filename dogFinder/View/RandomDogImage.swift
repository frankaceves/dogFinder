//
//  RandomDogImage.swift
//  dogFinder
//
//  Created by Frank Aceves on 5/18/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//

import UIKit

class RandomDogImage: UIImageView {
    var dogImage: UIImage?
    
    func getImageFrom(_ data: Data?) -> UIImage {
        guard let data = data else {
            print("no data to getImageFrom: using placeholder")
            return #imageLiteral(resourceName: "shiba-8.JPG")
        }
        
        if let image = UIImage(data: data) {
            return image
        } else {
            print("no data to getImageFrom: using placeholder")
            return #imageLiteral(resourceName: "shiba-8.JPG")
        }
    }
}
