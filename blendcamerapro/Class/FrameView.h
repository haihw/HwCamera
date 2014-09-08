//
//  FrameView.h
//  blendcamerapro
//
//  Created by ToanDK on 9/20/12.
//
//

#import <UIKit/UIKit.h>
@class ViewController;
@interface FrameView : UIView
{
    ViewController * rootViewController;
    NSMutableArray * listOfFrameNames; // contains list name of frame
    
    NSInteger currentTag;
    NSMutableArray * listThumbNailFrames;
    UIScrollView * thumnailScroll; // scroll view
}

@property(nonatomic,strong) NSMutableArray * listOfFrameNames;
@property(nonatomic,strong) ViewController * rootViewController;
@property(nonatomic,strong) NSMutableArray * listThumbNailFrames;

- (id)initWithFrame:(CGRect)frame;
// apply frame overlay filter
-(UIImage *)applyFrameFilterEffect:(UIImage *) inputImage withOverlay:(UIImage *)overlayImage alphalDegree:(float) alpha;
-(UIImage*)applyFrameForImage:(UIImage*) inputImage;
-(void)removeAll;
@end
