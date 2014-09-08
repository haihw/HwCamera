	//
//  ViewController.m
//  blendcamerapro
//
//  Created by Dung NP on 8/22/12.
//  Copyright (c) 2012 Applistar Vietnam. All rights reserved.
//

#import "GAI.h"
#import "ViewController.h"
#import "UIImage+Resize.h"
#import "EffectView.h"
#import "StickerView.h"
#import "TextView.h"
#import "FrameView.h"
#import "UtilityView.h"
#import "SharingView.h"
#import "SettingView.h"
#import "DraggableView.h"
#import "MBProgressHUD.h"
#import "HWCustomLabelView.h"
#import "InAppPurchaseView.h"

#import <QuartzCore/QuartzCore.h>

@implementation ViewController
@synthesize currentStickerItem;
@synthesize listDraggableItems;
@synthesize previewImageView;
@synthesize topBarView;
@synthesize bottomBarView;
@synthesize textView;
@synthesize sharedImage, previewImage, originalImage, btnHelp;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self hideAllSelectedButtonOnBottomBar];
    [self hideAllSelectedButtonsOnTopBar];
    currentView = kNoView;
    listDraggableItems = [[NSMutableArray alloc] initWithCapacity:0];
    self.clearButton = [[UIButton alloc]initWithFrame:previewImageView.frame];
    [self.clearButton addTarget:self action:@selector(tapPreviewImageViewHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.clearButton aboveSubview:previewImageView];
    
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        btnCamera.enabled = NO;
        btnSelCamera.enabled = NO;
    }
    
    //load sample image at first load
    self.originalImage = [UIImage imageNamed:@"sampleIMG2.jpg"];
    [self resetAll];
    //hide all other button at first load
    /*
    btnHelp.hidden = YES;
    bottomBarView.hidden = YES;
    topbarBackgoundView.alpha = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mainBackgroundView.image = [UIImage imageNamed:@"Default-Portrait"];
    }
    else
    {
        if ([UIScreen mainScreen].bounds.size.height > 480)
            mainBackgroundView.image = [UIImage imageNamed:@"Default-568h"];
        else
            mainBackgroundView.image = [UIImage imageNamed:@"Default"];

    }
    btnShare.hidden = YES;
    btnSetting.hidden = YES;
    btnDone.hidden = YES;
    self.clearButton.hidden = YES;
     */
//    self.screenName = @"Main View";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Set portrail only
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// buttons on topbar handle
-(IBAction)btnCamera_Click:(id)sender
{
    NSLog(@"btnCamera_Click");
//    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Input Image" withAction:kGAEventActionButtonTap withLabel:kGAEventCameraTap withValue:nil];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

-(IBAction)btnGalery_Click:(id)sender
{
    NSLog(@"btnGalery_Click");
//    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Input Image" withAction:kGAEventActionButtonTap withLabel:kGAEventGalleryTap withValue:nil];
    // reset system
    [self hideShareView];
    [self hideSettingView];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // Set source to the Photo Library
        imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    } else
        return;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // iphone
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else //iPad
    {
        NSLog(@"iPad galery click");
        
         NSLog(@"show popover to get image from library");
         if(libraryPopoverController == nil){
             libraryPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
             libraryPopoverController.delegate =self;
             NSLog(@"new");
         }
         
         UIButton *btn = (UIButton *) sender;
         CGRect popoverRect = [self.view convertRect:[btn frame]
         fromView:[btn superview]];
         popoverRect.size.width = MIN(popoverRect.size.width, 100);
         [libraryPopoverController
         presentPopoverFromRect:popoverRect
         inView:self.view
         permittedArrowDirections:UIPopoverArrowDirectionUp
         animated:YES];
    }
    imagePicker = nil;
}
-(IBAction)btnShareClick:(id)sender
{
    NSLog(@"Share");
    btnShare.hidden = YES;
    btnSelShare.hidden = NO;
    [self hideSettingView];
    
    //be sure current effect is applied
    if (effectView)
        [effectView applyCurrentEffect];
    if (shareView)
    {
        shareView.hidden = NO;
        [self.view bringSubviewToFront:shareView];
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            shareView = [[SharingView alloc] initWithFrame:CGRectMake(58, 46, 160, 128)];
            shareView.rootViewController = self;
        }
        else
        {
            NSLog(@"share ipad click");
            shareView = [[SharingView alloc] initWithFrame:CGRectMake(8, 98, 385, 307)];
            shareView.rootViewController = self;
            
        }
        
        [self.view addSubview:shareView];
    }
}
-(void) hideShareView
{
    if (shareView && !shareView.hidden)
    {
        btnShare.hidden = NO;
        btnSelShare.hidden = YES;
        shareView.hidden = YES;
    }
}
-(IBAction)btnShareOffClick:(id)sender
{
    NSLog(@"Share off");
    [self hideShareView];
}
-(IBAction)btnSettingOffClick:(id)sender
{
//    return;
    NSLog(@"Setting on");
    btnSetting.hidden = YES;
    btnSelSetting.hidden = NO;
    [self hideShareView];
    if (settingView)
    {
        settingView.hidden = NO;
        [settingView showGUI];
        [self.view bringSubviewToFront:settingView];
    }
    else
    {
        CGRect frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            frame = CGRectMake(75, 46, 245, 290);
            frame = CGRectMake(75, 46, 245, 270);
        else
//            frame = CGRectMake(768-550, 98, 550 , 620);
            frame = CGRectMake(768-550, 98, 550 , 600);
        settingView = [[SettingView alloc] initWithFrame:frame];
        
        settingView.rootViewController = self;
        [self.view addSubview:settingView];
    }
}
-(void) hideSettingView
{
    if (settingView && !settingView.hidden)
    {
        btnSetting.hidden = NO;
        btnSelSetting.hidden = YES;
        settingView.hidden = YES;
    }
}
-(IBAction)btnSettingClick:(id)sender
{
//    return;
    NSLog(@"Setting off");
    [self hideSettingView];
}
-(IBAction)btnResetAllClick:(id)sender
{
    NSLog(@"reset all");
    [self resetAll];
    
}


