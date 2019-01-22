//
//  LoginVC.swift
//  Movie
//
//  Created by Yousef At-tamimi on 1/17/19.
//  Copyright © 2019 Yousef. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginVC: UIViewController{
    
    let defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNewToken()
    }
    
    /**
     Redirect the user to Safari to authorize the request token
     - Parameter N\A
    */
    func authorizeRequestToken(){
        
        let requestToken = self.defaults.object(forKey: Keys.requestToken) as! String
        if let url = URL(string: "https://www.themoviedb.org/authenticate/\(requestToken)") {
            UIApplication.shared.open(url, options: [:], completionHandler: complition)
        }
    }
    
    /**
     shows the user an alert
     -Parameter didOpenURL: if the URL is opened or not
     */
    
    func complition(didOpenURL: Bool) {
        let alert = UIAlertController(title: "", message: "Did you authorize the app?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: pressedYes))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: pressedNo))

        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Check if the request token is authorized by attempting to creat a session ID a
     -Parameter N\A
     */
    func pressedNo(action: UIAlertAction){

        requestSessionID()
        self.requestNewToken()
    }
    
    /**
     Check if the request token is authorized by attempting to creat a session ID a
     -Parameter N\A
     */
    func pressedYes(action: UIAlertAction){

        requestSessionID()
        self.requestNewToken()
    }
    
    /**
     requesting a session ID if the attempt is success then save session ID in user default
     -Parameter N\A
     */
    func requestSessionID(){
        
        let URL = "\(Keys.BaseURL)/authentication/session/new?api_key=\(Keys.APIKey)"
        let requestToken = self.defaults.object(forKey: Keys.requestToken) as! String
        let parameters: Parameters = ["request_token": requestToken] //This will be the body of the request
        
        Alamofire.request(URL, method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json        = JSON(value)
                let statusCode  = json["status_code"].intValue
                if statusCode == 17{
                    self.showDeniedAlert()
                }
                else{
                    let sessionID   = json["session_id"].stringValue
                    self.saveSessionID(sessionID: sessionID)
                    self.getAccountDetails()
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
     Shows an alert if the app is still unauthorize after redirecting the user
     -Parameter N\A
     */
    
    func showDeniedAlert(){
        let alert = UIAlertController(title: "Attention", message: "We are still unauthorized to access your favorite movie.\nAutherize the app if you wish to see and edit your favorite movie list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay, Thank You!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    /**
     requesting the account details and saving it into user default (persistant memory)
     -Parameter N\A
     */
    func getAccountDetails(){
        
        let sessionID = defaults.object(forKey: Keys.sessionID) as! String
        let URL = "\(Keys.BaseURL)/account?api_key=\(Keys.APIKey)&session_id=\(sessionID)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let json         = JSON(value)
                let accountID    = json["id"].intValue

                self.getAccountFavoriteMovies(accountID: accountID)
                self.saveAccountID(accountID: accountID)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
     get an account's favorite movies
     -Parameter accountID: the account Id
     */
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
    
    /**
     Saving an account's favorite movies in the user default (persistant memory)
     -Parameter favoriteMovies: a json of movies
     */
    func saveAccountFavoriteMovies(favoriteMovies: JSON){
        
        guard let jsonString = favoriteMovies.rawString() else { return }
        defaults.set(jsonString, forKey: Keys.favoriteMovies)
    }

    func saveAccountID(accountID: Int){
        
        defaults.set(accountID, forKey: Keys.accountID)
    }
    
    /**
     Requesting a token from the API
     -Parameter N\A
     */
    func requestNewToken(){
        
        let URL = "\(Keys.BaseURL)/authentication/token/new?api_key=\(Keys.APIKey)"
        Alamofire.request(URL, method: .get).responseJSON { response in
            
            switch response.result {
            case .success(let value):
   
                let json         = JSON(value)
                let requestToken = json["request_token"].stringValue
                self.saveRequestToken(requestToken: requestToken)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
     Saving the session ID in the user default (persistant memory)
     -Parameter sessionID: the session ID
     */
    func saveSessionID(sessionID: String){
        
        defaults.set(sessionID, forKey: Keys.sessionID)
        defaults.set(true, forKey: Keys.isLoggedin)
    }
    
    /**
     Requesting a session ID from the API
     -Parameter requestToken: the request tokens
     */
    func saveRequestToken(requestToken: String){
        
        defaults.set(requestToken, forKey: Keys.requestToken)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        authorizeRequestToken()
    }
    
    
}
