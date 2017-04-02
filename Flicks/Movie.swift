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
    let releaseDate: String
    let voteAverage: Float

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

    var formattedReleaseDate: String {

        let paserDateFormatter = ISO8601DateFormatter.init()
        paserDateFormatter.formatOptions = [.withFullDate,.withDashSeparatorInDate]

        let dateToFormat = paserDateFormatter.date(from: releaseDate)

        let displayDateFormatter = DateFormatter()
        displayDateFormatter.locale = Locale.current
        displayDateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")

        let formattedDateStr = displayDateFormatter.string(from: dateToFormat ?? Date.init(timeIntervalSince1970: 118800))

        return formattedDateStr
    }

    var formattedRating: String {
        return "\(voteAverage) / 10"
    }

    init(title: String?, overview: String?, posterPath: String?, releaseDate: String?, voteAverage: Float?) {

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

        if let movieReleaseDate = releaseDate {
            self.releaseDate = movieReleaseDate
        } else {
            self.releaseDate = ""
        }

        if let movieVotingAverage = voteAverage {
            self.voteAverage = movieVotingAverage
        } else {
            self.voteAverage = 0
        }
    }

    init(dictionary: Dictionary<String, Any>) {

        self.init(title: dictionary["title"] as? String, overview: dictionary["overview"] as? String, posterPath: dictionary["poster_path"] as? String, releaseDate: dictionary["release_date"] as? String, voteAverage: dictionary["vote_average"] as? Float)
    }
}
