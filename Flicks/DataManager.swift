//
//  DataManager.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

enum DataFetchResult {
    case success([Movie])
    case failure(DataFetchError)
}

enum DataFetchError: Error {
    case networkFailure(String)
    case validationFailure(String)
    case dataPaserFailure
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
    func fetchNowPlayingMovies(completion: @escaping (DataFetchResult) -> Void) {

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
                    completion(DataFetchResult.failure(DataFetchError.networkFailure(errorDesc)))

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

                        completion(DataFetchResult.success((weakSelf?.fetchedMovies ?? [Movie]())))

                    } else if httpResponse.statusCode == 401 {

                        if let validationErrorMsg = responseDictionary["status_message"] as? String {

                            completion(DataFetchResult.failure(DataFetchError.validationFailure(validationErrorMsg)))
                        }

                    } else {

                        let errorDesc = error?.localizedDescription ?? "Network Error"
                        completion(DataFetchResult.failure(DataFetchError.networkFailure(errorDesc)))
                    }

                } else {

                    completion(DataFetchResult.failure(DataFetchError.dataPaserFailure))
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
