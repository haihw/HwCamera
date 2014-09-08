//
//  UtilityView.m
//  blendcamerapro
//
//  Created by Do Khanh Toan on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UtilityView.h"
#import "ImageFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "CropView.h"
#import "GPUImage.h"
#import "UIImageExtras.h"

#import "GAI.h"

#define kRightBarViewWidthIphone 60
#define kMovingBarWidthIphone  200

#define kRightBarViewWidthIpad 120

@implementation UtilityView
@synthesize rootViewController;
@synthesize btnCancel;
@synthesize btnApply;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentState = 0;
        shouldCropFlag = YES;
        [self createGUI];
    }
    return self;
}

// createGUI for iPhone 
-(void) createGUI
{
    int modeIconWidth = kRightBarViewWidthIphone;
    int modeIconHeight= modeIconHeight = self.frame.size.height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        modeIconWidth = kRightBarViewWidthIpad;
    }
    // Create LeftButton & RightButton
    
    rotationModeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, modeIconWidth, modeIconHeight)];
    UIImageView * rotationModeImgViewBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UtilityBG2"]];
    rotationModeImgViewBG.frame = rotationModeView.bounds;
    [rotationModeView addSubview:rotationModeImgViewBG];
    UIButton * btnRotationMode = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRotationMode.frame = rotationModeImgViewBG.frame;
    [btnRotationMode addTarget:self action:@selector(btnRotationMode_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    rotationModeImgViewOff = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RotationIconOff"]];
    [rotationModeImgViewOff setHighlightedImage:[UIImage imageNamed:@"RotationIconOn"]];
    rotationModeImgViewOff.frame = rotationModeView.bounds;
    rotationModeImgViewOff.contentMode = UIViewContentModeCenter;
    [rotationModeView addSubview:rotationModeImgViewOff];
    
    [rotationModeView addSubview:btnRotationMode];
    
    rotationModeImgViewOn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RotationIconOn"]];
    rotationModeImgViewOn.frame = rotationModeView.bounds;
    rotationModeImgViewOn.contentMode = UIViewContentModeCenter;
    rotationModeImgViewOn.hidden = YES;
    [rotationModeView addSubview:rotationModeImgViewOn];
    
    [self addSubview:rotationModeView];
    
    
    // create right button mode
    cropModeView =[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - modeIconWidth, 0, modeIconWidth, modeIconHeight)];
    UIImageView * cropModeImgViewBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UtilityBG2"]];
    cropModeImgViewBG.frame = cropModeView.bounds;
   
    cropModeImgViewOFF = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CropIconOff.png"]];
    cropModeImgViewOFF.frame = cropModeView.bounds;
    cropModeImgViewOFF.contentMode = UIViewContentModeCenter;
    cropModeImgViewON = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CropIconOn.png"]];
    cropModeImgViewON.frame = cropModeView.bounds;
    cropModeImgViewON.contentMode = UIViewContentModeCenter;
    cropModeImgViewON.hidden = YES;
    
    UIButton * btnCropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCropButton.frame = cropModeImgViewBG.frame;
    [btnCropButton addTarget:self action:@selector(btnCroptMode_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    [cropModeView addSubview:cropModeImgViewBG];
    [cropModeView addSubview:cropModeImgViewOFF];
    [cropModeView addSubview:btnCropButton];
    [cropModeView addSubview:cropModeImgViewON];
    
    [self addSubview:cropModeView];

    // create cropMovingBar
    [self createCropMovingBar];
    // create rotationMovingBar
    [self createRotationMovingBar];
    // bring rotation on front
    rotationModeImgViewOn.hidden = NO;
    [self bringSubviewToFront:rotationModeView];
    [self bringSubviewToFront:cropModeView];
}

// create moving bar for iphone
-(void) createRotationMovingBar
{
    int movingBarWidth = 200;
    int numberOfIconForRow = 4;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movingBarWidth = 512;
    }
    CGRect frameRotationMovingBar = CGRectMake((self.bounds.size.width - movingBarWidth)/2, 0, movingBarWidth, self.bounds.size.height);

    rotationMovingBar = [[UIView alloc] initWithFrame:frameRotationMovingBar];
    //add background
    UIImageView * rotationMovingBarImageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UtilityBG"]];
    rotationMovingBarImageBG.frame = rotationMovingBar.bounds;
    [rotationMovingBar addSubview:rotationMovingBarImageBG];
    
    //define Image
    UIImage *OffBGImgX = [UIImage imageNamed:@"CropBGOff"];
    UIImage *OnBGImgX = [UIImage imageNamed:@"CropBGOn"];
    UIImage* normalTurnLeftImgX = [UIImage imageNamed:@"TurnLeftOff"];
    UIImage* hightlightTurnLeftImgX = [UIImage imageNamed:@"TurnLeftOn"];
    UIImage* normalTurnRightImgX = [UIImage imageNamed:@"TurnRightOff"];
    UIImage* hightlightTurnRightImgX = [UIImage imageNamed:@"TurnRightOn"];
    UIImage* normalHozirontalFlipImgX = [UIImage imageNamed:@"FlipHorizontalOff"];
    UIImage* hightlightHozirontalFlipImgX = [UIImage imageNamed:@"FlipHorizontalOn"];
    UIImage* normalVerticalFlipImgX = [UIImage imageNamed:@"FlipVerticalOff"];
    UIImage* hightlightVerticalFlipImgX = [UIImage imageNamed:@"FlipVerticalOn"];

    // add TurnLeft button
    int spaceWidthForIcon = movingBarWidth/numberOfIconForRow;
    UIButton * btnTurnLeft = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*0, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnTurnLeft.contentMode = UIViewContentModeCenter;
    
    [btnTurnLeft addTarget:self action:@selector(btnTurnLeft_Click:) forControlEvents:UIControlEventTouchUpInside];
    //set image
    [btnTurnLeft setImage:normalTurnLeftImgX forState:UIControlStateNormal];
    [btnTurnLeft setImage:hightlightTurnLeftImgX forState:UIControlStateHighlighted];
    [btnTurnLeft setBackgroundImage:OffBGImgX forState:UIControlStateNormal];
    [btnTurnLeft setBackgroundImage:OnBGImgX forState:UIControlStateHighlighted];
    [rotationMovingBar addSubview:btnTurnLeft];
    
    // add TurnRight button
    UIButton * btnTurnRight = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*1, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnTurnRight.contentMode = UIViewContentModeCenter;
    [btnTurnRight addTarget:self action:@selector(btnTurnRight_Click:) forControlEvents:UIControlEventTouchUpInside];
    //set image
    [btnTurnRight setImage:normalTurnRightImgX forState:UIControlStateNormal];
    [btnTurnRight setImage:hightlightTurnRightImgX forState:UIControlStateHighlighted];
    [btnTurnRight setBackgroundImage:OffBGImgX forState:UIControlStateNormal];
    [btnTurnRight setBackgroundImage:OnBGImgX forState:UIControlStateHighlighted];
    [rotationMovingBar addSubview:btnTurnRight];

    // add Horizontal Flip
    UIButton * btnHozirontalFlip = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*2, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnHozirontalFlip.contentMode = UIViewContentModeCenter;
    [btnHozirontalFlip addTarget:self action:@selector(btnHozirontalFlip_Click:) forControlEvents:UIControlEventTouchUpInside];
    //set image
    [btnHozirontalFlip setImage:normalHozirontalFlipImgX forState:UIControlStateNormal];
    [btnHozirontalFlip setImage:hightlightHozirontalFlipImgX forState:UIControlStateHighlighted];
    [btnHozirontalFlip setBackgroundImage:OffBGImgX forState:UIControlStateNormal];
    [btnHozirontalFlip setBackgroundImage:OnBGImgX forState:UIControlStateHighlighted];
    [rotationMovingBar addSubview:btnHozirontalFlip];

    // add Vertical Flip
    UIButton * btnVerticalFlip = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*3, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnVerticalFlip.contentMode = UIViewContentModeCenter;
    [btnVerticalFlip addTarget:self action:@selector(btnVerticalFlip_Click:) forControlEvents:UIControlEventTouchUpInside];
    //set image
    [btnVerticalFlip setImage:normalVerticalFlipImgX forState:UIControlStateNormal];
    [btnVerticalFlip setImage:hightlightVerticalFlipImgX forState:UIControlStateHighlighted];
    [btnVerticalFlip setBackgroundImage:OffBGImgX forState:UIControlStateNormal];
    [btnVerticalFlip setBackgroundImage:OnBGImgX forState:UIControlStateHighlighted];
    [rotationMovingBar addSubview:btnVerticalFlip];

    [self addSubview:rotationMovingBar];
}

-(void) createCropMovingBar
{
    
    int movingBarWidth = 200;
    int numberOfIconForRow = 4;
    int numberOfIcon = 8;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movingBarWidth = 512;
    }
    int spaceWidthForIcon = movingBarWidth/numberOfIconForRow;
    

    CGRect frameCropMovingBar = CGRectMake((self.bounds.size.width - movingBarWidth)/2, 0, movingBarWidth, self.bounds.size.height);
    cropMovingBar = [[UIView alloc] initWithFrame:frameCropMovingBar];
    
    //add background
    UIImageView * rotationMovingBarImageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UtilityBG"]];
    rotationMovingBarImageBG.frame = cropMovingBar.bounds;
    [cropMovingBar addSubview:rotationMovingBarImageBG];

    UIScrollView *cropScrollBar = [[UIScrollView alloc] initWithFrame:cropMovingBar.bounds];
    [cropMovingBar addSubview:cropScrollBar];
    cropScrollBar.contentSize = CGSizeMake(numberOfIcon * spaceWidthForIcon, cropMovingBar.bounds.size.height);
    
    
    //define Image
    
    OffBGImg = [UIImage imageNamed:@"CropBGOff"];
    OnBGImg = [UIImage imageNamed:@"CropBGOn"];
    
    normalManualCropImg = [UIImage imageNamed:@"cropmanualoff"];
    hightlightManualCropImg = [UIImage imageNamed:@"cropmanualon"];

    normalSquareCropImg = [UIImage imageNamed:@"cropsquareoff"];
    hightlightSquareCropImg = [UIImage imageNamed:@"cropsquareon"];

    normalOriginalCropImg = [UIImage imageNamed:@"croporiginaloff"];
    hightlightOriginalCropImg = [UIImage imageNamed:@"croporiginalon"];

    normal3x2CropImg = [UIImage imageNamed:@"crop3x2off"];
    hightlight3x2CropImg = [UIImage imageNamed:@"crop3x2on"];
    
    normal4x3CropImg = [UIImage imageNamed:@"crop4x3off"];
    hightlight4x3CropImg = [UIImage imageNamed:@"crop4x3on"];

    normal3x4CropImg = [UIImage imageNamed:@"crop3x4off"];
    hightlight3x4CropImg = [UIImage imageNamed:@"crop3x4on"];

    normal16x9CropImg = [UIImage imageNamed:@"crop16x9off"];
    hightlight16x9CropImg = [UIImage imageNamed:@"crop16x9on"];
    
    normalFacebookCropImg = [UIImage imageNamed:@"cropfbcoveroff"];
    hightlightFacebookCropImg = [UIImage imageNamed:@"cropfbcoveron"];
    
    // add manual button
    btnManualCrop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*0, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnManualCrop.contentMode = UIViewContentModeCenter;
    
    [btnManualCrop addTarget:self action:@selector(btnManualCrop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btnManualCrop];

    // add square button
    btnSquareCrop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*1, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnSquareCrop.contentMode = UIViewContentModeCenter;
    
    [btnSquareCrop addTarget:self action:@selector(btnSquareCrop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btnSquareCrop];

    // add Original button
    btnOriginalCrop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*2, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnOriginalCrop.contentMode = UIViewContentModeCenter;
    
    [btnOriginalCrop addTarget:self action:@selector(btnOriginalCrop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btnOriginalCrop];

    // add 3x2 crop
    btn3x2Crop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*3, 0, spaceWidthForIcon, self.bounds.size.height)];
    btn3x2Crop.contentMode = UIViewContentModeCenter;
    
    [btn3x2Crop addTarget:self action:@selector(btn3x2Crop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btn3x2Crop];
    
    // add 4x3 square crop
    btn4x3Crop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*4, 0, spaceWidthForIcon, self.bounds.size.height)];
    btn4x3Crop.contentMode = UIViewContentModeCenter;
    
    [btn4x3Crop addTarget:self action:@selector(btn4x3Crop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btn4x3Crop];

    // add 3x4 square crop
    btn3x4Crop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*5, 0, spaceWidthForIcon, self.bounds.size.height)];
    btn3x4Crop.contentMode = UIViewContentModeCenter;
    [btn3x4Crop addTarget:self action:@selector(btn3x4Crop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btn3x4Crop];
    
    // add 16x9 square crop
    btn16x9Crop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*6, 0, spaceWidthForIcon, self.bounds.size.height)];
    btn16x9Crop.contentMode = UIViewContentModeCenter;
    [btn16x9Crop addTarget:self action:@selector(btn16x9Crop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btn16x9Crop];
    
    // add Facebook button
    btnFacebookCrop = [[UIButton alloc]initWithFrame:CGRectMake(spaceWidthForIcon*7, 0, spaceWidthForIcon, self.bounds.size.height)];
    btnFacebookCrop.contentMode = UIViewContentModeCenter;
    
    [btnFacebookCrop addTarget:self action:@selector(btnFacebookCrop_Click:) forControlEvents:UIControlEventTouchUpInside];
    [cropScrollBar addSubview:btnFacebookCrop];

    [self setNormalStateBtn];
    [self addSubview:cropMovingBar];
}


