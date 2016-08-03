//
//  InformationViewController.h
//  UVAPP
//
//  Created by perrin cloutier on 7/23/16.
//  Copyright © 2016 Clyff IOS supercompany. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InformationViewController : UIViewController<UIGestureRecognizerDelegate>

//views
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) IBOutlet UILabel *label5;
@property (strong, nonatomic) IBOutlet UILabel *label6;
@property (weak, nonatomic) IBOutlet UIButton *dot1;
@property (weak, nonatomic) IBOutlet UIButton *dot2;
@property (weak, nonatomic) IBOutlet UIButton *dot3;
@property (weak, nonatomic) IBOutlet UIButton *dot4;
@property (weak, nonatomic) IBOutlet UIButton *dot5;
@property (weak, nonatomic) IBOutlet UIButton *dot6;
@property (weak, nonatomic) IBOutlet UIButton *dot7;
@property (weak, nonatomic) IBOutlet UIButton *dot8;
@property (nonatomic) UIColor *dotColor;
@property (nonatomic) UIColor *highlightColor;
@property (nonatomic) NSMutableArray *hourlyLabels;
@property (nonatomic) NSMutableArray *passedHourlyStringValues;
@property (nonatomic) NSString *passedCity;
@property (nonatomic) NSString *passedDate;
@property (nonatomic) NSString *passedUvIndex;
@property (nonatomic) NSString *uvIndex;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *date;
@property (strong, nonatomic) NSMutableArray *hourlyStringValues;
@property (strong, nonatomic) NSMutableArray *hourlyNumberValues;
@property (nonatomic) BOOL passedDataNil;
@property (nonatomic) BOOL dataNil;
@property (nonatomic) NSInteger passedDisplayNumber;
@property (nonatomic) NSInteger displayNumber;
@property (nonatomic) NSArray *labels;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSNumber *background;




@property (strong, nonatomic) NSMutableArray *imageNames;
//-(void)configureLabel:(UILabel *)label withText:(NSString *)text andColor:(UIColor *)color andFont:(UIFont *)font;
-(void)configureTopLabel1:(NSString *)text1 andFontSize:(int)topFontsize andNumberOfLines:(int)topNumberOfLines label2:(NSString *)text2 label3:(NSString *)text3 label4:(NSString *)text4 label5:(NSString *)text5 label6:(NSString *)text6 andFontSize:(int)fontsize andNumberOfLines:(int)numberOfLine;





@end
