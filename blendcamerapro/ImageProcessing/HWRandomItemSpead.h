//
//  HWRandomItemSpead.h
//  blendcamerapro
//
//  Created by Hai Hw on 11/6/12.
//
//

#import <Foundation/Foundation.h>
@interface HWRandomItemSpead : NSObject
{
    NSArray *objectsName; //name of item images
    NSMutableArray *listObject; // list of item object that will be applied to background image
}
-(id)initWithObjectName:(NSArray*)listObjectsName;
-(void)randomizeAmount:(int)itemNumber;
-(UIImage*) applyItemForImage:(UIImage*)backgroundImage;
@end