#pragma  handle button click events

-(IBAction)btnCroptMode_Click:(id)sender
{
    NSLog(@"btnCroptMode_Click");
    // display CropMode View

    [self bringSubviewToFront:cropModeView];
    // test :
    cropModeView.backgroundColor = [UIColor yellowColor];
    
    cropModeImgViewON.hidden = NO;
    cropModeImgViewOFF.hidden = YES;

    rotationModeImgViewOff.hidden = NO;
    rotationModeImgViewOn.hidden = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7f];
    rotationMovingBar.frame = CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);

    int movingBarWidth = 200;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movingBarWidth = 512;
    }
    cropMovingBar.frame  = CGRectMake((self.bounds.size.width - movingBarWidth)/2, 0, movingBarWidth, self.bounds.size.height);
    [UIView commitAnimations];
    
    //Apply Manual Crop Mode by default
    [self createCropAreaWithWidthRate:1 heightRate:1 isCustomMode:YES];
    
    //Google analytics
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Utilities"
//                                                    withAction:kGAEventActionButtonTap
//                                                     withLabel:kGAEventCrop
//                                                     withValue:nil];

}

-(IBAction)btnRotationMode_Click:(id)sender
{
    NSLog(@"btnRotationMode_Click");
    // display Rotation View
    [self bringSubviewToFront:rotationModeView];
    cropModeImgViewON.hidden =YES;
    cropModeImgViewOFF.hidden = NO;

    rotationModeImgViewOn.hidden = NO;
    rotationModeImgViewOff.hidden = YES;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7f];
    cropMovingBar.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    if (currentCropView.hidden == NO)
        [self btnCancel_Click];
    int movingBarWidth = 200;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        movingBarWidth = 512;
    }
    rotationMovingBar.frame  = CGRectMake((self.bounds.size.width - movingBarWidth)/2, 0, movingBarWidth, self.bounds.size.height);

    [UIView commitAnimations];
    
    //Google analytics
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Utilities"
//                                                    withAction:kGAEventActionButtonTap
//                                                     withLabel:kGAEventRotate
//                                                     withValue:nil];

}

