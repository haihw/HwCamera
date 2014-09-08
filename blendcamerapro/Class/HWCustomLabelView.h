//
//  HWCustomLabelView.h
//  blendcamerapro
//
//  Created by Hai Hw on 9/18/12.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    menuViewStateMenuChoosing,
    menuViewStateParameterChanging,
    menuViewStateNone,
}MenuViewState;
@class HWEffectMenuView, ViewController, TextView;
@interface HWCustomLabelView : UIView
{
    HWEffectMenuView            *menuView;
    //for menuview
    CGPoint                     startLocationPanGesture;
    CGPoint                     previousLocationPanGesture;
    MenuViewState               menuState;
    UILabel                     *menuStatusLabel;

    NSArray                     *adjustmentLayersNames;
    NSMutableArray              *adjustmentLayerParameters;
    NSArray                     *defaultParameters;
    UIImage                     *processedImage;
    
    UIView                      *colorPreview;
}
@property (nonatomic, strong) ViewController *rootViewController;
@property (nonatomic, strong) TextView *textView;

@end
