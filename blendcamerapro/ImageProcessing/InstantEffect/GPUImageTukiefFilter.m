#import "GPUImageTukiefFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation GPUImageTukiefFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"lookup_tukief.png"];
    NSAssert(image, @"missing file lookup_tukief.png");
    
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
    return @"lookup_tukief";
}
@end