-(IBAction)btnTurnLeft_Click:(id)sender
{
    int turnLeftLookups[] = {7, 6, 5, 4, 0, 1, 2, 3};
    currentState = turnLeftLookups[currentState];
    NSLog(@"orientation state: %d", currentState );
    
    NSLog(@"btnTurnLeft_Click");
    NSLog(@"currentState:%d",currentState);
    [self.rootViewController f5Preview];
}

-(IBAction)btnTurnRight_Click:(id)sender
{
    int turnRightLookups[] = {4, 5, 6, 7, 3, 2, 1, 0};
    currentState = turnRightLookups[currentState];
    NSLog(@"orientation state: %d", currentState );

    NSLog(@"btnTurnRight_Click");
    NSLog(@"currentState:%d",currentState);
    [self.rootViewController f5Preview];
}

-(IBAction)btnHozirontalFlip_Click:(id)sender
{
    int horizontalFlipLookups[] = {1, 0, 3, 2, 6, 7, 4, 5};
    currentState = horizontalFlipLookups[currentState];

    NSLog(@"btnHorizontalFlip_Click");
     NSLog(@"currentState:%d",currentState);
   
    [self.rootViewController f5Preview];
}

-(IBAction)btnVerticalFlip_Click:(id)sender
{
    int verticalFlipLookups[] = {2, 3, 0, 1, 5, 4, 7, 6};
    currentState = verticalFlipLookups[currentState];

    NSLog(@"btnVerticalFlip_Click");
    NSLog(@"currentState:%d",currentState);
    [self.rootViewController f5Preview];
}