// hide the selected button on top and bottombars

-(void) hideAllSelectedButtonsOnTopBar
{
    //buttons for topbar
    btnSelCamera.hidden = YES;
    btnSelGalery.hidden = YES;
    btnSelShare.hidden = YES;
    btnSelSetting.hidden = YES;
    btnSelDone.hidden = YES;
}

-(void) hideAllSelectedButtonOnBottomBar
{
    // buttons for bottombar
    btnSelEffect.hidden = YES;
    btnSelEffectBG.hidden = YES;
    btnSelSticker.hidden = YES;
    btnSelStickerBG.hidden = YES;
    btnSelText.hidden = YES;
    btnSelTextBG.hidden = YES;
    btnSelFrame.hidden = YES;
    btnSelFrameBG.hidden = YES;
    btnSelUtility.hidden = YES;
    btnSelUtilityBG.hidden = YES;
}




// handle imagepikerdelegate
-(CGRect) getPreviewFrame
{
    UIImageView *iv = previewImageView;
    CGSize imageSize = iv.image.size;
    NSLog(@"size:%@", NSStringFromCGSize(imageSize));
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(floorf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), floorf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image)
    {
        self.originalImage = image;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && settingView && settingView.shouldSaveOriginal)
        {
            NSLog(@"Saved");
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }
    else
        NSLog(@"Input unavailable");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self resetAll];
    
    // dimiss library popovercontroller
    if (libraryPopoverController.isPopoverVisible) {
        [libraryPopoverController dismissPopoverAnimated:YES];
    }
    picker = nil;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // hide tongle button
    NSLog(@"imagePickerControllerDidCancel");
    btnSelGalery.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapPreviewImageViewHandle
{
    NSLog(@"preview image view clicked");
    [self hideBorderOfCurrentStickerItem];
    [textView previewImageViewClicked];
    [self hideShareView];
    [self hideSettingView];

}

