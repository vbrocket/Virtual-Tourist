//
//  PictureCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 6/12/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    @IBOutlet weak var btnDeletePhoto: UIButton!
    
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    
    override func prepareForReuse() {
        // fix image duplication issue in uicollection view when scrolling up and down
        imgPhoto.image = nil
        btnDeletePhoto.hidden = true
        super.prepareForReuse()
    }
    
    
    // show hide indicator
    func showHideIndicator(){
        if imgPhoto.image == nil {
            actIndicator.startAnimating()
        }
        else
        {
            actIndicator.stopAnimating()
        }
    }
}


    

    