- (void) setNormalStateBtn {
    [btnManualCrop setImage:normalManualCropImg forState:UIControlStateNormal];
    [btnManualCrop setImage:hightlightManualCropImg forState:UIControlStateHighlighted];
    [btnManualCrop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btnManualCrop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btnSquareCrop setImage:normalSquareCropImg forState:UIControlStateNormal];
    [btnSquareCrop setImage:hightlightSquareCropImg forState:UIControlStateHighlighted];
    [btnSquareCrop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btnSquareCrop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btnOriginalCrop setImage:normalOriginalCropImg forState:UIControlStateNormal];
    [btnOriginalCrop setImage:hightlightOriginalCropImg forState:UIControlStateHighlighted];
    [btnOriginalCrop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btnOriginalCrop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btn3x2Crop setImage:normal3x2CropImg forState:UIControlStateNormal];
    [btn3x2Crop setImage:hightlight3x2CropImg forState:UIControlStateHighlighted];
    [btn3x2Crop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btn3x2Crop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btn4x3Crop setImage:normal4x3CropImg forState:UIControlStateNormal];
    [btn4x3Crop setImage:hightlight4x3CropImg forState:UIControlStateHighlighted];
    [btn4x3Crop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btn4x3Crop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btn3x4Crop setImage:normal3x4CropImg forState:UIControlStateNormal];
    [btn3x4Crop setImage:hightlight3x4CropImg forState:UIControlStateHighlighted];
    [btn3x4Crop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btn3x4Crop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btn3x4Crop setImage:normal3x4CropImg forState:UIControlStateNormal];
    [btn3x4Crop setImage:hightlight3x4CropImg forState:UIControlStateHighlighted];
    [btn3x4Crop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btn3x4Crop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btn16x9Crop setImage:normal16x9CropImg forState:UIControlStateNormal];
    [btn16x9Crop setImage:hightlight16x9CropImg forState:UIControlStateHighlighted];
    [btn16x9Crop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btn16x9Crop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
    //
    [btnFacebookCrop setImage:normalFacebookCropImg forState:UIControlStateNormal];
    [btnFacebookCrop setImage:hightlightFacebookCropImg forState:UIControlStateHighlighted];
    [btnFacebookCrop setBackgroundImage:OffBGImg forState:UIControlStateNormal];
    [btnFacebookCrop setBackgroundImage:OnBGImg forState:UIControlStateHighlighted];
}

-(IBAction)btnManualCrop_Click:(id)sender
{
    NSLog(@"btnManualCrop_Click");
    [self createCropAreaWithWidthRate:1 heightRate:1 isCustomMode:YES];
    
    // hightlight btn :
    [self setNormalStateBtn];
    [btnManualCrop setImage:hightlightManualCropImg forState:UIControlStateNormal];
    [btnManualCrop setImage:normalManualCropImg forState:UIControlStateHighlighted];
    [btnManualCrop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btnManualCrop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];
}
-(IBAction)btnOriginalCrop_Click:(id)sender
{
    NSLog(@"btnOriginalCrop_Click");
    CGSize size = self.rootViewController.originalImage.size;
    [self createCropAreaWithWidthRate:size.width heightRate:size.height isCustomMode:NO];
    
    [self setNormalStateBtn];
    [btnOriginalCrop setImage:hightlightOriginalCropImg forState:UIControlStateNormal];
    [btnOriginalCrop setImage:normalOriginalCropImg forState:UIControlStateHighlighted];
    [btnOriginalCrop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btnOriginalCrop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];

}

-(IBAction)btnSquareCrop_Click:(id)sender
{
    NSLog(@"btnSquareCrop_Click");
    [self createCropAreaWithWidthRate:3 heightRate:3 isCustomMode:NO];
    
    [self setNormalStateBtn];
    [btnSquareCrop setImage:hightlightSquareCropImg forState:UIControlStateNormal];
    [btnSquareCrop setImage:normalSquareCropImg forState:UIControlStateHighlighted];
    [btnSquareCrop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btnSquareCrop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];
}

-(IBAction)btn3x2Crop_Click:(id)sender
{
    NSLog(@"btn3x2Crop_Click");
    [self createCropAreaWithWidthRate:3 heightRate:2 isCustomMode:NO];
    [self setNormalStateBtn];
    [btn3x2Crop setImage:hightlight3x2CropImg forState:UIControlStateNormal];
    [btn3x2Crop setImage:normal3x2CropImg forState:UIControlStateHighlighted];
    [btn3x2Crop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btn3x2Crop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];
}

-(IBAction)btn3x4Crop_Click:(id)sender
{
    NSLog(@"btn3x4Crop_Click");
    [self createCropAreaWithWidthRate:3 heightRate:4 isCustomMode:NO];
    [self setNormalStateBtn];
    [btn3x4Crop setImage:hightlight3x4CropImg forState:UIControlStateNormal];
    [btn3x4Crop setImage:normal3x4CropImg forState:UIControlStateHighlighted];
    [btn3x4Crop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btn3x4Crop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];
}

-(IBAction)btn4x3Crop_Click:(id)sender
{
    NSLog(@"btn4x3Crop_Click");
    [self createCropAreaWithWidthRate:4 heightRate:3 isCustomMode:NO];
    [self setNormalStateBtn];
    [btn4x3Crop setImage:hightlight4x3CropImg forState:UIControlStateNormal];
    [btn4x3Crop setImage:normal4x3CropImg forState:UIControlStateHighlighted];
    [btn4x3Crop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btn4x3Crop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];

    
}
-(IBAction)btn16x9Crop_Click:(id)sender {
    NSLog(@"btn16x9Crop_Click");
    [self createCropAreaWithWidthRate:16 heightRate:9 isCustomMode:NO];
    [self setNormalStateBtn];
    [btn16x9Crop setImage:hightlight16x9CropImg forState:UIControlStateNormal];
    [btn16x9Crop setImage:normal16x9CropImg forState:UIControlStateHighlighted];
    [btn16x9Crop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btn16x9Crop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];
}
-(IBAction)btnFacebookCrop_Click:(id)sender
{
    NSLog(@"btnFacebookCrop_Click");
    [self createCropAreaWithWidthRate:85 heightRate:32 isCustomMode:NO];
    [self setNormalStateBtn];
    [btnFacebookCrop setImage:hightlightFacebookCropImg forState:UIControlStateNormal];
    [btnFacebookCrop setImage:normalFacebookCropImg forState:UIControlStateHighlighted];
    [btnFacebookCrop setBackgroundImage:OnBGImg forState:UIControlStateNormal];
    [btnFacebookCrop setBackgroundImage:OffBGImg forState:UIControlStateHighlighted];

}

-(void) createCropAreaWithWidthRate:(int) rW heightRate:(int) rH isCustomMode:(BOOL)isCustomMode
{
    if (!self.rootViewController.previewImageView.image)
        return;
    shouldCropFlag = NO;
    [self.rootViewController f5NoIndicator];
    shouldCropFlag = YES;

    CGRect outlineOfCropArea = [self.rootViewController getDiplayFrameOfImageView:self.rootViewController.previewImageView];
    NSLog(@"outlineOfCropArea:%@",NSStringFromCGRect(outlineOfCropArea));
    
    CGSize sizeOfCrop = [self getSizeOfCropArea:rW :rH :outlineOfCropArea];
    NSLog(@"sizeOfCrop:%@",NSStringFromCGSize(sizeOfCrop));
    
    // check existing current cropview
    if(currentCropView)
    {
        [currentCropView removeFromSuperview];
        currentCropView = nil;
    }
    
    currentCropView = [[CropView alloc] initWithFrame:CGRectMake(0, 0, sizeOfCrop.width, sizeOfCrop.height)];
    currentCropView.center = self.rootViewController.previewImageView.center;
    currentCropView.maxSize = sizeOfCrop;
    currentCropView.outlineRect = outlineOfCropArea;
    currentCropView.utilityView = self;
    currentCropView.isCustomMode = isCustomMode;
    
    UIView * contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.alpha =0.4;
    [currentCropView setContentView:contentView];
    currentCropView.parentController = self.rootViewController;
    
    [self.rootViewController.view addSubview:currentCropView];
    
    // show Cancel and Apply button
    btnCancel.hidden = NO;
    btnApply.hidden = NO;
    
}

-(int)getCurrentState
{
    return currentState;
}


-(CGSize) getSizeOfCropArea:(int) rateWidth :(int) rateHeight :(CGRect)outlineRect 
{
    CGSize sizeOfCrop;
    
    sizeOfCrop.width = outlineRect.size.width;
    float rate =  (float)rateHeight/(float)rateWidth;
    sizeOfCrop.height = rate*sizeOfCrop.width;
    
    while (sizeOfCrop.height > outlineRect.size.height) {
        sizeOfCrop.width = sizeOfCrop.width - sizeOfCrop.width*10/100;
        sizeOfCrop.height = rate*sizeOfCrop.width;
    }
    
    NSLog(@"sizeOfCrop:%@",NSStringFromCGSize(sizeOfCrop));
    return sizeOfCrop;
}



// Apply cropfilter to input image
-(UIImage *) applyCropFilterFor:(UIImage *) inputImage
{
    if (!(shouldCropFlag && currentCropView))
        return inputImage;

    // get crop rect from cropview
    CGRect cropArea = [currentCropView getCropRectArea];
    //get display frame of image preview on rootView coordinate;
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:self.rootViewController.previewImageView.frame];
    tempImageView.image = inputImage;
    CGRect outlineOfCropedImage = [self.rootViewController getDiplayFrameOfImageView:tempImageView];
    
    CGRect outline = CGRectMake(outlineOfCropedImage.origin.x + tempImageView.frame.origin.x,
                                      outlineOfCropedImage.origin.y + tempImageView.frame.origin.y,
                                      outlineOfCropedImage.size.width, outlineOfCropedImage.size.height);
    
    NSLog(@"Outline: %@", NSStringFromCGRect(outline));
    NSLog(@"Crop: %@", NSStringFromCGRect(cropArea));

    //calculate crop area in range [0,1]
    CGRect newCropArea = CGRectMake(MIN(1, MAX(0,(cropArea.origin.x - outline.origin.x)/outline.size.width)),
                                    MIN(1, MAX(0,(cropArea.origin.y - outline.origin.y)/outline.size.height)),
                                    MIN(1, MAX(0,cropArea.size.width/outline.size.width)),
                                    MIN(1, MAX(0,cropArea.size.height/outline.size.height)));
    
    
    GPUImageCropFilter *stillCropFilter = [[GPUImageCropFilter alloc] init];
    stillCropFilter.cropRegion = newCropArea;
    NSLog(@"CROP AREA: %@", NSStringFromCGRect(newCropArea));
    NSLog(@"Image size: %@", NSStringFromCGSize(inputImage.size));
    UIImage* cropedImage = [stillCropFilter imageByFilteringImage:inputImage];
    NSLog(@"Image size: %@", NSStringFromCGSize(cropedImage.size));
    return cropedImage;
    
} 

