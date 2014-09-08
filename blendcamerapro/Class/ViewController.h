//
//  ViewController.h
//  blendcamerapro
//
//  Created by Dung NP on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//
#define kNumberOfFreeEffect 5
#import <UIKit/UIKit.h>
#import "Define.h"
@class EffectView,StickerView,TextView,UtilityView, DraggableView, SharingView, SettingView,FrameView, InAppPurchaseView;
@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>
{
    UIPopoverController * libraryPopoverController; // popover for get image from library of iPad
    UIPopoverController * sharePopoverController;  // for share
    UIPopoverController * settingPopoverController; // for setting
    
    // manage topbar & bottom bar
    IBOutlet UIView * topBarView;
    IBOutlet UIView * bottomBarView;
    IBOutlet UIImageView *mainBackgroundView;
    IBOutlet UIImageView *topbarBackgoundView;

    //buttons for topbar
    IBOutlet UIButton * btnCamera;
    IBOutlet UIButton * btnSelCamera;
    IBOutlet UIButton * btnGalery;
    IBOutlet UIButton * btnSelGalery;
    IBOutlet UIButton * btnShare;
    IBOutlet UIButton * btnSelShare;
    IBOutlet UIButton * btnSetting;
    IBOutlet UIButton * btnSelSetting;
    IBOutlet UIButton * btnDone;
    IBOutlet UIButton * btnSelDone;
    // buttons for bottombar
    IBOutlet UIButton * btnEffect;
    IBOutlet UIButton * btnSelEffect;
    IBOutlet UIButton * btnSelEffectBG;
    IBOutlet UIButton * btnSticker;
    IBOutlet UIButton * btnSelSticker;
    IBOutlet UIButton * btnSelStickerBG;
    IBOutlet UIButton * btnText;
    IBOutlet UIButton * btnSelText;
    IBOutlet UIButton * btnSelTextBG;
    IBOutlet UIButton * btnFrame;
    IBOutlet UIButton * btnSelFrame;
    IBOutlet UIButton * btnSelFrameBG;
    IBOutlet UIButton * btnUtility;
    IBOutlet UIButton * btnSelUtility;
    IBOutlet UIButton * btnSelUtilityBG;
    IBOutlet UIButton * btnHelp;
    
    // previewImageView
    IBOutlet UIImageView * previewImageView;
//    UIImage * originalImage;
    
    // manage allview
    EffectView  * effectView;
    StickerView * stickerView;
    TextView    * textView;
    UtilityView * utilityView;
    SharingView * shareView;
    SettingView * settingView;
    FrameView   * frameView;
    
    //Tool tip
    UIView * toolTipView;
    UIImageView *toolTipImageView;
    // current view mode
    enum kViewMode currentView;
    
    NSMutableArray * listDraggableItems;
    
    //inapp purchase
    InAppPurchaseView *IAPView;
    
}
@property (nonatomic, strong) DraggableView* currentStickerItem;
@property (nonatomic, strong) NSMutableArray * listDraggableItems;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton * btnHelp;
@property (nonatomic, strong) TextView * textView;
@property (nonatomic, strong) IBOutlet UIImageView * previewImageView;
@property (nonatomic, strong) IBOutlet UIView * topBarView;
@property (nonatomic, strong) IBOutlet UIView * bottomBarView;
@property (nonatomic, strong) UIImage *sharedImage;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImage *originalImage;
//@property (nonatomic, strong)    UIActivityIndicatorView *acIndicatorView;

-(void)f5Preview;
-(void)f5NoIndicator;
-(void)createFinalResultImage;
-(UIImage*)getShareImage;
-(void) hideSettingView;
-(void) hideShareView;
-(void) showToolTip;

//Item Management
// show current sticker item view
-(DraggableView*) getCurrentStickerItem;
-(void)setCurrenStickertItemView:(DraggableView*)itemView;
// remove item from list
-(void) removeStickerItemView:(DraggableView*)itemView;
//Add new
-(void) addNewStickerItem:(DraggableView*)itemView;
// hideBorderOfCurrentStickerItem
-(void) hideBorderOfCurrentStickerItem;
-(void)tapPreviewImageViewHandle;
// getDisplay Frame Of iamge view
-(CGRect) getDiplayFrameOfImageView:(UIImageView*) iv;
-(void)resetAll;
-(void)changeToTextView;
-(BOOL)isFreshLoad;
-(BOOL)isFullVersion;
-(void)unlockFullVersion;
-(void)inAppPurchaseCompleteWithStatus:(BOOL)isSuccess;

@end
