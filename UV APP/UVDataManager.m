//
//  UVDataManager.m
//  UVAPP
//
//  Created by perrin cloutier on 2/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

#import "UVDataManager.h"

@interface UVDataManager ()

@end
@implementation UVDataManager

+ (instancetype)sharedManager {
    
    static id dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[self alloc]init];
        NSLog(@"*** once ***");
    });
    return dataManager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        _locationManager = [[CLLocationManager alloc]init];
    }
    return self;
}

//- (void)startDataTimer {
//    self.dataTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(didGetUVData) userInfo:nil repeats:NO];
//}

- (void)setBooleans {
//    self.displayShown = false;
    self.isEarlyMorning = false;
    self.doReloadData = false;
    self.dataNil = true;
}

- (void)getLocation {
    self.locationManager = [[CLLocationManager alloc] init]; // calls getData
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self doFetchCurrentLocation];
}

-(void)doFetchCurrentLocation {
    self.locationFetchCounter = 0;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *>*)locations {
    if (self.locationFetchCounter > 0) return;
    self.locationFetchCounter++;
    // get zip code from location coordinates
    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        NSString *street = placemark.thoroughfare;
        self.city = placemark.locality;
        self.zipcode = placemark.postalCode;
        NSString *country = placemark.country;
        self.latitude = [NSString stringWithFormat:@"%.0f", self.location.coordinate.latitude];
        self.longitude = [NSString stringWithFormat:@"%.0f", self.location.coordinate.longitude];
        NSLog(@"Latitude : %@", self.latitude);
        NSLog(@"Longitude : %@", self.longitude);
        NSLog(@"Street is %@", street);
        NSLog(@"City of %@", self.city);
        NSLog(@"Country of %@", country);
        NSLog(@"Zipcode : %@", self.zipcode);
        [self.locationManager stopUpdatingLocation];
        [self getData];
        NSLog(@"***** get data ****");
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}

- (void)reverseGeocodeLocation:(CLLocation *)location {
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            for(CLPlacemark *p in placemarks)
            {
                self.zipcode = p.postalCode;
            }
        }
    }];
}

#pragma mark - Time

-(void)getTimeProperties {
    self.currentTime = [self getTimeDayOrDate: @"h:mm a"];
    self.militaryTime = [self getTimeDayOrDate:@"kk"];
    self.currentDay = [self getTimeDayOrDate:@"EEEE"];
    self.currentDate = [self getTimeDayOrDate:@"LLLL d"];
    // for API request comparison
    self.currentHour = [self getTimeDayOrDate:@"LLL/dd/yyyy hh a"];
}

- (NSString *)getTimeDayOrDate:(NSString *)dateFormat {
    NSDate *timeDayOrDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:timeDayOrDate];
}

-(void)earlyMorning {
    NSString *hour = [self getTimeDayOrDate:@"k"];
    self.currentHourValue = [hour intValue];
    if ((self.currentHourValue < 7)|| (self.currentHourValue == 24)){
        self.uvIndex = @"0";
        self.isEarlyMorning = TRUE;
    }
}

-(void)midday {
    self.militaryTimeValue = [self.militaryTime intValue];
    if((self.militaryTimeValue  > 9 ) && (self.militaryTimeValue  < 15)){ // need 24 hour value
        self.isMidday = TRUE;
    }
    else {
        self.isMidday = FALSE;
    }
}

-(void)middayDataCheck {
    if ((self.isMidday == TRUE) && ([self.uvIndex isEqualToString:@"0"])){
        self.middayDataIssue = TRUE; // if it's midday and uvIndex reads 0 there is bad data, show hourly but also show "searching" for current uv index
    }
    else{
        self.middayDataIssue = FALSE;
    }
}

#pragma mark - Data

-(void)getData {
    self.hourlyNumberValues = [[NSMutableArray alloc]init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/%@/JSON", self.zipcode]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"GET";
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error){
            [self handleDataError:error.localizedDescription];
        }else{
            if(data != nil){
                NSError *jsonError;
                NSArray *jsonToDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                self.uvIndex = nil;
                for (NSDictionary *dicts in jsonToDictionary) {
                    [self.hourlyNumberValues addObject:[dicts valueForKey:@"UV_VALUE"]];
                    NSString *timeData = [dicts valueForKey:@"DATE_TIME"];
                    NSLog(@"%@", timeData);
                    NSLog(@"UVI : %@",[dicts valueForKey:@"UV_VALUE"] );
                    if([self.currentHour caseInsensitiveCompare:timeData] == NSOrderedSame) {
                        // strings are equal except for possibly case
                        self.uvNumber = [dicts valueForKey:@"UV_VALUE"];
                        self.uvIndex = [self.uvNumber stringValue];
                    }
                    self.dataNil = FALSE;
                }
                [self setHourlyValues];
                self.dataNil = FALSE;
                [self midday];
                [self middayDataCheck];
            }
            else{
                self.dataNil = TRUE;
            }
        }
    }]
     resume];
}

- (void)handleDataError:(NSString *)errorDescription {
    self.dataRequestError = true;
    self.errorDescription = errorDescription;
//    [self startTimer];
}

- (void)setHourlyValues {
    self.hourlyStringValues = [[NSMutableArray alloc]init];
    NSString *string;
    NSInteger num = 0;
    for (NSNumber *hourNumber in self.hourlyNumberValues) {
        num = [hourNumber integerValue];
        string = [NSString stringWithFormat:@"%ld",(long)num];
        [self.hourlyStringValues addObject: string];
        
    }
    while ([self.hourlyStringValues count] > 15){
        [self.hourlyStringValues removeLastObject];
    }
}

//- (void)didGetUVData {
//    if( self.dataNil == TRUE){
//        [self dataNilMessage];
//    }
//    else{
//        [self displayUVData];
//    }
//}

//- (void)isplayUVDataTimer {
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayUVData) userInfo:nil repeats:NO];
//}

//-(void)startTimer {
//    if (!self.uvTimer){
//        self.uvTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doFetchCurrentLocation) userInfo:nil repeats:YES];
//        
//        self.displayShown = TRUE;
//    }
//}

//-(void)stopTimerIfTimer {
//    if(self.uvTimer){
//        [self.uvTimer invalidate];
//        [self.messageTimer invalidate];
//        self.dataNil = FALSE;
//    }
//}

//- (void)displayUVData {
//    [self stopTimerIfTimer];
//    [self createLabels];
//    if (self.middayDataIssue == false){
//        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showUVIndexRating) userInfo:nil repeats:NO];
//    }
//    self.displayShown = true;
//}


@end
