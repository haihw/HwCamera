#import "GPUImageMagicalCyanFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"
#import "ImageFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageSharpenFilter.h"
@implementation GPUImageMagicalCyanFilter
- (id)init
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image1 = [UIImage imageNamed:@"lookup_cyan_forrest_1.png"];
    NSAssert(image1, @"missing file lookup_cyan_forrest_1.png");

    lookupImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImageLookupFilter *lookupFilter1 = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter1];
    
    [lookupImageSource1 addTarget:lookupFilter1 atTextureLocation:1];
    [lookupImageSource1 processImage];
    

    //second
    //linear gradient

    linearGradientPic = [[GPUImagePicture alloc] init];
    linearGradientBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [self addFilter:linearGradientBlendFilter];
    
    [lookupFilter1 addTarget:linearGradientBlendFilter];
    [linearGradientPic addTarget:linearGradientBlendFilter];
    
    //radial gradient
    
    radialGradientPic = [[GPUImagePicture alloc] init];
    radialGradientBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [self addFilter:radialGradientBlendFilter];
    
    [linearGradientBlendFilter addTarget:radialGradientBlendFilter];
    [radialGradientPic addTarget:radialGradientBlendFilter];
    
    radialGradientBlendFilter.mix = 0.13;
    
    sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [self addFilter:sharpenFilter];
    sharpenFilter.sharpness = 0.3;
    [radialGradientBlendFilter addTarget:sharpenFilter];
    
    //final
    
    UIImage *image2 = [UIImage imageNamed:@"lookup_cyan_forrest_2.png"];
    NSAssert(image2, @"missing file lookup_cyan_forrest_2.png");
    
    GPUImageLookupFilter *lookupFilter2 = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter2];
    lookupImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    [sharpenFilter addTarget:lookupFilter2];
    [lookupImageSource2 addTarget:lookupFilter2];
    [lookupImageSource2 processImage];

    self.initialFilters = [NSArray arrayWithObjects:lookupFilter1, nil];
    self.terminalFilter = lookupFilter2;
    return self;
}

- (UIImage *)imageByFilteringImage:(UIImage *)imageToFilter
{
    CGSize gradientSize = imageToFilter.size;
    //second
    //linear gradient
    int num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.5, 1.0};
    CGFloat components[12] = {0, 0, 0, 1, 78.0/255.0,78.0/255.0,78.0/255.0, 0, 0, 0, 0, 1 };
    UIImage* linearGradientImg = [UIImage createLinearGradientImageWithSize:gradientSize
                                                           color_stop_number:num_locations
                                                            color_stop_point:locations
                                                            color_components:components
                                                                  startPoint:CGPointMake(0, 0)
                                                                    endPoint:CGPointMake(0, 1)];

    linearGradientPic = [linearGradientPic initWithImage:linearGradientImg];
    [linearGradientPic removeAllTargets];
    [linearGradientPic addTarget:linearGradientBlendFilter atTextureLocation:1];
    [linearGradientPic processImage];
    
    //radial gradient
    UIImage* radialGradientImg = [UIImage createRadialTwoColorGradientImageWithSize:gradientSize
                                                                         startColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]
                                                                           endColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]
                                                                             center:CGPointMake(0.5f,0.5f)
                                                                             radius:1.5];
    
    radialGradientPic = [radialGradientPic initWithImage:radialGradientImg];
    [radialGradientPic removeAllTargets];
    [radialGradientPic addTarget:radialGradientBlendFilter atTextureLocation:1];
    [radialGradientPic processImage];
    
    return [super imageByFilteringImage:imageToFilter];
}
-(NSString*)getEffectName
{
    return @"Magical Cyan";
}
@end
