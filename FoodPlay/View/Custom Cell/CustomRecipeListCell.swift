//
//  CustomRecipeListCell.swift
//  FoodPlay
//
//  Created by Walter Mitchell on 8/15/18.
//  Copyright © 2018 Walter Mitchell. All rights reserved.
//

import UIKit

class CustomRecipeListCell: UITableViewCell {
    
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var servings: UILabel!
    @IBOutlet var readyInMinutes: UILabel!
    
    var id: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
    }
}
