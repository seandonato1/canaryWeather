//
//  AppDelegate.h
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/22/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

