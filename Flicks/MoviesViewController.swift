//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var movies = [Movie]()

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup and add UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData(sender:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        // Load Movies list
        loadData(sender: self)
    }

    // MARK: Data Load

    func loadData(sender: AnyObject) {

        // Display progress indicator HUD if the load is not triggered by pull to refresh action
        if (sender as? UIRefreshControl) == nil {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        DataManager.shared.fetchNowPlayingMovies {[weak weakSelf = self] (result) in

            if let refreshControl = sender as? UIRefreshControl {
                // If data was loaded by pull to refresh action, mark end refreshing
                refreshControl.endRefreshing()
            } else {
                // In other cases hide the progress indicator HUD
                MBProgressHUD.hide(for: self.view, animated: true)
            }

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

