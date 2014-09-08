//
//  StickerView.h
//  blendcamerapro
//
//  Created by Do Khanh Toan on 8/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
typedef NS_ENUM(NSInteger, StickerMode){
    MakeupStk    = 0,
    TextBoxStk  = 1,
    SantaStk    = 2,
    SnowmanStk  = 3,
    DecoStk     = 4,
    EmoticonStk    = 5,
    LightItemStk   = 6,
};

@interface StickerView : UIView
{
    UIView * catalogView;
    
    UIView * makupStickerItemsView;     // conatians makup sticker items
    UIView * textStickerItemsView;      // text items view 
    UIView * santaStikerItemView;
    UIView * snowmanStikerItemView;
    UIView * decoStikerItemView;
    UIView * emotionStickerItemsView;  // emoticon items view
    UIView * lightStickerItemsView;
    
    UIView * extraPackView;
    
    NSArray *catalogIconNames;
    NSArray *stickerPrefixNames;
    NSArray *stickerThumbnailPrefixNames;
    NSArray *stickerThumbnailPostfixNames;

    NSArray *numberOfStickers;
    //Scroll view contains items
    UIScrollView * stickerScrollView;
    
    NSMutableArray * listStickerItems; // contains listitems
    int currentStickerItemTag;
    

    //current mode
    enum StickerMode currentMode;
}

@property (nonatomic, strong)  NSMutableArray * listMakupItems;
@property (nonatomic, strong)  NSMutableArray * listTextItems;
@property (nonatomic, strong)  NSMutableArray * listEmotion1Items;
@property (nonatomic, strong)  NSMutableArray * listEmotion2Items;
@property (nonatomic, strong)  ViewController * rootViewControler;
@property (nonatomic,strong)   NSMutableArray * listStickerItems; 
-(void)justUnlockedFullversion;
@end
