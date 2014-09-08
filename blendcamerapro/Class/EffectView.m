//
//  EffectView.m
//  blendcamerapro
//
//  Created by Hai HW on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import "EffectView.h"
#import "Define.h"
#import "ViewController.h"
#import "HWInstantEffectView.h"
#import "HWInstantEffect.h"
#import "MBProgressHUD.h"

#import "GAI.h"

@implementation EffectView
@synthesize listThumbNailEffects;
@synthesize listThumbNailEffectNames;
@synthesize rootViewControler;
@synthesize currentTag;
@synthesize effectStatusbarView;
- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // set current selected tag
        currentTag = 0;
        [self createGUI];
    }
    return self;
}

-(void)createGUI
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // iphone
    {
        // add ScrollView to View
         effectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kEffectScrollWidthIphone, kEffectScrollHeightIphone)];
        [self addSubview:effectScrollView];
        
        // init effectnames
        [self initListEffectNames];
        NSLog(@"listThumbNailEffectNames.count:%lu",(unsigned long)listThumbNailEffectNames.count);
        // create list thumbnail 
        CGSize contentSizeScroll = CGSizeMake(kEffectScrollLeftAlign + kEffectScrollRightAlign + listThumbNailEffectNames.count*kEffectWidthIphone + (listThumbNailEffectNames.count-1)*kSpace2EffectIphone, kEffectHeightIphone);
        [effectScrollView setContentSize:contentSizeScroll];
        [self createThumbNailEffectsIphone];
    } else
    {
        //ipad
        effectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kEffectScrollWidthIpad, kEffectScrollHeightIpad)];
        [self addSubview:effectScrollView];
        
        // init effectnames
        [self initListEffectNames];
        NSLog(@"listThumbNailEffectNames.count:%ld",(unsigned long)listThumbNailEffectNames.count);
        // create list thumbnail
        CGSize contentSizeScroll = CGSizeMake(kEffectScrollLeftAlignIpad + kEffectScrollRightAlignIpad + listThumbNailEffectNames.count*kEffectWidthIpad + (listThumbNailEffectNames.count-1)*kSpace2EffectIpad, kEffectHeightIpad);
        [effectScrollView setContentSize:contentSizeScroll];
        [self createThumbNailEffectsIpad];

    }
    [effectScrollView setShowsHorizontalScrollIndicator:NO];
    [effectScrollView setShowsVerticalScrollIndicator:NO];
}

-(void) initListEffectNames
{
    listThumbNailEffectNames = [[NSMutableArray alloc] initWithCapacity:0];
    // add name effect to list
    [listThumbNailEffectNames addObject:kEffectName0];
    [listThumbNailEffectNames addObject:kEffectName1];
    [listThumbNailEffectNames addObject:kEffectName2];
    [listThumbNailEffectNames addObject:kEffectName3];
    [listThumbNailEffectNames addObject:kEffectName4];
    [listThumbNailEffectNames addObject:kEffectName5];
    [listThumbNailEffectNames addObject:kEffectName6];
    [listThumbNailEffectNames addObject:kEffectName7];
    [listThumbNailEffectNames addObject:kEffectName8];
    [listThumbNailEffectNames addObject:kEffectName9];
    [listThumbNailEffectNames addObject:kEffectName10];
    [listThumbNailEffectNames addObject:kEffectName11];
    [listThumbNailEffectNames addObject:kEffectName12];
    [listThumbNailEffectNames addObject:kEffectName13];
    [listThumbNailEffectNames addObject:kEffectName14];
    [listThumbNailEffectNames addObject:kEffectName15];
    [listThumbNailEffectNames addObject:kEffectName16];
    [listThumbNailEffectNames addObject:kEffectName17];
    [listThumbNailEffectNames addObject:kEffectName18];
    [listThumbNailEffectNames addObject:kEffectName19];
    [listThumbNailEffectNames addObject:kEffectName20];
    [listThumbNailEffectNames addObject:kEffectName21];
    [listThumbNailEffectNames addObject:kEffectName22];
    [listThumbNailEffectNames addObject:kEffectName23];
    [listThumbNailEffectNames addObject:kEffectName24];
    [listThumbNailEffectNames addObject:kEffectName25];
    [listThumbNailEffectNames addObject:kEffectName26];
    [listThumbNailEffectNames addObject:kEffectName27];

}

