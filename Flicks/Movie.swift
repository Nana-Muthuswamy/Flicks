//
//  Movie.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

struct Movie {
    
    let title: String
    let overview: String
    let posterPath: String

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
}
