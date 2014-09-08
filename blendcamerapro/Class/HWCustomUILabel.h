//
//  HWCustomUILabel.h
//  UILabel with glow and stroke fx
//
//  Created by Hai HW on 12/09/2012.
// Copyright 2012 Applistar Vietnam. All rights reserved.
//


@interface HWCustomUILabel : UILabel {
}

@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGSize glowOffset;
@property (nonatomic, assign) CGFloat glowAmount;
@property (nonatomic, assign) CGFloat strokeWidth;
-(UIImage*)getImageWithMaxWidth:(CGFloat)maxWidth;
@end