-(void)tapToolTipHandler
{
    NSLog(@"hide tool tip view");
    toolTipView.hidden = YES;
}
-(IBAction)help_click:(id)sender
{
    [self showToolTip];
}
-(void)showToolTip
{
    if (toolTipView)
    {
        //show
        toolTipView.hidden = NO;
        [self.view bringSubviewToFront:toolTipView];
    }else
    {
        
        toolTipView = [[UIView alloc] initWithFrame:self.view.bounds];
        toolTipImageView = [[UIImageView alloc] initWithFrame:toolTipView.bounds];
        [toolTipView addSubview:toolTipImageView];
        [self.view addSubview:toolTipView];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToolTipHandler)];
        [toolTipView addGestureRecognizer:tapRecognizer];
    }
    switch (currentView) {
        case kEffectView:
            toolTipImageView.image = [UIImage imageNamed:@"Main_Tip"];
            break;
        case kTextView:
            toolTipImageView.image = [UIImage imageNamed:@"Text_Tip"];
            break;
        default:
            toolTipView.hidden = YES;
            break;
    }
    NSLog(@"show tool tip");

}
#pragma mark Change to views
-(BOOL) is4InchRetina
{
    return ([UIScreen mainScreen].bounds.size.height > 480);

}
-(void) enableAllStickerItem:(BOOL)enableFlag
{
    //enable all item
    for (DraggableView* item in listDraggableItems)
    {
        item.userInteractionEnabled = enableFlag;
        
    }

}
// Change to EffectView
-(void) changeToEffectView
{
//    [[GAI sharedInstance].defaultTracker sendView:kGAEffectScreenName];
    NSLog(@"changeToEffectView");
    //hide allview
    [self hideAllView];
    [self enableAllStickerItem:NO];
    // set current ViewMode
    currentView = kEffectView;
    if (effectView) {
        NSLog(@"existing EffectView");
        // show statusbar
        NSLog(@"currentTag:%ld",(long)effectView.currentTag);
        [effectView showEffectStatusBar:effectView.currentTag];
        [self.view bringSubviewToFront:effectView];
        effectView.hidden = NO;
        [effectView applyEffect];
        
    }
    else
    {
        // not including status bar height
        CGRect effectViewFrame;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // ipad
        {
            if ([self is4InchRetina]) {
                //4 inch retina
                effectViewFrame = CGRectMake(0, 470, 320, 61);
            }
            else
            {
                effectViewFrame = CGRectMake(0, 382, 320, 61);
            }
        }else
            effectViewFrame = CGRectMake(0, 816, 768, 128);

        
        effectView = [[EffectView alloc] initWithFrame:effectViewFrame];
        effectView.rootViewControler = self;
        effectView.isFullVersion = [self isFullVersion];
        [self.view addSubview:effectView];
    }
//    [effectView applyAllEffectForImage:originalImage];
}


-(void) changeToStickerView
{
//    [[GAI sharedInstance].defaultTracker sendView:kGAStickerScreenName];

    NSLog(@"changeToStickerView");
    //hide allview
    [self hideAllView];
    
    [self enableAllStickerItem:YES];
    // set current ViewMode
    currentView = kStickerView;
    
    if (stickerView) {
        NSLog(@"existing StickerView");
        stickerView.hidden = NO;
    }
    else
    {
        CGRect stickerViewFrame;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // ipad
        {
            if ([self is4InchRetina])
                stickerViewFrame = CGRectMake(0, 482, 320, 48);
            else
                stickerViewFrame = CGRectMake(0, 394, 320, 48);
        }else
            stickerViewFrame = CGRectMake(0, 845, 768, 95);

        stickerView = [[StickerView alloc] initWithFrame:stickerViewFrame];
        stickerView.rootViewControler = self;
        //effectView.alpha =0.0f;
        [self.view addSubview:stickerView];
    }
    //enable all item
    for (DraggableView* item in listDraggableItems)
    {
        item.userInteractionEnabled = YES;
        
    }

}

