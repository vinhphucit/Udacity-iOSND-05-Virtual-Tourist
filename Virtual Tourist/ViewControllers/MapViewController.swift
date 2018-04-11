//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    @IBOutlet weak var viewTapPinToDelete: UIView!
    
    private var mapChangedFromUserInteraction = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    private func setupView(){
        mkMapView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        viewTapPinToDelete.isHidden = true
        let allPins = loadPins()
        if let allPins = allPins {
            showPinsOnMap(pins: allPins)
        }
        
        if let region = MapUserDefault.shared.getMapRegion() {
            mkMapView.setRegion(region, animated: true)
        }
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        viewTapPinToDelete.isHidden = !editing
        
    }
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        
        
        
        if sender.state == .began {
            let location = sender.location(in: mkMapView)
            let locCoord = mkMapView.convert(location, toCoordinateFrom: mkMapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = locCoord
            
            mkMapView.addAnnotation(pinAnnotation)
            
        
            pinAnnotation.coordinate = locCoord
        
            let pin: Pin = Pin(context: DataController.shared.viewContext)
            pin.latitude = String(pinAnnotation.coordinate.latitude)
            pin.longitude = String(pinAnnotation.coordinate.longitude)
            
            DataController.shared.saveContext()
            
        }
    }
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mkMapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    // MARK: - MKMapViewDelegate
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        mkMapView.deselectAnnotation(annotation, animated: true)
        
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon) {
            if isEditing {
                mkMapView.removeAnnotation(annotation)
                DataController.shared.viewContext.delete(pin)
                DataController.shared.saveContext()
                
            } else {
                performSegue(withIdentifier: "goToPhotoSegue", sender: pin)
            }
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            print("New Region \(mkMapView.region)")
            MapUserDefault.shared.saveRegion(mapRegion: mkMapView.region)
        }
    }
    
    private func showPinsOnMap(pins: [Pin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mkMapView.addAnnotation(annotation)
        }
        mkMapView.showAnnotations(mkMapView.annotations, animated: true)
    }
    
    private func loadPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = DataController.shared.fetchAllPins()
        } catch {
            print(error)
        }
        return pins
    }
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = DataController.shared.fetchPin(predicate)
        } catch {
            print(error)
        }
        return pin
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToPhotoSegue") {
            guard let pin = sender as? Pin else {
                return
            }
            let controller = segue.destination as! PhotoViewController
            controller.pin = pin
        }
        
    }
}
