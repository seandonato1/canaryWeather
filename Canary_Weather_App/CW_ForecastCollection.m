//
//  CW_ForecastCollection.m
//  Canary_Weather_App
//
//  Created by Sean Donato on 6/24/18.
//  Copyright © 2018 Sean Donato. All rights reserved.
//

#import "CW_ForecastCollection.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "CW_ForecastCell.h"

@interface CW_ForecastCollection ()
@property (strong,nonatomic) NSMutableArray *forecastArrayCollectionView;
@property (strong,nonatomic) NSMutableArray *historyArrayCV;

@property (strong,nonatomic) NSArray *forecastArraySorted;
@property (strong,nonatomic) NSArray *historyArraySorted;

@property (weak, nonatomic) IBOutlet UIButton *currentButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@property (weak, nonatomic) IBOutlet UICollectionView *forecastCollectionView;

@end

@implementation CW_ForecastCollection

bool current;
bool history;

- (void)viewDidLoad {
    
    current = YES;
    [super viewDidLoad];
    _forecastCollectionView.delegate = self;
    _forecastCollectionView.dataSource = self;
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    _forecastArraySorted = [[NSArray alloc] init];
    _forecastArrayCollectionView = [[NSMutableArray alloc] init];
    
    _historyArraySorted = [[NSArray alloc] init];
    _historyArrayCV = [[NSMutableArray alloc] init];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @"present"];
    [request setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:moc]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    [_forecastArrayCollectionView addObjectsFromArray:results];
    
    NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"status == %@", @"future"];
    [request2 setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:moc]];
    [request2 setPredicate:predicate2];
    
    NSError *error2 = nil;
    NSArray *results2 = [moc executeFetchRequest:request2 error:&error2];
    [_forecastArrayCollectionView addObjectsFromArray:results2];
    for(int i = 0; i<[_forecastArrayCollectionView count];++i){
        
        NSManagedObject *ent = [_forecastArrayCollectionView objectAtIndex:i];
        NSNumber *nn = (NSNumber*)[ent valueForKey:@"timestamp"];
        NSLog(@"%@",nn);
        
    }
    NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    _forecastArraySorted = [_forecastArrayCollectionView sortedArrayUsingDescriptors:sortDescriptors];
    
    
    NSFetchRequest *requestHistory = [[NSFetchRequest alloc] init];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"status == %@", @"past"];
    [requestHistory setEntity:[NSEntityDescription entityForName:@"Forecast" inManagedObjectContext:moc]];
    [requestHistory setPredicate:predicate3];
    
    NSArray *results3 = [moc executeFetchRequest:requestHistory error:&error2];
    [_historyArrayCV addObjectsFromArray:results3];
    for(int i = 0; i<[_historyArrayCV count];++i){
        
        NSManagedObject *ent = [_historyArrayCV objectAtIndex:i];
        NSNumber *nn = (NSNumber*)[ent valueForKey:@"timestamp"];
        NSLog(@"%@",nn);
        
    }
    
    _historyArraySorted = [_historyArrayCV sortedArrayUsingDescriptors:sortDescriptors];
    
    
    //NSLog(@"sortedArray %@",sorted);
    [_forecastCollectionView reloadData];
    // Do any additional setup after loading the view.
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger numberOfItems;
    
    if(current){
        numberOfItems = [_forecastArraySorted count];
    }else{
        numberOfItems = [_historyArraySorted count];

    }
    
    return numberOfItems;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    CW_ForecastCell *cell = (CW_ForecastCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"forecastcell" forIndexPath:indexPath];
    
    // configuring cell
    // cell.customLabel.text = [yourArray objectAtIndex:indexPath.row]; // comment this line if you do not want add label from storyboard
    
    // if you need to add label and other ui component programmatically
    
    // this adds the label inside cell
    if(current){
        
        NSManagedObject *ent = [_forecastArraySorted objectAtIndex:indexPath.row];
        NSNumber *tstamp = (NSNumber*)[ent valueForKey:@"timestamp"];
        NSTimeInterval timestamp = (NSTimeInterval)tstamp.doubleValue;
        NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:updatetimestamp
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        NSString *separatorString = @",";
        NSString *myNewString = [dateString componentsSeparatedByString:separatorString].firstObject;
        cell.dateLabelFC.text = myNewString;
        NSString *icon = (NSString*)[ent valueForKey:@"icon"];
        UIImage *cellImage = [self setWeatherIcon:icon];
        cell.imageFC.image = cellImage;
        
    }else{
        NSManagedObject *ent = [_historyArraySorted objectAtIndex:indexPath.row];
        NSNumber *tstamp = (NSNumber*)[ent valueForKey:@"timestamp"];
        NSTimeInterval timestamp = (NSTimeInterval)tstamp.doubleValue;
        NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:updatetimestamp
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        NSString *separatorString = @",";
        NSString *myNewString = [dateString componentsSeparatedByString:separatorString].firstObject;
        cell.dateLabelFC.text = myNewString;
        NSString *icon = (NSString*)[ent valueForKey:@"icon"];
        UIImage *cellImage = [self setWeatherIcon:icon];
        cell.imageFC.image = cellImage;

        
    }
    return cell;

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = delegate.persistentContainer.viewContext;
    }
    return context;
}

- (IBAction)currentHistorySwitch:(id)sender {
    
    
        current = YES;
        history = NO;
        
        [_forecastCollectionView reloadData];

}
- (IBAction)historySwitch:(id)sender {
    
        current = NO;
        history = YES;
        
        [_forecastCollectionView reloadData];
  
    
}


-(UIImage*)setWeatherIcon:(NSString*)icon{
    
    UIImage *image = [UIImage imageNamed:@"sunVector"];
    if ([icon isEqualToString:@"clear-day"]) {
        
        image = [UIImage imageNamed:@"sunVector"];
        
    }else if ([icon isEqualToString:@"clear-night"]) {
        
        image = [UIImage imageNamed:@"sunVector"];

    }else if ([icon isEqualToString:@"clear-night"]){
        
        image = [UIImage imageNamed:@"sunVector"];

        
    }else if ([icon isEqualToString:@"rain"]){
        
        image = [UIImage imageNamed:@"rainy2"];
        
        
    }else if ([icon isEqualToString:@"snow"]){
        
        image = [UIImage imageNamed:@"rainy2"];
        
        
    }else if ([icon isEqualToString:@"sleet"]){
        
        image = [UIImage imageNamed:@"stormy"];
        
        
    }else if ([icon isEqualToString:@"wind"]){
        
        
        
    }else if ([icon isEqualToString:@"fog"]){
        
        
        
    }else if ([icon isEqualToString:@"cloudy"]){
        
        image = [UIImage imageNamed:@"cloud1"];
        
    }else if ([icon isEqualToString:@"partly-cloudy-day"]){
        
        image = [UIImage imageNamed:@"partlyCloudy"];
        
    }else if ([icon isEqualToString:@"partly-cloudy-night"]){
        
        image = [UIImage imageNamed:@"cloud1"];
        
    }
    
    return image;
    // clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
