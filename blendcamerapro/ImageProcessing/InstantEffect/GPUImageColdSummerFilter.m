#import "GPUImageColdSummerFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation GPUImageColdSummerFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    UIImage *image = [UIImage imageNamed:@"lookup_cold_summer.png"];
    NSAssert(image, @"missing file lookup_cold_summer.png");
    
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
    return @"Cold Summer";
}
@end
