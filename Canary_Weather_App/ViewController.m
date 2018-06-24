//
//  ViewController.m
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/22/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import "ViewController.h"
#import "CW_LocationSlide.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSMutableArray *locationSlides;

@end

@implementation ViewController

CLLocationManager *locationManager;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];

    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];

    _locationSlides = [[NSMutableArray alloc]init];
    
    _pageControl.numberOfPages = 3;
    
//    CGSize pageControlSize = [self.pageControl sizeThatFits:_pageView.bounds.size];
//    self.pageControl.frame = _pageView.frame;
    
    [_pageControl addTarget:self action:@selector(didChangePage:) forControlEvents: UIControlEventValueChanged];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.pageControl];
    
    
    CW_LocationSlide *view1 = [[[NSBundle mainBundle] loadNibNamed:@"CW_LocationSlide" owner:self options:nil] objectAtIndex:0];
    view1.temperatureLabel.text = @"73";
    [_locationSlides addObject:view1];
   // view1.backgroundColor = UIColor.redColor;
    UIView *view2 =  [[[NSBundle mainBundle] loadNibNamed:@"CW_LocationSlide" owner:self options:nil] objectAtIndex:0];
    [_locationSlides addObject:view2];
    UIView *view3 =  [[[NSBundle mainBundle] loadNibNamed:@"CW_LocationSlide" owner:self options:nil] objectAtIndex:0];
    [_locationSlides addObject:view3];

    CGFloat scrollWidth = view1.frame.size.width + view2.frame.size.width + view3.frame.size.width;
    
    _scrollView.contentSize = CGSizeMake(scrollWidth, _scrollView.frame.size.height);
//    [_scrollView addSubview:view1];
//    [_scrollView addSubview:view2];
//    [_scrollView addSubview:view3];

    CGSize pageSize = _scrollView.frame.size; // scrollView is an IBOutlet for our UIScrollView
    NSUInteger page = 0;
    for(UIView *view in _locationSlides) {
        
        [_scrollView addSubview:view];
        
        // This is the important line
        view.frame = CGRectMake(pageSize.width * page++ + 10, 0, pageSize.width, pageSize.height);
        // We're making use of the scrollView's frame size (pageSize) so we need to;
        // +10 to left offset of image pos (1/2 the gap)
        // -20 for UIImageView's width (to leave 10 gap at left and right)
    }
    _scrollView.contentSize = CGSizeMake(pageSize.width * 3, pageSize.height);

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
