//
//  ViewController.m
//  UV APP
//
//  Created by perrin cloutier on 7/15/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fadeOut];
    [self fadeIn];
    self.displayShown = FALSE;
    self.isWeeHours = FALSE;
    self.getNewData = FALSE;
    self.dataNil = TRUE;
    self.label2.text = @"I  N  D  E  X";//self.currentTime;
    self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
    self.uvLabel.text = [NSString stringWithFormat:@"UV" ];
    self.uvLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.uvLabel.font = [UIFont systemFontOfSize:250 weight:UIFontWeightUltraLight];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(didGetUVData) userInfo:nil repeats:NO];
    [self loadImages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeBackgroundImage) userInfo:nil repeats:YES];
    // check if time is between midnight and 6 am , if it is, display UV Index = 0, don't make API call
    [self weeHours];
    self.locationManager = [[CLLocationManager alloc] init]; // calls getData
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    [self doFetchCurrentLocation];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFromPList];
    if ( self.getNewData == TRUE){
        [self doFetchCurrentLocation];
        [self getCurrentDateAndTime];
    }
}

-(void)doFetchCurrentLocation
{
    // execute this method to start fetching location
     self.locationFetchCounter = 0;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];// startUpdatingLocation
}

#pragma mark - Location

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

- (void)reverseGeocodeLocation:(CLLocation *)location
{
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

-(void)getCurrentDateAndTime
{
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
    if ((self.currentHourValue < 7)|| (self.currentHourValue == 24)){
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

#pragma mark - Data

-(void)getData
{
    self.hourlyNumberValues = [[NSMutableArray alloc]init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/%@/JSON", self.zipcode]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"GET";
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error){
            self.label3.text = error.localizedDescription;
            self.label3.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
            self.label3.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
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

- (void)setHourlyValues
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
}

-(void)saveToPList
{
    NSMutableDictionary *dataForPlist = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (self.background != nil) {
        [dataForPlist setObject:self.background forKey:@"background"];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"settings.plist"];
    [dataForPlist writeToFile:filePath atomically:YES];
}

-(void)loadFromPList
{
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

- (void)didGetUVData
{
    if( self.dataNil == TRUE){
        [self dataNilMessage];
    }
    else{
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

-(void)dataNilMessage
{
    [self startTimer];
}

-(void)uvIndexRating
{
    if ([self.uvNumber intValue] < 3){
        self.uvRating = @"L o w";
    }
    else if (([self.uvNumber intValue] >=3) && ([self.uvNumber intValue] < 6 )){
        self.uvRating = @"M o d e r a t e";
    }
    else if (([self.uvNumber intValue] > 5 ) && ([self.uvNumber intValue] < 8 )){
        self.uvRating = @"H i g h";
    }
    else if ([self.uvNumber intValue] > 7 ){
        self.uvRating = @"V e r y  H i g h";
    }
}


#pragma mark - User Interface

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
    NSString *imageName = @"sun1.jpg";
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
    self.backgroundView.image = [UIImage imageNamed:imageName];
    self.background = [NSNumber numberWithLong:imageNumber]; //plist archive
    [self saveToPList];
}

- (void)createLabels
{
    UIFont *font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
    [self setLabels:self.uvLabel withText:@"UV" withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:[UIFont systemFontOfSize:250 weight:UIFontWeightUltraLight]];
    [self setLabels:self.label2 withText:@"I  N  D  E  X" withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:[UIFont systemFontOfSize:40 weight:UIFontWeightLight]];
//    [self setLabels:self.label3 withText: @"" withTextColor:[UIColor clearColor] andFont:font];
    [self setLabels:self.label4 withText:self.currentTime withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
    [self setLabels:self.label5 withText:self.currentDate withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
    [self setLabels:self.label6 withText:self.city withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
}

- (void)setLabels:(UILabel *)label withText:(NSString *)text withTextColor:(UIColor *)textColor andFont:(UIFont *)font
{
    NSTimeInterval duration = 0.4f;
    [UIView transitionWithView:label
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if(text){
                        label.text = text;
                        }
                        if(textColor){
                        label.textColor = textColor;
                        }
                        if(font){
                        label.font = font;
                        }
                    }
                    completion:nil];
}

- (void)displayUVData
{
    [self stopTimerIfTimer];
    [self createLabels];
    if (self.middayDataIssue == false){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showUVIndexRating) userInfo:nil repeats:NO];
    }
    self.displayShown = TRUE;
}

-(void)showUVIndexRating
{
    if( self.isWeeHours ==TRUE){
        self.uvIndex = @"0";
    }
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

#pragma mark - User Interaction

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


#pragma mark - Navigation

-(void)showInfoViewController
{
    InformationViewController *informationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"informationViewController"];
    self.getNewData = TRUE; // refresh data when second view controller is dismissed
    if (self.dataNil == TRUE){
        informationViewController.passedDataNil = TRUE;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
