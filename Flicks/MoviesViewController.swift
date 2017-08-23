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

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!

    fileprivate var searchController: UISearchController!

    fileprivate var movies = [Movie]() {
        didSet {
            filteredMovies = movies
        }
    }

    fileprivate var filteredMovies = [Movie]() {
        didSet {
            DispatchQueue.main.async {[weak weakSelf = self] in
                weakSelf?.tableView.reloadData()
            }
        }
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UISearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true

        // Setup Searchbar
        searchController.searchBar.placeholder = "Filter Movies"
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        // Setup Presentation Context
        self.definesPresentationContext = true

        // Setup and add UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData(sender:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        // Load Movies list
        loadData(sender: self)
    }

    // MARK: Data Load

    func loadData(sender: AnyObject) {

        // Hide the network error view, if required
        errorView.isHidden = true

        // Inactivate SearchController, if required
        self.searchController.isActive = false

        // Display progress indicator HUD if the load is not triggered by pull to refresh action
        if (sender as? UIRefreshControl) == nil {
            let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
            hudView.label.text = "Loading Movies..."
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

            case .failure(let error):

                switch error {

                case .other(_):
                    print("Failure Reason: \(error.localizedDescription)")
                    weakSelf?.errorView.isHidden = false

                default:
                    print("Failure Reason: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "MovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!

            destination.movie = filteredMovies[indexPath.row]
        }
    }
}

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tableCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell

        let movie = filteredMovies[indexPath.row]

        tableCell.title.text = movie.title
        tableCell.overview.text = movie.overview

        if let imageURL = movie.posterThumbnailImageURL {

            let request = URLRequest(url: imageURL)

            tableCell.poster.setImageWith(request, placeholderImage: nil, success: {(request, response, image) in

                // Response will not be nil if image is downloaded from network (as per AFNetworking docs), provide fade in animation
                if response != nil {
                    tableCell.poster.alpha = 0.0
                    tableCell.poster.image = image

                    UIView.animate(withDuration: 0.5, animations: {
                        tableCell.poster.alpha = 1.0
                    })

                } else { // If its retrieved from cache, just load it
                    tableCell.poster.image = image
                }

            }, failure: { (request, response, error) in
                // On failure to load image from network or cache, just load the default thumbnail
                tableCell.poster.image = UIImage(named: "MovieThumbnail")
            })
        }

        return tableCell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // De-select the tapped movie row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MoviesViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        if let searchText = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), searchText.characters.count > 0 {
            filteredMovies = movies.filter({ (element) in
                return element.title.lowercased().contains(searchText)
            })
        } else {
            filteredMovies = movies
        }
    }
}

