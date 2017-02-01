//
//  UVInformationViewController.h
//  UV Index Today
//
//  Created by perrin cloutier on 7/23/16.
//  Copyright © 2016 ptcloutier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVInformationViewController : UIViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) IBOutlet UILabel *label5;
@property (strong, nonatomic) IBOutlet UILabel *label6;
@property (weak, nonatomic) IBOutlet UIButton *tab1;
@property (weak, nonatomic) IBOutlet UIButton *tab2;
@property (weak, nonatomic) IBOutlet UIButton *tab3;
@property (weak, nonatomic) IBOutlet UIButton *tab4;
@property (weak, nonatomic) IBOutlet UIButton *tab5;
@property (weak, nonatomic) IBOutlet UIButton *tab6;
@property (weak, nonatomic) IBOutlet UIButton *tab7;
@property (nonatomic) UIColor *tabColor;
@property (nonatomic) UIColor *highlightColor;
@property (nonatomic) NSMutableArray *hourlyLabels;
@property (nonatomic) NSMutableArray *passedHourlyStringValues;
@property (nonatomic) NSString *passedCity;
@property (nonatomic) NSString *passedDate;
@property (nonatomic) NSString *passedUvIndex;
@property (nonatomic) NSString *uvIndex;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *date;
@property (nonatomic) NSMutableArray *tabs;
@property (strong, nonatomic) NSMutableArray *hourlyStringValues;
@property (strong, nonatomic) NSMutableArray *hourlyNumberValues;
@property (nonatomic) BOOL passedDataNil;
@property (nonatomic) BOOL dataNil;
@property (nonatomic) NSInteger passedDisplayNumber;
@property (nonatomic) NSInteger displayNumber;
@property (nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSNumber *background;
@property (strong, nonatomic) NSMutableArray *imageNames;
-(void)configureTopLabel1:(NSString *)text1 andFontSize:(int)topFontsize andNumberOfLines:(int)topNumberOfLines label2:(NSString *)text2 label3:(NSString *)text3 label4:(NSString *)text4 label5:(NSString *)text5 label6:(NSString *)text6 andFontSize:(int)fontsize andNumberOfLines:(int)numberOfLine;
@end
