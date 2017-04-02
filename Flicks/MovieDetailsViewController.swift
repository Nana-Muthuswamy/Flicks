//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailsView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch and Set the background Poster Image
        if let imageURL = movie.posterImageURL {
            poster.setImageWith(imageURL)
        }

        // Set movie details
        titleLabel.text = movie.title
        releaseDateLabel.text = movie.formattedReleaseDate
        ratingLabel.text = movie.formattedRating
        overviewLabel.text = movie.overview

        // Resize the overview label as per its contents
        overviewLabel.sizeToFit()

        // Set scroll view's content size
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailsView.frame.origin.y + detailsView.frame.size.height)
    }

}
