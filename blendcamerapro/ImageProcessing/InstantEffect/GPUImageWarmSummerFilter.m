#import "GPUImageWarmSummerFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation GPUImageWarmSummerFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"lookup_warm_summer.png"];
    NSAssert(image, @"missing file lookup_warm_summer.png");
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

-(NSString*)getEffectName
{
    return @"Warm Summer";
}
@end
