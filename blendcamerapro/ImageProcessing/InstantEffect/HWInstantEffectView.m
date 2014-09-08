//
//  HWInstantEffectView.m
//  imageprocessing
//
//  Created by Hai Hw on 8/13/12.
//
//

#import "HWInstantEffectView.h"
#import "GAI.h"
#import "Define.h"
#define kEpsilon            0.01

#define kDefaultOpacity     0.7
#define kDefaultHue         0.0
#define kDefaultSaturation  1.0
#define kDefaultBrightness  0.0
#define kDefaultConstrast   1.5

@implementation HWInstantEffectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initGUI];
    }
    return self;
}
-(void)initFilterChain
{
    if (filter)
        processedImage = [filter imageByFilteringImage:inputImage];
    else
        processedImage = inputImage;
    backgroundPic = [[GPUImagePicture alloc]initWithImage:inputImage];
    sourcePic = [[GPUImagePicture alloc]initWithImage:processedImage];
    
    hueFilter = [[GPUImageHueFilter alloc] init];
    saturationFilter = [[GPUImageSaturationFilter alloc]init];
    brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
    contrastFilter = [[GPUImageContrastFilter alloc]init];
    alphaFilter = [[GPUImageAlphaBlendFilter alloc] init];
    
    [sourcePic addTarget:hueFilter];
    [hueFilter addTarget:saturationFilter];
    [saturationFilter addTarget:brightnessFilter];
    [brightnessFilter addTarget:contrastFilter];
    
    [backgroundPic addTarget:alphaFilter];
    [contrastFilter addTarget:alphaFilter];
    [alphaFilter addTarget:imageView];
    
}
-(void)setFilter:(GPUImageFilterGroup *)newfilter andInputImage:(UIImage*)image;
{
    inputImage = image;
    filter = newfilter;
    adjustmentLayerParameters = [[NSMutableArray alloc]initWithArray:defaultParameters];
    [self initFilterChain];
}
-(void)initGUI
/* apply instant effect and display on UIImageView
* init menuView
*/
{
    self.backgroundColor = [UIColor clearColor];
    NSArray* layerNames = [[NSArray alloc] initWithObjects:
                           @"Effect Opacity",
                           @"Hue",
                           @"Saturation",
                           @"Brightness",
                           @"Contrast",
                           nil];
    NSArray* parameters = @[@kDefaultOpacity,
                             @kDefaultHue,
                             @kDefaultSaturation,
                             @kDefaultBrightness,
                             @kDefaultConstrast];
    defaultParameters = [[NSArray alloc] initWithArray:parameters];
    NSLog(@"New instant effect, need assign inputImage and filter");
    adjustmentLayersNames = layerNames;
    adjustmentLayerParameters = [[NSMutableArray alloc]initWithArray:parameters];
    
    //Image View
    imageView = [[GPUImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:imageView];
    
    menuView = [[HWEffectMenuView alloc] initWithItems:adjustmentLayersNames];
    menuView.center = self.center;
    [self addSubview:menuView];
    menuView.hidden = YES;
    
    menuStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 24)];
    menuStatusLabel.center = CGPointMake(self.frame.size.width/2, 20);
    menuStatusLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    menuStatusLabel.layer.cornerRadius = 10;
    menuStatusLabel.layer.masksToBounds = YES;
    menuStatusLabel.layer.shadowOffset = CGSizeMake(3, 0);
    menuStatusLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    menuStatusLabel.layer.shadowRadius = 5;
    menuStatusLabel.layer.shadowOpacity = .25;
    menuStatusLabel.layer.borderWidth = 2;
    menuStatusLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    menuStatusLabel.textColor = [UIColor whiteColor];
    menuStatusLabel.shadowColor = [UIColor blueColor];
    menuStatusLabel.font = [UIFont fontWithName:@"System Bold" size:18];
    menuStatusLabel.text = @"";
    menuStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:menuStatusLabel];
    menuStatusLabel.hidden = YES;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
}


