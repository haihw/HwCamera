//
//  TextView.m
//  blendcamerapro
//
//  Created by Dung NP on 8/31/12.
//  Modified by Hai Hw
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import "TextView.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "DraggableView.h"
#import "ViewController.h"
#import "HWCustomUILabel.h"
#import "HWCustomLabelView.h"

#import <QuartzCore/QuartzCore.h>
#define kMaxWidthText 960
#define kMaxFontSize 200
#define kTextPaddingWidth 1
#define kTextPaddingHeight 1

#define kFontSize 20
#define kOnlistFontSize 10
#define kTextItemHeigt 30
#define kSpaceOf2TextItems 5

@implementation CustomizeTextField
@synthesize  draggableHolder;
@synthesize  holderView;

@end

@implementation TextViewItem
@synthesize textContent;
@synthesize textFont;
@synthesize textColor;
@synthesize  fontSize;
@synthesize  fontName;
@synthesize tag;
@synthesize holderDraggabeView;

-(id)initWithTextContent:(NSString *) content Font:(UIFont *) font Color:(UIColor *)color fontName:(NSString *) fName fontSize:(float) fSize
{
    self.textContent = content;
    self.textFont = font;
    self.textColor = color;
    self.fontName = fName;
    self.fontSize = fSize;
    
    return self;
}

@end
@implementation TextView
@synthesize rootViewControler;
@synthesize  textItems;
@synthesize listFontNames;
@synthesize listDraggableTextItems;
@synthesize CLView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self initDefault];
        // drawGUI
        [self createGUI];
        
    }
    return self;
}
#pragma mark initial

-(void)initDefault
{
    
    // init list font name
    listFontNames = [[NSMutableArray alloc] initWithObjects:
                     @"Chalkduster",
                     @"Zapfino",
                     @"Jellyka Delicious Cake",
                     @"Ink In The Meat",
                     @"Eutemia I",
                     @"Top Secret",
                     @"ChopinScript",
                     @"Gabrielle",
                     @"AlphaClouds",
                     @"Cheap Fire",
                     @"TR2N",
                     @"Transformers",
                     @"1942 report",
                     @"A bite",
                     @"Cactus Sandwich FM",
                     @"DriftType",
                     @"Korean Calligraphy",
                     @"LeviReBrushed",
                     @"Porky's",
                     @"Helvetica-Bold",
                     @"Brankovic",
                     @"Kraboudja",
                     @"Sketchetik",
                     @"Fiolex Girls",
                     nil];
    // init list text items
    NSLog(@"NUmber of font: %lu", (unsigned long)listFontNames.count);
    textItems = [[NSMutableArray alloc] initWithCapacity:0];
    UIColor * textColor = [UIColor redColor];
    for(int i =0;i < listFontNames.count ;i++)
    {
        UIFont * textFont = [UIFont fontWithName:(NSString *)[listFontNames objectAtIndex:i] size:kOnlistFontSize];
        TextViewItem * textItem = [[TextViewItem alloc] initWithTextContent:listFontNames[i]  Font:textFont Color:textColor fontName:[listFontNames objectAtIndex:i] fontSize:kFontSize];
        textItem.tag = i;
        [textItems addObject: textItem];
        
    }
    // current textItem
    currentTextObject = [textItems objectAtIndex:0];
    // init list draggable text item
    listDraggableTextItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    //For custom label
    self.textColor = [UIColor redColor];
    self.glowAmount = 0;
    self.strokeWidth = 15;
    self.glowColor = [UIColor yellowColor];
    self.strokeColor = [UIColor whiteColor];
}