-(void) changeToTextView
{

//    [[GAI sharedInstance].defaultTracker sendView:kGATextScreenName];

    NSLog(@"changeToTextView");
    [self hideAllSelectedButtonOnBottomBar];
    btnSelText.hidden = NO;
    btnSelTextBG.hidden = NO;
    

    //hide allview
    [self hideAllView];
    btnHelp.hidden = NO;
    // set current ViewMode
    currentView = kTextView;
    
    if (textView)
    {
        NSLog(@"existing changeToTextView");
        textView.hidden = NO;
        textView.CLView.hidden = NO;
    }
    else
    {
        CGRect textViewFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            textViewFrame = CGRectMake(0, 668, 768, 264);
        else
            if ([self is4InchRetina])
                textViewFrame = CGRectMake(0, 404, 320, 123);
            else
                textViewFrame = CGRectMake(0, 316, 320, 123);
                
        textView = [[TextView alloc] initWithFrame:textViewFrame];
        textView.rootViewControler = self;
        textView.CLView = [[HWCustomLabelView alloc] initWithFrame:self.previewImageView.frame];
        
        textView.CLView.rootViewController = self;
        textView.CLView.textView = textView;
        [self.view addSubview:textView.CLView];
        
        NSLog(@"CustomLabelView frame: %@", NSStringFromCGRect(textView.CLView.frame));

        [self.view addSubview:textView];
        [textView addTextFieldNoIndicator];
        
    }
    // disable all other item
    for (DraggableView* item in listDraggableItems)
    {
        if (![item isTextContent])
            item.userInteractionEnabled = NO;
        else
            item.userInteractionEnabled = YES;
        
    }
}

-(void) changeToUtilityView
{
//    [[GAI sharedInstance].defaultTracker sendView:kGAUtilityScreenName];

    NSLog(@"changeToUtilityView");
    //hide allview
    [self hideAllView];
    [self enableAllStickerItem:NO];
    // set current ViewMode
    currentView = kUtilityView;
    
    if (utilityView) {
        NSLog(@"existing changeToUtilityView");
        utilityView.hidden = NO;
    }
    else
    {
        CGRect utilityViewFrame;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // ipad
        {
            if ([self is4InchRetina])
                utilityViewFrame = CGRectMake(0, 488, 320, 38);
            else
                utilityViewFrame = CGRectMake(0, 400, 320, 38);
        }else
            utilityViewFrame = CGRectMake(0, 855, 768, 80);

        utilityView = [[UtilityView alloc] initWithFrame:utilityViewFrame];
        utilityView.rootViewController = self;
        // add cancel and Apply button
        [utilityView addCancelAndApplyButtonToRootController];
        [self.view addSubview:utilityView];
    }
}

-(void) changeToFrameView
{
//    [[GAI sharedInstance].defaultTracker sendView:kGAFrameScreenName];

    NSLog(@"changeToFrameView");
    //hide allview
    [self hideAllView];
    [self enableAllStickerItem:NO];
    // set current ViewMode
    currentView = kFrameView;
    
    if (frameView) {
        NSLog(@"existing frameView");
        frameView.hidden = NO;
    }
    else
    {
        CGRect frameViewFrame;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)  // ipad
        {
            if ([self is4InchRetina])
                frameViewFrame = CGRectMake(0, 470, 320, 61);
            else
                frameViewFrame = CGRectMake(0, 382, 320, 61);
        }else
            frameViewFrame = CGRectMake(0, 816, 768, 128);

        frameView = [[FrameView alloc] initWithFrame:frameViewFrame];
        frameView.rootViewController = self;
        [self.view addSubview:frameView];
    }
    
}



// handle button click on bottombar
-(IBAction)btnEffect_Click:(id)sender
{
    NSLog(@"btnEffect_Click");
    // hideAllSelectedButtonOnBottomBar
    [self hideAllSelectedButtonOnBottomBar];
    btnSelEffect.hidden = NO;
    btnSelEffectBG.hidden = NO;
    
    // change to effect view
    [self changeToEffectView];
    
}

-(IBAction)btnSticker_Click:(id)sender
{
//    return;
    NSLog(@"btnSticker_Click");
    // hideAllSelectedButtonOnBottomBar
    [self hideAllSelectedButtonOnBottomBar];
    btnSelSticker.hidden = NO;
    btnSelStickerBG.hidden = NO;
    
    // change to effect view
    [self changeToStickerView];
    
}

-(IBAction)btnText_Click:(id)sender
{
//    return;
    NSLog(@"btnText_Click");
    
    // change to text view
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [self changeToTextView];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

    
}

-(IBAction)btnUtility_Click:(id)sender
{
//    return;
    NSLog(@"btnUtility_Click");
    
    [self hideAllSelectedButtonOnBottomBar];
    btnSelUtility.hidden = NO;
    btnSelUtilityBG.hidden = NO;
    
    // change to utility view
    [self changeToUtilityView];
}