-(UIImage *) applyCropFilterForol:(UIImage *) inputImage
{
    if (!currentCropView)
        return inputImage;
    // preprocessing
    // get crop rect from cropview
    CGRect cropArea = [currentCropView getCropRectArea];
    // get outline of croped image area
    CGRect outlineOfCropedImage = [currentCropView getOutlineImageBeCropedImage];
    
    // make newCropArea and newOutlineOfCropedImage of inputImage 
    float rateWidth = inputImage.size.width / outlineOfCropedImage.size.width;
    float rateHeight = inputImage.size.height / outlineOfCropedImage.size.height;
    
    float oldDx = cropArea.origin.x - outlineOfCropedImage.origin.x;
    float oldDy = cropArea.origin.y - outlineOfCropedImage.origin.y;
    
    // new crop area on input image
    CGRect newCropArea = CGRectMake(outlineOfCropedImage.origin.x + oldDx*rateWidth,outlineOfCropedImage.origin.y + rateHeight* oldDy, rateWidth*cropArea.size.width, rateHeight*cropArea.size.height);

    // need normalizing the coordinate of newCropArea following the input iamge
    float dx = newCropArea.origin.x - outlineOfCropedImage.origin.x;
    float dy = newCropArea.origin.y - outlineOfCropedImage.origin.y;
    
    newCropArea = CGRectMake(dx/inputImage.size.width, dy/inputImage.size.height, newCropArea.size.width/inputImage.size.width, newCropArea.size.height/inputImage.size.height);
    
    GPUImageCropFilter *stillCropFilter = [[GPUImageCropFilter alloc] init];
    stillCropFilter.cropRegion = newCropArea;
    NSLog(@"CROP AREA: %@", NSStringFromCGRect(newCropArea));
    NSLog(@"Image size: %@", NSStringFromCGSize(inputImage.size));
    UIImage* cropedImage = [stillCropFilter imageByFilteringImage:inputImage];
    NSLog(@"%ld", inputImage.imageOrientation);
    NSLog(@"Image size: %@", NSStringFromCGSize(cropedImage.size));
    return cropedImage;
    
} 

