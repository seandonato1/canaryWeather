//
//  CW_DarkSkyAPICaller.m
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/23/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import "CW_DarkSkyAPICaller.h"
#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface CW_DarkSkyAPICaller ()

@property (strong,nonatomic) ViewController *parentVC;
@property (strong, nonatomic) NSString *locationDS;
@property (strong,nonatomic) NSMutableArray *forecastArray;

@end

@implementation CW_DarkSkyAPICaller

-(id)initWithParentVC:(ViewController*)parent{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    _parentVC = parent;
    _forecastArray = [[NSMutableArray alloc] init];
    return self;
}

-(void)getForecast:(CLLocation*)location :(NSString*)locationName :(bool)userLocation{
    
    NSError *error;
    
    if([locationName isEqualToString:@"userLocation"]){
        
        [self reverseGeocode:location];

    }   
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *apiKey = @"37499db2734b00788c3497d343c9aa19";
    
    //manager.responseSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/%@/%.6f,%.6f", apiKey, location.coordinate.latitude, location.coordinate.longitude];

    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"request %@",[req URL]);
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error)
            
        {
            
            NSLog(@"Reply JSON: %@", responseObject);
            NSDictionary *response = responseObject;
            
            //NSDictionary *data = [responseObject objectForKey:@"data"];
            NSDictionary *currently = [responseObject objectForKey:@"currently"];
            [self setParentWeather:currently];
            
            NSDictionary *daily = [responseObject objectForKey:@"daily"];
            
            NSArray *data = [daily objectForKey:@"data"];
            
            [self->_forecastArray addObjectsFromArray:data];
            NSDictionary *dayEightDict = [data objectAtIndex:[data count]-1];
            NSNumber *dayEightTime = [dayEightDict objectForKey:@"time"];
            NSTimeInterval timeWithNumber = (NSTimeInterval)dayEightTime.doubleValue;;
            [self getForecastDaysNineandTen:location :timeWithNumber :locationName];
            //int x = 0;
            
        }
        
        else
            
        {
            
            //stop act ind
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               
                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                               [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                               //[self presentViewController:alertController animated:YES completion:nil];
                               
                           });
            
        }
        
    }]
     
     resume];
    // return data;
}
-(void)getForecastDaysNineandTen:(CLLocation*)location :(NSTimeInterval)day :(NSString*)locationName{
    NSError *error;
    
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:day];
    
    NSDate *nextDate = [[NSDate alloc] init];
    for(int i = 0; i < 2 ; i++){
        

        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;
        
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        timestamp = [theCalendar dateByAddingComponents:dayComponent toDate:timestamp options:0];
        
        NSLog(@"nextDate: %@ ...", nextDate);

        int newTimestamp = [timestamp timeIntervalSince1970];


        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSString *apiKey = @"37499db2734b00788c3497d343c9aa19";
        
        //manager.responseSerializer = [AFJSONRequestSerializer serializer];
        NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/%@/%.6f,%.6f,%d", apiKey, location.coordinate.latitude, location.coordinate.longitude,newTimestamp];
        
        NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
        
        [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSLog(@"request %@",[req URL]);
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (!error)
                
            {
                
                NSLog(@"Reply JSON: %@", responseObject);
                NSDictionary *response = responseObject;
                
                //NSDictionary *data = [responseObject objectForKey:@"data"];
                NSDictionary *daily = [responseObject objectForKey:@"daily"];
                
                NSArray *data = [daily objectForKey:@"data"];
                
                [self->_forecastArray addObjectsFromArray:data];

                if(i == 1){
                    
                    [self storeForecastsInCoreData:locationName];
                    
                }
                //int x = 0;
                
            }
            
            else
                
            {
                
                //stop act ind
                NSLog(@"Error: %@, %@, %@", error, response, responseObject);
                
                dispatch_async(dispatch_get_main_queue(), ^(void)
                               {
                                   
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                   [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                   //[self presentViewController:alertController animated:YES completion:nil];
                                   
                               });
                
            }
            
        }]
         
         resume];

        
    }
    
}
-(void)setParentWeather:(NSDictionary*)currently{
    
    [_parentVC setCurrentWeather:currently];

}

