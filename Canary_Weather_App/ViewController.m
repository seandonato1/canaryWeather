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
#import "CW_DarkSkyAPICaller.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface ViewController () <UIScrollViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSMutableArray *locationSlides;
@property (strong,nonatomic) CW_DarkSkyAPICaller *apiCaller;
@property (strong,nonatomic) CW_LocationSlide *view1;
@property (weak, nonatomic) IBOutlet UIView *currentView;
@property (weak, nonatomic) IBOutlet UIImageView *iconCV;
@property (weak, nonatomic) IBOutlet UILabel *tempLabelCV;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabelCV;
@property (strong, nonatomic) NSString *locationCV;

@end

@implementation ViewController

CLLocationManager *locationManager;
BOOL didGetCurrentWeather;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _apiCaller = [[CW_DarkSkyAPICaller alloc] initWithParentVC:self];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];

    

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    if(!didGetCurrentWeather){
        
        NSManagedObjectContext *context = [self managedObjectContext];

        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"userLocation"];
        [request setEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        
        NSUInteger count = [context countForFetchRequest:request
                                                                error:&error];
        if (count == 0) {
            NSManagedObject *userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
            [userLocation setValue:@"userLocation" forKey:@"name"];
            
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            
        } else {
            

        }

        NSNumber *latNum =  [NSNumber numberWithDouble:locationManager.location.coordinate.latitude];
        NSNumber *longNum = [NSNumber numberWithDouble:locationManager.location.coordinate.longitude];
        [_apiCaller getForecast:locationManager.location :@"userLocation" :YES];
        
        didGetCurrentWeather = YES;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCurrentWeather:(NSDictionary*)currently{
    
    NSString *tempWithDecimal = [NSString stringWithFormat:@"%@",[currently objectForKey:@"temperature"] ];
    NSString *separator = @".";
    NSString *tempWithoutDecimal = [tempWithDecimal componentsSeparatedByString:separator].firstObject;
    NSString *tempWithDegree = [NSString stringWithFormat:@"%@%@",tempWithoutDecimal, @"\u00B0"];

    _tempLabelCV.text = tempWithDegree;
    
    _summaryLabelCV.text = [currently objectForKey:@"summary"];

    NSNumber *timestampVal = [currently objectForKey:@"time"];
    NSTimeInterval timestamp = (NSTimeInterval)timestampVal.doubleValue;
    NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:updatetimestamp
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    NSString *separatorString = @",";
    NSString *myNewString = [dateString componentsSeparatedByString:separatorString].firstObject;
    
    NSLog(@"%@",dateString);

    [self setWeatherIcon:[currently objectForKey:@"icon"]];

}

-(void)setWeatherIcon:(NSString*)icon{
    
    if ([icon isEqualToString:@"clear-day"]) {
        
        _iconCV.image = [UIImage imageNamed:@"sunVector"];
        
    }else if ([icon isEqualToString:@"clear-night"]) {
        
        
    }else if ([icon isEqualToString:@"clear-night"]){
    
        
        
    }else if ([icon isEqualToString:@"rain"]){
        
        _iconCV.image = [UIImage imageNamed:@"rainy2"];

        
    }else if ([icon isEqualToString:@"snow"]){
        
        _iconCV.image = [UIImage imageNamed:@"rainy2"];


    }else if ([icon isEqualToString:@"sleet"]){
        
        _iconCV.image = [UIImage imageNamed:@"stormy"];


    }else if ([icon isEqualToString:@"wind"]){
        
        
        
    }else if ([icon isEqualToString:@"fog"]){
        


    }else if ([icon isEqualToString:@"cloudy"]){
        
        _iconCV.image = [UIImage imageNamed:@"cloud1"];

    }else if ([icon isEqualToString:@"partly-cloudy-day"]){
        
        _iconCV.image = [UIImage imageNamed:@"partlyCloudy"];

    }else if ([icon isEqualToString:@"partly-cloudy-night"]){
        
        _iconCV.image = [UIImage imageNamed:@"cloud1"];

    }

   // clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = delegate.persistentContainer.viewContext;
    }
    return context;
}
@end
