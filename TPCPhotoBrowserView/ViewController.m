//
//  ViewController.m
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/12/9.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "ViewController.h"
#import "TPCPhotoBrowserViewObjective-C/TPCPhotoBrowserView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect pageViewFrame = CGRectMake(20, 20, 200, 200);
    TPCPhotoBrowserView *pageView = [[TPCPhotoBrowserView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:pageView];
    pageView.imageURLStrings = @[@"http://www.kdatu.com/wp-content/uploads/2015/08/588514.jpg" , @"http://www.kdatu.com/wp-content/uploads/2015/08/588502.jpg", @"http://www.kdatu.com/wp-content/uploads/2015/02/q1.jpg", @"http://www.kdatu.com/wp-content/uploads/2015/11/087-MkYqE3v.jpg", @"http://www.kdatu.com/wp-content/uploads/2015/11/146-Vg6DyyH.jpg", @"http://www.kdatu.com/wp-content/uploads/2015/11/151-CQSHOjj.jpg"];
}

@end
