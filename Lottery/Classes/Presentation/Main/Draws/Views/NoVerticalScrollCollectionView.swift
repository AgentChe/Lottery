//
//  NoVerticalScrollCollectionView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/23/24.
//

import UIKit
class NoVerticalScrollCollectionView: UICollectionView {
    override var contentSize: CGSize {
        get {
            // Get the original content size from the super class (which would normally reflect the full content's width and height)
            let contentSize = super.contentSize
            
            // Modify the height: force it to match the collection view's height (bounds.height)
            // This means the content will never exceed the visible height of the collection view
            return CGSize(width: contentSize.width, height: bounds.height)
        }
        set {
            // Set the content size with the new width, but force the height to be the collection view's height
            super.contentSize = CGSize(width: newValue.width, height: bounds.height)
        }
    }
}
