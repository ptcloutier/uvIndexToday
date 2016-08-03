//
//  ViewController.m
//  UV APP
//
//  Created by Clyfford Millet on 7/15/16.
//  Copyright © 2016 Clyff IOS supercompany. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "UVAPP-Bridging-Header.h"



@interface ViewController ()

@end

@implementation ViewController


// To do list:
//app icons
 //start apple submission process
//uvlabel w x h 275:373
//constraints fr stack view height to bckgrd height 6:10


- (void)viewWillAppear:(BOOL)animated{
    [self loadFromPList];
    if ( self.getNewData == TRUE){
        [self doFetchCurrentLocation];
        [self getCurrentDateAndTime];
        [self didGetUVData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //configure views and properties
    [self fadeOut];
    [self fadeIn];
    self.displayShown = FALSE;
    self.isWeeHours = FALSE;
    self.getNewData = FALSE;
    self.dataNil = TRUE;
    
    self.uvLabel.text = [NSString stringWithFormat:@"UV" ];
    self.label2.text = @"INDEX";//self.currentTime;
    self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
    
    self.uvLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.uvLabel.font = [UIFont systemFontOfSize:250 weight:UIFontWeightUltraLight];
    
//    self.label2.text = @"INDEX" ;
//    self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
//    self.label2.font = [UIFont systemFontOfSize:50 weight:UIFontWeightLight];
    

    
    //display uv index upon opening app
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(didGetUVData) userInfo:nil repeats:NO];
    
    //start background animation
//    self.backgroundView.image = [UIImage imageNamed:@"sun7.jpg"];
    [self loadImages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeBackgroundImage) userInfo:nil repeats:YES];
    
    // check if time is between midnight and 6 am , if it is, display UV Index = 0, don't make API call
    [self weeHours];
    //get location
    if (self.isWeeHours == FALSE){ //if false, it's later than 6 am & before midnight, get time, location and call API
    self.locationManager = [[CLLocationManager alloc] init]; // calls getData
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self doFetchCurrentLocation];
    }
    // get time
    [self getCurrentDateAndTime];
    //initialize gesture recognizers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer * swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];

   
}

-(void)configureLabel:(NSString *)text andFont:(UIFont *)font andNumberOfLines:(int)topNumberOfLines
{
    
}


 // execute this method to start fetching location
-(void)doFetchCurrentLocation {
    // fetching current location start from here
    self.locationFetchCounter = 0;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    // this delegate method is constantly invoked every some miliseconds.
    // we only need to receive the first response, so we skip the others.
    if (self.locationFetchCounter > 0) return;
    self.locationFetchCounter++;
    // after we have current coordinates, we use this method to fetch the information data of fetched coordinate
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
        // stopping locationManager from fetching again
        [self.locationManager stopUpdatingLocation];
        [self getData];
    }];
 }

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}



