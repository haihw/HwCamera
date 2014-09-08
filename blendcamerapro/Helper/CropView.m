//
//  CropView.m
//  blendcamerapro
//
//  Created by Do Khanh Toan on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CropView.h"
#import "UtilityView.h"

//below rate is depend on screen size
#define kMaxWidthItem 0.8
#define kMinWidthItem 0.2
#define ESP 1
#define HMovingESP 2 
#define VMovingESP 2

// define SPGripViewBorderView
@interface CropGripViewBorderView : UIView
{
    UIView * topLeftButton;     //top left button 
    UIView * topRightButton;    //top right button
    UIView * bottomLeftButton; // bottom left button
    UIView * bottomRightButton; // bottom right button
}

@property(nonatomic,strong)   UIView * topLeftButton;
@property(nonatomic,strong)   UIView * topRightButton;
@property(nonatomic,strong)   UIView * bottomLeftButton;
@property(nonatomic,strong)   UIView * bottomRightButton;

@end

// implement SPGripViewBorderView
#define kCropControlButtonSize  20

@implementation CropGripViewBorderView
@synthesize topLeftButton;
@synthesize topRightButton;
@synthesize bottomLeftButton;
@synthesize bottomRightButton;


- (id)initWithFrame:(CGRect)frame {
    //Init Frame of SPGripViewBorderView
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
        // topLeft button
        topLeftButton =[[UIView alloc] initWithFrame:CGRectMake(kCropControlButtonSize/2,kCropControlButtonSize/2,kCropControlButtonSize,kCropControlButtonSize)];
        topLeftButton.center = CGPointMake(kCropControlButtonSize/2, kCropControlButtonSize/2);
        //topLeftButton.backgroundColor = [UIColor redColor];
        [self addSubview:topLeftButton];
        // topRigft button
        topRightButton =[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-kCropControlButtonSize/2,kCropControlButtonSize/2,kCropControlButtonSize,kCropControlButtonSize)];
        topRightButton.center = CGPointMake(self.frame.size.width-kCropControlButtonSize/2,kCropControlButtonSize/2);
        //topRightButton.backgroundColor = [UIColor redColor];
        [self addSubview:topRightButton];
        // bottomLeft button
        bottomLeftButton =[[UIView alloc] initWithFrame:CGRectMake(kCropControlButtonSize/2,self.frame.size.height-kCropControlButtonSize/2,kCropControlButtonSize,kCropControlButtonSize)];
        //bottomLeftButton.backgroundColor = [UIColor redColor];
        bottomLeftButton.center = CGPointMake(kCropControlButtonSize/2, self.frame.size.height-kCropControlButtonSize/2);
        [self addSubview:bottomLeftButton];
        
        // bottomRight button
        bottomRightButton = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-kCropControlButtonSize/2,self.frame.size.height-kCropControlButtonSize/2,kCropControlButtonSize,kCropControlButtonSize)];
        //bottomRightButton.backgroundColor = [UIColor redColor];
        bottomRightButton.center = CGPointMake(self.frame.size.width-kCropControlButtonSize/2,self.frame.size.height-kCropControlButtonSize/2);
        [self addSubview:bottomRightButton];
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    NSLog(@"drawRect on borderView");
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2));
    CGContextStrokePath(context);
    // draw grid
    [self drawGridOnBorder:context];
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft  = CGRectMake(0,0,kCropControlButtonSize,kCropControlButtonSize);
    topLeftButton.frame = upperLeft;
    
    CGRect upperRight = CGRectMake(self.frame.size.width-kCropControlButtonSize,0,kCropControlButtonSize,kCropControlButtonSize);
    topRightButton.frame = upperRight;
    
    CGRect lowerRight = CGRectMake(self.frame.size.width-kCropControlButtonSize,self.frame.size.height-kCropControlButtonSize,kCropControlButtonSize,kCropControlButtonSize);
    bottomRightButton.frame = lowerRight;
    
    CGRect lowerLeft  = CGRectMake(0,self.frame.size.height-kCropControlButtonSize,kCropControlButtonSize,kCropControlButtonSize);
    bottomLeftButton.frame = lowerLeft;
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = { 
        0.4, 0.8, 1.0, 1.0, 
        0.0, 0.0, 1.0, 1.0
    };
        
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    //CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    CGRect allPoints[4] = { upperLeft, upperRight, lowerRight, lowerLeft };
    for (NSInteger i = 0; i < 4; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
    
}
// draw grid view
-(void) drawGridOnBorder:(CGContextRef) context
{
    // Draw vertical the bounding box 1.
    CGRect rect1 = CGRectMake(kCropControlButtonSize/2, kCropControlButtonSize/2, (self.bounds.size.width-kCropControlButtonSize)/3, self.bounds.size.height-kCropControlButtonSize);
    
    // Draw vertical the bounding box 2
    CGRect rect2 = CGRectMake(rect1.size.width+kCropControlButtonSize/2, kCropControlButtonSize/2, rect1.size.width, rect1.size.height);
    // Draw hozirontal the bounding box 1
    CGRect horizontalRect1 = CGRectMake(kCropControlButtonSize/2,kCropControlButtonSize/2, self.bounds.size.width - kCropControlButtonSize,(self.bounds.size.height-kCropControlButtonSize)/3);
    // Draw hozirotal the bounding box 2
    CGRect horizontalRect2 = CGRectMake(kCropControlButtonSize/2, kCropControlButtonSize/2+horizontalRect1.size.height,horizontalRect1.size.width, horizontalRect1.size.height);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddRect(context, rect1);
    CGContextAddRect(context, rect2);
    
    CGContextAddRect(context, horizontalRect1);
    CGContextAddRect(context, horizontalRect2);
    // draw
    CGContextStrokePath(context);
}

