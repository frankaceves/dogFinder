//
//  GameViewController.swift
//  dogFinder
//
//  Created by Frank Aceves on 8/29/19.
//  Copyright © 2019 Frank Aceves. All rights reserved.
//

import Foundation
import UIKit



class GameViewController: UIViewController {
    // MARK: - PROPERTIES
    let dogClient = DogClient()
    var correctDogNumber = Int()
    var round: Int = 0 {
        didSet {
            roundLabel.text = "Round: \(round)"
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: - OUTLETS
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup game
        setupGame()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "RESET GAME", style: .plain, target: self, action: #selector(setupGame))
        configureButtons()
    }
    
    
    // MARK: - ACTIONS
    func configureButtons() {
        Button1.layer.cornerRadius = 10
        Button1.backgroundColor = .lightGray
        Button1.tintColor = .white
        Button2.layer.cornerRadius = 10
        Button2.backgroundColor = .lightGray
        Button2.tintColor = .white
        Button3.layer.cornerRadius = 10
        Button3.backgroundColor = .lightGray
        Button3.tintColor = .white
    }
    
    
    @objc func setupGame() {
        round = 1
        score = 0
        setupRound()
    }
    
    func setupRound() {
        clearButtons()
        
        getThreeDogs { (dogArray, error) in
            guard (error == nil) else {
                print("error GETTHREEDOGS")
                return
            }
            
            guard var dogs = dogArray else {
                print("no dogs GETTHREEDOGS")
                return
            }
            dogs = dogs.shuffled()
            let randomNumber = Int.random(in: 0..<3)
            //print("randomNumber: \(randomNumber)")
            let correctDog = dogs[randomNumber]
            
            self.correctDogNumber = randomNumber
            //print("correctDog: \(correctDog)")
            
            if let dogData = try? Data(contentsOf: URL(string: correctDog.urlString)!) {
                dogs[randomNumber].imageData = dogData
            }
            
            //print("final dogs from SetupRound: \(dogs)")
            
            var hasDuplicates: Bool = false
            
            if dogs[0].breed == dogs[1].breed || dogs[0].breed == dogs[2].breed || dogs[1].breed == dogs[2].breed {
                hasDuplicates = true
            }
            
            
            DispatchQueue.main.async {
                self.gameImageView.image = UIImage(data: dogs[randomNumber].imageData!)!
                
                if hasDuplicates {
                    self.Button1.setTitle(dogs[0].subBreed + " " + dogs[0].breed, for: .normal)
                    self.Button2.setTitle(dogs[1].subBreed + " " + dogs[1].breed, for: .normal)
                    self.Button3.setTitle(dogs[2].subBreed + " " + dogs[2].breed, for: .normal)
                } else {
                    self.Button1.setTitle(dogs[0].breed, for: .normal)
                    self.Button2.setTitle(dogs[1].breed, for: .normal)
                    self.Button3.setTitle(dogs[2].breed, for: .normal)
                }
                
                
            }
        }
    }
    
    func checkRound() {
        if round == 10 {
            let ac = UIAlertController(title: "Game Over!", message: "Your Score is \(score).", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Start Over", style: .default) { (action) in
                self.setupGame()
            }
            ac.addAction(okAction)
            present(ac, animated: true, completion: nil)
        } else {
            round += 1
            setupRound()
        }
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        print("tapped: \(sender.titleLabel!.text!)")

        if sender.tag == correctDogNumber {
            print("correct!")
            score += 1
            checkRound()
            
        } else {
            print("INCORRECT!")
            checkRound()
        }
    }
    
    func clearButtons() {
        self.Button1.setTitle("", for: .normal)
        self.Button2.setTitle("", for: .normal)
        self.Button3.setTitle("", for: .normal)
    }
    
    
    
    
    func getThreeDogs(completion: @escaping (_ dog: [Dog]?, _ error: String?) -> Void)  {
        
        dogClient.getThreeRandomDogs { (dogArray, error) in
            guard (error == nil) else {
                completion(nil, "error in ThreeRandDogs func: \(error!)")
                return
            }
            
            guard let dogArray = dogArray else {
                completion(nil, "no dogarray present")
                return
            }
            
            
            completion(dogArray, nil)
        } //3randDog func
        
    } // getThreeDogs
}
