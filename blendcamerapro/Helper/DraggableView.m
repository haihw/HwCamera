//
//  DraggableView.m
//
//  Created by Dung NP on 8/9/12.
//  Last Modified by Hai HW on 13/9/12
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import "DraggableView.h"
#import "TextView.h"

#define kEpsilon 0.0001
#define kSPUserResizableViewGlobalInset 5
#define kSPUserResizableViewDefaultMinWidth 48
#define kSPUserResizableViewDefaultMinHeight 48
#define kSPUserResizableViewInteractiveBorderSize 20

#define kMinSaleLimitedRate 0.8f

//below rate is depend on screen size
#define kMaxHeightItem 1.2
#define kMinHeightItemIpad 0.1
#define kMinHeightItemIphone 0.15

//Below define size of two button on border view
#define kBorderButtonSize 10
@interface SPGripViewBorderView : UIView
{
    UIView * closeView;  // close button on the topleft
    UIView * movingScaleView; //moving or rotation button on the right bottom 
}
@property(nonatomic,strong)  UIView * movingScaleView;
@property(nonatomic,strong)  UIView * closeView;  // close button on the topleft

@end

@implementation SPGripViewBorderView
@synthesize movingScaleView;
@synthesize closeView;


- (id)initWithFrame:(CGRect)frame {
    //Init Frame of SPGripViewBorderView
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
        // lowerRight
        movingScaleView =[[UIView alloc] initWithFrame:CGRectMake(frame.size.width-1, frame.size.height-1, kBorderButtonSize,kBorderButtonSize )];
        [self addSubview:movingScaleView];
        // upperLeft
        closeView = [[UIView alloc] initWithFrame:CGRectMake(0,0, kBorderButtonSize,kBorderButtonSize )];
        [self addSubview:closeView];

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
//    NSLog(@"SPGripViewBorderView DrawRect");
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(0.0, 0.0, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    // add topleft view
    closeView.userInteractionEnabled = YES;
    closeView.frame = upperLeft;
    
    
    CGRect lowerRight = CGRectMake(self.bounds.size.width - kSPUserResizableViewInteractiveBorderSize, self.bounds.size.height - kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize, kSPUserResizableViewInteractiveBorderSize);
    // add bottom right 
    movingScaleView.frame = lowerRight;
    movingScaleView.userInteractionEnabled = YES;
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = { 
        0.4, 0.8, 1.0, 1.0, 
        0.0, 0.0, 1.0, 1.0
    };
    
    CGFloat colors2 [] = { 
        1.0, 1.0, 1.0, 1.0, 
        1.0, 0.1, 0.1, 1.0
    };

    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(baseSpace, colors2, NULL, 2);
    
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    
    CGRect allPoints[2] = { upperLeft, lowerRight};
    
    for (NSInteger i = 0; i < 2; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        if (i==0) {
              CGContextDrawLinearGradient(context, gradient2, startPoint, endPoint, 0);
            [[UIImage imageNamed:@"closeIcon"] drawInRect:upperLeft];
        }else {
              CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
            [[UIImage imageNamed:@"rotateIcon"] drawInRect:lowerRight];
        }
      
        CGContextRestoreGState(context);
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGGradientRelease(gradient2), gradient2 = NULL;
    CGContextRestoreGState(context);
}

@end


@implementation DraggableView
@synthesize limitedMovingRegion;
@synthesize parentController;

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:self.bounds];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    minScaleHeightItem = kMinHeightItemIphone * [UIScreen mainScreen].bounds.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        minScaleHeightItem = kMinHeightItemIpad * [UIScreen mainScreen].bounds.size.width;
    
    maxScaleHeightItem = kMaxHeightItem * [UIScreen mainScreen].bounds.size.width;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"init");
        // Initialization code
        [self setupDefaultAttributes];
        self.autoresizesSubviews = YES;
        self.isTextContent = NO;
    }
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchItemHandle:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    pinchGestureRecognizer.delegate = self;
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationItemHandle:)];
    [self addGestureRecognizer:rotationGestureRecognizer];
    rotationGestureRecognizer.delegate = self;

    //double tap by one finger to edit text
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]init];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [tapGestureRecognizer addTarget:self action:@selector(doubleTapDragableItemHandle)];
    [self addGestureRecognizer:tapGestureRecognizer];

    
    //double tap by 2 finger to send view to back
