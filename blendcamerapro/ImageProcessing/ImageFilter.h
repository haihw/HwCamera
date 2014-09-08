
#import <Foundation/Foundation.h>

// swap UIamge class and add some basic filter
@interface UIImage (ImageFilter)

/* Filters */
- (UIImage*) greyscale;
- (UIImage*) sepia;
- (UIImage*) saturate:(double)amount;
- (UIImage*) brightness:(double)amount;
- (UIImage*) gamma:(double)amount;
- (UIImage*) opacity:(double)amount;
- (UIImage*) contrast:(double)amount;
// interset with other image
- (UIImage *) intersect:(UIImage *)overlayImage;

- (UIImage*) freshGreenFilter;
- (UIImage*) greenFilter;
- (UIImage*) CPGreenFilter;
- (UIImage*) lightGreenFilter;
- (UIImage*) lemonFilter;
- (UIImage*) saltLemonFilter;

- (UIImage*) hiBW;
- (UIImage*) higherBW;
- (UIImage*) highestBW;
- (UIImage*) lowBW;
- (UIImage*) lowerBW;

- (UIImage*) darkBrownFilter;
- (UIImage*) hiSepia;
- (UIImage*) CPBrownFilter;
- (UIImage*) softLightSepia;
- (UIImage*) freshSepia;
- (UIImage*) cyanSepia;
- (UIImage*) darkCyanSepia;
- (UIImage*) magentaSepia;

- (UIImage*) CPredFilter;
- (UIImage*) redscaleFilter;

//- (UIImage*) crossProcess;
- (UIImage*) hardlight;
- (UIImage*) softlight;

// overlay image with other image that is other opacity
- (UIImage *)getMergeImageWithOverlay:(UIImage*) foreground withOpacity: (float)opacity;

// Tool
+(UIImage*)createLinearGradientImageWithSize:(CGSize)size
                           color_stop_number:(int) num_locations
                            color_stop_point:(CGFloat*)locations
                            color_components:(CGFloat*)components
                                  startPoint:(CGPoint)startPoint
                                    endPoint:(CGPoint)endPoint;
+(UIImage*)createRadialTwoColorGradientImageWithSize:(CGSize)size
                                          startColor:(UIColor*)startColor
                                            endColor:(UIColor*)endColor
                                              center:(CGPoint)centerPoint
                                              radius:(float)radius;

//effect
-(UIImage*)sampleEffect;
-(UIImage*)violetCoffeeEffect;
-(UIImage*)frezzingBlueEffect;
-(UIImage*)foliageEffect;
-(UIImage*)coldSummerEffect;
-(UIImage*)warmSummerEffect;
-(UIImage*)wildDarkBlueEffect;
-(UIImage*)romanticPink;
-(UIImage*)specialBlue;
-(UIImage*)fearless;
-(UIImage*)cyanForrest;
-(UIImage*)summerForrest;
-(UIImage*)warmForrest;
-(UIImage*)warmLandscape;
-(UIImage*)sexyRed;
-(UIImage*)whiteFade;
-(UIImage*)softWhite;
@end