-(IBAction)effect_Click:(UIButton *)sender
{

    NSLog(@"effect_Click, sender.tag:%ld",(long)sender.tag);
    //Google analytics
//    NSString *gaEventName = [NSString stringWithFormat:@"%@ %@", kGAEventEffectPrefix, listThumbNailEffectNames[sender.tag]];
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Effect"
//                                                    withAction:kGAEventActionThumbnailTap
//                                                     withLabel:gaEventName
//                                                     withValue:nil];
    
    int leftAlign;
    int effectWidth;
    int effectHeight;
    int effectSpace;
    int effectMovingTop;
    int selectedEffectExpand;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // iphone
    {
        leftAlign = kEffectScrollLeftAlign;
        effectWidth = kEffectWidthIphone;
        effectHeight = kEffectHeightIphone;
        
        effectSpace = kSpace2EffectIphone;
        effectMovingTop = kMovingTopDistanceIphone;
        selectedEffectExpand = kSelectedEffectExpandIphone;
    }
    else{
        leftAlign = kEffectScrollLeftAlignIpad;
        effectWidth = kEffectWidthIpad;
        effectHeight = kEffectHeightIpad;
        effectSpace = kSpace2EffectIpad;
        effectMovingTop = kMovingTopDistanceIpad;
        selectedEffectExpand = kSelectedEffectExpandIpad;

        
    }
    
    // Scale down the current selected effect
    float xCurrent = leftAlign + currentTag*effectWidth +currentTag*effectSpace;
    if(currentTag ==0) 
        xCurrent = leftAlign;
     
    float yCurrent = effectMovingTop;
    CGRect currentFrame = CGRectMake(xCurrent, yCurrent, effectWidth, effectHeight);
    UIImageView * currentSelectedImage = [listThumbNailEffects objectAtIndex:currentTag];
    currentSelectedImage.frame = currentFrame;
    currentSelectedImage.backgroundColor = [UIColor clearColor];
    currentSelectedImage.layer.shadowOpacity = 0;
    currentSelectedImage.layer.borderWidth = 0;
    // update current selected tag
    currentTag = sender.tag;
    
    //demo indicator
    [MBProgressHUD showHUDAddedTo:self.rootViewControler.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        [self applyEffect];
        self.rootViewControler.previewImageView.hidden = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.rootViewControler.view animated:YES];
        });
    });
    // scroll to current tag
    xCurrent = leftAlign + currentTag*effectWidth +currentTag*effectSpace;
    currentFrame = CGRectMake(xCurrent, yCurrent, effectWidth, effectHeight);
    [effectScrollView scrollRectToVisible:currentFrame animated:YES];

    // Scale up the selected image to heighter than others
    UIImageView * imageView = (UIImageView*)[listThumbNailEffects objectAtIndex:sender.tag];
    imageView.center = CGPointMake(imageView.center.x, imageView.center.y-effectMovingTop+effectMovingTop - selectedEffectExpand);

    //imageView.bounds = CGRectMake(0,0,effectSelectWidth, effectSelectHeight);
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SelectEffectBorder"]];
    
//    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [[UIColor colorWithRed:0 green:204.0f/255 blue:1 alpha:1] CGColor];
    imageView.layer.shadowColor = [[UIColor colorWithRed:0 green:204.0f/255.0f blue:1 alpha:1] CGColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 0);
    imageView.layer.shadowRadius = selectedEffectExpand;
    imageView.layer.shadowOpacity = 1;
    // Show statusbar
    [self showEffectStatusBar:currentTag];

}