//    UITapGestureRecognizer *tap2FingerGestureRecognizer = [[UITapGestureRecognizer alloc]init];
//    tap2FingerGestureRecognizer.numberOfTapsRequired = 2;
//    tap2FingerGestureRecognizer.numberOfTouchesRequired = 2;
//    [tap2FingerGestureRecognizer addTarget:self action:@selector(doubleTap2FingerHandle)];
//    [self addGestureRecognizer:tap2FingerGestureRecognizer];

    return self;

}
-(void)doubleTapDragableItemHandle
{
    NSLog(@"abc");
    if ([self isTextContent])
        [self.parentController.textView doubleTapDragableItemHandle];
    else
    {
        CGAffineTransform Hflip = CGAffineTransformMake(-1, 0, 0, 1, 0, 1);
        contentView.transform = CGAffineTransformConcat(contentView.transform, Hflip);
    }
}
-(void)doubleTap2FingerHandle
{
    [self.parentController.view insertSubview:self aboveSubview:self.parentController.clearButton];
    [self.parentController.listDraggableItems insertObject:self atIndex:0];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(IBAction)pinchItemHandle:(UIPinchGestureRecognizer*)pinchGesture
{
    float scaleRate = pinchGesture.scale;
    NSLog(@"scale: %f", scaleRate);
    [self scaleSizeForAllView:scaleRate];
}
-(IBAction)rotationItemHandle:(UIRotationGestureRecognizer*)aGesture
{
    float angle = aGesture.rotation;
    NSLog(@"rotate: %f", angle);
    if (aGesture.state == UIGestureRecognizerStateBegan)
        preTransform = self.transform;
    
//    self.transform = CGAffineTransformMakeRotation(angle);
    CGAffineTransform rotateTransform =  CGAffineTransformMakeRotation(angle);
    self.transform = CGAffineTransformConcat(preTransform, rotateTransform);

}

#pragma  handle touch event to scale & rotation content view image

-(BOOL) touchOnRightBottomView:(CGPoint) touch
{
    if (touch.x > borderView.movingScaleView.frame.origin.x-5 && touch.y > borderView.movingScaleView.frame.origin.y-5) {
        return YES;
    }

    return NO;
}

-(BOOL) touchOnLeftTopView:(CGPoint) touch
{
    if (touch.x < borderView.closeView.frame.size.width+5 && touch.y < borderView.closeView.frame.size.height+5) {
        return YES;
    }
    
    return NO;
}

// handle touchesBegan
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    preTransform = self.transform;
    preLocation =  [aTouch locationInView: self.superview];
    originalBounds = self.bounds;
    CGPoint touchOnView = [aTouch locationInView:self];

    if([self touchOnLeftTopView:touchOnView])
    {
        // remove item from listitems
        [self.parentController removeStickerItemView:self];
    }
    else 
    {
        isSelectedControlPoint = NO;
        [self.parentController setCurrenStickertItemView:self];

        if ([self touchOnRightBottomView:touchOnView] )
        {
            isSelectedControlPoint = YES;
            center = self.center;
        }
        
    }
}

// define rotation direction
-(int) CCW:(CGPoint)p1 :(CGPoint)p2  :(CGPoint)p3
{
  float a1, b1, a2, b2, t;
  float Eps = kEpsilon;
   a1 = p2.x -p1.x;
   b1 = p2.y -p1.y;
   a2 = p3.x -p2.x;
   b2 = p3.y -p2.y;
   t = a1*b2 - a2*b1;
   if (abs(t) < Eps) 
   {
        return 0;
   }
   else if (t > 0)
   {
       return 1;
   }
   else return (-1);
}

// calculate cossProduct
-(float) cossProduct:(CGPoint)a with:(CGPoint)b angle:(float) anphal
{
    float distanceA = sqrtf(a.x*a.x + a.y*a.y);
    float distanceB = sqrtf(b.x*b.x + b.y*b.y);
    float cossProduct = distanceA*distanceB*sin(anphal);
    return cossProduct;
}

