//
//  FavoriteDogTableViewCell.swift
//  dogFinder
//
//  Created by Frank Aceves on 9/16/18.
//  Copyright © 2018 Frank Aceves. All rights reserved.
//

import UIKit

class FavoriteDogTableViewCell: UITableViewCell {
    
    @IBOutlet var favoriteDogImageView: UIImageView!
    
    @IBOutlet var favoriteDogBreedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.layoutMargins = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
