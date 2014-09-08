//
//  HWEffectMenuView.h
//  imageprocessing
//
//  Created by Hai Hw on 8/13/12.
//
//

#import <UIKit/UIKit.h>

@interface HWEffectMenuView : UIView
{
    NSArray* itemNames; //NSString
    NSArray* itemLabels;//UILabel
    NSInteger itemCount;
    NSInteger currentItem;
    float deltaY;
}
- (id)initWithItems:(NSArray*)items;
- (void)moveBy:(float)dy;
- (NSInteger)getCurrentItem;
@end
