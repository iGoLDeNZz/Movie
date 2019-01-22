//
//  ViewController.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/16/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import SwiftyJSON
import SDWebImage

/// Make them global to be accessed from anywhere in the app since they will be frequently used
/// This struct was made for readability, and to avoid any typo mistakes when using these data
struct Keys {
    static let requestToken    = "requestToken"
    static let sessionID       = "sessionID"
    static let isLoggedin      = "isLoggedin"
    static let imageBaseURL    = "https://image.tmdb.org/t/p/w500"
    static let APIKey          = "ac1920cedb6cbd8fb351e014d037fd3c"
    static let BaseURL         = "https://api.themoviedb.org/3"
    static let accountID       = "accountID"
    static let favoriteMovies  = "favoriteMovies"
    static let favoriteSegue   = "favoriteSegue"
    
    struct SortBy {
        static let popular     = "/movie/popular"
        static let topRated    = "/movie/top_rated"
        static let latest      = "/movie/latest"}
    
    struct status {
        static let login       = "Login"
        static let logout      = "Logout"}
}

class HomeVC: UIViewController {
   
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isLoggedin: Bool = false
    let defaults = UserDefaults.standard
    
    var movies: [JSON] = [] // An array of dictionaries of all the movies that will be loaded to the tableview
    var movieSelected: JSON? // The movie that has been selected to view its details

    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingUpUI()
        getMovies(sortMoviesBy: searchBar!.selectedScopeButtonIndex)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        isLoggedin(loginStatus: defaults.bool(forKey: Keys.isLoggedin))
    }
    
    /**
     request from the API a JSON array of movies based on the argument that's provided at call-time
     - Parameter sortMoviesBy: "Required" Determines the type of movies sorting.
     - Parameter pageToLoad: "Optional" Determine the what page of movies to load.
     - Parameter searchQuery: "Optional" The query on which the search will be applied.
     */

    func getMovies(sortMoviesBy:Int, pageToLoad: Int? = 1, searchQuery: String? = ""){
        
        // Forming the URL based on the argumants of the function
        let URL: String = formURL(sortMoviesBy: sortMoviesBy, pageToLoad: pageToLoad!, searchQuery: searchQuery!)
       
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json              = JSON(value)
                let CurrentParsedjson = JSON(json)["results"].array

                if(pageToLoad == 1){
                    self.movies = CurrentParsedjson!}
                else{
                    for movie in CurrentParsedjson!{
                        self.movies.append(movie)}}
                
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
     forms a URL to an API service, while validating user input taking into an account spaces in the searchQuery
     and transform it into '%20' so the server/browser would identify spaces.
     
     - Parameter sortMoviesBy: "Required" Determines the type of movies sorting.
     - Parameter pageToLoad: "Required" Determine the what page of movies to load.
     - Parameter searchQuery: "Required" The query on which the search will be applied.
     */
    
    func formURL(sortMoviesBy:Int, pageToLoad: Int, searchQuery: String) -> String{
        
        var sortBy: String?
        switch sortMoviesBy {
        case 0:
            sortBy = Keys.SortBy.popular
            
        case 1:
            sortBy = Keys.SortBy.topRated
            
        default:
            break
        }
        
        // Deciding what type of API service will be used based on the search bar text
        if (searchQuery.isEmpty) {

            return"\(Keys.BaseURL)\(sortBy!)?api_key=\(Keys.APIKey)&page=\(pageToLoad)"
        } else{
            let newSearchQuery = searchQuery.replacingOccurrences(of: " ", with: "%20")
            return "\(Keys.BaseURL)/search/movie?api_key=\(Keys.APIKey)&query=\(newSearchQuery)&page=\(pageToLoad)"
        }
        
    }
    
    /**
     Configures the User interface
     - Parameter N/A
     */
    
    func settingUpUI(){
        
        self.isLoggedin = defaults.bool(forKey: Keys.isLoggedin)
        isLoggedin(loginStatus: self.isLoggedin)
        tableView.delegate = self
        searchBar.backgroundImage = UIImage()
        
        //remove empty cells that are padding the table to the bottom
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    /**
     changes the favorite button functionality based on login status, change the image of login/logout button accorrding to login status
     - Parameter loginStatus: (Required) The login status of the user
     */
    func isLoggedin(loginStatus: Bool){

        if loginStatus{
            loginButton.title = Keys.status.logout
            checkSessionIDValidaty()
        }
        else{
            loginButton.title = Keys.status.login
        }
    }
    
    /**
     Whenever the view is loaded this method will be called to chech if the sessionId is still valid if so nothing happend otherwise it will logout the user
     - Parameter N\A
     */
    func checkSessionIDValidaty(){
        
        let sessionID = defaults.object(forKey: Keys.sessionID) as! String
        let URL = "\(Keys.BaseURL)/account?api_key=\(Keys.APIKey)&session_id=\(sessionID)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success:
                break
            case .failure(let error):
                self.defaults.set(false, forKey: Keys.isLoggedin)
                print(error)
            }
        }
    }
    
    /**
     Retrieves a movie details for a certain movie
     - Parameter movieID: (Required) The Movie ID
     */
    func getMovieDetails(movieID: Int){
        
        let URL = "\(Keys.BaseURL)/movie/\(movieID)?api_key=\(Keys.APIKey)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                self.movieSelected = JSON(value)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    /**
     Called whenever the user presses Login\Logout button
     - Parameter Any: (Required) a sender which is UIButton
     */
    @IBAction func logButtonPressed(_ sender: Any) {
        
        if defaults.bool(forKey: Keys.isLoggedin) {
            showLogoutAlert()
        }
        else{
            performSegue(withIdentifier: Keys.status.login, sender: sender)
        }
    }
    
    /**
     Called whenever the user presses Favorite button
     - Parameter Any: (Required) a sender which is UIButton
     */
    @IBAction func favListBtnTapped(_ sender: Any) {
        
        if defaults.bool(forKey: Keys.isLoggedin){
            performSegue(withIdentifier: Keys.favoriteSegue, sender: sender)
        }
        else{
            showLoginAlert()
        }
    }
 
    /**
     A function that gets called whenever a new view will be shown
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetails"{
            let detaildMovieVC = segue.destination as! MovieDetails
            detaildMovieVC.movie    = movieSelected!
            detaildMovieVC.movieID  = movieSelected!["id"].intValue
            detaildMovieVC.getCast()
            detaildMovieVC.getSimilarMovies()
        }
        else if segue.identifier == Keys.status.login && loginButton.title == Keys.status.login {
        }
    }
    
    /**
     Retrieves an account's favorite movies list
     - Parameter accountID: (Required) The account ID
     */
    func getAccountFavoriteMovies(accountID: Int){
        
        let sessionID = UserDefaults.standard.object(forKey: Keys.sessionID) as! String
        let URL = "\(Keys.BaseURL)/account/\(accountID)/favorite/movies?api_key=\(Keys.APIKey)&session_id=\(sessionID)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json           = JSON(value)
                let favoriteMovies = json["results"]
                self.saveAccountFavoriteMovies(favoriteMovies: favoriteMovies)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
     Saves the list of favorite movies for the account in the user defaults
     - Parameter favoriteMovies: (Required) A json of the movies to be saves
     */
    func saveAccountFavoriteMovies(favoriteMovies: JSON){
        guard let jsonString = favoriteMovies.rawString() else { return }
        UserDefaults.standard.set(jsonString, forKey: Keys.favoriteMovies)
    }
    
    /**
     Shows an alert for the user before logging out
     - Parameter N\A
     */
    func showLogoutAlert(){
        
        let alert = UIAlertController(title: "Logout", message: "Are You sure You want to logout", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: pressedYes))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     logsout the user
     - Parameter N\A
     */
    func pressedYes(action: UIAlertAction){
        
        defaults.set(false, forKey: Keys.isLoggedin)
        isLoggedin(loginStatus: defaults.bool(forKey: Keys.isLoggedin))
    }
    
    /**
     Shows an alert for the user if they try to either add a movie to the favorite or see thier favorite while not loggedin
     - Parameter N\A
     */
    func showLoginAlert(){
        let alert = UIAlertController(title: "Login required", message: "You need to login to access your favorite movies", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: pressedLogin))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
    Switches to loginVC
     - Parameter N\A
     */
    func pressedLogin(action: UIAlertAction){
        
        performSegue(withIdentifier: Keys.status.login, sender: nil)
    }
    
    /**
     Sets up the URL and seperate the functionality for a cleaner, more readable code
     - Parameter N\A
     */
    func setupURL() ->String {
        
        let accountID = defaults.integer(forKey: Keys.accountID)
        let APIKey = Keys.APIKey
        let sessionID = defaults.object(forKey: Keys.sessionID) as! String
        
        return "\(Keys.BaseURL)/account/\(accountID)/favorite?api_key=\(APIKey)&session_id=\(sessionID)"
    }
}


/**
 An extntion holding all the "SearchBarDelegate" functions and anything that is related to the searchbar
 */
extension HomeVC:UISearchBarDelegate {
    
    /**
     gets called whenever there is a change in the searchbar text, and it calls the function 'getMovies' providing a searchQuery
     */
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        getMovies(sortMoviesBy: searchBar.selectedScopeButtonIndex, pageToLoad: 1, searchQuery: searchBar.text)
    }
    
    /**
     Validate user input and do not accept '&' sign since it might crashes the app
     - Parameter N\A
     */
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "&" {
            return false
        }
        else{
            return true
        }
    }
    
    /**
     gets called whenever the searchscope changes and call the function 'getMovies' providing the appropriate scope
     */
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
       
        searchBar.endEditing(true)
        searchBar.text = ""
        getMovies(sortMoviesBy: selectedScope, pageToLoad: 1)
    }
    
    /**
     This will dismiss the keyboard once the user clicked search button
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
}


/**
 An extntion holding all the "TableViewDelegate" functions and anything that is related to the TableView
 */
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    /**
     Handles when a cell/movie is clicked and prepare for a segue to the 'MovieDetails' View
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        movieSelected = movies[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "showMovieDetails", sender: nil)
    }
    
    
    /**
     This will dismiss the keyboard once the user started scrolling
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    /**
     Number of rows in the table since we only have one section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    /**
     Loads the cell with the proper data that was retrieved from the APi
     -SDWebImage: module was used here to download the images asynchronously so the main thread will never be blocked
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MovieCell
        
        let currentMovie = movies[indexPath.row]
        
        cell.nameLbl.text = currentMovie["title"].stringValue
        cell.overViewLbl.text = currentMovie["overview"].stringValue
        cell.setupLabelSizes()
        
        /// RATING
        let rating: Double = currentMovie["vote_average"].doubleValue
        cell.ratingLblColor(rating: rating)
        cell.ratingLbl.text = String(format:"%.1f", rating) //Taking only one decimal point for the rating


        /// IMAGE
        let poseterPath = currentMovie["poster_path"].stringValue
        let imageURL = (Keys.imageBaseURL + poseterPath)
        cell.poster.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Placeholder 2-3"))
        
        // FAVORITE
        cell.movieID = currentMovie["id"].intValue
        cell.delegate = self
        
        return cell
    }
    
    /**
     Check every cell if it is the last cell or not to request another page of movies.
     -Each page is 20 movie long
     */
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if movies.count >= 20 {
            
            let lastItem = movies.count - 1
            if indexPath.row == lastItem{

                //This calculates what pages to load, and since each page contains 20 movies the formula will look like this
                let pageToLoad : Int = ((movies.count) / 20) + 1
                if (searchBar.text?.isEmpty)!{
                  
                    getMovies(sortMoviesBy: searchBar.selectedScopeButtonIndex, pageToLoad: pageToLoad)
                }
                else{
                   
                    getMovies(sortMoviesBy: searchBar.selectedScopeButtonIndex, searchQuery: searchBar.text!)
                }
            }
        }
    }
}

extension HomeVC: MovieCellDelegate{
    
    /**
     adds a certain movie into the account's favorite list
     - Parameter movieID: The Movie ID which will be added
     
     - Pre-condition: Loggedin
     */
    func didTapFavoriteButton(movieID: Int) {
        if self.defaults.bool(forKey: Keys.isLoggedin){

            let URL = self.setupURL()
            let requestBody: Parameters = ["media_type" : "movie",
                                           "media_id" : movieID,
                                           "favorite" : true]
        
            Alamofire.request(URL, method: .post, parameters: requestBody ,encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result {
                case .success:
                    self.getAccountFavoriteMovies(accountID: self.defaults.integer(forKey: Keys.accountID))
                    
                    break
                case .failure(let error):
                    print(error)
                }
            }
        }
        else{
            showLoginAlert()
        }
    }
}
