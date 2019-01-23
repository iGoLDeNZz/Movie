//
//  FavoriteVC.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/21/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import SDWebImage

class FavoriteVC: UIViewController {


    
    var favoriteMovies: [JSON] = []
    var movieSelected: JSON?
    let defaults = UserDefaults.standard
//    var cellIndex: IndexPath?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
        self.getUserFavMovies()
    }
    
    func getAccountFavoriteMovies(accountID: Int){
        
        let sessionID = UserDefaults.standard.object(forKey: Keys.sessionID) as! String
        let URL = "\(Keys.BaseURL)/account/\(accountID)/favorite/movies?api_key=\(Keys.APIKey)&session_id=\(sessionID)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json            = JSON(value)
                let favoriteMovies   = json["results"]
                self.saveAccountFavoriteMovies(favoriteMovies: favoriteMovies)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func saveAccountFavoriteMovies(favoriteMovies: JSON){
        guard let jsonString = favoriteMovies.rawString() else { return }
        UserDefaults.standard.set(jsonString, forKey: Keys.favoriteMovies)
        getUserFavMovies()
    }
    
    func getUserFavMovies(){
        let jsonString = defaults.string(forKey: Keys.favoriteMovies) ?? ""
        guard let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false) else { return }
        try! self.favoriteMovies = JSON(data: jsonData).array ?? []
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetails"{
            let detaildMovieVC      = segue.destination as! MovieDetails
            detaildMovieVC.movie    = self.movieSelected!
            detaildMovieVC.movieID  = self.movieSelected!["id"].intValue
            detaildMovieVC.getCast()
            detaildMovieVC.getSimilarMovies()
        }
    }
}

extension FavoriteVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        movieSelected = favoriteMovies[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "showMovieDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellinFav") as! MovieCell

        let currentMovie = favoriteMovies[indexPath.row]
//        self.cellIndex = indexPath
        
        cell.nameLbl.text = currentMovie["title"].stringValue
        cell.overViewLbl.text = currentMovie["overview"].stringValue
        cell.setupLabelSizes()
        
        /// RATING
        let rating: Double = currentMovie["vote_average"].doubleValue
        cell.ratingLblColor(rating: rating)
        cell.ratingLbl.text = String(format:"%.1f", rating) //Taking only one decimal point for the rating
        
        
        /// IMAGE
        let poseterPath = currentMovie["poster_path"].stringValue
        let imageURL = (Keys.imageBaseURL + (poseterPath))
        cell.poster.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Placeholder 2-3"))
        
        cell.movieID = currentMovie["id"].intValue
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.didTapFavoriteButton(movieID: favoriteMovies[indexPath.row]["id"].intValue)
            self.favoriteMovies.remove(at: indexPath.row)
        }
    }
}

extension FavoriteVC : MovieCellDelegate{
    
    func didTapFavoriteButton(movieID: Int) {
       
        let accountID = defaults.integer(forKey: Keys.accountID)
        let APIKey = Keys.APIKey
        let sessionID = defaults.object(forKey: Keys.sessionID) as! String
        
        let URL = "\(Keys.BaseURL)/account/\(accountID)/favorite?api_key=\(APIKey)&session_id=\(sessionID)"
        
        let requestBody: Parameters = ["media_type" : "movie",
                                       "media_id" : movieID,
                                       "favorite" : false]
        
        Alamofire.request(URL, method: .post, parameters: requestBody ,encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                self.getAccountFavoriteMovies(accountID: self.defaults.integer(forKey: Keys.accountID))
                self.getUserFavMovies()
            case .failure(let error):
                print(error)
            }
        }
    }
}
