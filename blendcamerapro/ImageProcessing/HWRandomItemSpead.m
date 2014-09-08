//
//  HWRandomItemSpead.m
//  blendcamerapro
//
//  Created by Hai Hw on 11/6/12.
//
//

#import "HWRandomItemSpead.h"
struct ItemObject
{
    CGPoint location;
    int nameIndex;
};

@implementation HWRandomItemSpead
-(id)initWithObjectName:(NSArray*)listObjectsName
{
    if (self = [super init])
    {
        objectsName = listObjectsName;
        listObject = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
-(void)randomizeAmount:(int)itemNumber
// create random location and random image content of item object with given amount
{
    
}
-(UIImage*) applyItemForImage:(UIImage*)backgroundImage
//apply randomized items listObject to backgroundImage
{
    return backgroundImage;
}

@end
