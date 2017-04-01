//
//  DataManager.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

class DataManager {

    // Singleton Object
    static let shared = DataManager()

    // Private vars
    private var fetchedMovies = [Movie]()

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
    func getMovies() -> [Movie] {

        fetchedMovies.append(Movie(title: nil, overview: nil, posterPath: nil))

        return fetchedMovies
    }

    // Gets more movies by fetching next page from remote TMDb API
    func getMoreMovies() -> [Movie] {

        return fetchedMovies
    }
}
