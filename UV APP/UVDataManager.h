//
//  UVDataManager.h
//  UVAPP
//
//  Created by perrin cloutier on 2/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UVDataManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSNumber *uvNumber;
@property (nonatomic, strong) NSString *uvRating;
@property (nonatomic, strong) NSNumber *hourlyNumber;
@property (nonatomic, strong) NSString *uvIndex;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSString *city;
//@property (nonatomic) UIColor *color;
@property (nonatomic) int timeIntFromAPI;
@property (nonatomic) int militaryTimeValue;
@property (nonatomic) int currentHourValue;
@property (nonatomic) NSString *militaryTime;
@property (nonatomic) NSString *currentHour;
@property (strong, nonatomic) NSMutableArray *hourlyStringValues;
@property (strong, nonatomic) NSMutableArray *hourlyNumberValues;
@property (nonatomic) NSString *currentDate;
@property (nonatomic) NSString *currentTime;
@property (nonatomic) NSString *currentDay;
@property (strong, nonatomic) NSMutableArray *imageNames;
@property (strong, nonatomic)   NSString *myAddress;
@property (strong, nonatomic) NSTimer *dataTimer;
@property (strong, nonatomic) NSTimer *uvTimer;
@property (strong, nonatomic) NSTimer *messageTimer;
//@property (nonatomic) BOOL displayShown;
@property (nonatomic) BOOL textInvisible;
@property (nonatomic) BOOL isEarlyMorning;
@property (nonatomic) BOOL isMidday;
@property (nonatomic) BOOL middayDataIssue;
@property (nonatomic) BOOL doReloadData;
@property (nonatomic) BOOL dataRequestError;
@property (nonatomic) NSString *errorDescription;
@property (nonatomic) BOOL dataNil;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) int locationFetchCounter;
@property (strong, nonatomic) CLGeocoder *geocoder;
//- (void)startDataTimer;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
- (void)doFetchCurrentLocation;
+ (instancetype)sharedManager;
- (void)setBooleans;
- (void)earlyMorning;
- (void)getLocation;
- (void)getTimeProperties;
//- (void)stopTimerIfTimer;
//- (void)startTimer;


@end