- (void)reverseGeocodeLocation:(CLLocation *)location {
    //Set properties
    
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getCurrentDateAndTime {
    
    NSDate *militaryTime = [NSDate date]; // get 24 hour time
    NSDate *time = [NSDate date];   // for display time
    NSDate *dateAndTime = [NSDate date]; // for API comparison
    NSDate *date = [NSDate date]; // for display date
    NSDate *day = [NSDate date]; // for display day of the week
    

    NSDateFormatter *militaryViewFormatter = [[NSDateFormatter alloc]init];
    [militaryViewFormatter setTimeStyle:(NSDateFormatterMediumStyle)];
    NSDateFormatter *timeViewFormatter = [[NSDateFormatter alloc]init];
    [timeViewFormatter setTimeStyle:(NSDateFormatterMediumStyle)];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *militaryViewFormat = @"kk";
    [militaryViewFormatter setDateFormat:militaryViewFormat];
    NSString *timeViewFormat = @"h:mm a";
    [timeViewFormatter setDateFormat:timeViewFormat];
    NSString *dateFormat = @"LLL/dd/yyyy hh a";
    [timeFormatter setDateFormat:dateFormat];
    NSString *dateForView = @"LLLL d";
    [dateFormatter setDateFormat:dateForView];
    NSString *dayForView = @"EEEE";
    [dayFormatter setDateFormat:dayForView];

    
    self.militaryTime = [militaryViewFormatter stringFromDate:militaryTime];
    self.currentTime = [timeViewFormatter stringFromDate:time];
    self.currentHour = [timeFormatter stringFromDate:dateAndTime]; // for API
    self.currentDate = [dateFormatter stringFromDate:date]; // for date view
    self.currentDay = [dayFormatter stringFromDate:day];

}


-(void)weeHours
{
    NSDate *dateAndTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
     NSString *timeFormat= @"k";
    [dateFormatter setDateFormat:timeFormat];
    NSString *hour = [dateFormatter stringFromDate:dateAndTime];
    self.currentHourValue = [hour intValue];
    if ( self.currentHourValue < 7){
        self.uvIndex = @"0";
        self.isWeeHours = TRUE;
   }
}

-(void)midday
{
    self.militaryTimeValue = [self.militaryTime intValue];
    if((self.militaryTimeValue  > 9 ) && (self.militaryTimeValue  < 15)){ // need 24 hour value
        self.isMidday = TRUE;
    }
    else {
        self.isMidday = FALSE;
    }
}

-(void)middayDataCheck
{
    if ((self.isMidday == TRUE) && ([self.uvIndex isEqualToString:@"0"])){
        self.middayDataIssue = TRUE; // if it's midday and uvIndex reads 0 there is bad data, show hourly but also show "searching" for current uv index
    }
    else{
        self.middayDataIssue = FALSE;  
    }
    
}

-(void)getData { //Call EPA API
    
    self.hourlyNumberValues = [[NSMutableArray alloc]init];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/%@/JSON", self.zipcode]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"GET";
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error){

                NSTimeInterval duration = 0.5f;
                [UIView transitionWithView:self.label3
                                  duration:duration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.label3.text = error.localizedDescription;
                                    self.label3.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                                    self.label3.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
                                    
                                } completion:nil];
                [self startTimer];
    }
    else{
        if( data != nil){
            NSError *jsonError;
            NSArray *jsonToDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
             self.uvIndex = nil;
            for (NSDictionary *dicts in jsonToDictionary) {
                [self.hourlyNumberValues addObject:[dicts valueForKey:@"UV_VALUE"]];
                NSString *timeData = [dicts valueForKey:@"DATE_TIME"];
                NSLog(@"%@", timeData);
                NSLog(@"UVI : %@",[dicts valueForKey:@"UV_VALUE"] );
                if( [self.currentHour caseInsensitiveCompare:timeData] == NSOrderedSame ) {
                    // strings are equal except for possibly case
                    self.uvNumber = [dicts valueForKey:@"UV_VALUE"];
                    self.uvIndex = [self.uvNumber stringValue];
                }
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
      



    
-(void)setHourlyValues
{
    self.hourlyStringValues = [[NSMutableArray alloc]init];
    NSString *string;
    NSInteger numb = 0;
    for (NSNumber *hourNumber in self.hourlyNumberValues) {
        numb = [hourNumber integerValue];
        string = [NSString stringWithFormat:@"%ld",(long)numb];
        [self.hourlyStringValues addObject: string];
        
    }
    while ([self.hourlyStringValues count] > 15){
        [self.hourlyStringValues removeLastObject];
    }
//   
//    
//    for (int i = 0; i < self.hourlyStringValues.count;i++) {
//        UILabel * label = self.hourlyLabels[i];
//        label.text = self.hourlyStringValues[i];
//     }
   
}




-(void)saveToPList {
    
    NSMutableDictionary *dataForPlist = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (self.background != nil) {
        [dataForPlist setObject:self.background forKey:@"background"];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"settings.plist"];
    [dataForPlist writeToFile:filePath atomically:YES];
}

-(void)loadFromPList {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"settings.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSMutableDictionary *savedData =[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        
        if ([savedData objectForKey:@"background"] != nil) {
            self.background = [savedData objectForKey:@"background"];
        }
    }
}

-(void)fadeOut
{
    NSTimeInterval duration = 1.5f;
    [UIView transitionWithView:self.backgroundView
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.alpha = 0.0;
                    } completion:nil];
    
    NSTimeInterval bDuration = 1.9f;
    [UIView transitionWithView:self.backgroundView
                      duration:bDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.alpha = 1.0;
                    } completion:nil];
}