@end


@implementation CropView
@synthesize parentController;
@synthesize outlineRect;
@synthesize maxSize;
@synthesize utilityView;


- (void)setupDefaultAttributes {
    borderView = [[CropGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds,0, 0)];
    borderView.backgroundColor =[UIColor clearColor];
    [self addSubview:borderView];
    [borderView setNeedsDisplay];
    
    self.isCustomMode = false;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         [self setupDefaultAttributes]; 
        
    }
    return self;
}
// set contentView
- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2);
    [self addSubview:contentView];
    
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
//    [borderView removeFromSuperview];
//    [self addSubview:borderView];
    [self bringSubviewToFront:borderView];
}



// handle touchesBegan
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    preLocation =  [aTouch locationInView: self.superview];
    // check touch on controll point
    if ((aTouch.view ==borderView.topLeftButton)||(aTouch.view ==borderView.topRightButton) || (aTouch.view ==borderView.bottomLeftButton) || (aTouch.view ==borderView.bottomRightButton) ) 
    {
        NSLog(@"isSelectedControlPoint");
        isSelectedControlPoint = YES;
        // set current button selected
        if ((aTouch.view ==borderView.topLeftButton)) {
            currSelectedButton = TopLeft;
        }
        else if(aTouch.view ==borderView.topRightButton )
        {
            currSelectedButton = TopRight;   
        }
        else if(aTouch.view ==borderView.bottomLeftButton)
        {
            currSelectedButton = BottomLeft;
        }
        else {
            currSelectedButton = BottomRight;
        }
        
    } else {
        isSelectedControlPoint = NO;
    }  
}

