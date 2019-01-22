//
//  MovieDetailsViewController.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/17/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage


class MovieDetails: UIViewController {

    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var posterimage: UIImageView!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var budgetLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var castCollection: UICollectionView!
    @IBOutlet weak var similarMovieCollection: UICollectionView!
    
    var movie: JSON?
    var movieID: Int?
    var cast: [JSON] = []
    var similarMovies: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//         Do any additional setup after loading the view.
        getMovieDetails()
    }

    func getMovieDetails(){
        
        let URL = "\(Keys.BaseURL)/movie/\(movieID!)?api_key=\(Keys.APIKey)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.movie = JSON(value)
                self.loadUI()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func loadUI(){
        
        setupLabels()
        setupRating()
        setupImages()
    }
 
//    genres
//
//
//
//    vote_count
    
    func getCast(){

        let URL = "\(Keys.BaseURL)/movie/\(movieID!)/credits?api_key=\(Keys.APIKey)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json         = JSON(value)
                self.cast = json["cast"].array ?? []
                self.castCollection.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getSimilarMovies(){
        
        let URL = "\(Keys.BaseURL)/movie/\(movieID!)/similar?api_key=\(Keys.APIKey)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json         = JSON(value)
                self.similarMovies = json["results"].array ?? []
                self.similarMovieCollection.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupLabels(){
        
        movieTitleLbl.text = movie?["title"].stringValue ?? "Movie Title"
        let movietitleHeight = movieTitleLbl.optimalHeight
        movieTitleLbl.frame = CGRect(x: movieTitleLbl.frame.origin.x, y: movieTitleLbl.frame.origin.y, width: movieTitleLbl.frame.width, height: movietitleHeight)
        
        overviewLbl.text = movie?["overview"].stringValue ?? "This is an overview of the movie"
        let overviewHeight = overviewLbl.optimalHeight
        overviewLbl.frame = CGRect(x: overviewLbl.frame.origin.x, y: overviewLbl.frame.origin.y, width: overviewLbl.frame.width, height: overviewHeight)
        
        releaseDateLbl.text = movie?["release_date"].stringValue ?? "1996-9-9"
        durationLbl.text = "\(movie?["runtime"].stringValue ?? "120 Minutes") Minutes"
        budgetLbl.text = "\(movie?["budget"].stringValue ?? "1,000,000,000.00")$"
        genreLbl.text = getGenres()
        
        
    }
    
    func getGenres() -> String{
        
        var text: String = ""
        let genres: [JSON] = self.movie?["genres"].array ?? []
        
        for genre in genres{
            print("\n\n\(genre["name"])")
            text += "\(genre["name"]) - "
        }
        
        if text.count > 1 {
            text.removeLast(2)
        }
        
        return text
    }
    
    func setupRating(){
        
        let rating: Double = movie?["vote_average"].doubleValue ?? 0.0
        ratingLbl.text = String(format:"%.1f", rating) //Taking only one decimal point for the rating
        ratingLblColor(rating: rating)
    }
    
    func setupImages(){
        
        let poseterPath = self.movie?["poster_path"].stringValue ?? ""
        let backdropPath = self.movie?["backdrop_path"].stringValue ?? ""

        let posterImageURL = (Keys.imageBaseURL + poseterPath)
        let backdropImageURL = (Keys.imageBaseURL + backdropPath)
        
        backdrop.sd_setImage(with: URL(string: backdropImageURL), placeholderImage: UIImage(named: "Placeholder 3-2"))
        posterimage.sd_setImage(with: URL(string: posterImageURL), placeholderImage: UIImage(named: "Placeholder 2-3"))
        applyViewMotionEffect(toView: backdrop, magnitudeX: 0, magnitudeY: 50)
        
    }
    
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
            ratingLbl.textColor = UIColor.red
            break
        }
        
    }
    
    @IBAction func imdbButtonPressed(_ sender: Any) {

        if let link = URL(string: "https://www.imdb.com/title/\(self.movie!["imdb_id"])/") {
            let objectsToShare = ["Checkout this movie in IMDb",link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}

extension MovieDetails: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if UIDevice.current.orientation.isLandscape {
            if scrollView.contentOffset.x != 0 {
                scrollView.contentOffset.x = 0
            }
        }
    }
}

extension MovieDetails: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.castCollection{
            return cast.count
        }
        else{
            return similarMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == castCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastCell

            let currentCast = cast[indexPath.row]
            cell.castNameLbl.text   = currentCast["name"].stringValue
            cell.castRoleLbl.text   = "As \(currentCast["character"].stringValue)"

            let poseterPath         = currentCast["profile_path"].stringValue
            let imageURL            = (Keys.imageBaseURL + poseterPath)
            cell.castImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Placeholder 2-3"))

            return cell
        }
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarMovieCell", for: indexPath) as! SimilarMovieCell
            
            let currentMovie    = similarMovies[indexPath.row]

            cell.nameLbl.text   = currentMovie["title"].stringValue
            
            let posterPath      = currentMovie["poster_path"].stringValue
            let imageURL        = (Keys.imageBaseURL + posterPath)
            cell.movieImg.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Placeholder 2-3"))
            
            return cell
        }
    }
    
    

}
