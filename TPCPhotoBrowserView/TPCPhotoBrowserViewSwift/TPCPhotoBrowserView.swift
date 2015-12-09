//
//  TPCPhotoBrowserView
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/11/23.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCPhotoBrowserView: UIView {
    let padding: CGFloat = 40
    var imageMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit {
        didSet {
            currentImageView.imageMode = imageMode
            backupImageView.imageMode = imageMode
        }
    }
    var imageURLStrings: [String]! {
        didSet {
            guard imageURLStrings.count > 0 else { return }
            if imageURLStrings.count > 1 {
                backupImageView.imageURLString = imageURLStrings[1]
                backupImageView.tag = 1
            } else {
                scrollView.scrollEnabled = false
            }
            currentImageView.imageURLString = imageURLStrings[0]
            currentImageView.tag = 0
        }
    }
    var scrollView: UIScrollView!
    var currentImageView: TPCImageView!
    var backupImageView: TPCImageView!
    var edgeMaskView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: bounds.width * 3, height: 0)
        scrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        currentImageView = TPCImageView(frame: CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height))
        scrollView.addSubview(currentImageView)
        
        backupImageView = TPCImageView(frame: CGRect(x: bounds.width * 2, y: 0, width: bounds.width, height: bounds.height))
        scrollView.addSubview(backupImageView)
        
        edgeMaskView = UIView(frame: CGRect(x: -padding, y: 0, width: padding, height: bounds.height))
        edgeMaskView.backgroundColor = UIColor.blackColor()
        addSubview(edgeMaskView)
        
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}

extension TPCPhotoBrowserView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        if offsetX < bounds.width {
            edgeMaskView.frame.origin.x = padding / bounds.width * (bounds.width - offsetX) + bounds.width - offsetX - padding
            backupImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            backupImageView.tag = (currentImageView.tag - 1 + imageURLStrings.count) % imageURLStrings.count
            backupImageView.imageURLString = imageURLStrings[backupImageView.tag]
        } else if offsetX > bounds.width {
            edgeMaskView.frame.origin.x = padding / bounds.width * (bounds.width - offsetX) + 2 * bounds.width - offsetX
            backupImageView.frame = CGRect(x: bounds.width * 2, y: 0, width: bounds.width, height: bounds.height)
            backupImageView.tag = (currentImageView.tag + 1) % imageURLStrings.count
            backupImageView.imageURLString = imageURLStrings[backupImageView.tag]
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        scrollView.contentOffset.x = bounds.size.width
        if offsetX < bounds.width * 1.5 && offsetX > bounds.width * 0.5 {
            return
        }
        currentImageView.imageURLString = backupImageView.imageURLString
        currentImageView.tag = backupImageView.tag
    }
}