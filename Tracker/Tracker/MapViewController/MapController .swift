//
//  ViewController.swift
//  Tracker
//
//  Created by Nuri Chun on 9/15/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

// MARK: - MapController (MAIN)

class MapController : UIViewController, UISearchControllerDelegate {
    
    let locationManager = CLLocationManager()
    let annotationId = "MKAnnotation"
    let application = UIApplication.shared
    let mapResultsController = MapResultsController()
    let searchController = UISearchController(searchResultsController: nil)
    

    let navBarHeight: CGFloat = 200

    var mapView: MKMapView = {
        let mv = MKMapView()
        mv.mapType = .standard
        mv.isZoomEnabled = true
        return mv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let searchController = UISearchController(searchResultsController: mapResultsController)
        
        setupMapView()
        setupNavBar()
        setupLocationManager()
        setupAnnotationView()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapOnView() {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.text = ""
        searchController.searchBar.showsCancelButton = false
        navigationItem.titleView = nil
        
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No Access to desired location")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access Granted")
                locationManager.requestWhenInUseAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.startUpdatingLocation()
                locationManager.stopUpdatingLocation()
            }
        } else {
            print("Current Location Not Authorized, please change settings to activate current location.")
        }
    }
    
    private func setupAnnotationView() {
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationId)
        
        // 40.7128° N, 74.0060° W
        let newYorkLocation2D = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let newYorkCityAnnotation = CityAnnotation(coordinate: newYorkLocation2D, title: "New York City", subtitle: "Population of: 8.53 Million")
        mapView.addAnnotation(newYorkCityAnnotation)
        mapView.setRegion(newYorkCityAnnotation.region, animated: true)
    }
    
    private func setupMapView() {
        mapView.frame = view.frame
        view.addSubview(mapView)
    }
    
    private func setupNavBar() {
        title = "MapQuest"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(handleSearch)), animated: true)
    }
    
    @objc func handleSearch() {
        let viewWidth = view.frame.width
        let navBarHeight: CGFloat = 70
        guard let navBar = navigationController?.navigationBar else { return }
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Place..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navBar.frame = CGRect(x: 0, y: 0, width: viewWidth, height: navBarHeight)
        navigationItem.titleView = searchController.searchBar
    }
}

// MARK: - UISearchBarDelegate

extension MapController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.titleView = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text: \(searchBar.text ?? "" )")
        searchController.searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        application.beginIgnoringInteractionEvents()
        setupActivityIndicatorView(searchBar: searchBar)
        dismissSearchBar(searchBar: searchBar)
    }
    
    // Center the acitivity inidicator in the center frame
    // Before then..
    //
    
    private func setupActivityIndicatorView(searchBar: UISearchBar) {
        let activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorViewStyle)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .blue
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
        setupSearchRequest(searchBar: searchBar, activityIndicatorView: activityIndicatorView)
    }
    
    private func dismissSearchBar(searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    private func setupSearchRequest(searchBar: UISearchBar, activityIndicatorView: UIActivityIndicatorView) {
        
        // self.delegate?.searchResult()
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
    
        
        let localSearch = MKLocalSearch(request: searchRequest)
        
        localSearch.start { (response, err) in
            
            activityIndicatorView.stopAnimating()
            self.application.endIgnoringInteractionEvents()
            
            if let err = err { print("Unable to search: ", err) }
            
            if response != nil {
                
                guard let latitude = response?.boundingRegion.center.latitude else { return }
                guard let longitude = response?.boundingRegion.center.longitude else { return }
                
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
            
                let marker = MKPointAnnotation()
                marker.title = searchBar.text
                
                let center = CLLocationCoordinate2DMake(latitude, longitude)
                marker.coordinate = center
                self.mapView.addAnnotation(marker)
 
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                let region = MKCoordinateRegion(center: center, span: span)
                
                self.mapView.setRegion(region, animated: true)
                
            } else {
                print("Unable to retrieve the searched location")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate, MKMapViewDelegate

extension MapController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cityAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKMarkerAnnotationView {

            cityAnnotationView.animatesWhenAdded = true
            cityAnnotationView.titleVisibility = .adaptive
            cityAnnotationView.subtitleVisibility = .adaptive
            
            return cityAnnotationView
        }
        return nil
    }
}

































