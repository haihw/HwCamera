#import "GPUImageFearlessFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"
#import "GPUImageSharpenFilter.h"
@implementation GPUImageFearlessFilter

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"lookup_fearless.png"];
    NSAssert(image, @"missing file lookup_fearless.png");

    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    [lookupFilter addTarget:sharpenFilter];
    [self addFilter:sharpenFilter];

    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = sharpenFilter;
    
    return self;
}

-(NSString*)getEffectName
{
    return @"Fearless";
}
@end