// Scale crop area
-(void)applyFrame :(CGRect)newFrame
{
    int min = self.parentController.view.bounds.size.height * 0.1;
    if (newFrame.size.height < min || newFrame.size.width < min)
        return;
    
    self.frame = newFrame;
}
-(void) scaleCropArea:(CGPoint)location isCustomMode:(BOOL)isCustomMode
{
    // check custom mode
    float dx = location.x - preLocation.x;
    float dy = location.y - preLocation.y;
    NSLog(@"dx:%f,dy:%f",dx,dy);

    
    if (!isCustomMode)
    {
        if (ABS(dx)==0 || ABS(dy)==0 ) {
            return;
        }
        
        float tmp = MIN(ABS(dx/self.frame.size.width), ABS(dy/self.frame.size.height));
        
        if (dx <0) {
            dx = -tmp*self.frame.size.width;
        }
        else {
            dx = tmp*self.frame.size.width;
        }
        
        if (dy < 0) {
            dy = -tmp*self.frame.size.height;
        }else {
            dy = tmp*self.frame.size.height;
        }
    }
     CGRect outline = CGRectMake(parentController.previewImageView.frame.origin.x+outlineRect.origin.x,parentController.previewImageView.frame.origin.y + outlineRect.origin.y, outlineRect.size.width, outlineRect.size.height);
    
    CGRect newFrame;
    if (currSelectedButton ==TopLeft) {
        // check the topLeft button is outside of outline 
        CGPoint newPoint = CGPointMake(self.frame.origin.x +dx, self.frame.origin.y +dy);
        if(![self checkPointOutSideRect:newPoint outline:outline])
        {
            // update new size
            if (dx * dy < 0) {
                newFrame = CGRectMake(newPoint.x, newPoint.y - 2 * dy , self.frame.size.width - dx, self.frame.size.height + dy);
            } else {
                newFrame = CGRectMake(newPoint.x, newPoint.y, self.frame.size.width-dx, self.frame.size.height-dy);
            }
         [self applyFrame:newFrame];
        }else {
            NSLog(@"topLeft outside");
            return;
        }
        
        contentView.frame = CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2);
        borderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [borderView setNeedsDisplay];
    } 
    else if(currSelectedButton == TopRight)
    {        
        // check the topRight button is outside of outline
        CGPoint topRightPoint = CGPointMake(self.frame.origin.x+self.frame.size.width+dx, self.frame.origin.y +dy);
        if(![self checkPointOutSideRect:topRightPoint outline:outline])
        {
            if (dx * dy > 0) {
                newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - dy, self.frame.size.width+dx, self.frame.size.height + dy);
            } else {
                newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y +dy, self.frame.size.width+dx, self.frame.size.height-dy);
            }
            [self applyFrame:newFrame];
        }else {
            NSLog(@"topRight outside");
            return;
        }
        
        contentView.frame = CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2);
        borderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [borderView setNeedsDisplay];
    }
    else if(currSelectedButton == BottomLeft)
    {
        CGPoint bottomLeftPoint = CGPointMake(self.frame.origin.x+dx, self.frame.origin.y+self.frame.size.height+dy);
        if (![self checkPointOutSideRect:bottomLeftPoint outline:outline]) {
            
            if (dx * dy > 0) {
                newFrame = CGRectMake( self.frame.origin.x+dx,self.frame.origin.y, self.frame.size.width-dx, self.frame.size.height - dy);
            } else {
                newFrame = CGRectMake( self.frame.origin.x+dx,self.frame.origin.y, self.frame.size.width-dx, self.frame.size.height+dy);
            }
            [self applyFrame:newFrame];
        }
        else {
            NSLog(@"BottomLeft is outside");
            return;
        }
        

        contentView.frame = CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2);
        borderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [borderView setNeedsDisplay];
    }
    else if(currSelectedButton == BottomRight)
    {
        CGPoint bottomRightPoint = CGPointMake(self.frame.origin.x+self.frame.size.width+dx, self.frame.origin.y+self.frame.size.height+dy);
        if (![self checkPointOutSideRect:bottomRightPoint outline:outline]) {
            if (dx * dy < 0) {
                newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+dx, self.frame.size.height - dy);
            } else {
                newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+dx, self.frame.size.height+dy);
            }
            [self applyFrame:newFrame];
        }
        else {
            NSLog(@"bottom right is outside");
            return;
        }
       
        contentView.frame = CGRectInset(self.bounds, kCropControlButtonSize/2, kCropControlButtonSize/2);
        borderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [borderView setNeedsDisplay];
    }

}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touchesMoved");
   
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    if (isSelectedControlPoint) 
    {
        [self scaleCropArea:location isCustomMode:self.isCustomMode];
    }
    else 
    {
        // pan the UIView to destination location     
        CGPoint translatedPoint = CGPointMake(location.x - preLocation.x, location.y - preLocation.y);
        CGPoint centerTranslatedPoint = CGPointMake(self.center.x + translatedPoint.x, self.center.y+translatedPoint.y);

        UIImageView* tempImageView = parentController.previewImageView;
        CGRect outlineOfCropedImage = [parentController getDiplayFrameOfImageView:tempImageView];
        
        CGRect outline = CGRectMake(outlineOfCropedImage.origin.x + tempImageView.frame.origin.x,
                                    outlineOfCropedImage.origin.y + tempImageView.frame.origin.y,
                                    outlineOfCropedImage.size.width, outlineOfCropedImage.size.height);
        // check the centerTranslatedPoint is outside of outlineRect
//        CGRect outline = CGRectMake(parentController.previewImageView.frame.origin.x+outlineRect.origin.x,parentController.previewImageView.frame.origin.y + outlineRect.origin.y, outlineRect.size.width, outlineRect.size.height);
        
        if(![self checkCropMovingToOutsideOutline:centerTranslatedPoint :outline])
        {
             self.center = centerTranslatedPoint;
        }

    }
    preLocation = location;
    
    // hide cancel and apply button
    self.utilityView.btnApply.hidden = YES;
    self.utilityView.btnCancel.hidden = YES;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    // show Apply and Cancel button
    [self.parentController.view bringSubviewToFront:self.utilityView.btnApply];
    [self.parentController.view bringSubviewToFront:self.utilityView.btnCancel];
    
    self.utilityView.btnApply.hidden = NO;
    self.utilityView.btnCancel.hidden = NO;
}