-(void) createGUI
{
    // add TextBar Background
    CGRect textBarFrame = CGRectMake(0, 85, 320, 40);
    CGRect selectedTextItemFrame = CGRectMake(15, 90, 121, 28);
    CGRect btnArrowFrame = CGRectMake(0, 97, 15, 16);
    CGRect colorSliderFrame = CGRectMake(140, 94, 148, 11);
    CGRect btnAddTextFrame = CGRectMake(290, 90, 32, 32);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        textBarFrame = CGRectMake(0, 183, 768, 81);
        selectedTextItemFrame = CGRectMake(57, 202, 285, 43);
        btnArrowFrame = CGRectMake(14, 206, 24, 35);
        colorSliderFrame = CGRectMake(360, 218, 336, 12);
        btnAddTextFrame = CGRectMake(698, 189, 70, 70);
    }
    
    UIImage * textBarBGImage = [UIImage imageNamed:@"TextBarBG"];
    UIImageView * textBarBGImageView = [[UIImageView alloc] initWithFrame:textBarFrame];
    textBarBGImageView.image = textBarBGImage;
    [self addSubview:textBarBGImageView];
    
    // create arrow button
    btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnArrow setImage:[UIImage imageNamed:@"Arrow.png"] forState:UIControlStateNormal];
    btnArrow.frame = btnArrowFrame;
    [btnArrow addTarget:self action:@selector(btnArrow_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnArrow];
    
    // add selected text item view 
   
    seletedTextItemView = [[UIView alloc] initWithFrame:selectedTextItemFrame];
    isHideSelectedTextItemView = NO;
    
    UIImageView * imageViewOff = [ [UIImageView alloc] initWithImage:[UIImage imageNamed:@"TextStyleBGOff.png"]];
    imageViewOff.frame = CGRectMake(0, 0, seletedTextItemView.frame.size.width, seletedTextItemView.frame.size.height);
    UIButton * btnShowListFont = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowListFont.frame = imageViewOff.frame;
    [btnShowListFont addTarget:self action:@selector(btnArrow_Click:) forControlEvents:UIControlEventTouchUpInside];
    [seletedTextItemView addSubview:btnShowListFont];
    [seletedTextItemView addSubview:imageViewOff];
    
    //add lable with default text string to selectedTextViewItemView
    lblCurrentText = [[UILabel alloc] initWithFrame: CGRectMake(5,5, imageViewOff.frame.size.width-10, imageViewOff.frame.size.height-10)];
    lblCurrentText.textColor = currentTextObject.textColor;
    lblCurrentText.text = currentTextObject.textContent;
    lblCurrentText.textAlignment = NSTextAlignmentCenter;
    lblCurrentText.backgroundColor =[UIColor clearColor];
    lblCurrentText.font = [UIFont fontWithName:currentTextObject.fontName size:currentTextObject.fontSize];
    
    [seletedTextItemView addSubview:lblCurrentText];

    [self addSubview:seletedTextItemView];
    
    // add show list item view
    [self createListItemView];    

    // create color slider
    colorSlider = [[UISlider alloc] initWithFrame:colorSliderFrame];
    colorSlider.minimumValue = 0;
    colorSlider.maximumValue = 360;
    colorSlider.value = 0;
    UIImage * sliderBarImage = [[UIImage imageNamed:@"ColorSlideBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [colorSlider setMinimumTrackImage:sliderBarImage forState:UIControlStateNormal];
    [colorSlider setMaximumTrackImage:sliderBarImage forState:UIControlStateNormal];
    [colorSlider setThumbImage:[UIImage imageNamed:@"NewMain_SliderIcon"] forState:UIControlStateNormal];
    [colorSlider setThumbImage:[UIImage imageNamed:@"NewMain_SliderIcon"] forState:UIControlStateHighlighted];

    [colorSlider addTarget:self action:@selector(colorSlider_Change:) forControlEvents:UIControlEventTouchUpInside];
    [colorSlider addTarget:self action:@selector(colorSlider_Change:) forControlEvents:UIControlEventTouchUpOutside];
    [colorSlider addTarget:self action:@selector(colorSlider_Changing:) forControlEvents:UIControlEventValueChanged];

    [self addSubview:colorSlider];
    
    // add the add text button
    UIButton * btnAddText =[UIButton buttonWithType:UIButtonTypeCustom];
    btnAddText.frame = btnAddTextFrame;
    [btnAddText setImage:[UIImage imageNamed:@"btnAddTextOff"] forState:UIControlStateNormal];
    [btnAddText setImage:[UIImage imageNamed:@"btnAddTextOn"] forState:UIControlStateHighlighted];
    [btnAddText addTarget:self action:@selector(btnAddText_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnAddText];
    
}


-(void) createListItemView
{
    NSLog(@"createListItemView");
    CGRect showListFontFrame = CGRectMake(15, 0, 121, 120);
    int margin = 5;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        showListFontFrame = CGRectMake(57, 0, 285, 244);
        margin = 10;
    }
    showListTextItemView = [[UIView alloc] initWithFrame:showListFontFrame];
    UIImageView * showListTextItemViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, showListTextItemView.frame.size.width,showListTextItemView.frame.size.height)];
    showListTextItemViewImageView.image =[UIImage imageNamed:@"TextStyleBGOn.png"];
    [showListTextItemView addSubview:showListTextItemViewImageView];
    
    // add scroll view of list item to this view
    
    scrollText = [[UIScrollView alloc] initWithFrame:CGRectMake(margin, margin, showListTextItemView.frame.size.width - 2*margin, showListTextItemView.frame.size.height-2*margin)];
    int y =0;
    // add textItem to scroll
    for (int i =0; i< textItems.count; i++) {
        
        if (i == currentTextItemTag) {
            UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSpaceOf2TextItems, scrollText.frame.size.width, kTextItemHeigt)];
            bg.image =[UIImage imageNamed:@"TextStyleOn.png"];
            [scrollText addSubview:bg];
            // add lable text 
            UILabel * lblCurrent = [[UILabel alloc] initWithFrame:bg.frame];
            lblCurrent.backgroundColor = [UIColor clearColor];
            lblCurrent.text = currentTextObject.textContent;
            lblCurrent.textColor = currentTextObject.textColor;
            //lblCurrent.font = currentTextObject.textFont;
            lblCurrent.font = [UIFont fontWithName:currentTextObject.fontName size:currentTextObject.fontSize];
            lblCurrent.textAlignment = NSTextAlignmentCenter;
            [scrollText addSubview:lblCurrent];
            // add button to select item
            UIButton * btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSelect.frame = lblCurrent.frame;
            btnSelect.tag = currentTextObject.tag;
            [btnSelect addTarget:self action:@selector(selectTextItem_Click:) forControlEvents:UIControlEventTouchUpInside];
            [scrollText addSubview:btnSelect];
        }
        else 
        {
            y = kTextItemHeigt*i;// + kSpaceOf2TextItems;
            UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0,y, scrollText.frame.size.width, kTextItemHeigt)];
            bg.image =[UIImage imageNamed:@"TextStyleOff.png"];
            [scrollText addSubview:bg];
            // add lable text 
            TextViewItem * textItem = [textItems objectAtIndex:i];
            UILabel * lblCurrent = [[UILabel alloc] initWithFrame:bg.frame];
            lblCurrent.backgroundColor = [UIColor clearColor];
            lblCurrent.text = textItem.textContent;
            lblCurrent.textColor = textItem.textColor;
            //lblCurrent.font = currentTextObject.textFont;
            lblCurrent.font = [UIFont fontWithName:textItem.fontName size:textItem.fontSize];
            lblCurrent.textAlignment = NSTextAlignmentCenter;
            [scrollText addSubview:lblCurrent];
            // add button to select item
            UIButton * btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSelect.frame = lblCurrent.frame;
            btnSelect.tag = textItem.tag;
            [btnSelect addTarget:self action:@selector(selectTextItem_Click:) forControlEvents:UIControlEventTouchUpInside];
            [scrollText addSubview:btnSelect];  
        }
        
    }
    // set scroll content size
    
    scrollText.contentSize = CGSizeMake(scrollText.frame.size.width,textItems.count*kTextItemHeigt);
    
    [showListTextItemView addSubview:scrollText];
    
    showListTextItemView.hidden = YES;
    [self addSubview:showListTextItemView];
    
    
}
#pragma mark select text item

