//
//  TPCImageView.swift
//  TPCPageScrollView
//
//  Created by tripleCC on 15/11/25.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import DACircularProgress
import SDWebImage

class TPCImageView: UIView {
    var imageMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit {
        didSet {
            imageView.contentMode = imageMode
        }
    }
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var progressView: DALabeledCircularProgressView!
    var imageURLString: String! {
        didSet {
            resetSubviews()
            imageView.sd_setImageWithURL(NSURL(string: imageURLString), placeholderImage: UIImage(), options: SDWebImageOptions.RetryFailed, progress: { (receivedSize, expectedSize) -> Void in
                guard CGFloat(receivedSize) / CGFloat(expectedSize) > 0.009 else {
                    self.progressView.progressLabel.text = "0.00"
                    self.progressView.progress = 0
                    return
                }
                
                self.progressView.setProgress(CGFloat(receivedSize) / CGFloat(expectedSize), animated: true)
                self.progressView.progressLabel.text = String(format:"%.2f", self.progressView.progress)
                if receivedSize / expectedSize >= 1 {
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.progressView.alpha = 0
                    })
                }
                }) { (image, error, cacheType, imageURL) -> Void in
                    self.adjustImageViewFrameByImage(image)
                    self.progressView.alpha = 0
            }
        }
    }
    private func adjustImageViewFrameByImage(image: UIImage?) {
        if let image = image {
            if imageView.contentMode == UIViewContentMode.ScaleAspectFit || imageView.contentMode == UIViewContentMode.Center{
                if (image.size.width > image.size.height) {
                    imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width / image.size.width * image.size.height)
                } else {
                    imageView.frame = CGRect(x: 0, y: 0, width: bounds.height / image.size.height * image.size.width, height: image.size.height)
                }
            } else {
                imageView.frame = bounds
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func resetSubviews() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        imageView.transform = CGAffineTransformIdentity
        progressView.alpha = 1
        progressView.progress = 0
        progressView.progressLabel.text = "0.00"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    private func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = bounds
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.blackColor()
        addSubview(scrollView)
        
        imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(imageView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        progressView = DALabeledCircularProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        progressView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        progressView.roundedCorners = Int(true)
        progressView.progressLabel.font = UIFont.systemFontOfSize(10)
        progressView.progressLabel.textColor = UIColor.whiteColor()
        addSubview(progressView)
    }

    func doubleTap(gesture: UIGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            let point = gesture.locationInView(gesture.view)
            let width = bounds.width / scrollView.maximumZoomScale
            let height = bounds.height / scrollView.maximumZoomScale
            scrollView.zoomToRect(CGRect(x: point.x - width * 0.5, y: point.y - height * 0.5, width: width, height: height), animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundsSize = bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) * 0.5
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) * 0.5
        } else {
            frameToCenter.origin.y = 0
        }
        if !CGRectEqualToRect(imageView.frame, frameToCenter) {
            imageView.frame = frameToCenter
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TPCImageView: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}