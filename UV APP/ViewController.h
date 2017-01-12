//
//  ViewController.h
//  UV APP
//
//  Created by perrin cloutier on 7/15/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "InformationViewController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *uvLabel;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) IBOutlet UILabel *label5;
@property (strong, nonatomic) IBOutlet UILabel *label6;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) int locationFetchCounter;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSNumber *uvNumber;
@property (nonatomic, strong) NSString *uvRating;
@property (nonatomic, strong) NSNumber *hourlyNumber;
@property (nonatomic, strong) NSString *uvIndex;//value for display
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic) UIColor *color;
@property (nonatomic) int timeIntFromAPI;
@property (nonatomic) int militaryTimeValue;
@property (nonatomic) int currentHourValue;
@property (nonatomic) NSString *militaryTime;
@property (nonatomic) NSString *currentHour;
@property (nonatomic) NSString *currentDate;
@property (nonatomic) NSString *currentTime;
@property (nonatomic) NSString *currentDay;
@property (strong, nonatomic) NSMutableArray *imageNames;
@property (strong, nonatomic)   NSString *myAddress;
@property (nonatomic) BOOL textInvisible;
@property (nonatomic) BOOL displayShown;
@property (nonatomic) BOOL isWeeHours;
@property (nonatomic) BOOL isMidday;
@property (nonatomic) BOOL middayDataIssue;
@property (nonatomic) BOOL dataNil;
@property (nonatomic) BOOL getNewData;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *uvTimer;
@property (strong, nonatomic) NSTimer *messageTimer;
@property (strong, nonatomic) NSNumber *background;
@property (strong, nonatomic) NSMutableArray *hourlyStringValues;
@property (strong, nonatomic) NSMutableArray *hourlyNumberValues;
-(void)uvIndexRating;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
@end

