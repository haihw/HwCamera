//
//  TextView.h
//  blendcamerapro
//
//  Created by Dung NP on 8/31/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DraggableView, ViewController, HWCustomLabelView;
@interface CustomizeTextField : UITextField
{
    DraggableView * draggableHolder;
    UIView * holderView;
}

@property (nonatomic,strong) DraggableView * draggableHolder;
@property (nonatomic, strong) UIView * holderView;

@end

@interface  TextViewItem: NSObject
{
    NSString * textContent;
    NSString * fontName;
    float fontSize;
    UIFont * textFont; // text font on View
    UIFont * textFontOnlist; // font show onlist
    UIColor * textColor;
    int tag;
    
    DraggableView * holderDraggabeView;
}

@property (nonatomic, strong)  NSString * textContent;
@property (nonatomic, strong)  UIFont * textFont;
@property (nonatomic, strong)  UIColor * textColor;
@property (nonatomic, strong)  NSString * fontName;
@property (nonatomic, assign)  float fontSize;
@property (nonatomic, assign)  int tag;
@property (nonatomic, strong)  DraggableView * holderDraggabeView;


-(id)initWithTextContent:(NSString *) content Font:(UIFont *) font Color:(UIColor *)color fontName:(NSString *) fName fontSize:(float) fSize;

@end

@interface TextView : UIView<UITextFieldDelegate>
{
    ViewController * rootViewControler;
    TextViewItem * currentTextObject;
    UILabel * lblCurrentText;
    UIScrollView * scrollText;
    
    
    NSMutableArray * textItems; 
    NSMutableArray * listFontNames;
    
    
    UIView * showListTextItemView;
    UIView * seletedTextItemView;
    UIButton * btnArrow;
    UISlider * colorSlider;
    
    BOOL isHideSelectedTextItemView;
    
    UIView * textFieldHolder; // hodler textfield
    int currentTextItemTag;
    NSMutableArray * listDraggableTextItems;
    UITextField * currentTextField;
    
    HWCustomLabelView *CLView;
}

@property (nonatomic,strong)  NSMutableArray * textItems; 
@property (nonatomic,strong)  NSMutableArray * listFontNames;
@property (nonatomic,strong)  NSMutableArray * listDraggableTextItems;
@property (nonatomic,strong)  ViewController * rootViewControler;
@property (nonatomic,strong)  HWCustomLabelView *CLView;
@property (nonatomic,assign) int glowAmount;
@property (nonatomic,assign) int strokeWidth;
@property (nonatomic,strong) UIColor *glowColor;
@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,strong) UIColor *textColor;

-(void)previewImageViewClicked;
-(void)updateCurrentTextItem;
-(void)hideAll;
-(void)removeAll;
-(void)addTextField;
-(void)addTextFieldNoIndicator;
-(void)doubleTapDragableItemHandle;
@end