-(void)fadeIn
{
    NSTimeInterval duration = 1.9f;
    [UIView transitionWithView:self.backgroundView
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.alpha = 1.0;
                    } completion:nil];

}


-(void)loadImages
{
    if (self.imageNames == nil){
        self.imageNames = [[NSMutableArray alloc]init];
        for ( int i = 1; i <= 42; i++){
            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
            [self.imageNames addObject:image];
        }
        for ( int i = 41; i >0; i--){
            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
            [self.imageNames addObject:image];
        }
    }
    
}


-(void)changeBackgroundImage
{
    NSString *imageName;
    long imageNumber = 0;
        if (self.imageNames == nil){
            self.imageNames = [[NSMutableArray alloc]init];
            for ( int i = 1; i <= 42; i++){
                NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
                [self.imageNames addObject:image];
            }
            for ( int i = 41; i >0; i--){
                NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
                [self.imageNames addObject:image];
            }
        }
    if (( [self.background intValue] + 1) == [self.imageNames count]){
        imageNumber = 0;
        imageName = [self.imageNames objectAtIndex:imageNumber];
    }
    else if ( [self.background integerValue] >= 0){
        imageNumber = [self.background intValue] + 1;
        imageName = [self.imageNames objectAtIndex:imageNumber];
    }
    //             If you want to make a short sequence that stops
    //          if (( [self.background intValue] + 1) == [imageNames count]){
    //            [self.timer invalidate];
    //            self.timer = nil;
    //            imageNumber = [self.background intValue];
    //            imageName = [imageNames objectAtIndex:imageNumber];
    //            imageNumber = 0;
    //}
    self.backgroundView.image = [UIImage imageNamed:imageName];
    self.background = [NSNumber numberWithLong:imageNumber]; //plist archive
    [self saveToPList];
    //    NSLog(@"%lu %@", imageNumber, imageName);
}




-(void)handleGesture:(UIGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded ){
        
        if (self.displayShown == FALSE){
        [self didGetUVData];
        }
        else {
            [self showInfoViewController];
        }
    }
}
  

-(void)didGetUVData
{
    if( self.dataNil == TRUE){
        [self dataNilMessage];
    }
    else if (self.middayDataIssue == TRUE){
        [self middayCase];
    }
    else {
        [self displayUVData];
    }
}



-(void)startTimer
{
    if (!self.uvTimer){
        self.uvTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(doFetchCurrentLocation) userInfo:nil repeats:YES];
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didGetUVData) userInfo:nil repeats:YES];
        self.displayShown = TRUE;
    }
}
-(void)stopTimerIfTimer
{
    if(self.uvTimer){
        [self.uvTimer invalidate];
        [self.messageTimer invalidate];
        self.dataNil = FALSE;
    }
}

//if error error object .localized description  
-(void)dataNilMessage
{
//    NSTimeInterval duration = 0.5f;
//    [UIView transitionWithView:self.label2
//                      duration:duration
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        self.label2.text = @"SEARCHING...";
//                        self.label2.font = [UIFont systemFontOfSize:49 weight:UIFontWeightLight];
//                        
//                    } completion:nil];
    [self startTimer];
}



