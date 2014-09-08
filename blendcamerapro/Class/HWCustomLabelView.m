//
//  HWCustomLabelView.m
//  blendcamerapro
//
//  Created by Hai Hw on 9/18/12.
//
//
#define kEpsilon            0.01

#include <QuartzCore/QuartzCore.h>

#import "HWCustomLabelView.h"
#import "HWEffectMenuView.h"
#import "ViewController.h"
#import "TextView.h"
#import "DraggableView.h"


@implementation HWCustomLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initGUI];
        
    }
    return self;
}
-(void)initGUI
/* apply instant effect and display on UIImageView
* init menuView
*/
{
    NSArray* layerNames = [[NSArray alloc] initWithObjects:
                           @"Text Color",
                           @"Stroke Width",
                           @"Stroke Color",
                           @"Glow Amount",
                           @"Glow Color",
                           nil];
    NSArray* parameters = [NSArray  arrayWithObjects:
                           [NSNumber numberWithFloat:1],
                           [NSNumber numberWithFloat:0.15],
                           [NSNumber numberWithFloat:0],
                           [NSNumber numberWithFloat:0],
                           [NSNumber numberWithFloat:0],
                           nil];
    defaultParameters = [[NSArray alloc] initWithArray:parameters];
    NSLog(@"New Custom Text View");
    adjustmentLayersNames = layerNames;
    adjustmentLayerParameters = [[NSMutableArray alloc]initWithArray:parameters];
    
    //Image View
    
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(tapGestureHandle)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    int previewSquareSize = 40;
    CGRect colorPreviewFrame = CGRectMake((self.bounds.size.width - previewSquareSize)/1, 0, previewSquareSize, previewSquareSize);
    colorPreview = [[UIView alloc] initWithFrame:colorPreviewFrame];
    colorPreview.backgroundColor = [UIColor clearColor];
    colorPreview.layer.cornerRadius = 10;
    colorPreview.layer.masksToBounds = YES;
    [self addSubview:colorPreview];
    colorPreview.hidden = YES;
}
-(IBAction)panGestureHandler:(UIPanGestureRecognizer*) recognizer
{
    DraggableView *currentTextItem = self.rootViewController.getCurrentStickerItem;
    if (!currentTextItem || !currentTextItem.isTextContent)
    {
        NSLog(@"ERROR ! No Text Item To Update");
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        previousLocationPanGesture = [recognizer locationInView:self];
        menuState = menuViewStateNone;
        menuStatusLabel.hidden = NO;
        [self.superview bringSubviewToFront:self];

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
                // [self processEffect];
                
                
                break;
            default:
                break;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.superview insertSubview:self aboveSubview:self.rootViewController.clearButton];
        menuView.hidden = YES;
        menuStatusLabel.hidden = YES;
        if (menuState == menuViewStateParameterChanging)
        {
            [self applyChange];
        }
        colorPreview.hidden = YES;
    }
}
-(void)changeParameterOfLayerHasIndex:(NSInteger)layerIndex withValue:(float)value
{
    
    float newValue = [[adjustmentLayerParameters objectAtIndex:layerIndex] floatValue ] + value;
    
    int changedValueInt;
    switch (layerIndex) {
        case 0:
            //text color
            newValue = MAX(0, MIN(1.8, newValue));
            colorPreview.backgroundColor = [self getColorFromValue:newValue];
            colorPreview.hidden = NO;
            break;
        case 1:
            //Stroke Width
            newValue = MAX(0, MIN(1.0, newValue));
            break;
        case 2:
            //Stroke Color
            newValue = MAX(0, MIN(1.8, newValue));
            colorPreview.backgroundColor = [self getColorFromValue:newValue];
            colorPreview.hidden = NO;
            break;
        case 3:
            //Glow Amount
            newValue = MAX(0, MIN(1.0, newValue));
            
            break;
        case 4:
            //Glow Color
            newValue = MAX(0, MIN(1.8, newValue));
            colorPreview.backgroundColor = [self getColorFromValue:newValue];
            colorPreview.hidden = NO;
            break;
        default:
            break;
    }
    NSLog(@"%f %f", newValue, value);
    [adjustmentLayerParameters replaceObjectAtIndex:layerIndex withObject:[NSNumber numberWithFloat:newValue]];
    changedValueInt = (int)roundf(100*newValue);
    menuStatusLabel.text = [NSString stringWithFormat:@"%@ : %d", [adjustmentLayersNames objectAtIndex:layerIndex], changedValueInt];
    
}
-(UIColor*)getColorFromValue:(float)value
{
    int colorInt = (int)roundf(value*100);
    if (colorInt < 1)
        return [UIColor whiteColor];
    if (colorInt > 179)
        return [UIColor blackColor];
    
    return [UIColor colorWithHue:(float)colorInt/180 saturation:1 brightness:1 alpha:1];
}
-(void)applyChange
{
    NSLog(@"apply change");
    int strokeWidthInt = (int)roundf([[adjustmentLayerParameters objectAtIndex:1] floatValue]*100);
    int glowAmountInt = (int)roundf([[adjustmentLayerParameters objectAtIndex:3] floatValue]*100);
    
    UIColor *strokeColor;
    UIColor *glowColor;
    UIColor *textColor;
    
    //set threshhold to get white color and black color
    textColor = [self getColorFromValue:[[adjustmentLayerParameters objectAtIndex:0] floatValue]];
    strokeColor = [self getColorFromValue:[[adjustmentLayerParameters objectAtIndex:2] floatValue]];
    glowColor = [self getColorFromValue:[[adjustmentLayerParameters objectAtIndex:4] floatValue]];
    self.textView.textColor = textColor;
    self.textView.strokeWidth = strokeWidthInt/3;
    self.textView.glowAmount = glowAmountInt;
    self.textView.strokeColor = strokeColor;
    self.textView.glowColor = glowColor;
    
    [self.textView updateCurrentTextItem];
}
-(void)tapGestureHandle
{
    NSLog(@"tap");
    [self.rootViewController tapPreviewImageViewHandle];
}
@end
