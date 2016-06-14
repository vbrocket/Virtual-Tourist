//
//  FlickerConstants.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 5/24/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import Foundation
extension FlickerClient{
    
    
    // MARK: Constants
    struct Constants {
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        
        // API Key
        static let APIKey = "4fe6bddde5856cf28c28ee50bb11c1e4"
    }
    
    // MARK: - Methods
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    struct URLKeys {
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: - URL Values
    struct URLValues {
        static let JSONFormat = "json"
        static let PhotoURL = "url_m"
        static let PhotoTitle = "title"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    

    
}