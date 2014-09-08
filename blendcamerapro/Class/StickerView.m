//
//  StickerView.m
//  blendcamerapro
//
//  Created by Do Khanh Toan on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "StickerView.h"
#import "Define.h"
#import "DraggableView.h"
#import "GAI.h"
#define kNumberOfFreeItem       6

#define kStickerItemWidthIphone           28
#define kStickerItemHeightIphone          28
#define kStickerItemScrollWitdthIphone    255
#define kStickerItemScrollHeightIphone    48
#define kLeftAlignStickerItem             10
#define kRightAlignStickerItem            10
#define kSpace2StickerItems               20


@implementation StickerView
@synthesize listMakupItems;
@synthesize listTextItems;
@synthesize listEmotion1Items;
@synthesize listEmotion2Items;
@synthesize rootViewControler;
@synthesize  listStickerItems;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        listStickerItems = [[NSMutableArray alloc] initWithCapacity:0];
        [self createGUI];
    
    }
    return self;
}

// create mainGUI
-(void) createGUI
{
    NSLog(@"createGUI");
    
    // add 4 items to catalog view
    catalogIconNames= [[NSArray alloc] initWithObjects:
                          @"Sticker_1",
//                          @"Sticker_2",
//                          @"NewMain_SantaOn",
//                          @"Snowman",
//                          @"NewMain_DecorationOn",
                          @"Sticker_4",
//                          @"Sticker_5",
                          nil];
    stickerPrefixNames = [[NSArray alloc] initWithObjects:
                          @"Makeup_",
//                          @"Textbox",
//                          @"Santa_",
//                          @"SnowMan_",
//                          @"Decoration_",
                          @"emoticon2_",
//                          @"LightItem",
                          nil];
    stickerThumbnailPrefixNames = [[NSArray alloc] initWithObjects:
                                   @"Makeup_",
//                                   @"tn_Textbox",
//                                   @"TN_Santa_",
//                                   @"TN_SnowMan_",
//                                   @"TN_Decoration_",
                                   @"emoticon2_",
//                                   @"LightItem",
                                   nil];
    stickerThumbnailPostfixNames = [[NSArray alloc] initWithObjects:
                                   @"_tn",
//                                   @"",
//                                   @"",
//                                   @"",
//                                   @"",
                                   @"_tn",
//                                   @"_tn",
                                   nil];
    numberOfStickers = [[NSArray alloc] initWithObjects:
                        @"31",
//                        @"14",
//                        @"23",
//                        @"20",
//                        @"54",
                        @"9",
//                        @"39",
                        nil];
    // makeup
    NSInteger numberOfCatalog = [catalogIconNames count];
    int iconSize = self.frame.size.height;
    int space2Icon = self.frame.size.width/numberOfCatalog - iconSize;
    // Create view level 1
    catalogView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
    
    UIImage * bg = [UIImage imageNamed:@"Stickerbar"];
    UIImageView * bgView = [[UIImageView alloc] initWithFrame:catalogView.frame];
    bgView.image = bg;
    [catalogView addSubview:bgView];

    for (int i=0; i< numberOfCatalog; i++)
    {
        CGRect makeupFrame = CGRectMake(space2Icon/2+ (space2Icon + iconSize)*i, 0, iconSize, iconSize);
        UIButton *stickerBtn = [[UIButton alloc] initWithFrame:makeupFrame];
        stickerBtn.tag = i;
        stickerBtn.contentMode = UIViewContentModeCenter;
        [stickerBtn setImage:[UIImage imageNamed:[catalogIconNames objectAtIndex:i]] forState:UIControlStateNormal];
        [stickerBtn addTarget:self action:@selector(stickerCatalogTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [catalogView addSubview:stickerBtn];
    }
    [self addSubview:catalogView];
    
}

-(IBAction)stickerCatalogTapped:(UIButton*)sender
{
    NSString *gaEventName;
    UIView *stickerListView;
    currentMode = sender.tag;
    switch (sender.tag) {
        case 0:
            NSLog(@"makeup");
            gaEventName = kGAEventStickerMakeup;
            if (!makupStickerItemsView)
                makupStickerItemsView = [self createStickerItemViewForType:currentMode];
            stickerListView = makupStickerItemsView;
            break;
        case 1:
            NSLog(@"textbox");
            gaEventName = kGAEventStickerTextBox;
            if (!textStickerItemsView)
                textStickerItemsView = [self createStickerItemViewForType:currentMode];
            stickerListView = textStickerItemsView;
            break;
//        case 2:
//            NSLog(@"santa");
//            if (!santaStikerItemView)
//                santaStikerItemView = [self createStickerItemViewForType:currentMode];
//            stickerListView = santaStikerItemView;
//            break;
//        case 3:
//            NSLog(@"snow man");
//            if (!snowmanStikerItemView)
//                snowmanStikerItemView = [self createStickerItemViewForType:currentMode];
//            stickerListView = snowmanStikerItemView;
//            break;
//        case 2:
//            NSLog(@"deco");
//            if (!decoStikerItemView)
//                decoStikerItemView = [self createStickerItemViewForType:currentMode];
//            stickerListView = decoStikerItemView;
//            break;
        case 2:
            NSLog(@"emoticon");
            gaEventName = kGAEventStickerTrollFace;
            if (!emotionStickerItemsView)
                emotionStickerItemsView = [self createStickerItemViewForType:currentMode];
            stickerListView = emotionStickerItemsView;
            break;
        case 3:
            NSLog(@"light");
            gaEventName = kGAEventStickerLightItem;
            if (!lightStickerItemsView)
                lightStickerItemsView = [self createStickerItemViewForType:currentMode];
            stickerListView = lightStickerItemsView;
            break;
        default:
            break;
    }
    
    // annimation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    stickerListView.frame = CGRectMake(0, catalogView.frame.origin.y, catalogView.frame.size.width, catalogView.frame.size.height);
    catalogView.frame = CGRectMake(catalogView.frame.size.width, catalogView.frame.origin.y, catalogView.frame.size.width, catalogView.frame.size.height);
    

    [UIView commitAnimations];
    
    //Google analytics
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Sticker"
//                                                    withAction:kGAEventActionThumbnailTap
//                                                     withLabel:gaEventName
//                                                     withValue:nil];

}
// handle sticker item click
-(IBAction)stickerItem_Click:(UIButton *)sender
{
    NSLog(@"btnMakupItem_Click");
    NSInteger tag = sender.tag;
    float scaleX = 0.25;
    float scaleY = 0.25;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        scaleX = 0.5;
        scaleY = 0.5;
    }
    UIImage * img;
    NSString *stickerName = [NSString stringWithFormat:@"%@%ld", [stickerPrefixNames objectAtIndex:currentMode], (long)tag];
    img = [UIImage imageNamed:stickerName];
   
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.transform = CGAffineTransformScale(imgView.transform, scaleX, scaleY);
    
    // initial draggableview
    CGPoint centerOfPreviewImage = CGPointMake( rootViewControler.previewImageView.frame.origin.x+ rootViewControler.previewImageView.frame.size.width/2,rootViewControler.previewImageView.frame.origin.y+ rootViewControler.previewImageView.frame.size.height/2);
    
    centerOfPreviewImage = CGPointMake(centerOfPreviewImage.x-imgView.frame.size.width/2, centerOfPreviewImage.x-imgView.frame.size.height/2);
    DraggableView * holderView = [[DraggableView alloc] initWithFrame:CGRectMake(centerOfPreviewImage.x,centerOfPreviewImage.y , imgView.frame.size.width, imgView.frame.size.height)];

    // set peroperties for draggable view
    holderView.parentController = self.rootViewControler;
    [holderView setContentView:imgView];
    [self.rootViewControler addNewStickerItem:holderView];
    
    //Google analytics
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"Sticker"
//                                                    withAction:kGAEventActionThumbnailTap
//                                                     withLabel:stickerName
//                                                     withValue:nil];

}

-(UIView*) createStickerItemViewForType:(int)typeIndex
{
    int leftViewWidth = 260;
    int righViewWidth = 58;
    int padding = 2;
    int numberOfItemOneRow = 5;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        righViewWidth = 125;
        leftViewWidth = 638;
        padding = 5;
    }
    int itemSpaceWidth = (leftViewWidth - padding*2)/numberOfItemOneRow;
    
    NSLog(@"createMakupItemsView");
    UIView *stickerView = [[UIView alloc] initWithFrame:CGRectMake(catalogView.frame.origin.x-catalogView.frame.size.width, catalogView.frame.origin.y, catalogView.frame.size.width, catalogView.frame.size.height)];
    [self addSubview:stickerView];
    
    // add left background image
    UIImage * leftBGImage = [UIImage imageNamed:@"UtilityBG"];
    UIImageView * leftImageView = [[UIImageView alloc] initWithImage:leftBGImage];
    leftImageView.frame = CGRectMake(0, 0, leftViewWidth , self.bounds.size.height);
    [stickerView addSubview:leftImageView];
    
    // add right blackground image
    UIImage * rightBGImage = [UIImage imageNamed:@"UtilityBG2"];
    UIImageView * rightImageView = [[UIImageView alloc] initWithImage:rightBGImage];
    rightImageView.frame = CGRectMake(leftViewWidth + padding, 0, righViewWidth , self.bounds.size.height);
    [stickerView addSubview:rightImageView];
    
    // add MakupOnItem
    UIButton * btnMakupOn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMakupOn.frame = rightImageView.frame;
    btnMakupOn.contentMode = UIViewContentModeCenter;
    [btnMakupOn setImage:[UIImage imageNamed:[catalogIconNames objectAtIndex:typeIndex]] forState:UIControlStateNormal];
    btnMakupOn.tag =1;
    [btnMakupOn addTarget:self action:@selector(btnStickerModeOn_Click:) forControlEvents:UIControlEventTouchUpInside];
    [stickerView addSubview:btnMakupOn];
    
    
    // add scrollview
    BOOL isFullversion = [self.rootViewControler isFullVersion];
    int stickerNum;
    if (isFullversion)
         stickerNum = ((NSString*)[numberOfStickers objectAtIndex:typeIndex]).intValue;
    else
        stickerNum = kNumberOfFreeItem;

    UIScrollView * makupScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, leftViewWidth - padding*2, leftImageView.bounds.size.height)];
    for (int i=1; i<= stickerNum; i++) {
        NSString *itemName = [NSString stringWithFormat:@"%@%d", [stickerPrefixNames objectAtIndex:typeIndex], i];
        NSLog(@"itemName:%@",itemName);
        // create imageview
        UIImage * itemImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d%@",[stickerThumbnailPrefixNames objectAtIndex:typeIndex], i, [stickerThumbnailPostfixNames objectAtIndex:typeIndex]]];
        CGRect itemRect = CGRectMake((i-1)*itemSpaceWidth, 0, itemSpaceWidth, leftImageView.bounds.size.height);
        UIImage * hightlightBG = [UIImage imageNamed:@"SelectBG.png"];
        
        // add button
        UIButton * btnItem =[UIButton buttonWithType:UIButtonTypeCustom];
        btnItem.contentMode = UIViewContentModeCenter;
        btnItem.frame = itemRect;
        btnItem.tag = i;
        [btnItem setImage:itemImage forState:UIControlStateNormal];
        [btnItem setBackgroundImage:hightlightBG forState:UIControlStateHighlighted];
        [btnItem addTarget:self action:@selector(stickerItem_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        [makupScrollView addSubview:btnItem];
        
    }
    if (!isFullversion)
    {
        stickerNum ++;
        //create extra pack button
        CGRect itemRect = CGRectMake((stickerNum-1)*itemSpaceWidth, 0, itemSpaceWidth, leftImageView.bounds.size.height);
        UIImage * itemImage = [UIImage imageNamed:@"Extra PackIcon"];
        UIImage * hightlightBG = [UIImage imageNamed:@"SelectBG"];
        
        // add button
        UIButton * btnItem =[UIButton buttonWithType:UIButtonTypeCustom];
        btnItem.contentMode = UIViewContentModeCenter;
        btnItem.frame = itemRect;
        btnItem.tag = stickerNum;
        [btnItem setImage:itemImage forState:UIControlStateNormal];
        [btnItem setBackgroundImage:hightlightBG forState:UIControlStateHighlighted];
        [btnItem addTarget:self action:@selector(getExtraPack) forControlEvents:UIControlEventTouchUpInside];
        
        [makupScrollView addSubview:btnItem];
        
    }
    // calculate content size of makupview
    makupScrollView.contentSize = CGSizeMake(padding*2 + stickerNum*itemSpaceWidth, leftImageView.bounds.size.height);
    [stickerView addSubview:makupScrollView];
    
    return stickerView;

}
#pragma mark - Extra Pack View
-(void)createGUIExtraPack
{
    extraPackView = [[UIView alloc] initWithFrame:self.rootViewControler.view.bounds];
    [self.rootViewControler.view addSubview:extraPackView];
    extraPackView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    
    UIView *gestureView = [[UIView alloc] initWithFrame:extraPackView.bounds];
    [extraPackView addSubview:gestureView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(extraPackBGTapped)];
    [gestureView addGestureRecognizer:tapGesture];
    
    int contentHeight = 306;
    int contentWidth  = 231;
    int iconSquareSize = 32;
    int margin = 5;
    int paddingTop = 15;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        contentHeight = 733;
        contentWidth = 554;
        iconSquareSize = 80;
        margin = 10;
        paddingTop = 30;
    }
    CGRect scrollBGViewFrame = CGRectMake((extraPackView.bounds.size.width - contentWidth)/2,
                                     (extraPackView.bounds.size.height - contentHeight)/2,
                                     contentWidth,
                                     contentHeight);
    UIView *scrollBGView = [[UIImageView alloc] initWithFrame:scrollBGViewFrame];
    scrollBGView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ExtraPack"]];
    
    CGRect contentFrame = CGRectMake(scrollBGViewFrame.origin.x + margin,
                                     scrollBGViewFrame.origin.y + paddingTop + margin,
                                     contentWidth - 2*margin,
                                     contentHeight - 2*margin - paddingTop);
    UIScrollView *contentScroll = [[UIScrollView alloc] initWithFrame:contentFrame];
    [extraPackView addSubview:scrollBGView];
    [extraPackView addSubview:contentScroll];
    
    NSInteger numberOfCatalog = [catalogIconNames count];
    int numberOnRow = contentScroll.bounds.size.width / iconSquareSize;
    int actualIconSize = contentScroll.bounds.size.width/numberOnRow;
    int HIndex = 0;
    int WIndex = 0;
    for (int i=0; i<numberOfCatalog; i++)
    {
        int stickerNum = ((NSString*)[numberOfStickers objectAtIndex:i]).intValue;
        for (int stickerIndex = kNumberOfFreeItem; stickerIndex<stickerNum;stickerIndex++)
        {
            UIImage * itemImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d%@",[stickerThumbnailPrefixNames objectAtIndex:i], stickerIndex, [stickerThumbnailPostfixNames objectAtIndex:i]]];
            
            
            CGRect itemRect = CGRectMake(WIndex * actualIconSize, HIndex * actualIconSize, actualIconSize, actualIconSize);
            WIndex ++;
            if (WIndex > numberOnRow-1)
            {
                WIndex = 0;
                HIndex ++;

            }
            UIImage * hightlightBG = [UIImage imageNamed:@"SelectBG.png"];
            
            // add button
            UIButton * btnItem =[UIButton buttonWithType:UIButtonTypeCustom];
            btnItem.contentMode = UIViewContentModeScaleAspectFit;
            btnItem.frame = itemRect;
            btnItem.tag = i;
            [btnItem setImage:itemImage forState:UIControlStateNormal];
            [btnItem setBackgroundImage:hightlightBG forState:UIControlStateHighlighted];
            [btnItem addTarget:self action:@selector(extraPackIconTapped) forControlEvents:UIControlEventTouchUpInside];
            
            [contentScroll addSubview:btnItem];
        }
    }
    contentScroll.contentSize = CGSizeMake(contentScroll.bounds.size.width, (HIndex+1)*actualIconSize);

}
-(void)getExtraPack
{
    if (!extraPackView)
    {
        [self createGUIExtraPack];
    }
    extraPackView.hidden = NO;
    [extraPackView.superview bringSubviewToFront:extraPackView];
}
-(void)extraPackBGTapped
{
    NSLog(@"hide extra pack view");
    extraPackView.hidden = YES;
}
-(void)extraPackIconTapped
{
    NSLog(@"packIcon tapped");
    [self.rootViewControler unlockFullVersion];
}
-(void)justUnlockedFullversion
{
    if (makupStickerItemsView)
        [self createStickerItemViewForType:MakeupStk];
    if (textStickerItemsView)
        [self createStickerItemViewForType:TextBoxStk];
    if (santaStikerItemView)
        [self createStickerItemViewForType:SantaStk];
    if (snowmanStikerItemView)
        [self createStickerItemViewForType:SnowmanStk];
    if (decoStikerItemView)
        [self createStickerItemViewForType:DecoStk];
    if (emotionStickerItemsView)
        [self createStickerItemViewForType:EmoticonStk];
    if (lightStickerItemsView)
        [self createStickerItemViewForType:LightItemStk];
}
// click from makupItemView
-(IBAction)btnStickerModeOn_Click:(id)sender
{
    NSLog(@"btnMakeUpOn_Click");
    // hide the makupItemsView and show catalog
    // annimation
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    UIView *stickerListView;
    switch (currentMode) {
        case 0:
            stickerListView = makupStickerItemsView;
            break;
        case 1:
            stickerListView = textStickerItemsView;
            break;
//        case 2:
//            stickerListView = santaStikerItemView;
//            break;
//        case 3:
//            stickerListView = snowmanStikerItemView;
//            break;
//        case 2:
//            stickerListView = decoStikerItemView;
//            break;
        case 2:
            stickerListView = emotionStickerItemsView;
            break;
        case 3:
            stickerListView = lightStickerItemsView;
            break;
        default:
            break;
    }
    
    stickerListView.frame = CGRectMake(0-catalogView.frame.size.width, catalogView.frame.origin.y, catalogView.frame.size.width, catalogView.frame.size.height);
    catalogView.frame = CGRectMake(0, catalogView.frame.origin.y, catalogView.frame.size.width, catalogView.frame.size.height);
    [UIView commitAnimations];
}


@end
