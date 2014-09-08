//
//  HWCustomUILabel.m
//  UILabel with glow and stroke fx
//
//  Created by Hai HW on 12/09/2012.
// Copyright 2012 Applistar Vietnam. All rights reserved.
//
#include <QuartzCore/QuartzCore.h>
#import "HWCustomUILabel.h"
#define kMaxFontSize = 90;

@interface HWCustomUILabel()
- (void)initialize;
@end

@implementation HWCustomUILabel

@synthesize glowColor, glowOffset, glowAmount, strokeColor, strokeWidth;


- (void)initialize {
    self.glowOffset = CGSizeMake(0.0, 0.0);
    self.glowAmount = 0.0;
    self.glowColor = [UIColor clearColor];
    self.strokeWidth = 0.0;

}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        [self initialize];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetShadow(context, self.glowOffset, self.glowAmount);
    CGContextSetShadowWithColor(context, self.glowOffset, self.glowAmount, [glowColor CGColor]);
    
    [super drawTextInRect:rect];
    
    
    if(!self.strokeColor)
    {
        [self setStrokeColor:[UIColor blackColor]];
    }
    UIColor *saveTextColor = self.textColor;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    self.textColor = [self strokeColor];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    self.textColor = saveTextColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    self.shadowOffset = CGSizeMake(0, 0);
    CGContextRestoreGState(context);
    

}
-(UIImage*)getImageWithMaxWidth:(CGFloat)maxWidth;
{
    NSDate *now = [NSDate date];
    //get fit size to text content tow the maxwidth
    CGFloat realFont;
    CGSize fitSize = [self.text sizeWithFont:self.font minFontSize:10 actualFontSize:&realFont forWidth:maxWidth lineBreakMode:NSLineBreakByCharWrapping];
    self.font = [UIFont fontWithName:self.font.fontName size:realFont];
    NSLog(@"font size: %f", realFont);

    CGSize labelSize = CGSizeMake(fitSize.width + 100, fitSize.height);
    self.bounds = CGRectMake(0, 0, labelSize.width, labelSize.height);
    self.contentMode = UIViewContentModeCenter;
    NSLog(@"text size: %@", NSStringFromCGSize(labelSize));
    //render in context to get image
    
    UIGraphicsBeginImageContext(labelSize);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    float time = [now timeIntervalSinceNow];
    NSLog(@"Time :%f", -time);
    return viewImage;
}
@end

