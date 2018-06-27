//
//  CW_LocationSlide.h
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/22/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CW_LocationSlide : UIView
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconSlide;

@end
