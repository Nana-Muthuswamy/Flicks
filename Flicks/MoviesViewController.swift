//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UITableViewController {

    private var movies = [Movie]()

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Load movies
        DataManager.shared.fetchNowPlayingMovies {[weak weakSelf = self] (result) in

            switch result {

            case .success(let fetchedMovieList):
                weakSelf?.movies = fetchedMovieList
                weakSelf?.tableView.reloadData()

            case .failure(let error):

                switch error {
                case .networkFailure(let reason):
                    print("Network Failure: \(reason)")
                case .validationFailure(let reason):
                    print("Validation Failure: \(reason)")
                case .dataPaserFailure:
                    print("Unable to parse the TMDb API response")
                }
            }
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tableCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell

        let movie = movies[indexPath.row]

        tableCell.title.text = movie.title
        tableCell.overview.text = movie.overview

        if let imageURL = movie.posterImageURL {
            tableCell.poster.setImageWith(imageURL)
        }

        return tableCell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // De-select the tapped movie row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "MovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!

            destination.movie = movies[indexPath.row]
        }
    }
}