-(IBAction)btnFrame_Click:(id)sender
{
    NSLog(@"btnFrame_Click");
    [self hideAllSelectedButtonOnBottomBar];
    btnSelFrame.hidden = NO;
    btnSelFrameBG.hidden = NO;
    
    // change to utility view
    [self changeToFrameView];

}

-(void) hideAllView
{
    NSLog(@"hideAllView");
    effectView.hidden = YES;
    stickerView.hidden = YES;
    textView.hidden = YES;
    textView.CLView.hidden = YES;
    utilityView.hidden = YES;
    frameView.hidden = YES;
    [self hideSettingView];
    [self hideShareView];
    if (utilityView)
        [utilityView hideAll];
    if (textView)
        [textView hideAll];
    [self hideBorderOfCurrentStickerItem];
    btnHelp.hidden = YES;
}


#pragma  handle for apply the adding Sticker item

// getDisplay Frame Of iamge view
-(CGRect) getDiplayFrameOfImageView:(UIImageView*) iv
{
    CGSize imageSize = iv.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(floorf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), floorf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
}


// Crop image
- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
//    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, self.view.opaque, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image 
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

// get cropt of holderView contains UIImage and some stikers

-(UIImage *)getCropImageOfAttackmentSticker:(UIView *)holderView :(CGRect)cropRect :(NSArray *)stickers
{
    
    //add sticker to holderView
    for (int i =0; i< stickers.count;i++) {
        DraggableView  * sticker = [stickers objectAtIndex:i];
        [holderView addSubview:sticker];
    }
    
    UIGraphicsBeginImageContextWithOptions(holderView.frame.size, holderView.opaque, 0.0);
//    UIGraphicsBeginImageContext(holderView.frame.size);
    
    // reder in previewImageView context
    [holderView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *holderViewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    //cropt holderViewImage by croptRect
    UIImage * croptImage = [self  getSubImageFrom:holderViewImage WithRect:cropRect];
    
    return  croptImage;
} 


// apply Sticker process for input image not is previewimage
-(UIImage *) applyStickerItemForImage:(UIImage *) inputImage  Stickers:(NSMutableArray *)listStickerItem
{
    [self hideBorderOfCurrentStickerItem];
    // get display image rect
    CGRect cropFrame = [self getDiplayFrameOfImageView:previewImageView];
    cropFrame = CGRectMake(previewImageView.frame.origin.x + cropFrame.origin.x, cropFrame.origin.y+previewImageView.frame.origin.y, cropFrame.size.width, cropFrame.size.height);
    
    float sx = inputImage.size.width/cropFrame.size.width;
    float sy = inputImage.size.height/cropFrame.size.height;
    
    // create holderView
    UIView * holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width *sx, self.view.frame.size.height*sy)];
    
    // change list Stiker
    NSArray *stickerItemsList = [[NSArray alloc] initWithArray:listStickerItem copyItems:YES];
    for (int i =0; i< stickerItemsList.count; i++) {
        DraggableView * sticker = [stickerItemsList objectAtIndex:i];
        sticker.center = CGPointMake(sticker.center.x*sx, sticker.center.y*sy);
        sticker.transform =CGAffineTransformScale(sticker.transform, sx, sy);
    }
    // add diplay image 
    cropFrame = CGRectMake(cropFrame.origin.x*sx, cropFrame.origin.y*sy, cropFrame.size.width*sx, cropFrame.size.height*sy);
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:cropFrame];
    imgView.image = inputImage;
    [holderView addSubview:imgView];
    
    UIImage * result = [self getCropImageOfAttackmentSticker:holderView :cropFrame :stickerItemsList];
    
    return result;
}


#pragma -
#pragma mark Item_Management
// handle DraggableView event
// show current sticker item view
-(DraggableView*) getCurrentStickerItem
{
    return self.currentStickerItem;
}
-(void)setCurrenStickertItemView:(DraggableView*)itemView
{
    // hide all boder of items
    NSLog(@"sticker count : %ld", (unsigned long)listDraggableItems.count);
    for (DraggableView *stikerItem in listDraggableItems) {
        [stikerItem hideEditingHandles];
    }
    self.currentStickerItem = itemView;
    [self.currentStickerItem showEditingHandles];

    
}

