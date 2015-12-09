//
//  TPCPhotoBrowserView.m
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/12/9.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCPhotoBrowserView.h"
#import "TPCImageView.h"

@interface TPCPhotoBrowserView() <UIScrollViewDelegate>
{
    TPCImageView *_currentImageView;
    TPCImageView *_backupImageView;
    UIScrollView *_scrollView;
    UIView *_edgeMaskView;
}
@end

#define ViewWidth self.bounds.size.width
#define ViewHeight self.bounds.size.height

static const CGFloat padding = 40;
@implementation TPCPhotoBrowserView

- (void)setImageURLStrings:(NSArray *)imageURLStrings {
    _imageURLStrings = imageURLStrings;
    if (imageURLStrings.count == 0) { return; }
    if (imageURLStrings.count > 1) {
        _backupImageView.imageURLString = imageURLStrings[1];
        _backupImageView.tag = 1;
    } else {
        _scrollView.scrollEnabled = NO;
    }
    _currentImageView.imageURLString = imageURLStrings[0];
    _currentImageView.tag = 0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(ViewWidth * 3, 0);
    _scrollView.contentOffset = CGPointMake(ViewWidth, 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    _currentImageView = [[TPCImageView alloc] initWithFrame:CGRectMake(ViewWidth, 0, ViewWidth, ViewHeight)];
    [_scrollView addSubview:_currentImageView];
    
    _backupImageView = [[TPCImageView alloc] initWithFrame:CGRectMake(ViewWidth * 2, 0, ViewWidth, self.bounds.size.height)];
    [_scrollView addSubview:_backupImageView];
    
    _edgeMaskView = [[UIView alloc] initWithFrame:CGRectMake(-padding, 0, padding, ViewHeight)];
    _edgeMaskView.backgroundColor = [UIColor blackColor];
    [self addSubview:_edgeMaskView];
    
    self.clipsToBounds = YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGRect frame = _edgeMaskView.frame;
    if (offsetX < ViewWidth) {
        frame.origin.x = padding / ViewWidth * (ViewWidth - offsetX) + ViewWidth - offsetX - padding;
        _backupImageView.frame = CGRectMake(0, 0, ViewWidth, ViewHeight);
        _backupImageView.tag = (_currentImageView.tag - 1 + _imageURLStrings.count) % _imageURLStrings.count;
        _backupImageView.imageURLString = _imageURLStrings[_backupImageView.tag];
    } else if (offsetX > ViewWidth) {
        frame.origin.x = padding / ViewWidth * (ViewWidth - offsetX) + 2 * ViewWidth - offsetX;
        _backupImageView.frame = CGRectMake(ViewWidth * 2, 0, ViewWidth, ViewHeight);
        _backupImageView.tag = (_currentImageView.tag + 1) % _imageURLStrings.count;
        _backupImageView.imageURLString = _imageURLStrings[_backupImageView.tag];
    }
    _edgeMaskView.frame = frame;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    scrollView.contentOffset = CGPointMake(ViewWidth, scrollView.contentOffset.y);
    if (offsetX < ViewWidth * 1.5 && offsetX > ViewWidth * 0.5) { return; }
    
    _currentImageView.imageURLString = _backupImageView.imageURLString;
    _currentImageView.tag = _backupImageView.tag;
}
@end
