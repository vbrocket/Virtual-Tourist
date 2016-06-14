//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 6/11/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var colImagesCollection: UICollectionView!
    
    @IBOutlet weak var lblNoImages: UILabel!
    @IBOutlet weak var btnNewCollection: UIButton!
    
    var editedCells: [String] = []
    
    let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    var fetchedResultsController: NSFetchedResultsController!
    var curPin: Pin!
    var numberOfPhotosToDownload: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize Fetched Results Controller and retreive data
        initializeFetchedResultsController()
        colImagesCollection.delegate = self
        colImagesCollection.dataSource = self
        
        mapView.delegate = self
        
        // init map with pin location and center it
        setMapLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        AdjustNewCollectionVisibility()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "pin == %@", curPin)
        request.predicate = predicate
        
        let idsort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [idsort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// Handle Collection View Delegates
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Return the number of photos from fetchedResultsController
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("Number of photos returned from fetchedResultsController #\(sectionInfo.numberOfObjects)")
       
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PictureCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        if let imagedata = photo.imageData {
            cell.imgPhoto.image = UIImage(data: imagedata)
        }
        else{
            cell.imgPhoto.image = nil
        }
        
        cell.btnDeletePhoto.addTarget(self, action: "deletePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.showHideIndicator()
        
        // handle cell edit mode
        let index = editedCells.indexOf(photo.id!)
        
        // if cell in edit mode (exist in edited cells array)
        if index >= 0 {
            cell.btnDeletePhoto.hidden = false
        }
        else {
            cell.btnDeletePhoto.hidden = true
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let index = editedCells.indexOf(photo.id!)
        if index >= 0 {
            editedCells.removeAtIndex(index!)
        }
        else {
                editedCells.append(photo.id!)
        }
        
        print("******** edit cells count \(editedCells.count)")
        for cell in editedCells {
            print("cell \(cell)")
        }
        // reload cell to show edit mode effect or hide it
        colImagesCollection.reloadItemsAtIndexPaths([indexPath])
    }
    
    // delete photo click handler
    func deletePhoto(sender: UIButton){
        // get button parent cell
        let cell = sender.superview as! PictureCollectionViewCell
        
        // get index path of cell
        let indexPath = colImagesCollection.indexPathForCell(cell)
        
        // get photo to delete
        let photo = fetchedResultsController.objectAtIndexPath(indexPath!) as! Photo
        
        // delete the photo
        sharedContext.deleteObject(photo)
        
        // remove cell from editedcells array
        let index = editedCells.indexOf(photo.id!)
        editedCells.removeAtIndex(index!)
        
        print("******** edit cells count \(editedCells.count)")
        for cell in editedCells {
            print("cell \(cell)")
        }
        
        // save context
        CoreDataStackManager.sharedInstance().saveContext()
        
        // if you dleted unloaded picture check if new collection should appear
        AdjustNewCollectionVisibility()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////// Handle Fetched Results
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    // used as work around to avoid error in number of items in sections
    var blockOperations: [NSBlockOperation] = []
    
    // handle changes in the managed objects and bind it directly to the colection view
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Update:
            blockOperations.append(NSBlockOperation(block: { () -> Void in
                self.colImagesCollection.reloadItemsAtIndexPaths([indexPath!])
                print("Item updated at index path = \(indexPath!)")
                
            }))
        case .Insert:
            blockOperations.append(NSBlockOperation(block: { () -> Void in
                print("Item inserted at index path = \(newIndexPath!)")
                self.colImagesCollection.insertItemsAtIndexPaths([newIndexPath!])
            }))
        case .Delete:
            blockOperations.append(NSBlockOperation(block: { () -> Void in
                print("Item deleted at index path = \(indexPath!)")
                self.colImagesCollection.deleteItemsAtIndexPaths([indexPath!])
            }))
        default:
            break
        }
        
        AdjustNewCollectionVisibility()
        print("numberOfPhotosToDownload() = \(numberOfPhotosToDownload)")
    }
    
    // clear array of blocks before changes
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("controller change conent = \(self.blockOperations.count)")
        // execute all DB queued operations
        colImagesCollection.performBatchUpdates({ () -> Void in
            for operation: NSBlockOperation in self.blockOperations {
                    operation.start()
            }
            }, completion: { (finished) -> Void in
                // clear block array after it all executed to not execute again
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }
    
    
    
    // set map to Pin point and center it
    func setMapLocation() {
        
        let point = MKPointAnnotation()
        
        point.coordinate = CLLocationCoordinate2DMake(Double(curPin.latitude!), Double(curPin.longitude!))
        
        // zoom
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: point.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(point)
        //mapView.centerCoordinate = point.coordinate
        mapView.setCenterCoordinate(point.coordinate, animated: true)
        // Select the annotation so the title can be shown
        mapView.selectAnnotation(point, animated: true)
    }

    @IBAction func btnNewCollectionClick(sender: AnyObject) {
        
        if let photos = curPin.photos {
            for pic in photos {
                let photo = pic as! Photo
                sharedContext.deleteObject(photo)
            }
        }
        
        // empty edited cells array
        editedCells.removeAll()
        
        // Saving to core data
        CoreDataStackManager.sharedInstance().saveContext()
        
        //download new collection pics
        FlickerClient.sharedInstance().downloadPhotos(curPin) { ( uccess, error) -> Void in
            
        }
    }
    
    // Adjust New Collection button Visibility
    func AdjustNewCollectionVisibility(){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.getNumberOfPhotosToDownload()
            self.btnNewCollection.hidden = self.numberOfPhotosToDownload > 0
            
            if self.curPin.photos?.count > 0 {
                self.lblNoImages.hidden = true
            }
            else{
                self.lblNoImages.hidden = false
            }
        }
    }
    
    // get number of downloaded photo in each pin depending if it has data on it or not.
    func getNumberOfPhotosToDownload(){
        var counter = 0
        if let photos = curPin.photos {
        for photo in photos {
            let pic = photo as! Photo
            if pic.imageData == nil {
                counter++
            }
        }
        }
        numberOfPhotosToDownload = counter
    }

}
