# Movie


## Introduction
This is an assignment handed to me on the 15th January 2019 to evaluate my knowledge on using API calls, handling lists and different data-structures, my coding logic and solving problem. I was presented with a various options on how I would like to implement my solution for the problem, I selected the 'iOS' path using swift language.

### In This document I will explain:
* How to Install the app on your iDevice
* The content of the project and how I implement each one of them.
* The approach that I took on solving the problem and why
* Some key feature of the app 
* Area's the could have been improved with more time

 
## Requirements
* For installing:
    * iOS 11.1+
* For editing the code:
    * Xcode 10.1+
    * Swift 4.2+
    * MacOS system

## Installation
Go to the following repository: [Movie](https://github.com/iGoLDeNZz/Movie)
Then clone or download the project. If you chose to download the project extract the Zip file and open the Movie.xcworkspace file inside the Movie folder with xCode.


### You can build the application on your device by 
1.	Plugging in your device to your Mac
2.	Open `Movie.xcworkspace`
3.	Press on the project name then sign with you’re apple ID
4.	Run the App 

## Content
The project follows the Model View Controller (MVC) design for separating the code and for nicer and readable code.
The classes are separated as follows
### Models
   * `MovieCell`: A model used to populate the cells in table view in HomeVC and FavoriteVC
   
   * `CastCell`: A model used to populate the cells in a collection view for all the cast in a certain movie in MovieDetails 
   
   * `SimilarMovieCell`: A model used to populate the cells in a collection view for all the similar movies to a certain movie in MovieDetails 
   
### View

   * UILabel

      An extension of UILabel has one property that allow you to dynamically set the height of a label based on the amount of text it has

   * MotionViewEffect:

      An extension of `UIVeiwController` that implement a function that allows you to apply a motion effect when moving the phone around. *it was used in `MovieDetails` on the header poster*
### Controller
   * HomeVC
   
      Here is the landing page and where you can (search a movie, look at the most popular/top rated movies, and add movies to your favorite)

   * LoginVC

      Here is where the user will be directed to TMDb website, so they can login/register then Authorize the app to access their favorite movies list.

   * MovieDetails
   
      Here the user can see more details about a certain movie with the cast of the movie, similar movies, and you can also share the movie link to IMDb 
      
   * FavoriteVC
   
      Here the user can see and edit their own favorite movies  

## Approach 
The assessment document as well as the TMDb API documentation were user as a guide lines on implementing the solution. However, there was some points were left unexplained perhaps to leave room for creativity i.e. one of the stories that the document state's that *"As a user, I can see the latest movies."* and the API allows you to search movies on either one of these three options:

a.	`Most popular movies`

b.	`Top rated movies`

c.	`Latest movie`

Even-though the document stated *`latest movies`* on the requirement, it was not very stable from the API side, since it mostly returns one movie at a time. And that movie is so new that it has most of its data missing/null. Such as no detailed information about the movie, no description and cast team. So I decided to implement `a` and `b` only.



### Cocoapods
   pods are libraries in swift and I used some of them in this project. Such as
   
   * `Alamofire` Alamofire is an HTTP networking library written in Swift
       
   * `SwiftyJSON` SwiftyJSON makes it easy to deal with JSON data in Swift. Such as parsing the json
      
   * `SDWebImage`This library provides an asynchronous image downloader with cache support. This provides a place holder until the image downloads and caches the images for faster load time.
   
   
## Features

1.	**Implementing persistent data**

   I used "UserDefault" that is provided from the swift language to save certain data on phone memory to be accessible at all times. Such as:

   *	`isLoggedin` *Boolean*: Track user login status
    
   *	`SessionID` *String*: user sessionID 
    
   *	`favoriteMovieList` *JSON*: a dictionary with all favorite movies of the user
    
   *	`requestToken` *String*: latest request token

2.	**Validate user input**

     The app checks the user input in the search bar as another layer of security to not let a user inject some query in the search since it will be used to form the URL that will be sent to the API such as:

      i.	`'&' sign`: The app won't allow the user to put `&` as an input in the search bar as it will crash any app that user the same API without handling this problem
     
     ii.	`Spaces`: normally a white space will sometimes crash the apps or at best will be ignored and won't make it to the search query. But the app replaces each space with `%20` so the browser/server understands the query

3.	**Using extension**

     I used extension to prevent redundancy and reuse the code and in force generic functions arguments, so it can be used multiple times and by many controllers. Also using the same model of movie cell in both favoriteVC and homeVC
     
4.	**Supports Landscape**

     The constraints and auto layout are perfectly set to support portrait as well as landscape throughout the app
     
5.	**Micro features**

     i.	To enhance the UI/UX be letting it easy to identify high rating movies. The app colors the rating label based on how high the rating is going from red for low rating, yellow for medium, and green for high rating. 
     
     ii.	Implanting swipe to delete in favorite movies to allow for the native feel of the iOS as well as providing a button.

     iii.	Since The cannot predict how long the description of a movie is it has a built-in function that dynamically determine the right size of a label and set that label with the right height constraint.

## Arguments 
Some argue about the decisions about some data structures or such that I have taken in the app. One argument is:

   o	Using one data structure for both popular movies and top-rated movies. 

    The reason I took that approach is that with the help of `SDWebImage` cashing some of the images
    in both categories Even if the request took a bit more time the images will still be cashed and
    presented immediately. And the list must be refreshed each time the user tap on one of them since
    the list updates regularly by the API provider. 

## improvements
Areas that the app can be improved in if there was more time to be spent on developing the app.

   o	Using `DispatchQueue` for managing all the asynchronous thread to fetch the data then load the UI

   o	Disabling the buttons in `HomeVC` for the movie that has been added to favorite using closures and delegates 

   o	Making the user able to see the details of the similar movies making it invoke a segue to its own view 
