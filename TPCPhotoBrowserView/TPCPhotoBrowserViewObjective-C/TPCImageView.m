//
//  TPCImageView.m
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/12/9.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCImageView.h"
#import "DALabeledCircularProgressView.h"
#import "UIImageView+WebCache.h"

@interface TPCImageView() <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    DALabeledCircularProgressView *_progressView;
}
@end

@implementation TPCImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self adjustImageFrame];
}

- (void)adjustImageFrame {
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter)) {
        _imageView.frame = frameToCenter;
    }
}

- (void)setImageURLString:(NSString *)imageURLString {
    if ([_imageURLString isEqualToString:imageURLString]) { return; }
    _imageURLString = imageURLString;
    [self resetSubviews];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        if (progress < 0.009) {
            _progressView.progressLabel.text = @"0.00";
            _progressView.progress = 0;
        } else {
            [_progressView setProgress:progress animated:YES];
            _progressView.progressLabel.text = [NSString stringWithFormat:@"%.2f", _progressView.progress];
            if (progress >= 1.0) {
                [UIView animateWithDuration:0.1 animations:^{
                    _progressView.alpha = 0;
                }];
            }
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self adjustImageViewFrameByImage:image];
        _progressView.alpha = 0;
    }];
}

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 3.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
    
    _progressView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _progressView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    _progressView.roundedCorners = YES;
    _progressView.progressLabel.font = [UIFont systemFontOfSize:10.0];
    _progressView.progressLabel.textColor = [UIColor whiteColor];
    [self addSubview:_progressView];
}

- (void)doubleTap: (UIGestureRecognizer *)gesture {
    if (_scrollView.zoomScale == 1) {
        CGPoint point = [gesture locationInView:gesture.view];
        CGFloat width = self.bounds.size.width / _scrollView.maximumZoomScale;
        CGFloat height = self.bounds.size.height / _scrollView.maximumZoomScale;
        [_scrollView zoomToRect:CGRectMake(point.x - width * 0.5, point.y - height * 0.5, width, height) animated:YES];
    } else {
        [_scrollView setZoomScale:1 animated:YES];
    }
}

- (void)adjustImageViewFrameByImage:(UIImage *)image {
    _imageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    CGFloat xScale = self.bounds.size.width / image.size.width;
    CGFloat yScale = self.bounds.size.height / image.size.height;
    CGFloat minScale = MIN(xScale, yScale);
    _imageView.bounds = CGRectMake(0, 0, _imageView.bounds.size.width * minScale, _imageView.bounds.size.height * minScale);
    [self adjustImageFrame];
}

- (void)resetSubviews {
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.contentOffset = CGPointZero;
    _scrollView.contentSize = CGSizeZero;
    _imageView.transform = CGAffineTransformIdentity;
    _progressView.alpha = 1;
    _progressView.progress = 0;
    _progressView.progressLabel.text = @"0.00";
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustImageFrame];
}
@end
