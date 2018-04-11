//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Phuc Tran on 4/10/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class PhotoViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    var pin: Pin?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        setupFetchedResultController()
        setupMap()
        setupPinAndPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    @IBAction func onClickNewCollectionButton(_ sender: Any) {
        // delete all photos
        for photos in fetchedResultsController.fetchedObjects! {
            DataController.shared.viewContext.delete(photos)
        }
        DataController.shared.saveContext()
        fetchPhotosFromAPI(pin!)
    }
    
    private func setupPinAndPhoto() {
        if let pin = pin , let photos = pin.photos, photos.count == 0 {
            // pin selected has no photos
            fetchPhotosFromAPI(pin)
        }
    }
    
    private func setupMap(){
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        if let pin = pin {
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locCoord
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            mapView.setCenter(locCoord, animated: true)
        }
        
        
    }
    
    private func fetchPhotosFromAPI(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        
        
        NetworkClient.shared.doSearchPhotos(latitude: lat, longitude: lon, completion: { (data, error) in
            
            if error != nil {
              
                
            }else {
        
              
                if let data = data {
                    self.totalPages = data.photos.pages
                    let totalPhotos = data.photos.photo.count
                    
                    self.storePhotos(data.photos.photo, forPin: pin)
                   
                
                }
            }
            
        })
        
        
    }
    
    private func storePhotos(_ photos: [PhotoParser], forPin: Pin) {
        for photo in photos {
            performUIUpdatesOnMain {
                if let url = photo.url {
                    let pho:Photo = Photo(context: DataController.shared.viewContext)
                    
                    pho.title = photo.title
                    pho.imageUrl = photo.url
                    pho.pin = forPin
                    
                    DataController.shared.saveContext()
                    
                }
            }
        }
    }
    
    
    private func setupFetchedResultController() {
        
        let fr = NSFetchRequest<Photo>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    //=================================
    // NSFetchedResultsControllerDelegate
    //=================================
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
    
    //=================================
    // End Of NSFetchedResultsControllerDelegate
    //=================================
    
    
    //=================================
    // Collection view delegate
    //=================================
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(photoToDelete)
        DataController.shared.saveContext()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celldentifier = "PhotoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
                downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
        return cell
    }
    


    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
    }
    
    // End of Collection view
    
    private func downloadImage(using cell: PhotoCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: imageData))
        } else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicator.startAnimating()
                FileDownloader.shared.downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        cell.activityIndicator.stopAnimating()
//                        self.errorForImageUrl(imageUrl)
                        return
                    } else if let data = data {
                        
                            
                            if let currentCell = collectionView.cellForItem(at: index) as? PhotoCell {
//                            if currentCell.imageUrl == imageUrl {
                                    currentCell.imageView.image = UIImage(data: data)
                                    cell.activityIndicator.stopAnimating()
                                }
//                            }
                            photo.image = NSData(data: data)
//                            DispatchQueue.global(qos: .background).async {
                                DataController.shared.saveContext()
//                            }
                        
                    }
                }
            }
        }
    }
    
}

