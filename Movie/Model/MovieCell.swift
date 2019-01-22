//
//  MovieCell.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/17/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit

protocol MovieCellDelegate {
    func didTapFavoriteButton(movieID: Int)
}

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var overViewLbl: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var addFavorieBtn: UIButtonX!
    
    var movieID: Int = 0
    var delegate: MovieCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLabelSizes() {

        self.nameLbl.adjustsFontSizeToFitWidth = true
        let overviewHeight = overViewLbl.optimalHeight
        overViewLbl.frame = CGRect(x: overViewLbl.frame.origin.x, y: overViewLbl.frame.origin.y, width: overViewLbl.frame.width, height: overviewHeight)
        
    }
    
    
    // To change the rating color of the movie based on how high the rating
    func ratingLblColor(rating: Double){
    
        switch rating {
        case 0..<5.0:
            ratingLbl.textColor = UIColor.red
            break
            
        case 5.0..<8.0:
            ratingLbl.textColor = UIColor.yellow
            break
            
        case 8.0..<10:
            ratingLbl.textColor = UIColor.green
            break
            
        default:
            break
        }
    }

    @IBAction func addFavoriteTapped(_ sender: Any) {
        delegate?.didTapFavoriteButton(movieID: self.movieID)
    }
}
