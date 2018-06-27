//
//  CW_LocationsTable.m
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/24/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CW_LocationsView.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface CW_LocationsView () <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapViewLT;
@property (weak, nonatomic) IBOutlet UITableView *locationsTableLT;
@property (strong,nonatomic) NSMutableArray *locationsArrayLT;

@end

@implementation CW_LocationsView


- (void)viewDidLoad{
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *requestForLocation = [[NSFetchRequest alloc]initWithEntityName:@"Location"];

    NSError *error = nil;
    
    NSArray *locationResults = [context executeFetchRequest:requestForLocation error:&error];
    _locationsArrayLT = [[NSMutableArray alloc] init];
    
    
    [_locationsArrayLT addObjectsFromArray:locationResults];
    
    
    _locationsTableLT.delegate = self;
    _locationsTableLT.dataSource = self;
    [self.view bringSubviewToFront:_locationsTableLT];
    
    [_locationsTableLT reloadData];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    
    NSManagedObject *ent = [_locationsArrayLT objectAtIndex:indexPath.row];
    
    NSString* locName = (NSString*)[ent valueForKey:@"name"];
    
    NSArray *forecasts = [ent valueForKey:@"forecast"];
    if([locName isEqualToString:@"userLocation"]){
        cell.textLabel.text = @"current location";
        cell.tag = 1;
    }
    
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_locationsArrayLT count];

}

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//
//}
//
//- (void)setNeedsFocusUpdate {
//
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//
//}
//
//- (void)updateFocusIfNeeded {
//
//}


-(void)reverseGeocode:(CLLocation*)location{
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = [placemarks firstObject];
        if (placemark) {
            
            //Using blocks, get zip code
            NSString *newLoc = [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.administrativeArea];
        }
    }];
}
- (IBAction)addLocation:(id)sender {
    
    
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