-(void)storeForecastsInCoreData:(NSString*)locationName{
    
    // Create a new managed object
    NSManagedObjectContext *context = [self managedObjectContext];

    for(int i = 0; i<[_forecastArray count];i++){
        
        NSDictionary *dailyDictionary = [_forecastArray objectAtIndex:i];
        
        NSNumber *timestampVal = (NSNumber*)[dailyDictionary objectForKey:@"time"];

        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp == %@", timestampVal];
        [request setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:context]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        if([results count]){
            
            NSManagedObject *forecast = [results objectAtIndex:0];
            
         //   NSManagedObject *currentDayObject = [results objectAtIndex:0];
            NSNumber *ts = (NSNumber*)[forecast valueForKey:@"timestamp"];
            NSString *lo = [forecast valueForKey:@"location"];
            NSString *st = [forecast valueForKey:@"status"];

            NSLog(st);
            NSLog(@"%@",ts);

            if(timestampVal.doubleValue == ts.doubleValue){
                

                NSNumber *low = [dailyDictionary objectForKey:@"temperatureLow"];
                NSNumber *high = [dailyDictionary objectForKey:@"temperatureHigh"];
                NSNumber *icon = [dailyDictionary objectForKey:@"icon"];
                NSNumber *moon = [dailyDictionary objectForKey:@"moonphase"];
                
                
                NSTimeInterval timestamp = (NSTimeInterval)timestampVal.doubleValue;
                NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
                NSString *dateString = [NSDateFormatter localizedStringFromDate:updatetimestamp
                                                                      dateStyle:NSDateFormatterShortStyle
                                                                      timeStyle:NSDateFormatterFullStyle];
                NSString *separatorString = @",";
                NSString *myNewString = [dateString componentsSeparatedByString:separatorString].firstObject;
                NSLog(myNewString);

                [forecast setValue:timestampVal forKey:@"timestamp"];
                [forecast setValue:low forKey:@"low"];
                [forecast setValue:high forKey:@"high"];
                [forecast setValue:icon forKey:@"icon"];
                [forecast setValue:_locationDS forKey:@"location"];
                [forecast setValue:moon forKey:@"moonphase"];
            }
            if(i == 0){
                
                //   NSManagedObjectContext *moc = [self managedObjectContext];
                
                NSString *status = @"present";
                NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status == %@", status];
                [request2 setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:context]];
                [request2 setPredicate:predicate2];
                
                NSError *error = nil;
                NSArray *results2 = [context executeFetchRequest:request2 error:&error];
                if([results2 count]){
                    
                    NSManagedObject *currentDayObject = [results2 objectAtIndex:0];
                    NSNumber *ts2 = (NSNumber*)[currentDayObject valueForKey:@"timestamp"];
                    if(ts2.doubleValue < timestampVal.doubleValue){
                        
                        [currentDayObject setValue:@"past" forKey:@"status"];
                        
                    }
                    
                }
            }
        }else{
        
        
            NSNumber *low = [dailyDictionary objectForKey:@"temperatureLow"];
            NSNumber *high = [dailyDictionary objectForKey:@"temperatureHigh"];
            NSNumber *icon = [dailyDictionary objectForKey:@"icon"];
            NSNumber *moon = [dailyDictionary objectForKey:@"moonphase"];
            
            
            NSTimeInterval timestamp = (NSTimeInterval)timestampVal.doubleValue;
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
            NSString *dateString = [NSDateFormatter localizedStringFromDate:updatetimestamp
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterFullStyle];
            NSString *separatorString = @",";
            NSString *myNewString = [dateString componentsSeparatedByString:separatorString].firstObject;
            
            NSManagedObject *forecast = [NSEntityDescription insertNewObjectForEntityForName:@"Forecast" inManagedObjectContext:context];
            if([locationName isEqualToString:@"userLocation"]){
                
                NSString *nameForLocationEntity = @"userLocation";
                NSFetchRequest *requestForLocation = [[NSFetchRequest alloc] init];
                NSPredicate *predicateForLocation = [NSPredicate predicateWithFormat:@"name == %@", nameForLocationEntity];
                [requestForLocation setEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context]];
                [requestForLocation setPredicate:predicateForLocation];
                
                NSError *error = nil;
                NSArray *locationResults = [context executeFetchRequest:requestForLocation error:&error];

                NSManagedObject *locationObject = [locationResults objectAtIndex:0];
                
                [forecast setValue:locationObject forKey:@"locationData"];
            }else{
                
                
                NSString *nameForLocationEntity = locationName;
                NSFetchRequest *requestForLocation = [[NSFetchRequest alloc] init];
                NSPredicate *predicateForLocation = [NSPredicate predicateWithFormat:@"name == %@", nameForLocationEntity];
                [requestForLocation setEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context]];
                [requestForLocation setPredicate:predicateForLocation];
                
                NSError *error = nil;
                NSArray *locationResults = [context executeFetchRequest:requestForLocation error:&error];
                
                NSManagedObject *locationObject = [locationResults objectAtIndex:0];
                
                [forecast setValue:locationObject forKey:@"locationData"];
                
            }
            
            [forecast setValue:timestampVal forKey:@"timestamp"];
            [forecast setValue:low forKey:@"low"];
            [forecast setValue:high forKey:@"high"];
            [forecast setValue:icon forKey:@"icon"];
            [forecast setValue:_locationDS forKey:@"location"];
            [forecast setValue:moon forKey:@"moonphase"];
            
            
            if(i == 0){
                
                //   NSManagedObjectContext *moc = [self managedObjectContext];
                
                NSString *status = @"present";
                NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
                NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status == %@", status];
                [request2 setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:context]];
                [request2 setPredicate:predicate2];
                
                NSError *error = nil;
                NSArray *results2 = [context executeFetchRequest:request error:&error];
                if([results2 count]){
                    
                    NSManagedObject *currentDayObject = [results2 objectAtIndex:0];
                    NSNumber *ts = [currentDayObject valueForKey:@"timestamp"];
                    if(ts.doubleValue < timestampVal.doubleValue){
                        
                        [currentDayObject setValue:@"past" forKey:@"status"];
                        
                    }
                    
                }
                
                [forecast setValue:@"present" forKey:@"status"];
            }else{
                
                [forecast setValue:@"future" forKey:@"status"];
                
            }
            
            // NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        
        }
    }
}

-(void)reverseGeocode:(CLLocation*)location{
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = [placemarks firstObject];
        if (placemark) {
            
            //Using blocks, get zip code
            NSString *newLoc = [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.administrativeArea];
            self->_locationDS = placemark.locality;
            self->_parentVC.localityCV.text = newLoc;
        }
    }];
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
