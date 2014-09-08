#import "GPUImageFoliageFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"

@implementation GPUImageFoliageFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"lookup_foliage.png"];
    NSAssert(image, @"To use GPUImageAmatorkaFilter you need to add lookup_foliage.png from GPUImage/framework/Resources to your application bundle.");
    
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
    return @"Foliage";
}

@end
