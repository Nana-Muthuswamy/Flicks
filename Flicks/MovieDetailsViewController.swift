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
        if let lowResolutionImageURL = movie.posterThumbnailImageURL, let highResolutionImageURL = movie.posterImageURL {

            let lowResolutionRequest = URLRequest(url: lowResolutionImageURL)
            let highResolutionRequest = URLRequest(url: highResolutionImageURL)

            // Closure to fetch high resolution image whenever deemed appropriate
            let setHighResolutionImage = {[weak weakSelf = self] in

                weakSelf?.poster.setImageWith(highResolutionRequest, placeholderImage: nil, success: {(request, response, image) in

                    // Response will not be nil if image is downloaded from network (as per AFNetworking docs), provide fade in animation
                    if response != nil {
                        weakSelf?.poster.alpha = 0.65
                        weakSelf?.poster.image = image

                        UIView.animate(withDuration: 0.5, animations: {
                            weakSelf?.poster.alpha = 1.0
                        })

                    } else { // If its retrieved from cache, just load it
                        weakSelf?.poster.alpha = 1.0
                        weakSelf?.poster.image = image
                    }

                    }, failure: {(request, response, error) in
                        // On failure to load large image from network or cache, let current image (thumbnail or low resolution image) continue to display
                        weakSelf?.poster.alpha = 1.0
                })
            }

            // Fetch low resolution image first. Since MovieDetailsViewController is loaded 
            // only from MoviesViewController, almost everytime low res image is fetched from cache
            poster.setImageWith(lowResolutionRequest, placeholderImage: nil, success: {[weak weakSelf = self] (request, response, image) in

                // Response will not be nil if image is downloaded from network (as per AFNetworking docs), provide fade in animation
                if response != nil {
                    weakSelf?.poster.alpha = 0.0
                    weakSelf?.poster.image = image

                    UIView.animate(withDuration: 0.5, animations: { 
                        weakSelf?.poster.alpha = 0.65
                    })

                } else { // If its retrieved from cache, just load it
                    weakSelf?.poster.alpha = 0.65
                    weakSelf?.poster.image = image
                }

                // Try for high resolution image
                DispatchQueue.main.async {
                    setHighResolutionImage()
                }

            }, failure: {[weak weakSelf = self] (request, response, error) in
                // On failure to load image from network or cache, just load the default thumbnail
                weakSelf?.poster.alpha = 0.65
                weakSelf?.poster.image = UIImage(named: "MovieThumbnail")

                // Try for high resolution image
                DispatchQueue.main.async {
                    setHighResolutionImage()
                }
            })
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