-(void) createThumbNailEffectsIphone
{
    NSLog(@"createThumbNailEffectsIphone");
    listThumbNailEffects = [[NSMutableArray alloc] initWithCapacity:0];
    float width = kEffectWidthIphone;
    float height = kEffectHeightIphone;
    int x =kEffectScrollLeftAlign;
    int y =0+kMovingTopDistanceIphone;
    int space2Effect = kSpace2EffectIphone;
    
    for (int i =0; i < listThumbNailEffectNames.count; i++) {
        NSString *effectNamesStrimed = [listThumbNailEffectNames[i] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * imagename = [NSString stringWithFormat:@"%@%@", kFxThumbnailPrefix, effectNamesStrimed];
        UIImage * image = [UIImage imageNamed:imagename];
        NSLog(@"%@", imagename);
        CGRect frame = CGRectMake(x+i*(width+space2Effect),y,width, height);
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = i;
        // create custome buttons 
        UIButton * btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImage.frame = imageView.frame;
        btnImage.tag = i;
        [btnImage addTarget:self action:@selector(effect_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        // add the title lable effects
        CGRect titleFrame = CGRectMake(frame.origin.x, height +y, width, 8);
        UILabel * lblTitle = [[UILabel alloc] initWithFrame:titleFrame];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = [listThumbNailEffectNames objectAtIndex:i];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [UIFont systemFontOfSize:7];
        lblTitle.textColor = [UIColor whiteColor];
        
        [listThumbNailEffects addObject:imageView];
        
        [effectScrollView addSubview:imageView];
        [effectScrollView addSubview:btnImage];
        [effectScrollView addSubview:lblTitle];
    }
    
}
-(void) createThumbNailEffectsIpad
{
    NSLog(@"createThumbNailEffectsIpad");
    listThumbNailEffects = [[NSMutableArray alloc] initWithCapacity:0];
    float width = kEffectWidthIpad;
    float height = kEffectHeightIpad;
    int x =kEffectScrollLeftAlignIpad;
    int y =0+kMovingTopDistanceIpad;
    int space2Effect = kSpace2EffectIpad;
    int titleHeight = 16;
    int titleFont = 15;
    for (int i =0; i < listThumbNailEffectNames.count; i++) {
        NSString *effectNamesStrimed = [listThumbNailEffectNames[i] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * imagename = [NSString stringWithFormat:@"%@%@", kFxThumbnailPrefix, effectNamesStrimed];
        UIImage * image = [UIImage imageNamed:imagename];
        NSAssert(image, @"%@ not found", imagename);
        CGRect frame = CGRectMake(x+i*(width+space2Effect),y,width, height);
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = i;
        // create custome buttons
        UIButton * btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImage.frame = imageView.frame;
        btnImage.tag = i;
        [btnImage addTarget:self action:@selector(effect_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        // add the title lable effects
        CGRect titleFrame = CGRectMake(frame.origin.x, height +y, width, titleHeight);
        UILabel * lblTitle = [[UILabel alloc] initWithFrame:titleFrame];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = [listThumbNailEffectNames objectAtIndex:i];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [UIFont systemFontOfSize:titleFont];
        lblTitle.textColor = [UIColor whiteColor];
        
        [listThumbNailEffects addObject:imageView];
        
        [effectScrollView addSubview:imageView];
        [effectScrollView addSubview:btnImage];
        [effectScrollView addSubview:lblTitle];
    }
    
}

// statusbar manager
-(void)cancelApplyButton_Click
{
    NSLog(@"cancelApplyButton_Click");
    effectStatusbarView.hidden = YES;
    self.rootViewControler.btnHelp.hidden = YES;
    self.rootViewControler.previewImageView.hidden = NO;
    IEView.hidden = YES;
    // resize this view 
    // hide statusbar
    //resize frame of effect bar to reveal bottombar view, so user can interactive with it
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-effectStatusbarView.bounds.size.height);

}

-(void)applyButton_Click
{
    NSLog(@"ApplyButton_Click");
    effectStatusbarView.hidden = YES;
    self.rootViewControler.previewImageView.hidden = NO;
    IEView.hidden = YES;
    self.rootViewControler.btnHelp.hidden = YES;
    // resize this view
    //resize frame of effect bar to reveal bottombar view, so user can interactive with it
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-effectStatusbarView.bounds.size.height);

    if (!self.isFullVersion)
    {
        if (currentTag > kNumberOfFreeEffect)
        {
            [rootViewControler unlockFullVersion];
            return;
        }
    }
    hue         = [IEView getHue];
    saturation  = [IEView getSaturation];
    brightness  = [IEView getBrightness];
    contrast    = [IEView getContrast];
    opacity     = [IEView getOpacity];
    [self.rootViewControler f5Preview];
}
-(void)applyCurrentEffect
{
    //only apply when IEVIew is visible
    if (!IEView || IEView.hidden)
        return;
    
    [self applyButton_Click];
}
// show statusbar
-(void)showEffectStatusBar:(NSInteger)effectTag
{

    NSLog(@"effectTag:%ld",(long)effectTag);
    IEView.hidden = NO;
    self.rootViewControler.btnHelp.hidden = NO;

    int statusBarHeight;
    CGRect statusbarRect;
    CGRect applyBtnFrame;
    CGRect cancelBtnFrame;
    CGRect titleBoxFrame;
    int titleFontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        statusBarHeight = kStatusBarRectHeightIphone;
        statusbarRect = CGRectMake(kStatusBarRectXIphone, kStatusBarRectYIphone, kStatusBarRectWidthIphone, kStatusBarRectHeightIphone);
        cancelBtnFrame = CGRectMake(12, 1, 28, 28);
        applyBtnFrame = CGRectMake(280, 1, 28, 28);
        titleBoxFrame = CGRectMake(67, 1, 186, 32);
        titleFontSize = 16;
    } else
    {
        statusBarHeight = kStatusBarRectHeightIpad;
        statusbarRect = CGRectMake(kStatusBarRectXIpad, kStatusBarRectYIpad, kStatusBarRectWidthIpad, kStatusBarRectHeightIpad);
        cancelBtnFrame = CGRectMake(20, 8, 62, 62);
        applyBtnFrame = CGRectMake(686, 8, 62, 62);
        titleBoxFrame = CGRectMake(176, 8, 416, 69);
        titleFontSize = 32;

    }
    if(effectStatusbarView)
    {
        NSLog(@"existing effectStatusbarView");
        if (effectStatusbarView.hidden) {
            // change size for contain effectstatusbar
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height+statusBarHeight);
        }
        effectStatusbarView.hidden = NO;
    }
    else 
    {
       NSLog(@"create new effectStatusbarView");
        // resize of this view 
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height+statusBarHeight);
        
        // add status bar view
        effectStatusbarView =[[UIView alloc] initWithFrame:statusbarRect];
        UIImageView * statusImageView = [[UIImageView alloc] initWithFrame:effectStatusbarView.bounds];
        statusImageView.image = [UIImage imageNamed:@"StatusBar"];
        [effectStatusbarView addSubview:statusImageView];
        [self addSubview:effectStatusbarView];
        
        // add cancelEffectButton
        UIButton *cancelBtnOff =[UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtnOff.frame = cancelBtnFrame;
        [cancelBtnOff setImage:[UIImage imageNamed:@"StatusBarBackOff"] forState:UIControlStateNormal];
        [cancelBtnOff setImage:[UIImage imageNamed:@"StatusBarBackOn"] forState:UIControlStateHighlighted];
        [cancelBtnOff addTarget:self action:@selector(cancelApplyButton_Click) forControlEvents:UIControlEventTouchUpInside];
        [effectStatusbarView addSubview:cancelBtnOff];
        // add applyEffectButton
        UIButton *applyBtnOff =[UIButton buttonWithType:UIButtonTypeCustom];
        applyBtnOff.frame = applyBtnFrame;
        [applyBtnOff setImage:[UIImage imageNamed:@"StatusBarNextOff"] forState:UIControlStateNormal];
        [applyBtnOff setImage:[UIImage imageNamed:@"StatusBarNextOn"] forState:UIControlStateHighlighted];
        [applyBtnOff addTarget:self action:@selector(applyButton_Click) forControlEvents:UIControlEventTouchUpInside];
        [effectStatusbarView addSubview:applyBtnOff];
        
        statusBarTitle =  [[UILabel alloc] initWithFrame:titleBoxFrame];
        statusBarTitle.font = [UIFont systemFontOfSize:titleFontSize];
        statusBarTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"StatusBarBox"]];
        statusBarTitle.textColor =[UIColor whiteColor];
        statusBarTitle.textAlignment = NSTextAlignmentCenter;
        [effectStatusbarView addSubview:statusBarTitle];
    }
     // show text on title
     statusBarTitle.text = [listThumbNailEffectNames objectAtIndex:effectTag];

}
-(id)getFilterFromTag:(NSInteger)tag
{
    id result;
    switch (tag) {
        case 0:
            //original
            result = nil;
            break;
        case 1:
            result = [[GPUImageRomanticPinkFilter alloc]init];
            break;
        case 2:
            result = [[GPUImageFrezzingBlueFilter alloc]init];
            break;
        case 3:
            result = [[GPUImageFoliageFilter alloc]init];
            break;
        case 4:
            result = [[GPUImageVioletCoffeeFilter alloc]init];
            break;
        case 5:
            result = [[GPUImageWarmSummerFilter alloc]init];
            break;
        case 6:
            result = [[GPUImageColdSummerFilter alloc]init];
            break;
        case 7:
            result = [[GPUImageWildDarkBlueFilter alloc]init];
            break;
        case 8:
            result = [[GPUImageSpecialBlueFilter alloc]init];
            break;
        case 9:
            result = [[GPUImageFearlessFilter alloc]init];
            break;
        case 10:
            result = [[GPUImageMagicalCyanFilter alloc]init];
            break;
        case 11:
            result = [[GPUImageWarmForrestFilter alloc]init];
            break;
        case 12:
            result = [[GPUImageSummerForrestFilter alloc]init];
            break;
        case 13:
            result = [[GPUImageWarmLandscapeFilter alloc]init];
            break;
        case 14:
            result = [[GPUImageSexyRedFilter alloc]init];
            break;
        case 15:
            result = [[GPUImageWhiteFaceFilter alloc]init];
            break;
        case 16:
            result = [[GPUImageSoftWhiteFilter alloc]init];
            break;
        case 17:
            result = [[GPUImageLoveGreenFilter alloc]init];
            break;
        case 18:
            result = [[GPUImageVanpireFilter alloc]init];
            break;
        case 19:
            result = [[GPUImageGreenLandscapeFilter alloc]init];
            break;
        case 20:
            result = [[GPUImageMagentaLeavesFilter alloc]init];
            break;
        case 21:
            result = [[GPUImageGreenFodderFilter alloc]init];
            break;
        case 22:
            result = [[GPUImageDarkStreetFilter alloc]init];
            break;
        case 23:
            result = [[GPUImageGreenBoostFilter alloc]init];
            break;
        case 24:
            result = [[GPUImageCityNightFilter alloc]init];
            break;
        case 25:
            result = [[GPUImageColdWhiteFilter alloc]init];
            break;
        case 26:
            result = [[GPUImageTukiefFilter alloc]init];
            break;
        case 27:
            result = [[GPUImageVivaJupiFilter alloc]init];
            break;
        default:
            break;
    }
    return result;

}
-(void)applyEffect
{
    if (rootViewControler.previewImage == Nil)
    {
        NSLog(@"need load image first");
        return;
        
    }

    NSLog(@"Appling Effect");
    GPUImageFilterGroup *filter = [self getFilterFromTag:currentTag];
    if (!IEView)
    {
        CGRect IEViewFrame;
        IEViewFrame = [self.rootViewControler getDiplayFrameOfImageView: self.rootViewControler.previewImageView];
        IEView = [[HWInstantEffectView alloc] initWithFrame:IEViewFrame];
        IEView.backgroundColor = [UIColor clearColor];
        IEView.center = rootViewControler.previewImageView.center;
        [self.rootViewControler.view addSubview:IEView];
        //Show help at the first user load
        [self.rootViewControler.view bringSubviewToFront:self.rootViewControler.btnHelp];

        if ([self shouldAutoShowToolTip])
            [self.rootViewControler showToolTip];

    }
    
    IEView.hidden = NO;
    [IEView setFilter:filter andInputImage:rootViewControler.previewImage];
    [IEView processEffect];

}
-(UIImage*)applyEffectForImage:(UIImage*)image
{
//    NSAssert(IEView, @"not apply effect yet");
    if (!IEView){
        return image;
    }
    
    UIImage *filteredImage;
    GPUImageFilterGroup *selectedFilter = [self getFilterFromTag:currentTag];
    if (selectedFilter)
    {
        [selectedFilter removeAllTargets];
        [selectedFilter removeOutputFramebuffer];
        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
        [picture addTarget:selectedFilter];
        [selectedFilter useNextFrameForImageCapture];
        [picture processImage];
        filteredImage = [selectedFilter imageFromCurrentFramebuffer];
    }
    else
        filteredImage = image;
    NSLog(@"Size : %@ and %@", NSStringFromCGSize(image.size), NSStringFromCGSize(filteredImage.size));
    
//    return filteredImage;
    GPUImagePicture* backgroundPicNew  = [[GPUImagePicture alloc]initWithImage:image];
    GPUImagePicture* sourcePicNew      = [[GPUImagePicture alloc]initWithImage:filteredImage];
    
    GPUImageHueFilter* hueFilterNew                 = [[GPUImageHueFilter alloc] init];
    GPUImageSaturationFilter* saturationFilterNew   = [[GPUImageSaturationFilter alloc]init];
    GPUImageBrightnessFilter* brightnessFilterNew   = [[GPUImageBrightnessFilter alloc]init];
    GPUImageContrastFilter* contrastFilterNew       = [[GPUImageContrastFilter alloc]init];
    GPUImageAlphaBlendFilter* alphaFilterNew        = [[GPUImageAlphaBlendFilter alloc] init];
    
    hueFilterNew.hue                = hue;
    saturationFilterNew.saturation  = saturation;
    brightnessFilterNew.brightness  = brightness;
    contrastFilterNew.contrast      = contrast;
    alphaFilterNew.mix              = opacity;
    
    [sourcePicNew           addTarget:hueFilterNew];
    [hueFilterNew           addTarget:saturationFilterNew];
    [saturationFilterNew    addTarget:brightnessFilterNew];
    [brightnessFilterNew    addTarget:contrastFilterNew];
    
    [backgroundPicNew       addTarget:alphaFilterNew];
    [contrastFilterNew      addTarget:alphaFilterNew];
    
    [backgroundPicNew   processImage];
    [sourcePicNew       processImage];
    [alphaFilterNew useNextFrameForImageCapture];
    UIImage* outputImg = [alphaFilterNew imageFromCurrentFramebuffer];
    return outputImg;
}
-(BOOL)shouldAutoShowToolTip
{
    NSString* homeDir    = NSHomeDirectory();
    NSString* fullPath = [homeDir stringByAppendingPathComponent:@"blendConfigEffectToolTip.ini"];
    NSError* error = nil;
    NSStringEncoding encoding;
    NSString* contents = [NSString stringWithContentsOfFile:fullPath usedEncoding:&encoding
                                                      error:&error];
    if (contents)
        return NO;
    else
    {
        NSString *toolTipStr = @"YES";
        [toolTipStr writeToFile:fullPath atomically:NO encoding:NSASCIIStringEncoding error:&error];
        return YES;
    }
}
-(void)removeAll
{
    [self removeFromSuperview];
    if (IEView)
    {
        [IEView removeFromSuperview];
        IEView = nil;
    }
}
-(void)applyAllEffectForImage:(UIImage *)input
{
    NSLog(@"create thumnail for all effect");
    int numberOfFx = 28;
    for (int i=9; i<numberOfFx; i++)
    {
        NSLog(@"...%d", i);
        GPUImageFilterGroup *onefilter = [self getFilterFromTag:i];
        UIImage *output = [onefilter imageByFilteringImage:input];
        UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil);
        onefilter = nil;
    }
}
@end
