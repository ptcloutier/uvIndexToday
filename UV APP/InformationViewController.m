//
//  InformationViewController.m
//  UVAPP
//
//  Created by perrin cloutier on 7/23/16.
//  Copyright © 2016 Clyff IOS supercompany. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()

@end

@implementation InformationViewController


- (void)viewWillAppear:(BOOL)animated{
    
    [self loadFromPList];
     [self fadeOut];
     [self fadeIn];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //set values for hourly
    self.dataNil = self.passedDataNil;
    if(self.dataNil == 0){
        self.hourlyStringValues = self.passedHourlyStringValues;
        self.uvIndex = self.passedUvIndex;
        self.city = self.passedCity;
        self.date = self.passedDate;
    }
    else {
        self.hourlyStringValues = [NSMutableArray arrayWithObjects: @"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-",@"-", nil];
        self.uvIndex = @"-" ;
        self.city = @"-" ;
        self.date = @"-" ;
    }
    //configure labels
    UIColor *textColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.label1.textColor = textColor;
    
    self.label2.textColor = textColor;
    self.label3.textColor = textColor;
    self.label4.textColor = textColor;
    self.label5.textColor = textColor;
    self.label6.textColor = textColor;
    
    self.dotColor = [UIColor colorWithRed:35.0/255.0 green:52.0/255.0 blue:68.0/255.0 alpha:0.3];
    self.highlightColor = [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:0.7];
    //[UIColor colorWithRed:182.0/255.0 green:52.0/255.0 blue:68.0/255.0 alpha:1.0];
    // [UIColor colorWithRed:255.0/255.0 green:239.0/255.0 blue:226.0/255.0 alpha:0.7];
    
    self.dot1.backgroundColor = self.dotColor;
    self.dot2.backgroundColor = self.dotColor;
    self.dot3.backgroundColor = self.dotColor;
    self.dot4.backgroundColor = self.dotColor;
    self.dot5.backgroundColor = self.dotColor;
    self.dot6.backgroundColor = self.dotColor;
    self.dot7.backgroundColor = self.dotColor;
    self.dot8.backgroundColor = self.dotColor;

    self.displayNumber = 0;
    [self changeDisplay];
    //start background animation
//    self.backgroundView.image = [UIImage imageNamed:@"sun7.jpg"];
    
    
    [self loadImages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeBackgroundImage) userInfo:nil repeats:YES];
  
    //initialize gesture recognizers
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer * swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDownGesture:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
    
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



-(void)handleSwipeRightGesture:(UIGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded ){
        self.displayNumber--;
        if (self.displayNumber < 0){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ((self.dataNil == TRUE) && (self.displayNumber == 3)){
            self.displayNumber = 2;
            [self changeDisplay];
        }
        else {
        [self changeDisplay];
        }
    }
}

-(void)handleSwipeLeftGesture:(UIGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded ){
        
        self.displayNumber++;
        if ((self.dataNil == TRUE) && (self.displayNumber == 3)){
            self.displayNumber = 4;
            [self changeDisplay];
        }
        else if(self.displayNumber == 7){
            [self changeDisplay];
            self.displayNumber = 0;
        }
        else{
            [self changeDisplay];
        }
    }
}

