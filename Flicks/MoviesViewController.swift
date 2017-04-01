//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nana on 4/1/17.
//  Copyright © 2017 Nana. All rights reserved.
//

import UIKit

class MoviesViewController: UITableViewController {

    private var movies = [Movie]()

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Load movies
        movies = DataManager.shared.getMovies()
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

        return tableCell
    }
    
}