-(IBAction)selectTextItem_Click:(UIButton *)sender
{
    NSLog(@"selecte item :%ld",(long)sender.tag);
    // change currentTextObject 
    currentTextObject = [textItems objectAtIndex:sender.tag];
    lblCurrentText.text = currentTextObject.textContent;
    lblCurrentText.textColor = currentTextObject.textColor;
    lblCurrentText.textAlignment = NSTextAlignmentCenter;
    lblCurrentText.font = [UIFont fontWithName:currentTextObject.fontName size:currentTextObject.fontSize];
    // hide the showlist item view
    showListTextItemView.hidden = YES;
    seletedTextItemView.hidden = NO;
    isHideSelectedTextItemView = NO;
    // update currentTextFiled
    
    [self updateCurrentTextItem];

}


-(void) changecurrentTextObjectOnScroll
{
    NSLog(@"changecurrentTextObjectOnScroll");
    NSArray * textitems =  [scrollText subviews];
    for (UIView * view in textitems) {
        [view removeFromSuperview]; 
    }
    
    int y =0;
    // add textItem to scroll
    for (int i =0; i< textItems.count; i++) {
        
        if (i == currentTextObject.tag) {
            y = kTextItemHeigt*i + kSpaceOf2TextItems;
            UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0,y, scrollText.frame.size.width, kTextItemHeigt)];
            bg.image =[UIImage imageNamed:@"TextStyleOn.png"];
            [scrollText addSubview:bg];
            // add lable text 
            UILabel * lblCurrent = [[UILabel alloc] initWithFrame:bg.frame];
            lblCurrent.backgroundColor = [UIColor clearColor];
            lblCurrent.text = currentTextObject.textContent;
            lblCurrent.textColor = currentTextObject.textColor;
            //lblCurrent.font = currentTextObject.textFont;
            lblCurrent.font = [UIFont fontWithName:currentTextObject.fontName size:currentTextObject.fontSize];
            lblCurrent.textAlignment = NSTextAlignmentCenter;
            [scrollText addSubview:lblCurrent];
            // add button to select item
            UIButton * btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSelect.frame = lblCurrent.frame;
            btnSelect.tag = currentTextObject.tag;
            [btnSelect addTarget:self action:@selector(selectTextItem_Click:) forControlEvents:UIControlEventTouchUpInside];
            [scrollText addSubview:btnSelect];
        }
        else 
        {
            y = kTextItemHeigt*i + kSpaceOf2TextItems;
            UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0,y, scrollText.frame.size.width, kTextItemHeigt)];
            bg.image =[UIImage imageNamed:@"TextStyleOff.png"];
            [scrollText addSubview:bg];
            // add lable text 
            TextViewItem * textItem = [textItems objectAtIndex:i];
            UILabel * lblCurrent = [[UILabel alloc] initWithFrame:bg.frame];
            lblCurrent.backgroundColor = [UIColor clearColor];
            lblCurrent.text = textItem.textContent;
            lblCurrent.textColor = textItem.textColor;
            //lblCurrent.font = currentTextObject.textFont;
            lblCurrent.font = [UIFont fontWithName:textItem.fontName size:textItem.fontSize];
            lblCurrent.textAlignment = NSTextAlignmentCenter;
            [scrollText addSubview:lblCurrent];
            // add button to select item
            UIButton * btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSelect.frame = lblCurrent.frame;
            btnSelect.tag = textItem.tag;
            [btnSelect addTarget:self action:@selector(selectTextItem_Click:) forControlEvents:UIControlEventTouchUpInside];
            [scrollText addSubview:btnSelect];  
        }
    }
}