-(void)handleSwipeDownGesture:(UIGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateEnded ){
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

-(void)changeDisplay
{
switch (self.displayNumber) {
    
    case 0:
        [self configureTopLabel1:@"Hourly UV Index" andFontSize:30 andNumberOfLines:1 label2:[NSString stringWithFormat:@"7 am\t\t%@\n8 am\t\t%@\n9 am\t\t%@",self.hourlyStringValues[0],self.hourlyStringValues[1],self.hourlyStringValues[2]] label3: [NSString stringWithFormat:@"10 am\t\t%@\n11 am\t\t%@\n12 pm\t\t%@",self.hourlyStringValues[3],self.hourlyStringValues[4],self.hourlyStringValues[5]]label4:[NSString stringWithFormat:@"1 pm\t\t%@\n2 pm\t\t%@\n3 pm\t\t%@",self.hourlyStringValues[6],self.hourlyStringValues[7],self.hourlyStringValues[8]] label5:[NSString stringWithFormat:@"4 pm\t\t%@\n5 pm\t\t%@\n6 pm\t\t%@",self.hourlyStringValues[9],self.hourlyStringValues[10],self.hourlyStringValues[11]] label6:[NSString stringWithFormat:@"7 pm\t\t%@\n8 pm\t\t%@\n9 pm\t\t%@",self.hourlyStringValues[12],self.hourlyStringValues[13],self.hourlyStringValues[14]] andFontSize:20 andNumberOfLines:3];
        [self highlightDot];
        break;
    case 1:
         [self configureTopLabel1:@"UV Index Range" andFontSize:30 andNumberOfLines:1 label2:@"0 to 2" label3:@"3 to 5" label4:@" 6 to 7" label5:@"8 to 10" label6:@"11 +" andFontSize:25 andNumberOfLines:1];
        
        [self highlightDot];
        break;
    case 2:
        [self configureTopLabel1:@"Danger Category" andFontSize:30 andNumberOfLines:1 label2:@"Low" label3:@"Moderate" label4:@"High" label5:@"Very high" label6:@"Extreme" andFontSize:25 andNumberOfLines:1];
        
        [self highlightDot];
        break;
    case 3:
        [self configureTopLabel1:@"Sun burn time" andFontSize:30 andNumberOfLines:1 label2:@"1 hour + " label3:@"40 minutes" label4:@"30 minutes" label5:@"20 minutes" label6:@"Less than 15 minutes" andFontSize:25 andNumberOfLines:1];
        [self highlightDot];
        break;
    case 4:
        [self configureTopLabel1:@"Recommended\nsun protection" andFontSize:25 andNumberOfLines:2 label2: @" No danger to the average\nperson. Wear a hat and\nsunglasses on bright days." label3:@" Wear a hat, sunglasses and\nuse SPF 15+ sunscreen. Seek\nshade during midday hours." label4:@" Apply SPF 30+ sunscreen\nevery 2 hours. Wear a hat,\nsunglasses and protective clothing." label5:@" Take extra precautions.\nUnprotected skin can burn\nquickly. Seek shade if outdoors." label6:@" Take all precautions, unprotected\nskin can burn in minutes.\nIt is advised to stay indoors." andFontSize:20 andNumberOfLines:4];
        [self highlightDot];
        break;
    case 5:
        [self configureTopLabel1:@"  UV Index is a forecast of the\namount of UV radiation expected\nto reach the Earth's surface." andFontSize:20 andNumberOfLines:4 label2:@" UVI usually ranges\nfrom 0 (at night)\nto 11 or 12." label3:@" It can be even higher in\nthe tropics or at high\nelevations under clear skies." label4:@" The peak daily ultraviolet\nradiation level\nchanges over the year."  label5:@" The strongest being at the\nSummer solstice on June 21st." label6:@" The weakest at the Winter\nsolstice on December 21st."andFontSize:20 andNumberOfLines:4];
        [self highlightDot];
        break;
        
    case 6:
        [self configureTopLabel1:@"The amount of UV radiation\nreaching the surface is primarily\nrelated to three factors." andFontSize:20 andNumberOfLines:4 label2:@"The elevation of the sun,\nthe cloud cover and\nthe ozone in the stratosphere." label3:@"Thick cloud cover can greatly reduce ultraviolet radiation levels. " label4:@"There are types of thin\ncloud cover that can magnify\nthe ultraviolet radiation strength." label5:@"Even on cloudy days\napply sunscreen, and reapply\nafter swimming or sweating." label6: @"Watch out for bright surfaces\nlike sand, water, and snow\nwhich reflect UV radiation."andFontSize:20 andNumberOfLines:4];
        [self highlightDot];
        break;
    case 7:
        [self dismissViewControllerAnimated:YES completion:nil];
        [self highlightDot];
        break;
    default:
        break;
    }
}

 -(void)highlightDot
{
    // grab value of self.displayNumber and use it to highlight the dot corresponding
    
    switch (self.displayNumber) {
            
        case 0:
            self.dot1.backgroundColor = self.highlightColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;
//
            break;
            
        case 1:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.highlightColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
        case 2:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.highlightColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
        case 3:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.highlightColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
        case 4:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.highlightColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
        case 5:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.highlightColor;
            self.dot7.backgroundColor = self.dotColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
        case 6:
            self.dot1.backgroundColor = self.dotColor;
            self.dot2.backgroundColor = self.dotColor;
            self.dot3.backgroundColor = self.dotColor;
            self.dot4.backgroundColor = self.dotColor;
            self.dot5.backgroundColor = self.dotColor;
            self.dot6.backgroundColor = self.dotColor;
            self.dot7.backgroundColor = self.highlightColor;
            self.dot8.backgroundColor = self.dotColor;

            break;
            
//        case 7:
//            self.dot1.backgroundColor = self.dotColor;
//            self.dot2.backgroundColor = self.dotColor;
//            self.dot3.backgroundColor = self.dotColor;
//            self.dot4.backgroundColor = self.dotColor;
//            self.dot5.backgroundColor = self.dotColor;
//            self.dot6.backgroundColor = self.dotColor;
//            self.dot7.backgroundColor = self.dotColor;
//            self.dot8.backgroundColor = self.highlightColor;
//            break;
//            
            
        default:
            break;
    }
    
    
    
    
    
}

-(void)configureTopLabel1:(NSString *)text1 andFontSize:(int)topFontsize andNumberOfLines:(int)topNumberOfLines label2:(NSString *)text2 label3:(NSString *)text3 label4:(NSString *)text4 label5:(NSString *)text5 label6:(NSString *)text6 andFontSize:(int)fontsize andNumberOfLines:(int)numberOfLines
{
    
    NSTimeInterval duration = 0.2f;
    [UIView transitionWithView:self.label1
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label1.text = text1;
                        self.label1.font = [UIFont systemFontOfSize:topFontsize];
                        self.label1.numberOfLines = topNumberOfLines;
                    } completion:nil];
    
    NSTimeInterval bDuration = 0.4f;
    [UIView transitionWithView:self.label2
                      duration:bDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label2.text = text2;
                        self.label2.font = [UIFont systemFontOfSize:fontsize];
                        self.label2.numberOfLines = numberOfLines;
                    } completion:nil];
    
    NSTimeInterval cDuration = 0.6f;
    [UIView transitionWithView:self.label3
                      duration:cDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label3.text = text3;
                        self.label3.font = [UIFont systemFontOfSize:fontsize];
                        self.label3.numberOfLines = numberOfLines;
                    } completion:nil];
    
    NSTimeInterval dDuration = 0.8f;
    [UIView transitionWithView:self.label4
                      duration:dDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label4.text = text4;
                        self.label4.font = [UIFont systemFontOfSize:fontsize];
                        self.label4.numberOfLines = numberOfLines;
                    } completion:nil];
    
    NSTimeInterval eDuration = 1.0f;
    [UIView transitionWithView:self.label5
                      duration:eDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label5.text = text5;
                        self.label5.font = [UIFont systemFontOfSize:fontsize];
                        self.label5.numberOfLines = numberOfLines;
                    } completion:nil];
    
    NSTimeInterval fDuration = 1.2f;
    [UIView transitionWithView:self.label6
                      duration:fDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.label6.text = text6;
                        self.label6.font = [UIFont systemFontOfSize:fontsize];
                        self.label6.numberOfLines = numberOfLines;
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
//    if (self.imageNames == nil){
//        self.imageNames = [[NSMutableArray alloc]init];
//        for ( int i = 1; i <= 42; i++){
//            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
//            [self.imageNames addObject:image];
//        }
//        for ( int i = 41; i >0; i--){
//            NSString *image = [NSString stringWithFormat:@"sun%d.jpg", i ];
//            [self.imageNames addObject:image];
//        }
//    }
    if (( [self.background intValue]+1) == [self.imageNames count]){
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
-(void)fadeOut
{
    NSTimeInterval duration = 1.5f;
    [UIView transitionWithView:self.backgroundView
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundView.alpha = 0.0;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