// remove item from list
-(void) removeStickerItemView:(DraggableView*)itemView;
{
    //if remove text item
    if (itemView.isTextContent)
    {
        itemView.isTextContent = NO;
    }
    [itemView removeFromSuperview];
    [listDraggableItems removeObject:itemView];
    itemView = nil;
    NSLog(@"listDraggableItems.count:%ld",(unsigned long)listDraggableItems.count);
}

// hideBorderOfself.currentStickerItem
-(void) hideBorderOfCurrentStickerItem
{
    if (self.currentStickerItem)
        [self.currentStickerItem hideEditingHandles];
}

// remove all stikerItems
-(void)removeAllStickerItemFromSuperView;
{
    currentStickerItem.isTextContent = NO;
    //because after remove all item, current item hasn't destroyed, still in memory in awhile
    //So set isTextContent = NO to make textView run correctly

    DraggableView *stikerItem;
    for (stikerItem in listDraggableItems) {
        [stikerItem removeFromSuperview];
    }
    [listDraggableItems removeAllObjects];
    
    NSLog(@"Removed all items view %ld",(unsigned long)listDraggableItems.count);
}
//Add new
-(void) addNewStickerItem:(DraggableView*)itemView
{
    [listDraggableItems addObject:itemView];
    NSLog(@"listDraggableItems.count:%ld",(unsigned long)listDraggableItems.count);
    [self.view insertSubview:itemView belowSubview:topBarView];
    [self setCurrenStickertItemView:itemView];
    
}
#pragma -
#pragma mark Pipe Process

//----------------------------------------------------
// Let input image run through pipe process
// apply effect -> add items -> add text -> add frame
// Return the final result
//
-(UIImage*)pipeProcess:(UIImage*)inputImage isFinal:(bool)isFinal
{
    
    if (inputImage == Nil)
    {
        NSLog(@"No input image");
        return nil;
    }
    NSLog(@"Begin Pipe Process");
    UIImage *tempImage = inputImage;
    if (effectView)
    {
        NSLog(@"..3..Effecting...");
        tempImage = [effectView applyEffectForImage:tempImage];
    }

    if (utilityView)
    {
        if (utilityView.shouldRotate)
        {
            NSLog(@"..1..Rotating...");
            tempImage = [utilityView applyRotationImageFor:tempImage withStage:utilityView.getCurrentState];
        }
        if (utilityView.shouldCrop)
        {
            NSLog(@"..2..Cropping...");
            tempImage = [utilityView applyCropFilterFor:tempImage];
        }
        
    }
    //only final output has sticker items (for shareview)
    if ((isFinal)&&(textView || stickerView))
    {
        NSLog(@"..4..Stickering...");
        tempImage = [self applyStickerItemForImage:tempImage Stickers:listDraggableItems];
    }
    if (frameView)
    {
        NSLog(@"..5..Framing...");
        tempImage = [frameView applyFrameForImage:tempImage];
    }
    NSLog(@"END Pipe Process");
    
    return tempImage;
}


//----------------------------------------------------
// apply pipe process on preview image
// No return
-(void)f5Preview
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [self f5NoIndicator];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}
-(void)f5NoIndicator
{
    self.previewImageView.image = [self pipeProcess:self.previewImage isFinal:NO];
}
-(UIImage*)getShareImage
{
    float size = 800;
    //get output resolution from setting
    if (settingView)
        size = settingView.getOuputResolution;
    //check to be sure output resolution smaller or equal to original size
    float originalSize = MAX(self.originalImage.size.width, self.originalImage.size.height);
    if (size > originalSize || size < 1) //size = 0 when setting full resolution
        size = originalSize;
    
    UIImage* inputImage = [self.originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(size, size) interpolationQuality:kCGInterpolationDefault];
    
    NSLog(@"Output size: %@", NSStringFromCGSize(inputImage.size));
    UIImage* outputImage;
    @autoreleasepool {
        outputImage =  [self pipeProcess:inputImage isFinal:YES];
    }
    return outputImage;
}
-(void)createFinalResultImage
{
    self.sharedImage = [self pipeProcess:self.previewImage isFinal:YES];
}


