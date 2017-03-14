//
//  BookDetailViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/9/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import MapKit

class BookDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var book: BookMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = false
        
        title = "Details"
        bookImageView.image = UIImage(data: book.image! as Data)
        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 240.0/250.0, green: 240.0/250.0, blue: 240.0/250.0, alpha: 0.8)
        tableView.separatorColor = UIColor(red: 240.0/250.0, green: 240.0/250.0, blue: 240.0/250.0, alpha: 0.8)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(book.location!) { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        
    }

    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        if let rating = segue.identifier {
            book.haveRead = true
            
            switch rating {
            case "great": book.rating = "Absolutely loved it! Must read."
            case "good": book.rating = "It was pretty good."
            case "dislike": book.rating = "I didn't like it."
            default: break
            }
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
        
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookDetailTableViewCell
        cell.backgroundColor = UIColor.clear
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = book.name
        case 1:
            cell.fieldLabel.text = "Author"
            cell.valueLabel.text = book.author
        case 2:
            cell.fieldLabel.text = "Genre"
            cell.valueLabel.text = book.genre
        case 3:
            cell.fieldLabel.text = "Discovered"
            cell.valueLabel.text = book.location
        case 4:
            cell.fieldLabel.text = "Have read"
            cell.valueLabel.text = (book.haveRead) ? "Yes, I've read this book. \(book.rating ?? "")" : "No"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReview" {
            let reviewController = segue.destination as! ReviewViewController
            reviewController.book = book
        } else if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.book = book
        }
    }
}
