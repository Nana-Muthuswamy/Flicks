//
//  Movie.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import Foundation

struct Movie {
    
    let title: String
    let overview: String
    let posterPath: String

    var posterImageURL: URL? {
        if self.posterPath.characters.count > 0, let finalURL = URL(string: originalPosterBaseUrl + self.posterPath) {
                return finalURL
        } else {
            return nil
        }
    }

    var posterThumbnailImageURL: URL? {
        if self.posterPath.characters.count > 0, let finalURL = URL(string: posterBaseUrl + self.posterPath) {
            return finalURL
        } else {
            return nil
        }
    }

    init(title: String?, overview: String?, posterPath: String?) {

        if let movieTitle = title {
            self.title = movieTitle
        } else {
            self.title = "Title not available"
        }

        if let movieOverview = overview {
            self.overview = movieOverview
        } else {
            self.overview = "Overview not available"
        }

        if let moviePosterPath = posterPath {
            self.posterPath = moviePosterPath
        } else {
            self.posterPath = ""
        }
    }

    init(dictionary: Dictionary<String, Any>) {

        self.init(title: dictionary["title"] as? String, overview: dictionary["overview"] as? String, posterPath: dictionary["poster_path"] as? String)
    }
}
