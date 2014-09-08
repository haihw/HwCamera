//
//  Define.h
//  blendcamerapro
//
//  Created by Do Khanh Toan on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// mode views
enum kViewMode {
       kEffectView  = 0,
       kStickerView = 1,
       kTextView    = 2,
       kFrameView   = 3,
       kUtilityView = 4,
       kNoView      = 5,
    };

#define kEffectName0  @"Original"
#define kEffectName1  @"Romantic Pink"
#define kEffectName2  @"Frezzing Blue"
#define kEffectName3  @"Foliage"
#define kEffectName4  @"Violet Coffee"
#define kEffectName5  @"Warm Summer"
#define kEffectName6  @"Cool Summer"
#define kEffectName7  @"Wild Dark Blue"
#define kEffectName8  @"Special Blue"
#define kEffectName9  @"Fearless"
#define kEffectName10 @"Magical Cyan"
#define kEffectName11 @"Warm Forest"
#define kEffectName12 @"Summer Forest"
#define kEffectName13 @"Warm Landscape"
#define kEffectName14 @"Sexy Red"
#define kEffectName15 @"White Fade"
#define kEffectName16 @"Soft White"
#define kEffectName17 @"Love Green"
#define kEffectName18 @"Vampire"
#define kEffectName19 @"Green Landscape"
#define kEffectName20 @"Magenta Leaves"
#define kEffectName21 @"Green Fodder"
#define kEffectName22 @"Dark Street"
#define kEffectName23 @"Green Boost"
#define kEffectName24 @"City Night"
#define kEffectName25 @"Cold White"
#define kEffectName26 @"Tukief"
#define kEffectName27 @"Vivajupi"

#define kFxThumbnailPrefix @"Thn_"
// define name of frames
#define kFrame_Prefixname               @"Frames_"


//padding space for font is base on font.lineHeight
#define kPaddingFont1   2
#define kPaddingFont2   2
#define kPaddingFont3   2
#define kPaddingFont4   2
#define kPaddingFont5   2
#define kPaddingFont6   2
#define kPaddingFont7   2
#define kPaddingFont8   2
#define kPaddingFont9   2
#define kPaddingFont10   2
#define kPaddingFont11   2
#define kPaddingFont12   2
#define kPaddingFont13   2
#define kPaddingFont14   2
#define kPaddingFont15   2
#define kPaddingFont16   2
#define kPaddingFont17   2
#define kPaddingFont18   2
#define kPaddingFont19   2
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)


// For Google Analytics
#define kGAEffectScreenName @"Effect View"
#define kGAFrameScreenName @"Frame View"
#define kGAStickerScreenName @"Sticker View"
#define kGATextScreenName @"Text View"
#define kGAUtilityScreenName @"Utility View"

//Event
#define kGAEventActionThumbnailTap @"ThumnailTap"
#define kGAEventActionButtonTap @"ButtonTap"

#define kGAEventCameraTap @"Camera"
#define kGAEventGalleryTap @"Photo Library"
#define kGAEventEffectPrefix @"Effect"
#define kGAEventCustomEffect @"Customize Effect"
#define kGAEventFramePrefix @"Frame"

#define kGAEventStickerMakeup @"Sticker Makeup"
#define kGAEventStickerTextBox @"Sticker TextBox"
#define kGAEventStickerTrollFace @"Sticker TrollFace"
#define kGAEventStickerLightItem @"Sticker LightItem"

#define kGAEventCustomText @"Customize Text"
#define kGAEventCrop @"Crop"
#define kGAEventRotate @"Rotate"
#define kGAEventChangeResolution @"Resolution"