// check crop moving outside
-(BOOL) checkCropMovingToOutsideOutline:(CGPoint) cropCenter :(CGRect) borderRect 
{
    
    NSLog(@"checkCropMovingToOutsideOutline");
    float esp = ESP; //5 pixels
    if ((cropCenter.x-self.frame.size.width/2) < (borderRect.origin.x-kCropControlButtonSize/2+esp)) {
        return  TRUE;
    }
    else if((cropCenter.y -self.frame.size.height/2) < (borderRect.origin.y-kCropControlButtonSize/2+esp))
    {
        return TRUE;    
    }
    else if((cropCenter.x+ self.frame.size.width/2) > (borderRect.origin.x + borderRect.size.width+kCropControlButtonSize/2-esp)) {
        return TRUE;
    }
    else if((cropCenter.y + self.frame.size.height/2) > (borderRect.origin.y + borderRect.size.height+kCropControlButtonSize/2-esp))
    {
        return TRUE;
    }
    else {
        NSLog(@"else");
    }
    
    return FALSE;
}

// check point outside of outline RECT
-(BOOL)checkPointOutSideRect:(CGPoint) point outline:(CGRect) outRect
{
    float esp = ESP; //5 pixels
    if ((point.x < outRect.origin.x-kCropControlButtonSize/2+esp) || 
        (point.x > (outRect.origin.x + outRect.size.width+kCropControlButtonSize/2-esp)) || 
        (point.y < outRect.origin.y-kCropControlButtonSize/2+esp) || 
        (point.y > (outRect.origin.y + outRect.size.height+kCropControlButtonSize/2-esp)))
    {
        return TRUE;
    }
    
    return FALSE;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//   get actuall crop rect
-(CGRect) getCropRectArea
{
    CGRect cropRect = CGRectMake(self.frame.origin.x + kCropControlButtonSize/2, self.frame.origin.y+kCropControlButtonSize/2, self.frame.size.width-kCropControlButtonSize, self.frame.size.height - kCropControlButtonSize);
    return cropRect;
}
// get actault outline of image be croped
-(CGRect) getOutlineImageBeCropedImage
{
    CGRect outline = CGRectMake(parentController.previewImageView.frame.origin.x+outlineRect.origin.x,parentController.previewImageView.frame.origin.y + outlineRect.origin.y, outlineRect.size.width, outlineRect.size.height);
    return outline;
}

@end
