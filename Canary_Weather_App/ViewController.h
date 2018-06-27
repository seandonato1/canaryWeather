//
//  ViewController.h
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/22/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)setCurrentWeather:(NSDictionary*)currently;
@property (weak, nonatomic) IBOutlet UILabel *localityCV;

@end

