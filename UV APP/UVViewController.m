//
//  UVViewController.m
//  UV Index Today
//
//  Created by perrin cloutier on 7/15/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import "UVViewController.h"
#import "UVConstants.h"
#import "UVDataManager.h"

@interface UVViewController ()

@property (nonatomic) UVDataManager *dataManager;

@end

@implementation UVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UVDataManager *dataManager = [UVDataManager sharedManager];
    self.dataManager = dataManager;
    [self fadeAnimation];
    [self setTopLabels];
    self.displayShown = false;
    [self.dataManager setBooleans];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(didGetUVData) userInfo:nil repeats:NO];
    [self loadImages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeBackgroundImage) userInfo:nil repeats:YES];
    // check if time is between midnight and 6 am , if it is, display UV Index = 0, don't make API call
    [self.dataManager earlyMorning];
    [self.dataManager getLocation];
    [self.dataManager getTimeProperties];
    [self initializeGestureRecognizers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFromPList];
    if (self.dataManager.doReloadData == true){
        [self.dataManager doFetchCurrentLocation];
        [self.dataManager getTimeProperties];
    }
}

#pragma mark - Animations

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

-(void)fadeAnimation {
    [self fadeOut];
    [self fadeIn];
}

- (void)fadeIn {
    NSTimeInterval duration = 1.9f;
    [UIView transitionWithView:self.backgroundView
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.alpha = 1.0;
                    } completion:nil];
}

- (void)fadeOut {
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

- (void)loadImages {
    if (self.imageNames == nil){
        self.imageNames = [[NSMutableArray alloc]init];
        for ( int i = 1; i <= kAnimationCellCount; i++){
            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
            [self.imageNames addObject:image];
        }
        for ( int i = kAnimationCellCount-1; i >0; i--){
            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
            [self.imageNames addObject:image];
        }
    }
}

-(void)changeBackgroundImage {
    NSString *imageName = @"sun1.jpg";
    long imageNumber = 0;
        if (self.imageNames == nil){
            self.imageNames = [[NSMutableArray alloc]init];
            for ( int i = 1; i <= kAnimationCellCount; i++){
                NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
                [self.imageNames addObject:image];
            }
            for ( int i = kAnimationCellCount-1; i >0; i--){
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

#pragma mark - Display

- (void)setTopLabels {
    self.label2.text = @"I  N  D  E  X";
    self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
    self.uvLabel.text = [NSString stringWithFormat:@"UV" ];
    self.uvLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.uvLabel.font = [UIFont systemFontOfSize:250 weight:UIFontWeightUltraLight];
}

- (void)createLabels {
    UIFont *font = [UIFont systemFontOfSize:35 weight:UIFontWeightLight];
//    [self setLabels:self.uvLabel withText:@"UV" withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:[UIFont systemFontOfSize:250 weight:UIFontWeightUltraLight]];
//    [self setLabels:self.label2 withText:@"I  N  D  E  X" withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:[UIFont systemFontOfSize:40 weight:UIFontWeightLight]];
//    [self setLabels:self.label3 withText: @"" withTextColor:[UIColor clearColor] andFont:font];
    [self setLabels:self.label4 withText:self.dataManager.currentTime withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
    [self setLabels:self.label5 withText:self.dataManager.currentDate withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
    [self setLabels:self.label6 withText:self.dataManager.city withTextColor:[UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0] andFont:font];
}

- (void)setLabels:(UILabel *)label withText:(NSString *)text withTextColor:(UIColor *)textColor andFont:(UIFont *)font {
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

- (void)displayUVData {
    [self stopTimerIfTimer];
    [self createLabels];
    if (self.dataManager.middayDataIssue == false){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showUVIndexRating) userInfo:nil repeats:NO];
    }
    self.displayShown = true;
}

-(void)showUVIndexRating {
    if( self.dataManager.isEarlyMorning == true){
        self.dataManager.uvIndex = @"0";
    }
    [self uvIndexRating];
    NSTimeInterval duration = 0.5f;
    [UIView transitionWithView:self.uvLabel
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.uvLabel.text = self.dataManager.uvIndex;
                    } completion:nil];
    [UIView transitionWithView:self.label2
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label2.text = self.uvRating;//self.currentTime;
                        self.label2.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
                        self.label2.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
                    } completion:nil];
    [self displayUVData];
}

- (void)didGetUVData {
    if(self.dataManager.dataNil == true){
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didGetUVData) userInfo:nil repeats:YES];
    }else{
        [self displayUVData];
    }
}

-(void)stopTimerIfTimer {
    if(self.messageTimer){
        [self.messageTimer invalidate];
    }
}

- (void)handleDataRequestError:(NSString *)errorDescription{
    self.label3.text = self.dataManager.errorDescription;
    self.label3.textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.label3.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
}

-(void)uvIndexRating {
    if ([self.dataManager.uvNumber intValue] < 3){
        self.uvRating = @"L o w";
    }
    else if (([self.dataManager.uvNumber intValue] >=3) && ([self.dataManager.uvNumber intValue] < 6 )){
        self.uvRating = @"M o d e r a t e";
    }
    else if (([self.dataManager.uvNumber intValue] > 5 ) && ([self.dataManager.uvNumber intValue] < 8 )){
        self.uvRating = @"H i g h";
    }
    else if ([self.dataManager.uvNumber intValue] > 7 ){
        self.uvRating = @"V e r y  H i g h";
    }
}


#pragma mark - Gestures

- (void)initializeGestureRecognizers {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ){
        
        if (self.displayShown == FALSE){
            [self didGetUVData];
        }
        else {
            [self showUVInformationViewController];
        }
    }
}

#pragma mark - Navigation

-(void)showUVInformationViewController {
    UVInformationViewController *uviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"uvInformationViewController"];
    self.dataManager.doReloadData = true; // refresh data when second view controller is dismissed
    [self presentViewController:uviViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