-(UIImage *) getRotationAndFlipImage:(int)stage from:(UIImage*)inputImage
{
    UIImage *output = inputImage;
    switch (stage) {
        case 0:
            output =  [inputImage rotate:UIImageOrientationUp];
            break;
        case 1: // HF
            output =  [inputImage rotate:UIImageOrientationUpMirrored];
            break;
        case 2: // VF
            output =  [inputImage rotate:UIImageOrientationDownMirrored];
            break;
        case 3: // RR ( down)
            output =  [inputImage rotate:UIImageOrientationDown];
            break;
        case 4:
            output =  [inputImage rotate:UIImageOrientationRight];
            break;
        case 5:
            output =  [inputImage rotate:UIImageOrientationLeftMirrored];
            break;
        case 6:
            output =  [inputImage rotate:UIImageOrientationRightMirrored];
            break;
        case 7:
            output =  [inputImage rotate:UIImageOrientationLeft];
            break;
        default:
            output =  inputImage;
    }
    return output;
}


// Apply rotation for input image
-(UIImage *) applyRotationImageFor:(UIImage *) inputImage withStage:(int) stage
{
    UIImage * image = [self getRotationAndFlipImage:currentState from:inputImage];
    return image;
}
// handle cancel and apply button click
-(void)btnCancel_Click
{
    [currentCropView removeFromSuperview];
    currentCropView = nil;
    btnApply.hidden  = YES;
    btnCancel.hidden = YES;
}

