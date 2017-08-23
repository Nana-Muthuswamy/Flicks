//
//  DataManager.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

// Generic enum that holds the result of any (preferrably, data related) operations
enum Result<Value> {
    // Success case holds a generic type value associated
    case success(Value)
    // Failure case holds DataError associated
    case failure(DataError)

    /* Convenient computed properties for quick checks and extraction of result content */

    // For checking whether the result is success
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }

    // For checking whether the result is failure
    var isFailure: Bool {
        switch self {
        case .success(_):
            return false
        case .failure(_):
            return true
        }
    }

    // For extracting the value associated with the result
    var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }

    // For extracting the error associated with the result
    var error: DataError? {
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }


}

// Enum to hold possible error variants while dealing with data
enum DataError: Error {
    // This case highlights incompatible or unexpected data than from the desired version
    case invalidData
    // This case highlights absence of data when its desired to be present
    case dataNotAvailable
    // This is the default case that can represent any error with some reasonable explanation, if any
    case other(String?)

    // Convenience computed property to express the error reason for all possible scenarios
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Unexpected or incompatible data."
        case .dataNotAvailable:
            return "Data not available."
        case .other(let reason):
            return reason ?? "Unknown error."
        }
    }
}

class DataManager {

    // Singleton Object
    static let shared = DataManager()

    // Private vars
    private var fetchedMovies = [Movie]()
    private var pageToFetch = 1 // Initial load is always page=1

    // Public vars
    var movies: [Movie] {
        get {
            return fetchedMovies
        }
    }

    // MARK: Singleton
    private init() {

    }

    // MARK: Data Mart APIs

    // Loads movies either from local storage. If not present, then from remote TMDb API
    func fetchNowPlayingMovies(completion: @escaping (Result<[Movie]>) -> Void) {

        let fullServicePath = "\(ServicePathNowPlayingMovies)?api_key=\(TMDbAPIKey)&language=en-US&page=\(pageToFetch)&region=US"

        let request = URLRequest(url: URL(string:fullServicePath)!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: {[weak weakSelf = self] (data, response, error) in

                if error != nil {

                    let errorDesc = error?.localizedDescription ?? "Network Error"
                    completion(Result.failure(DataError.other(errorDesc)))

                } else if let data = data, let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String,Any> {

                    print("responseDictionary: \(responseDictionary)")
                    
                    let httpResponse = response as! HTTPURLResponse

                    if httpResponse.statusCode == 200 {

                        if let movieList = responseDictionary["results"] as? [Dictionary<String, Any>] {

                            weakSelf?.fetchedMovies.removeAll()

                            for movieDict in movieList {
                                weakSelf?.fetchedMovies.append(Movie(dictionary: movieDict))
                            }
                        }

                        if let movies = weakSelf?.fetchedMovies {
                            completion(Result.success(movies))
                        } else {
                            completion(Result.failure(DataError.dataNotAvailable))
                        }

                    } else if httpResponse.statusCode == 401 {

                        if let validationErrorMsg = responseDictionary["status_message"] as? String {

                            completion(Result.failure(DataError.other(validationErrorMsg)))
                        }

                    } else {

                        let errorDesc = error?.localizedDescription ?? "Network Error"
                        completion(Result.failure(DataError.other(errorDesc)))
                    }

                } else {

                    completion(Result.failure(DataError.invalidData))
                }

            })

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (_) in
            task.resume()
        }
    }

    // Gets more movies by fetching next page from remote TMDb API
    func fetchMoreRunningMovies() -> [Movie] {

        return fetchedMovies
    }
}