-(void)middayCase
{
    [self stopTimerIfTimer];
    
        NSTimeInterval duration = 0.5f;
    
//    [UIView transitionWithView:self.label2
//                      duration:duration
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        self.label2.text = @"SEARCHING...";
//                        self.label2.font = [UIFont systemFontOfSize:49 weight:UIFontWeightLight];
//                        
//                    } completion:nil];
 
//    [UIView transitionWithView:self.label3
//                      duration:duration
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        self.label3.text =  self.currentTime;
//                        self.label3.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
//                        self.label3.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
//                    } completion:nil];
    
    [UIView transitionWithView:self.label4
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label4.text = self.currentTime;//self.currentDay;
                        self.label4.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label4.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
    
    [UIView transitionWithView:self.label5
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label5.text = self.currentDate; //date;
                        self.label5.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label5.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
    
     [UIView transitionWithView:self.label6
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label6.text = self.city;
                        self.label6.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label6.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
   
    [UIView transitionWithView:self.uvLabel
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.uvLabel.text = @"UV";
                    } completion:nil];
    
    [UIView transitionWithView:self.label2
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label2.text = @"INDEX";//self.currentTime;
                        self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
                    } completion:nil];

    self.displayShown = TRUE;
    

}

-(void)displayUVData
{
    
    [self stopTimerIfTimer];
    
    NSTimeInterval duration = 0.5f;
    
    [UIView transitionWithView:self.uvLabel
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.uvLabel.text = @"UV";
                         } completion:nil];
                        
    [UIView transitionWithView:self.label2
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label2.text = @"INDEX";//self.currentTime;
                        self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];

                    } completion:nil];
    
    [UIView transitionWithView:self.label4
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label4.text =  self.currentTime;//self.currentDay;
                        self.label4.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label4.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
    
    [UIView transitionWithView:self.label5
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label5.text = self.currentDate; //date;
                        self.label5.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label5.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
    
    [UIView transitionWithView:self.label6
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label6.text = self.city;
                        self.label6.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label6.font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
                    } completion:nil];
    
    
    
//    [UIView transitionWithView:self.label3
//                      duration:duration
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        self.label3.text = @"UV INDEX";
//                        self.label3.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
//                         self.label3.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
//                        
//                    } completion:nil];
   [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showUVIndexRating) userInfo:nil repeats:NO];
    
    self.displayShown = TRUE;
}


-(void)uvIndexRating
{
    if ([self.uvNumber intValue] < 3){
       self.uvRating = @"Low";
    }
    else if (([self.uvNumber intValue] >=3) && ([self.uvNumber intValue] < 6 )){
        self.uvRating = @"Moderate";
    }
    else if (([self.uvNumber intValue] > 5 ) && ([self.uvNumber intValue] < 8 )){
            self.uvRating = @"High";
    }
    else if (([self.uvNumber intValue] > 7 ) && ([self.uvNumber intValue] < 11 )){
        self.uvRating = @"Very High";
    }
    else if ([self.uvNumber intValue] >= 11 ){
        self.uvRating = @"Very High";
        
    }
}




-(void)showUVIndexRating
{
    [self uvIndexRating];
    
    NSTimeInterval duration = 0.5f;

    [UIView transitionWithView:self.uvLabel
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.uvLabel.text = self.uvIndex;
                        
                    } completion:nil];
    
    [UIView transitionWithView:self.label2
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label2.text = self.uvRating;//self.currentTime;
                        self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];

                    } completion:nil];
    
[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayUVData) userInfo:nil repeats:NO];
    
    
}

-(void)showInfoViewController
{
    InformationViewController *informationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"informationViewController"];
    
    self.getNewData = TRUE; // refresh data when second view controller is dismissed 
    
    if (self.dataNil == TRUE){
        informationViewController.passedDataNil = TRUE;
        //                informationViewController.passedDisplayNumber =
        [self presentViewController:informationViewController animated:YES completion:nil];
        
    }
    else {
        informationViewController.passedHourlyStringValues = self.hourlyStringValues;
        informationViewController.passedCity = [NSString stringWithFormat:@"%@",[self.city uppercaseString]];
        informationViewController.passedDate = [NSString stringWithFormat:@"%@",[self.currentDate uppercaseString]];
        informationViewController.passedUvIndex = self.uvIndex;
        [self presentViewController:informationViewController animated:YES completion:nil];
        
    }
}
             






@end