-(IBAction)panGestureHandler:(UIPanGestureRecognizer*) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        previousLocationPanGesture = [recognizer locationInView:self];
        menuState = menuViewStateNone;
        menuStatusLabel.hidden = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self];
        float dx = location.x-previousLocationPanGesture.x;
        float dy = location.y-previousLocationPanGesture.y;
        if ( (menuState == menuViewStateParameterChanging && abs(dx)<1)
            || (menuState == menuViewStateMenuChoosing && abs(dy)<1))
            return;
        
        previousLocationPanGesture = location;
        float opacityChangeValue;
        switch (menuState) {
            case menuViewStateNone:
                if (fabs(dx) > fabs(dy))
                    menuState = menuViewStateParameterChanging;
                else
                {
                    menuState = menuViewStateMenuChoosing;
                    menuView.hidden = NO;
                }
                break;

            case menuViewStateMenuChoosing:
                [menuView moveBy:dy];
                int value = (int)100*[[adjustmentLayerParameters objectAtIndex:menuView.getCurrentItem] floatValue];
                menuStatusLabel.text = [NSString stringWithFormat:@"%@ : %d", [adjustmentLayersNames objectAtIndex:menuView.getCurrentItem], value];

                break;
            case menuViewStateParameterChanging:
                if (dx>0)
                    opacityChangeValue = 0.01f;
                else
                    opacityChangeValue =-0.01f;

                [self changeParameterOfLayerHasIndex:menuView.getCurrentItem withValue:opacityChangeValue];
//uncomment below line to make real-time process
                [self processEffect];
                

                break;
            default:
                break;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        menuView.hidden = YES;
        menuStatusLabel.hidden = YES;
        if (menuState == menuViewStateParameterChanging)
        {
            [self processEffect];
        }

        //Google analytics
//        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Frame"
//                                                        withAction:kGAEventActionButtonTap
//                                                         withLabel:kGAEventCustomEffect
//                                                         withValue:nil];
        
    }
}
-(void)changeParameterOfLayerHasIndex:(NSInteger)layerIndex withValue:(float)value
{
    
    float newValue = [[adjustmentLayerParameters objectAtIndex:layerIndex] floatValue ] + value;
    
    int changedValueInt;
    switch (layerIndex) {
        case 0:
            //Opacity
            newValue = MAX(0, MIN(1.0, newValue));
            break;
        case 1:
            //Hue
            newValue = MAX(-1.80, MIN(1.80, newValue));
            break;
        case 2:
            //Saturation
            newValue = MAX(0, MIN(2.0, newValue));
            
            break;
        case 3:
            newValue = MAX(-1.0, MIN(1.0, newValue));
            break;
        case 4:
            //Contrast
            newValue = MAX(0.0, MIN(4.0, newValue));
            break;
        default:
            break;
    }
    NSLog(@"%f %f", newValue, value);
    [adjustmentLayerParameters replaceObjectAtIndex:layerIndex withObject:[NSNumber numberWithFloat:newValue]];
    changedValueInt = (int)roundf(100*newValue);
    menuStatusLabel.text = [NSString stringWithFormat:@"%@ : %d", [adjustmentLayersNames objectAtIndex:layerIndex], changedValueInt];
    
}

-(void)processEffect
{
    NSDate* start = [NSDate date];
    float newValue;
//    [self initFilterChain];
    alphaFilter.mix             = [[adjustmentLayerParameters objectAtIndex:0] floatValue];
    newValue                    = [[adjustmentLayerParameters objectAtIndex:1] floatValue];
    hueFilter.hue = (int)roundf(100*newValue);
    saturationFilter.saturation = [[adjustmentLayerParameters objectAtIndex:2] floatValue];
    brightnessFilter.brightness = [[adjustmentLayerParameters objectAtIndex:3] floatValue];
    contrastFilter.contrast     = [[adjustmentLayerParameters objectAtIndex:4] floatValue];
    
//add target filter
    [backgroundPic processImage];
    [sourcePic processImage];
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time : %f", -timeInterval);

}
#pragma -
#pragma getter
-(float)getHue
{
    return hueFilter.hue;
}
-(float)getSaturation
{
    return saturationFilter.saturation;
}
-(float)getBrightness
{
    return brightnessFilter.brightness;
}
-(float)getContrast
{
    return contrastFilter.contrast;
}
-(float)getOpacity
{
    return alphaFilter.mix;
}

@end