// handle uicontrol event
-(IBAction)btnArrow_Click:(id)sender
{
    NSLog(@"btnArrow_Click");
    
    if (!isHideSelectedTextItemView) {
        NSLog(@"!isHideSelectedTextItemView");
        isHideSelectedTextItemView = YES;
        seletedTextItemView.hidden = YES;
        // show listTextItemView
        showListTextItemView.hidden = NO;
        // change current select item 
        [self changecurrentTextObjectOnScroll];
        
    }else {
        
        isHideSelectedTextItemView = NO;
        seletedTextItemView.hidden = NO;
        showListTextItemView.hidden = YES;
    }
    
}

-(IBAction)btnTextStyle_Click:(id)sender
{
    NSLog(@"btnTextStyle_Click");
}
-(IBAction)colorSlider_Changing:(UISlider*) sender
{
    UIColor *color;
    if (sender.value < 5)
        color = [UIColor whiteColor];
    else if (sender.value >355)
        color = [UIColor blackColor];
    else
        color = [UIColor colorWithHue:sender.value/360.0f saturation:1.0f brightness:1.0f alpha:1.0f];
    lblCurrentText.textColor = color;
    // change color for all items
    for (TextViewItem *textItem in textItems) {
        textItem.textColor = color;
    }

}
-(IBAction)colorSlider_Change:(UISlider *)sender
{
    NSLog(@"colorSlider_Change");
    currentTextObject.textColor = lblCurrentText.textColor;
    self.textColor = lblCurrentText.textColor;
    [self updateCurrentTextItem];
}