// scale & rotation uiview
-(void) scaleAndRotationView:(CGPoint) location
{
    //1. Scale first
    float preDistance = sqrtf(powf(preLocation.x -self.center.x, 2)+powf(preLocation.y-self.center.y, 2));
    float currDistance = sqrtf(powf(location.x-self.center.x, 2)+powf(location.y-self.center.y, 2));
    
    if (preDistance  < kEpsilon || currDistance < kEpsilon)
        return;
    float scaleRate = currDistance/preDistance;

    [self scaleSizeForAllView:scaleRate];

    //2. Rotation
    // calculate cosin of 2 vectors 
    float distanceOfVectorAB = sqrtf(powf(preLocation.x-location.x, 2)+powf(preLocation.y-location.y, 2));
    
    float cosinACB = preDistance*preDistance + currDistance*currDistance - powf(distanceOfVectorAB, 2);
    cosinACB = cosinACB/(2*preDistance*currDistance);
    float angleACB = acosf(cosinACB);
    currRotationAngle = angleACB;
    // calculate crossproduct
    int rotationDirection = [self CCW:preLocation :self.center :location];
    currRotationDirection = rotationDirection;
    if (rotationDirection > 0)
        angleACB = -angleACB;
    
//    self.transform = CGAffineTransformMakeRotation(angleACB);
    CGAffineTransform rotateTransform =  CGAffineTransformMakeRotation(angleACB);
    self.transform = CGAffineTransformConcat(preTransform, rotateTransform);

}


-(void) scaleSizeForAllView:(float)scaleRate
{
    float newWf = originalBounds.size.width*scaleRate;
    float newHf = originalBounds.size.height*scaleRate;
    
    if (newHf < minScaleHeightItem || newHf > maxScaleHeightItem ||
        newWf < minScaleHeightItem || newWf > maxScaleHeightItem)
    {
        NSLog(@"Wrong Size %f, %f", newHf, newWf);
        return;
    }
    int newH = (int)roundf(newHf);
    int newW = (int)roundf(newWf);
    NSLog(@"New Size %d, %d", newH, newW);

    self.bounds = CGRectMake(0, 0, newW, newH);

    CGRect contentFrame = CGRectMake(kBorderButtonSize, kBorderButtonSize, self.bounds.size.width  - kBorderButtonSize*2, self.bounds.size.height - kBorderButtonSize*2);
    contentView.frame = contentFrame;
    borderView.frame  = self.bounds;
    [borderView setNeedsDisplay];

}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
 
    isMoving = TRUE;
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    if (isSelectedControlPoint) 
    {
        [self scaleAndRotationView:location];
    }
    else 
    {
        // pan the UIView to destination location     
        CGPoint translatedPoint = CGPointMake(location.x - preLocation.x, location.y - preLocation.y);
        
        CGPoint centerTranslatedPoint = CGPointMake(self.center.x + translatedPoint.x, self.center.y+translatedPoint.y);

        if ([self canMoveToCenter:centerTranslatedPoint])
            self.center = centerTranslatedPoint;
        preLocation = location;
    }
    
}
-(bool)canMoveToCenter:(CGPoint)newCenter
{
    CGRect imageFrame =  self.parentController.previewImageView.frame;
    //limited area is the preview frame area plus a half of item size
    CGRect limitedArea = CGRectMake(imageFrame.origin.x - self.bounds.size.width/2,
                                    imageFrame.origin.y - self.bounds.size.height/2,
                                    imageFrame.size.width + self.bounds.size.width,
                                    imageFrame.size.height + self.bounds.size.height);
    return CGRectContainsPoint(limitedArea, newCenter);
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isMoving = FALSE;
   
}



// mange add ContentView and show or hide editting mode

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    CGRect contentFrame = CGRectMake(kBorderButtonSize, kBorderButtonSize, self.bounds.size.width  - kBorderButtonSize*2, self.bounds.size.height - kBorderButtonSize*2);
    contentView.frame = contentFrame;
    contentView.backgroundColor =[UIColor clearColor];
    [self insertSubview:contentView belowSubview:borderView];
    
}

- (void)hideEditingHandles
{
    [borderView setHidden:YES];
}
- (void)showEditingHandles
{
    [borderView setHidden:NO];
}

-(id)copy
{
    DraggableView* new = [[DraggableView alloc] initWithFrame:self.frame];
    
    UIImage *imageContent = [((UIImageView*)contentView).image copy];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:imageContent];
    [new setContentView:imgView];
    imgView.frame = contentView.frame;

    new.center = self.center;
    new.bounds = self.bounds;
    new.transform = self.transform;
    return new;
}
-(id)copyWithZone:(NSZone*)zone
{
    return [self copy];
}
@end
