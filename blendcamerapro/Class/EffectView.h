//
//  EffectView.h
//  blendcamerapro
//
//  Created by Hai HW on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>

// effect scroll define
#define kEffectScrollWidthIphone  320
#define kEffectScrollHeightIphone 61
#define kEffectScrollLeftAlign    5
#define kEffectScrollRightAlign   5
// effect item define
#define kEffectWidthIphone         53   //53
#define kEffectHeightIphone        40   //48
#define kEffectSelectedWidthIphone 68
#define kEffectSelectedHeigthIphone 56
#define kSpace2EffectIphone       15
#define kMovingTopDistanceIphone  14    //10
#define kSelectedEffectExpandIphone     10
// statusbar define
#define kStatusBarRectXIphone      0
#define kStatusBarRectYIphone      65
#define kStatusBarRectWidthIphone  320
#define kStatusBarRectHeightIphone 33

//ipad
#define kEffectScrollWidthIpad  768
#define kEffectScrollHeightIpad 128
#define kEffectScrollLeftAlignIpad  24
#define kEffectScrollRightAlignIpad  24
#define kEffectWidthIpad            116   //53
#define kEffectHeightIpad           87   //48
#define kSpace2EffectIpad           35
#define kMovingTopDistanceIpad      28    //10
#define kSelectedEffectExpandIpad     20
#define kEffectSelectedWidthIpad 143
#define kEffectSelectedHeigthIpad 116

#define kStatusBarRectXIpad      0
#define kStatusBarRectYIpad      130
#define kStatusBarRectWidthIpad  768
#define kStatusBarRectHeightIpad 86

@class ViewController, HWInstantEffectView, GPUImageFilterGroup;
@interface EffectView : UIView
{
    NSMutableArray *listThumbNailEffects;
    NSMutableArray *listThumbNailEffectNames;
    UIScrollView * effectScrollView;
    NSInteger currentTag;
    
    // statusbarview
    UIView *effectStatusbarView;
    
    //Instant Effect View
    HWInstantEffectView *IEView;
    UILabel * statusBarTitle;
    
    //Effect Parameters
    float hue;
    float saturation;
    float brightness;
    float contrast;
    float opacity;
}

@property (nonatomic, assign) NSInteger currentTag; // selected current status bar
@property (nonatomic, strong) UIView *effectStatusbarView; // statusbarview
@property (nonatomic, strong) NSMutableArray *listThumbNailEffects;
@property (nonatomic, strong) NSMutableArray *listThumbNailEffectNames;
@property (nonatomic, strong) ViewController *rootViewControler;
@property (nonatomic, assign) BOOL isFullVersion;
-(void)applyEffect;
-(UIImage*)applyEffectForImage:(UIImage*)inputImage;
// show statusbar
-(void)showEffectStatusBar:(NSInteger)effectTag;
-(BOOL)shouldAutoShowToolTip;
-(void)applyCurrentEffect;
-(void)removeAll;
-(void)applyAllEffectForImage:(UIImage*)input;
@end