#pragma  mark Add TextField handle
-(void)addTextField//InIndicator
{
    [MBProgressHUD showHUDAddedTo:self.rootViewControler.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addTextFieldNoIndicator];
        [MBProgressHUD hideHUDForView:self.rootViewControler.view animated:YES];
    });

}
// addTextField for iphone
-(void)addTextFieldNoIndicator
{
    CGSize rootSize = self.rootViewControler.view.bounds.size;
    CGRect newTextItemFrame = CGRectMake(rootSize.width/5, rootSize.height/3, rootSize.width*3/5, rootSize.height/6);
    DraggableView *dragableView = [[DraggableView alloc] initWithFrame:newTextItemFrame];
    dragableView.isTextContent = YES;
    dragableView.parentController = rootViewControler;
    HWCustomUILabel *newLabel = [[HWCustomUILabel alloc] init];
    UIFont * font = [UIFont fontWithName:currentTextObject.fontName size:kMaxFontSize];
    newLabel.font = font;
    newLabel.text = @"";
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.textAlignment = NSTextAlignmentCenter;

    newLabel.numberOfLines = 1;
    dragableView.label = newLabel;

    [self.rootViewControler addNewStickerItem:dragableView];
    
    //check current text field is existing or not
    if (!currentTextField)
    {
        CGRect textFrame = CGRectMake(0, rootSize.height/4, self.bounds.size.width, 100);
        currentTextField = [[UITextField alloc]initWithFrame:textFrame];
        currentTextField.placeholder = @"Enter Text";
        currentTextField.textAlignment = NSTextAlignmentCenter;
        currentTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        currentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        currentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        currentTextField.delegate = self;
        currentTextField.returnKeyType = UIReturnKeyDone;
        [self.rootViewControler.view addSubview:currentTextField];
        
    }
    [self tapTextItemHandle];
    
}
-(void)doubleTapDragableItemHandle
{
    DraggableView *currentItem = rootViewControler.getCurrentStickerItem;
    if (!currentItem)
    {
        NSLog(@"ERROR ! No dragable item");
    }
    [self tapTextItemHandle];
    
}
-(void)tapTextItemHandle
{
    int fontsize = 50;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        fontsize = 20;
    NSLog(@"edit Text");
    DraggableView *currentTextItem = rootViewControler.getCurrentStickerItem;
    if (!currentTextItem.isTextContent)
    {
        NSLog(@"ERROR ! No Text Item To Edit");
        return;
    }
    [self.rootViewControler changeToTextView];
    currentTextField.text = currentTextItem.label.text;
    currentTextField.font = [UIFont fontWithName:currentTextItem.label.font.fontName size:fontsize];
    currentTextField.textColor = self.textColor;//currentTextItem.label.textColor;
    currentTextField.hidden = NO;
    currentTextItem.hidden = YES;
    [currentTextField becomeFirstResponder];
}
//implement UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(BOOL)shouldAutoShowToolTip
{
    NSString* homeDir    = NSHomeDirectory();
    NSString* fullPath = [homeDir stringByAppendingPathComponent:@"blendConfigTextToolTip.ini"];
    NSError* error = nil;
    NSStringEncoding encoding;
    NSString* contents = [NSString stringWithContentsOfFile:fullPath usedEncoding:&encoding
                                                      error:&error];
    if (contents)
        return NO;
    else
    {
        NSString *toolTipStr = @"YES";
        [toolTipStr writeToFile:fullPath atomically:NO encoding:NSASCIIStringEncoding error:&error];
        return YES;
    }
}
- (void)pjnkyHW
{
    NSLog(@"pj");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"<3" message:@"You mean Pj & Hw?" delegate:nil cancelButtonTitle:@":o" otherButtonTitles:nil];
    [alert show];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn: %@", textField.text);
    [textField resignFirstResponder];
    //update label end content view of current text sticker item
    DraggableView *currentTextItem = rootViewControler.getCurrentStickerItem;
    currentTextItem.hidden = NO;
    currentTextField.hidden = YES;
    if ([textField.text isEqualToString:@""])
    {
        [self.rootViewControler removeStickerItemView:currentTextItem];
        return YES;
    }
    if ([textField.text isEqualToString:currentTextItem.label.text])
        return YES;
    if ([[textField.text capitalizedString] isEqualToString:@"Pjnky"])
    {
        [self pjnkyHW];
    }
    currentTextItem.label.text = textField.text;
    //content view image is got from label
    [self updateCurrentTextItem];
    if ([self shouldAutoShowToolTip])
        [self.rootViewControler showToolTip];
    return YES;
}