// reset all function
-(void)resetAll
{
    // show all other view that be hidden at the first load
    if (bottomBarView.hidden)
    {
        bottomBarView.hidden = NO;
        topbarBackgoundView.alpha = 1;
        
        //change main background to black depend on screen size
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [self is4InchRetina])
            mainBackgroundView.image = [UIImage imageNamed:@"Main_Bg4inch"];
        else
            mainBackgroundView.image = [UIImage imageNamed:@"Main_Bg"];
        
        btnShare.hidden = NO;
        btnSetting.hidden = NO;
        btnDone.hidden = NO;
        self.clearButton.hidden = NO;

    }
    NSLog(@"resetAll");
    // remove effectView
    if (effectView) {
        self.previewImageView.hidden = NO;
        NSLog(@"remove effectView");
        [effectView removeAll];
        effectView = nil;
    }
    // remove StickerView
     // remove all stickers 
    if (stickerView||textView) {
        
         NSLog(@"remove stickerView");
        [self removeAllStickerItemFromSuperView];
        [stickerView removeFromSuperview];
        stickerView = nil;
    }
    
    if (textView) {
        NSLog(@"remove textView");
        [textView removeAll];
        textView = nil;
    }
    // Utility
    if (utilityView) {
        NSLog(@"remove utilityView");
        [utilityView removeAll];
        utilityView = nil;
    }
    // frame view
    
    if (frameView) {
        NSLog(@"remove frameView");
        [frameView removeAll];
        frameView = nil;
    }
    
    //
    [self hideAllSelectedButtonOnBottomBar];
    [self hideAllSelectedButtonsOnTopBar];
    [self hideSettingView];
    [self hideShareView];

    
    previewImageView.image = self.originalImage;
    // get previewIamge frame on previewImageView
    CGRect previewFrame= [self getPreviewFrame];
    CGSize previewSize = previewFrame.size;
    if ([UIScreen mainScreen].scale == 2.0){
        // change previewSize
        NSLog(@"Retina supported");
        previewSize = CGSizeMake(previewSize.width*2, previewSize.height*2);
    }
     self.previewImage = [self.originalImage resizedImage:previewSize interpolationQuality:kCGInterpolationDefault];
    //call F5 preview to update previewImageView
    [self f5Preview];
    //chang to effect view by default
    [self changeToEffectView];

}
-(BOOL)isFreshLoad
{
    //return yes if this is the first load of application
    return NO;
}
#pragma mark - In App Purchase
- (BOOL) isFullVersion
{
return YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/isFullVersion.ini",
                          documentsDirectory];
    NSString *content = [[NSString alloc] initWithContentsOfFile:fileName
                                                    usedEncoding:nil
                                                           error:nil];
    if (content)
    {
        NSLog(@"check full version: YES %@", content);
        return YES;
    }
    else
    {
        NSLog(@"check full version: NO");
        
        return NO;
    }
}
-(void)makeInAppPurchase
{
    if ([self isFullVersion])
    {
        NSLog(@"This is full version");
        return;
    }
    if (!IAPView)
    {
        IAPView = [[InAppPurchaseView alloc] initWithFrame:self.view.bounds];
        IAPView.rootViewController = self;
        [self.view addSubview:IAPView];
        IAPView.hidden = YES;
    }
    [IAPView active];
    [self.view bringSubviewToFront:IAPView];
}

-(void) unlockFullVersion
{
    NSLog(@"Unlock full version");
    //    [self setFullVersion];
    [self makeInAppPurchase];
}
-(void)inAppPurchaseCompleteWithStatus:(BOOL)isSuccess
{
    //hide HUD indicator
    if (isSuccess)
    {
        [self setFullVersion];
        //refresh GUI
        if (stickerView)
            [stickerView justUnlockedFullversion];
        if (effectView)
            effectView.isFullVersion = YES;
        [self changeToEffectView];
        //AlerView show notice to user
        UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Transaction Succeeds" message:@"Thank You" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [newAlert show];
        //
    }else
    {
        //AlerView show notice to user
        UIAlertView *newAlert = [[UIAlertView alloc]initWithTitle:@"Transaction Errors" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [newAlert show];
    }
}
-(void)setFullVersion
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/isFullVersion.ini", documentsDirectory];
    NSString *content = @"FUllVersion";
    //save content to the documents directory
    [content writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    NSLog(@"Write full version to disk successfully");
    
}

@end
