//
//  HWEffectMenuView.m
//  imageprocessing
//
//  Created by Hai Hw on 8/13/12.
//
//

#import "HWEffectMenuView.h"
#import <QuartzCore/QuartzCore.h>
#define kItemHeight 33
@implementation HWEffectMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithItems:(NSArray*)items
{
    itemNames = items;
    itemCount = [itemNames count];
    self = [super initWithFrame:CGRectMake(0, 0, 170, itemCount*kItemHeight + 10)];
    if (self) {
        
        [self createGUI];
        // Initialization code
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)createGUI
{
    NSLog(@"Init Menu View");
    self.opaque = YES;
    self.alpha = 0.8;
    self.backgroundColor = [UIColor grayColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.shadowOffset = CGSizeMake(3, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = .25;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    currentItem = 0;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:itemCount];
    for (int i=0; i<itemCount; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, i*kItemHeight+7, 150, 28)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_Item"]];

        label.text = [itemNames objectAtIndex:i];
        label.font = [UIFont fontWithName:@"Arial" size:16];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor purpleColor];
        label.shadowOffset = CGSizeMake(1, 1);
        [self addSubview:label];
        [array addObject:label];
    }
    itemLabels = array;
    [self selectItemHasIndex: currentItem];
    
}
-(void)selectItemHasIndex:(NSInteger) index
{
    
    UILabel *label = [itemLabels objectAtIndex:currentItem];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_Item"]];

    label = [itemLabels objectAtIndex:index];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_Item_Selected"]];
    currentItem = index;
}
-(void)moveBy:(float)dy
{
    if ((dy>0 && currentItem ==0) || (dy<0 && currentItem == itemCount-1))
        return;
    
    deltaY -= dy;
    float newY = self.center.y + dy;
    self.center = CGPointMake(self.center.x, newY);

    if (abs(deltaY) > kItemHeight)
    {
        NSInteger newValue;
        if (deltaY>0)
            newValue = currentItem + 1;
        else
            newValue = currentItem - 1;
        newValue = MIN(MAX(newValue, 0), itemCount-1);
        [self selectItemHasIndex:newValue];
        deltaY = 0;
    }
}
-(NSInteger)getCurrentItem
{
    return currentItem;
}
@end