-(void)btnApply_Click
{
    NSLog(@"call pipeprocessing");
    btnApply.hidden  = YES;
    btnCancel.hidden = YES;
    currentCropView.hidden = YES;
    [self.rootViewController f5Preview];

}

// add 2 button Cancel and Apply
-(void) addCancelAndApplyButtonToRootController
{
    CGRect applyFrame = CGRectMake(274, 336, 30, 30);
    CGRect cancelFrame = CGRectMake(15, 336, 30, 30);
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        applyFrame = CGRectMake (688, 730, 50,50);
        cancelFrame = CGRectMake(30, 730, 50, 50);
    }
    // create cancel button and apply button
    btnCancel =[UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = cancelFrame;
    [btnCancel setImage:[UIImage imageNamed:@"btnCancel.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCancel_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.rootViewController.view addSubview:btnCancel];
    btnCancel.hidden = YES;
    
    btnApply =[UIButton buttonWithType:UIButtonTypeCustom];
    btnApply.frame = applyFrame;
    [btnApply setImage:[UIImage imageNamed:@"btnApply.png"] forState:UIControlStateNormal];
    [btnApply addTarget:self action:@selector(btnApply_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.rootViewController.view addSubview:btnApply];
    btnApply.hidden = YES;
    
}
-(void)removeAll
{
    [self removeFromSuperview];
    if (currentCropView)
    {
        [currentCropView removeFromSuperview];
        currentCropView = nil;
    }
    if (btnApply)
    {
        [btnApply removeFromSuperview];
        btnApply = nil;
    }
    if (btnCancel)
    {
        [btnCancel removeFromSuperview];
        btnCancel = nil;
    }
    
}
-(void)hideAll
{
    if (currentCropView.hidden == NO)
    {
        [self btnCancel_Click];
    }
    currentCropView.hidden = YES;
    btnApply.hidden  = YES;
    btnCancel.hidden = YES;

    self.hidden = YES;
}
-(bool)shouldCrop
{
    return (shouldCropFlag);
}
-(bool)shouldRotate
{
    return (currentState != 0);
}
@end
