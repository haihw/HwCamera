#import "GPUImageGreenFodderFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation GPUImageGreenFodderFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"lookup_green_fodder.png"];
    NSAssert(image, @"missing file lookup_green_fodder.png");
    
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
    return @"lookup_green_fodder";
}
@end
