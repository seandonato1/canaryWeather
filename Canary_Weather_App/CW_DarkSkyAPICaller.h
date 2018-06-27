//
//  CW_DarkSkyAPICaller.h
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/23/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface CW_DarkSkyAPICaller : NSObject

-(void)getForecast:(CLLocation*)location :(NSString*)locationName :(bool)userLocation;
-(id)initWithParentVC:(ViewController*)parent;

@end