-(IBAction)btnAddText_Click:(UIButton*)sender
{
    NSLog(@"btnAddText_Click");
    [self addTextField];
    
}

-(void)previewImageViewClicked
{
    isHideSelectedTextItemView = NO;
    seletedTextItemView.hidden = NO;
    showListTextItemView.hidden = YES;
    if (!currentTextField.hidden)
        [self textFieldShouldReturn:currentTextField];
}

-(void)updateCurrentTextItemInIndicator
{
    NSLog(@"Update Text");
    DraggableView *currentTextItem = rootViewControler.getCurrentStickerItem;
    if (!currentTextItem || !currentTextItem.isTextContent)
    {
        NSLog(@"ERROR ! No Text Item To Update");
        return;
    }
    
    currentTextItem.label.font = [UIFont fontWithName:currentTextObject.fontName size:kMaxFontSize];
    currentTextItem.label.textColor = self.textColor;
    currentTextItem.label.glowColor = self.glowColor;
    currentTextItem.label.glowAmount = self.glowAmount;
    currentTextItem.label.strokeWidth = self.strokeWidth;
    currentTextItem.label.strokeColor = self.strokeColor;
    
    UIImage *imageLabel = [currentTextItem.label getImageWithMaxWidth:kMaxWidthText];
    NSLog(@"size text img: %@", NSStringFromCGSize(imageLabel.size));
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageLabel];
    [currentTextItem setContentView:imageView];

}
-(void)updateCurrentTextItem
{
    [MBProgressHUD showHUDAddedTo:self.rootViewControler.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [self updateCurrentTextItemInIndicator];
        [MBProgressHUD hideHUDForView:self.rootViewControler.view animated:YES];
    });
}
-(void)hideCLView
{
    if (CLView)
        CLView.hidden = YES;
}
-(void)showCLView
{
    if (CLView)
        CLView.hidden = NO;
    
}
-(void)hideAll
{
    [self hideCLView];
}
-(void)removeAll
{
    [self removeFromSuperview];
    if (CLView)
    {
        [CLView removeFromSuperview];
        CLView = nil;
    }
    [currentTextField resignFirstResponder];
    [currentTextField removeFromSuperview];
    
}
@end
