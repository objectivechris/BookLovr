//
//  MapViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/11/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentPlacemark: CLPlacemark?
    
    var book: BookMO!
    
    @IBAction func getDirections(_ sender: UIButton) {
        guard let currentPlacemark = currentPlacemark else { return }
        
        let directionRequest = MKDirectionsRequest()
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (routeResponse, routeError) in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    let alertController = UIAlertController(title: "Uh Oh!", message: "\(routeError.localizedDescription)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            let route = routeResponse.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = book.location
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsScale = true
        
        // Do any additional setup after loading the view.
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(book.location!) { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                self.currentPlacemark = placemark
                
                let annotation = MKPointAnnotation()
                annotation.title = self.book.name
                annotation.subtitle = "Author: " + self.book.author!
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
        
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
        leftIconView.image = UIImage(data: book.image! as Data)
        leftIconView.contentMode = .scaleAspectFill
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 30.0/255.0, green: 187.0/255.0, blue: 186.0/255.0, alpha: 1.0)
        renderer.lineWidth = 3.0
        
        return renderer
    }
}
