//
//  CharacterCollectionView.swift
//  OCR
//
//  Created by Kevin Ayuque on 28/04/16.
//  Copyright © 2016 Kevin Ayuque. All rights reserved.
//

import UIKit

class CharacterCollectionView: UICollectionViewController {

    var array = [Int]()
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 12
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        if array[(indexPath.section * 12) + indexPath.row] == 1{
            cell.backgroundColor=UIColor.blackColor()
        }
        return cell
    }
    
    
}
