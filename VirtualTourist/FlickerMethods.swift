//
//  FlickerMethods.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 5/24/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import Foundation

extension FlickerClient {
    
    
    func downloadPhotos(pin: Pin, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        var randomPageNumber: Int = 1
        // if not first time get random page number
        if let numberPages = pin.pageCount?.integerValue {
            if numberPages > 0 {
                let pageLimit = min(numberPages, 20)
                randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1 
            }
        }
        
        // Parameters for request photos
        let parameters: [String : AnyObject] = [
            URLKeys.Method : Methods.Search,
            URLKeys.APIKey : Constants.APIKey,
            URLKeys.Format : URLValues.JSONFormat,
            URLKeys.NoJSONCallback : 1,
            URLKeys.Latitude : pin.latitude!,
            URLKeys.Longitude : pin.longitude!,
            URLKeys.Extras : URLValues.PhotoURL,
            URLKeys.Page : randomPageNumber,
            URLKeys.PerPage : 20
        ]
        
        // Make GET request for get photos for pin
        taskForGETMethod(parameters,completionHandlerForGET: {
            results, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                
                // Response dictionary
                if let photosDictionary = results.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject],
                    photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String : AnyObject]],
                    numberOfPhotoPages = photosDictionary[JSONResponseKeys.Pages] as? Int {
                        
                        pin.pageCount = numberOfPhotoPages
                        
                      

                        for var i = 0; i < photosArray.count ; ++i {
                            
                            guard let photoURLString = photosArray[i][URLValues.PhotoURL] as? String else {
                                print ("error, photoDictionary)"); continue}
                            print(photoURLString)
                            
                            guard let title = photosArray[i][URLValues.PhotoTitle] as? String else {
                                print ("error, photoDictionary)"); continue}

                            let id = String(i)
                            // Create the Photos model
                            let newPhoto = Photo(photoURL: photoURLString,title: title, photoId: id, pin: pin, context: self.sharedContext)
                            
 
                            //Download photo by url
                            self.downloadPhotoImage(newPhoto, completionHandler: {
                                success, error in

                            })
                        }
                        
                        completionHandler(success: true, error: nil)
                } else {
                    
                    completionHandler(success: false, error: NSError(domain: "downloadPhotosForPin", code: 0, userInfo: nil))
                }
            }
        })
    }
    
    // Download save image and change file path for photo
    func downloadPhotoImage(photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let imageURLString = photo.url
        
        // Make GET request for download photo by url
        taskForGETImageData(imageURLString!, completionHandler: {
            result, error in
            
            // If there is an error - set file path to error to show blank image
            if let error = error {
                print("Error from downloading images \(error.localizedDescription )")
                photo.imageData = nil
                completionHandler(success: false, error: error)
                
            } else {
                
                if let result = result {
                    
                    // check if photo still exist and not delete by user before it fully loaded
                    if photo.managedObjectContext != nil {
                    // Update the Photos model
                    photo.imageData = result
                    // Save the context
                    dispatch_async(dispatch_get_main_queue(), {
                        CoreDataStackManager.sharedInstance().saveContext()
                    })
                    }
                    completionHandler(success: true, error: nil)
                }
            }
        })
    }
}