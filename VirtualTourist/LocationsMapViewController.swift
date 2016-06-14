//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 5/23/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsMapViewController: UIViewController ,MKMapViewDelegate {
    var selectedPin: Pin!
    let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // handle long press
        let longGuestureHanlde = UILongPressGestureRecognizer(target: self, action: "handleMapLongPress:")
        mapView.addGestureRecognizer(longGuestureHanlde)
        
        // load previous saved pins
        loadPinsFromDB()
        
        // load latest map locaion if exist
        LoadMapSettings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // save latest map locaion if exist
        SaveMapSettings()
    }
    
    func loadPinsFromDB(){
        
        let request = NSFetchRequest(entityName: "Pin")
        
        do {
            let pins = try sharedContext.executeFetchRequest(request) as! [Pin]
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude! as CLLocationDegrees, longitude: pin.longitude! as CLLocationDegrees)

                mapView.addAnnotation(annotation)
            }
        } catch {
            print("error in fetch")
        }
    }
    
    // find pin by latitude and longtude
    func findPin(lat: NSNumber, long: NSNumber) -> Pin? {
        let request = NSFetchRequest(entityName: "Pin")
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", lat , long)
        request.predicate = predicate
        
        do {
            let pins = try sharedContext.executeFetchRequest(request) as! [Pin]
            if pins.count > 0 {
                return pins[0]
            }
        }
        catch {
            print("error in fetch")
        }
        return nil
    }

    func LoadMapSettings(){
        let possibleData = NSUserDefaults.standardUserDefaults().objectForKey("mapSettings")
        if let data = possibleData {
            
            var object:[String:AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! [String: AnyObject]
            
            print("********************* Loading Data")
            print(object)
            
            let lat = object["lat"] as! CLLocationDegrees
            let lon = object["lon"] as! CLLocationDegrees
            let latDelta = object["latDelta"] as! CLLocationDegrees
            let lonDelta = object["lonDelta"] as! CLLocationDegrees
            
            let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat , lon),  MKCoordinateSpanMake(latDelta, lonDelta))
            mapView.setRegion(region, animated: false)
        }
    }
    
    func SaveMapSettings(){
        let r = mapView.region
        let data:[String:AnyObject] = ["lat":r.center.latitude, "lon":r.center.longitude, "latDelta":r.span.latitudeDelta, "lonDelta":r.span.longitudeDelta]
        print("********************* Saving Data")
        print(data)
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(data), forKey: "mapSettings")
    }
    

    
    func handleMapLongPress(getstureRecognizer : UIGestureRecognizer){
        guard getstureRecognizer.state == UIGestureRecognizerState.Ended else {
            //mapView.region.span
            
            return
        }
        
        
        print("long press........")
        let pressPoint = getstureRecognizer.locationInView(self.mapView)
        let pressMapCoordinate = mapView.convertPoint(pressPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pressMapCoordinate
        
        
      
        let newPin = Pin(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: self.sharedContext)

        
        // Saving to core data
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Adding the newPin to the map
        self.mapView.addAnnotation(annotation)

        
        // download pin photos
        FlickerClient.sharedInstance().downloadPhotos(newPin) { ( uccess, error) -> Void in

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segPhotoAlbum") {
            let viewController = segue.destinationViewController as! PhotoAlbumViewController
            viewController.curPin = selectedPin
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        // deselect to be able to select again
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        // find pin from selected annotation
        selectedPin = findPin((view.annotation?.coordinate.latitude)!, long: (view.annotation?.coordinate.longitude)!)
        self.performSegueWithIdentifier("segPhotoAlbum", sender: nil)
    }



}

