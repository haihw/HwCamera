//
//  FrameView.m
//  blendcamerapro
//
//  Created by ToanDK on 9/20/12.
//
//
#import "Define.h"
#import "EffectView.h"
#import "ViewController.h"
#import "FrameView.h"
#import "UIImage+Resize.h"
#import "GPUImage.h"
#import <QuartzCore/QuartzCore.h>

#import "GAI.h"
@implementation FrameView
@synthesize listOfFrameNames;
@synthesize rootViewController;
@synthesize listThumbNailFrames;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createGUI];
    }
    return self;
}


-(void) createGUI
{
    [self createThumbNailFrames];
    
}

-(void) initThumnailNames
{
    // setup list frame names
    listOfFrameNames =[[NSMutableArray alloc] initWithObjects:
                       @"No Frame",
                       @"Vignette",
                       @"CenterBlur",
//                       
//                       @"RedFlower",
//                       @"Red PTR",
//                       @"Card 1",
//
                       @"Sewing",
                       @"Cyan Button",
//
//                       @"Gift",
//                       @"Heart",
//                       @"Noel Tree",
//                       @"Card 2",
//                       @"Tree",
//                       @"Silver Gift",
//                       @"Red Gift",
//                       @"Pattern",
//                       @"Xmas Tree",
//                       @"WR frame",
//                       @"Red Card",
//                       @"Green Card",
//                       @"Santa",
//                       @"Snow",
//
                       @"Orange",
                       @"Wood",
                       @"Simple",
                       @"Blue Tile",
                       @"Violet Tile",
                       @"Sponge",
                       @"Butterfly",
                       @"Black",
                       @"Blue Sun",
                       @"Red",
                       @"White Cloud",
                       @"Chalk",
                       @"Pencil",
                       @"Old Pencil",
                       nil];
    
}
-(void) createThumbNailFrames
{
    [self initThumnailNames];
    // create thumbnail scroll
    thumnailScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];

    NSLog(@"createThumbNailEffects");
    listThumbNailFrames = [[NSMutableArray alloc] initWithCapacity:0];
    float width = kEffectWidthIpad;
    float height = kEffectHeightIpad;
    int x =kEffectScrollLeftAlignIpad;
    int y =0+kMovingTopDistanceIpad;
    int space2Effect = kSpace2EffectIpad;
    int titleHeight = 16;
    int titleFont = 15;
    CGSize scrollSize = CGSizeMake(kEffectScrollLeftAlignIpad + kEffectScrollRightAlignIpad + listOfFrameNames.count*kEffectWidthIpad + (listOfFrameNames.count-1)*kSpace2EffectIpad, kEffectHeightIpad);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        NSLog(@"iphone");
        width = kEffectWidthIphone;
        height = kEffectHeightIphone;
        x = kEffectScrollLeftAlign;
        y = kMovingTopDistanceIphone;
        space2Effect = kSpace2EffectIphone;
        titleFont = 7;
        titleHeight = 8;
        scrollSize = CGSizeMake(kEffectScrollLeftAlign +kEffectScrollRightAlign + listOfFrameNames.count*kEffectWidthIphone + (listOfFrameNames.count-1)*space2Effect, thumnailScroll.frame.size.height);
    }
    for (int i =0; i < listOfFrameNames.count; i++) {
        //NSString * imagename = [listOfFrameNames objectAtIndex:i];
        NSString *imagename =[NSString stringWithFormat:@"%@%d_tn",kFrame_Prefixname, i];
        NSLog(@"imagename:%@",imagename);
        UIImage * image = [UIImage imageNamed:imagename];
        CGRect frame = CGRectMake(x+i*(width+space2Effect),y,width, height);
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.image = image;
        imageView.tag = i;
        // create custome buttons
        UIButton * btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImage.frame = imageView.frame;
        btnImage.tag = i;
        [btnImage addTarget:self action:@selector(frameItem_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        // add the title lable effects
        CGRect titleFrame = CGRectMake(frame.origin.x, height +y, width, titleHeight);
        UILabel * lblTitle = [[UILabel alloc] initWithFrame:titleFrame];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = [listOfFrameNames objectAtIndex:i];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        lblTitle.font = [UIFont systemFontOfSize:titleFont];
        lblTitle.textColor = [UIColor whiteColor];
        
        [listThumbNailFrames addObject:imageView];
        
        [thumnailScroll addSubview:imageView];
        [thumnailScroll addSubview:btnImage];
        [thumnailScroll addSubview:lblTitle];
    }
    thumnailScroll.contentSize = scrollSize ;
    [self addSubview:thumnailScroll];

}

-(IBAction)frameItem_Click:(UIButton*)sender
{
    
    NSLog(@"frameItem_Click, sender.tag:%ld",(long)sender.tag);
    //Google analytics
//    NSString *gaEventName = [NSString stringWithFormat:@"%@ %@", kGAEventFramePrefix, listOfFrameNames[sender.tag]];
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Frame"
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
    UIImageView * currentSelectedImage = [listThumbNailFrames objectAtIndex:currentTag];
    currentSelectedImage.frame = currentFrame;
//    currentSelectedImage.backgroundColor = [UIColor clearColor];
    currentSelectedImage.layer.shadowOpacity = 0;
    currentSelectedImage.layer.borderWidth = 0;
    // update current selected tag
    currentTag = sender.tag;
    
    // scroll to current tag
    xCurrent = leftAlign + currentTag*effectWidth +currentTag*effectSpace;
    currentFrame = CGRectMake(xCurrent, yCurrent, effectWidth, effectHeight);
    [thumnailScroll scrollRectToVisible:currentFrame animated:YES];
    
    // Scale up the selected image to heighter than others
    UIImageView * imageView = (UIImageView*)[listThumbNailFrames objectAtIndex:sender.tag];
    imageView.center = CGPointMake(imageView.center.x, imageView.center.y-effectMovingTop+effectMovingTop - selectedEffectExpand);

    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [[UIColor colorWithRed:0 green:204.0f/255 blue:1 alpha:1] CGColor];
    imageView.layer.shadowColor = [[UIColor colorWithRed:0 green:204.0f/255.0f blue:1 alpha:1] CGColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 0);
    imageView.layer.shadowRadius = selectedEffectExpand;
    imageView.layer.shadowOpacity = 1;

    [self.rootViewController f5Preview];

}

// apply frame overlay filter
-(UIImage *)applyFrameFilterEffect:(UIImage *) inputImage withOverlay:(UIImage *)overlayImage alphalDegree:(float) alpha
{
  
    GPUImageAlphaBlendFilter * alphaBlend = [[GPUImageAlphaBlendFilter alloc] init];
    alphaBlend.mix = alpha;
    
    GPUImagePicture* picture1 = [[GPUImagePicture alloc] initWithImage:inputImage];
    GPUImagePicture* picture2 = [[GPUImagePicture alloc] initWithImage:overlayImage];
    [picture1 addTarget:alphaBlend];
    [picture1 processImage];
    [picture2 addTarget:alphaBlend];
    [picture2 processImage];
    
    [alphaBlend useNextFrameForImageCapture];
    UIImage* blendImage = [alphaBlend imageFromCurrentFramebufferWithOrientation:inputImage.imageOrientation];
    
    return blendImage;
}
-(UIImage*)applyFrameForImage:(UIImage*) inputImage
{
    if (currentTag == 0)
    {
        return inputImage;
    }
    
    GPUImageOutput *frameFilter;
    switch (currentTag) {
        case 1:
            NSLog(@"vignette");
            frameFilter = [[GPUImageVignetteFilter alloc]init];
            return [frameFilter imageByFilteringImage:inputImage];
            break;
        case 2:
            NSLog(@"tilt-Shift");
            frameFilter = [[GPUImageGaussianSelectiveBlurFilter alloc]init];
            ((GPUImageGaussianSelectiveBlurFilter*)frameFilter).excludeCircleRadius = 0.5;
            return [frameFilter imageByFilteringImage:inputImage];
        default:
            break;
    }
    UIImage *result;
    @autoreleasepool {

        __weak NSString *imagename =[NSString stringWithFormat:@"%@%ld",kFrame_Prefixname, (long)currentTag];
        __weak UIImage * frameImg = [UIImage imageNamed:imagename];
        if (!frameImg){
            result = inputImage;
        } else
            result = [self applyFrameFilterEffect:inputImage withOverlay:frameImg alphalDegree:1.0f];
        frameImg = nil;
        imagename = nil;
    }
    return result;
    
}
-(void)removeAll
{
    [self removeFromSuperview];
}
@end
