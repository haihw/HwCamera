
#include <math.h>
#import "ImageFilter.h"
#import "GPUImage.h"
#import "GPUImageFoliageFilter.h"
/* These constants are used by ImageMagick */
typedef unsigned char Quantum;
typedef double MagickRealType;

#define RoundToQuantum(quantum)  ClampToQuantum(quantum)
#define ScaleCharToQuantum(value)  ((Quantum) (value))
#define SigmaGaussian  ScaleCharToQuantum(4)
#define TauGaussian  ScaleCharToQuantum(20)
#define QuantumRange  ((Quantum) 65535)

/* These are our own constants */
#define SAFECOLOR(color) MIN(255,MAX(0,color))

typedef void (*FilterCallback)(UInt8 *pixelBuf, UInt32 offset, void *context);
typedef void (*FilterBlendCallback)(UInt8 *pixelBuf, UInt8 *pixelBlendBuf, UInt32 offset, void *context);


@implementation UIImage (ImageFilter)

#pragma mark -
#pragma mark Basic Filters
#pragma mark Internals
-(void) printAlpha
{
    CGImageRef inImage = self.CGImage;
	CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
	
	//int length = CFDataGetLength(m_DataRef);
	// before
    for (int i=0; i<4*4; i+=4)
	{
        int alpha =m_PixelBuf[i+3];
		NSLog(@"before change alpha(%d):%d",i,alpha);
	}
    
}
- (UIImage*) applyFilter:(FilterCallback)filter context:(void*)context
{
	CGImageRef inImage = self.CGImage;
	CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
	
	long length = CFDataGetLength(m_DataRef);
	
	for (int i=0; i<length; i+=4)
	{
		filter(m_PixelBuf,i,context);
	}
	
	CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
											 CGImageGetWidth(inImage),
											 CGImageGetHeight(inImage),
											 CGImageGetBitsPerComponent(inImage),
											 CGImageGetBytesPerRow(inImage),
											 CGImageGetColorSpace(inImage),
											 CGImageGetBitmapInfo(inImage)
											 );
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CFRelease(m_DataRef);
	return finalImage;
	
}

#pragma mark C Implementation
void filterGreyscale(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	uint32_t gray = 0.3 * red + 0.59 * green + 0.11 * blue;
	
	pixelBuf[r] = gray;
	pixelBuf[g] = gray;
	pixelBuf[b] = gray;
}

void filterSepia(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	pixelBuf[r] = SAFECOLOR((red * 0.393) + (green * 0.769) + (blue * 0.189));
	pixelBuf[g] = SAFECOLOR((red * 0.349) + (green * 0.686) + (blue * 0.168));
	pixelBuf[b] = SAFECOLOR((red * 0.272) + (green * 0.534) + (blue * 0.131));
}
void filterDarkBrown(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
    
    //convert to HSB
    CGFloat h, s, l, a;
    UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
    [color getHue:&h saturation:&s brightness:&l alpha:&a];
    //    NSLog (@"%d - %d - %d - %d", h, s, l, a);
    
    //adjust hue
    h = 35.0f/360.0f;
    //adjust saturation
    s = 25.0f/360.0f;
    //convert back to RGB
    color = [UIColor colorWithHue:h saturation:s brightness:l alpha:1.0f];
    CGFloat newR, newG, newB;
    [color getRed:&newR green:&newG blue:&newB alpha:&a];
    pixelBuf[r] = SAFECOLOR(newR*255);
    pixelBuf[g] = SAFECOLOR(newG*255);
    pixelBuf[b] = SAFECOLOR(newB*255);
    
}


void filterSaturate(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	double t = *((double*)context);
	
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	int avg = ( red + green + blue ) / 3;
	
	pixelBuf[r] = SAFECOLOR((avg + t * (red - avg)));
	pixelBuf[g] = SAFECOLOR((avg + t * (green - avg)));
	pixelBuf[b] = SAFECOLOR((avg + t * (blue - avg)));
}

void filterBrightness(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	double t = *((double*)context);
	
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	pixelBuf[r] = SAFECOLOR(red*t);
	pixelBuf[g] = SAFECOLOR(green*t);
	pixelBuf[b] = SAFECOLOR(blue*t);
}

void filterGamma(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	double amount = *((double*)context);
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	pixelBuf[r] = SAFECOLOR(pow(red,amount));
	pixelBuf[g] = SAFECOLOR(pow(green,amount));
	pixelBuf[b] = SAFECOLOR(pow(blue,amount));
}

void filterOpacity(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	double val = *((double*)context);
	
	int a = offset+3;
	
	int alpha = pixelBuf[a];
	
	pixelBuf[a] = SAFECOLOR(alpha * val);
}

double calcContrast(double f, double c){
	return (f-0.5) * c + 0.5;
}

void filterContrast(UInt8 *pixelBuf, UInt32 offset, void *context)
{
	double val = *((double*)context);
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	pixelBuf[r] = SAFECOLOR(255 * calcContrast((double)((double)red / 255.0f), val));
	pixelBuf[g] = SAFECOLOR(255 * calcContrast((double)((double)green / 255.0f), val));
	pixelBuf[b] = SAFECOLOR(255 * calcContrast((double)((double)blue / 255.0f), val));
}

void linearEquation4Unknown(float x[], float y[], float result[])
{
    float a, b, c, d;
    float A[4], B[4], C[4], D[4];
    
    //    A[1] a + B[1] b + C[1] c = D[1];
    //
    for (int i = 1; i<=3; i++)
    {
        A[i] = x[i]*x[i]*x[i] - x[4]*x[4]*x[4];
        B[i] = x[i]*x[i]      - x[4]*x[4];
        C[i] = x[i]           - x[4];
        D[i] = y[i]           - y[4];
    }
    
    // 3 an
    float X[3], Y[3], Z[3];
    for (int i=1; i<=2; i++)
    {
        X[i] = A[i]*C[3] - A[3]*C[i];
        Y[i] = B[i]*C[3] - B[3]*C[i];
        Z[i] = D[i]*C[3] - D[3]*C[i];
    }
    // 2 an
    a = (Z[1]*Y[2] - Z[2]*Y[1]) / (X[1]*Y[2] - X[2]*Y[1]);
    b = (Z[1]*X[2] - Z[2]*X[1]) / (Y[1]*X[2] - Y[2]*X[1]);
    
    c = (D[1] - a*A[1] - b*B[1]) / C[1];
    d = y[1] - x[1]*x[1]*x[1]*a - x[1]*x[1]*b - x[1]*c;
    
    result[0] = a;
    result[1] = b;
    result[2] = c;
    result[3] = d;
}

void curvesSpaceTransform(float coefficient[], int numOfCoe, float space[], int numOfSpace)
{
    //space : [0, 255]
    //numOfSpace : 256;
    //coefficient : [0, 3];
    //numOfCoe: 4;
    
    float temp;
    for (int i = 0; i < numOfSpace; i++)
    {
        temp = 1;
        space[i] = 0;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            space[i] += temp*coefficient[j];
            temp = temp * i;
        }
        space[i] = SAFECOLOR(space[i]);
    }
}
void curvesSpaceTransformTwoFunction(float coefficient[], float otherCoefficient[], int numOfCoe, float space[], int numOfSpace)
{
    float temp;
    float tempSpace;
    for (int i = 0; i < numOfSpace; i++)
    {
        temp = 1;
        tempSpace = 0;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            tempSpace += temp*coefficient[j];
            temp = temp * i;
        }
        tempSpace = SAFECOLOR(tempSpace);
        space[i] = 0;
        temp = 1;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            space[i] += temp*otherCoefficient[j];
            temp = temp * tempSpace;
        }
        
        space[i] = SAFECOLOR(space[i]);
    }
}
void curvesSpaceTransformThreeFunction(float firstCoefficient[], float secondCoefficient[], float thirdCoefficient[], int numOfCoe, float space[], int numOfSpace)
{
    float temp;
    float tempSpace, tempSpace2;
    for (int i = 0; i < numOfSpace; i++)
    {
        temp = 1;
        tempSpace = 0;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            tempSpace += temp*firstCoefficient[j];
            temp = temp * i;
        }
        tempSpace = SAFECOLOR(tempSpace);
        temp = 1;
        tempSpace2 = 0;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            tempSpace2 += temp*secondCoefficient[j];
            temp = temp * tempSpace;
        }
        tempSpace2 = SAFECOLOR(tempSpace2);
        space[i] = 0;
        temp = 1;
        for (int j = numOfCoe-1; j>=0; j--)
        {
            space[i] += temp*thirdCoefficient[j];
            temp = temp * tempSpace2;
        }
        
        space[i] = SAFECOLOR(space[i]);
    }
}
/*void curves4Red(UInt8 *pixelBuf, UInt32 offset, void *context)
 {
 float* result = (float*) context;
 int r = offset;
 
 int red = pixelBuf[r];
 pixelBuf[r] = SAFECOLOR(result[0] * red*red*red + result[1] * red*red + result[2] * red + result[3]);
 }
 void curves4Green(UInt8 *pixelBuf, UInt32 offset, void *context)
 {
 float* result = (float*) context;
 int g = offset+1;
 
 int green = pixelBuf[g];
 pixelBuf[g] = SAFECOLOR(result[0] * green*green*green + result[1] * green*green + result[2] * green + result[3]);
 }
 void curves4Blue(UInt8 *pixelBuf, UInt32 offset, void *context)
 {
 float* result = (float*) context;
 int b = offset+2;
 
 int blue = pixelBuf[b];
 pixelBuf[b] = SAFECOLOR(result[0] * blue*blue*blue + result[1] * blue*blue + result[2] * blue + result[3]);
 }
 void curves4RGB(UInt8 *pixelBuf, UInt32 offset, void *context)
 {
 float* result = (float*) context;
 int r = offset;
 int g = offset+1;
 int b = offset+2;
 
 int red = pixelBuf[r];
 int green = pixelBuf[g];
 int blue = pixelBuf[b];
 
 pixelBuf[r] = SAFECOLOR(result[0] * red*red*red + result[1] * red*red + result[2] * red + result[3]);
 pixelBuf[g] = SAFECOLOR(result[0] * green*green*green + result[1] * green*green + result[2] * green + result[3]);
 pixelBuf[b] = SAFECOLOR(result[0] * blue*blue*blue + result[1] * blue*blue + result[2] * blue + result[3]);
 }
 */
void curvesRed(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    float* map = (float*) context;
	int r = offset;
	
	int red = pixelBuf[r];
    pixelBuf[r] = map[red];
}
void curvesGreen(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    float* map = (float*) context;
	int g = offset+1;
	
	int green = pixelBuf[g];
    pixelBuf[g] = map[green];
}
void curvesBlue(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    float* map = (float*) context;
	int b = offset+2;
	
	int blue = pixelBuf[b];
    pixelBuf[b] = map[blue];
}
void curvesRGB(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    curvesRed(pixelBuf, offset, context);
    curvesGreen(pixelBuf, offset, context);
    curvesBlue(pixelBuf, offset, context);
}

/*
 * The arguments are pointers to int representing channel values in the
 * RGB colorspace, and the values pointed to are all in the range [0, 255].
 *
 * The function changes the arguments to point to the corresponding HLS
 * value with the values pointed to in the following ranges:  H [0, 360],
 * L [0, 255], S [0, 255].
 */
void rgb_to_hsl(float r, float g, float b, float *hue, float*saturation, float*lightness)
{
    float max, min, delta, h, s, l;
    if (r > g)
    {
        max = MAX (r, b);
        min = MIN (g, b);
    }
    else
    {
        max = MAX (g, b);
        min = MIN (r, b);
    }
    
    l = (max + min) / 2.0;
    
    if (max == min)
    {
        s = 0.0;
        h = 0.0;
    }
    else
    {
        delta = (max - min);
        
        if (l < 128)
            s = 255 * delta / (max + min);
        else
            s = 255 * delta /(511 - max - min);
        
        if (r == max)
            h = (g - b) / delta;
        else if (g == max)
            h = 2 + (b - r) / delta;
        else
            h = 4 + (r - g) / delta;
        
        h = h * 42.5;
        
        if (h < 0)
            h += 255;
        else if (h > 255)
            h -= 255;
    }
    *hue = h;
    *saturation = s;
    *lightness = l;
    
}
//RGB to lightness
float rgb_to_L (float red,float green,float blue)
{
    float min, max;
    
    if (red > green)
    {
        max = MAX (red,   blue);
        min = MIN (green, blue);
    }
    else
    {
        max = MAX (green, blue);
        min = MIN (red,   blue);
    }
    
    return (max + min) / 2.0;
}
int hsl_value_int (float n1, float n2, float hue)
{
    float value;
    if (hue > 255)
        hue -= 255;
    else if (hue < 0)
        hue += 255;
    
    if (hue < 42.5)
        value = n1 + (n2 - n1) * (hue / 42.5);
    else if (hue < 127.5)
        value = n2;
    else if (hue < 170)
        value = n1 + (n2 - n1) * ((170 - hue) / 42.5);
    else
        value = n1;
    
    return (int)round(value * 255.0);
}

/**
 * gimp_hsl_to_rgb_int:
 * @hue: Hue channel, returns Red channel
 * @saturation: Saturation channel, returns Green channel
 * @lightness: Lightness channel, returns Blue channel
 *
 * The arguments are pointers to int, with the values pointed to in the
 * following ranges:  H [0, 360], L [0, 255], S [0, 255].
 *
 * The function changes the arguments to point to the RGB value
 * corresponding, with the returned values all in the range [0, 255].
 **/
void hsl_to_rgb (float h, float s, float l, int *red, int *green, int *blue)
{
    if (s == 0)
    {
        /*  achromatic case  */
        *red    = l;
        *green  = l;
        *blue   = l;
    }
    else
    {
        float m1, m2;
        
        if (l < 128)
            m2 = (l * (255 + s)) / 65025.0;
        else
            m2 = (l + s - (l * s) / 255.0) / 255.0;
        
        m1 = (l / 127.5) - m2;
        
        /*  chromatic case  */
        *red    = hsl_value_int (m1, m2, h + 85);
        *green  = hsl_value_int (m1, m2, h);
        *blue   = hsl_value_int (m1, m2, h - 85);
    }
}


void colorBalance(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    float* ref = (float*) context;
    float cyanRed = ref[0];
    float magentaGreen = ref[1];
    float yellowBlue = ref[2];
    
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
    /*
     float h, s, l;
     float old_l;
     rgb_to_hsl(red, green, blue, &h, &s, &l);
     old_l = l;
     */
    red += cyanRed;
    green += magentaGreen;
    blue += yellowBlue;
    /*
     red = SAFECOLOR(red);
     green = SAFECOLOR(green);
     blue = SAFECOLOR(blue);
     
     rgb_to_hsl(red, green, blue, &h, &s, &l);
     hsl_to_rgb(h, s, old_l, &red, &green, &blue);
     */
    pixelBuf[r] = SAFECOLOR(red);
    pixelBuf[g] = SAFECOLOR(green);
    pixelBuf[b] = SAFECOLOR(blue);
}
void colorBalancePreserveLuminosity(UInt8 *pixelBuf, UInt32 offset, void *context)
{
    float* ref = (float*) context;
    float cyanRed = ref[0];
    float magentaGreen = ref[1];
    float yellowBlue = ref[2];
    
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
    if (cyanRed != 0)
    {
        // First, calculate the current lightness.
        //        float oldL = red * 0.30 + green * 0.59 + blue * 0.11;
        float oldL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        // Adjust the color components. This changes lightness.
        red += cyanRed;
        red = SAFECOLOR(red);
        // Now correct the color back to the old lightness.
        float newL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        if (newL > 0) {
            red   = SAFECOLOR(red * oldL / newL);
            green = SAFECOLOR(green * oldL / newL);
            blue  = SAFECOLOR(blue * oldL / newL);
        }
    }
    if (magentaGreen != 0)
    {
        // First, calculate the current lightness.
        float oldL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        // Adjust the color components. This changes lightness.
        green += magentaGreen;
        green = SAFECOLOR(green);
        // Now correct the color back to the old lightness.
        float newL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        if (newL > 0) {
            red   = SAFECOLOR(red * oldL / newL);
            green = SAFECOLOR(green * oldL / newL);
            blue  = SAFECOLOR(blue * oldL / newL);
        }
    }
    if (yellowBlue != 0)
    {
        // First, calculate the current lightness.
        float oldL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        // Adjust the color components. This changes lightness.
        blue += yellowBlue;
        blue = SAFECOLOR(blue);
        // Now correct the color back to the old lightness.
        float newL = red * 0.2126 + green * 0.7152 + blue * 0.0722;
        if (newL > 0) {
            red   = SAFECOLOR(red * oldL / newL);
            green = SAFECOLOR(green * oldL / newL);
            blue  = SAFECOLOR(blue * oldL / newL);
        }
    }
    pixelBuf[r] = SAFECOLOR(red);
    pixelBuf[g] = SAFECOLOR(green);
    pixelBuf[b] = SAFECOLOR(blue);
    
}
#pragma mark processing to merge 2 images
void intersectFilter(UInt8 *pixelBufSrc,UInt8 *pixelBufOvr,int width,int height,int ovrWidth,int ovrHeight,int length,int lengthOvr)
{
    //NSLog(@"source.width:%d, source.height:%d",width,height);
    //NSLog(@"source length:%d ,%d",length,width*height*4);
    int diffLines = (length - width*height*4)/(width*4);
    
    //NSLog(@"overlay.width:%d, overlay.height:%d",ovrWidth,ovrHeight);
    //NSLog(@"overlay length:%d ,%d",lengthOvr,ovrWidth*ovrHeight*4);
    //int diffLinesOvr = (lengthOvr - ovrWidth*ovrHeight*4)/(ovrWidth*4);
    //NSLog(@"diffLinesOvr:%d",diffLinesOvr);
    
    int lineSize = width*4;
    int overLineSize = ovrWidth*4;
    NSLog(@"lineSize :%d",lineSize);
    NSLog(@"overLineSize :%d",overLineSize);
    
    int i =0;
    int j=0;
    int nextOvrLine = 0;
    
    // calculate totalLines
    int totalLines = height;
    if (diffLines>0) {
        totalLines = height + diffLines;
    }
    //NSLog(@"totalLines:%d",totalLines);
    BOOL finishIntersect=NO;
    
    for (int y =0;y<totalLines;y++)
    {
        // for each byte
        for (int x=0; x<lineSize;x++)
        {
            i = x+y*lineSize;
            j =nextOvrLine + x;
            
            if (i >= length ) {
                //NSLog(@"i:%d,j:%d",i,j);
                finishIntersect = YES;
                break;
            }
            
            int srcValue = pixelBufSrc[i];
            int ovrValue = pixelBufOvr[j];
            //NSLog(@"m_PixelBuf[i] :%d m_PixelBufOvr[j]:%d",srcValue,ovrValue);
            if ( srcValue > ovrValue ) {
                //NSLog(@"m_PixelBuf[i] :%d m_PixelBufOvr[j]:%d",m_PixelBuf[i],m_PixelBufOvr[j] );
                pixelBufSrc[i] = ovrValue;
                //NSLog(@"m_PixelBuf[i] :%d",m_PixelBuf[i]);
            }
            
        }
        if (finishIntersect) {
            //NSLog(@"finishIntersect");
            break;
        }
        nextOvrLine = overLineSize*(y+1);
        //NSLog(@"i:%d,j:%d, height :%d",i,j,y);
        
    }
    
    if(!finishIntersect)
    {
        //NSLog(@"not finishIntersect");
        for (int k = i ; k < length && k < lengthOvr; k++) {
            if(pixelBufSrc[k]  > pixelBufOvr[k])
                pixelBufSrc[k]  = pixelBufOvr[k];
        }
    }
    
}

- (UIImage*) applyFilterForMergeImages:(UIImage *)overlayImg
{
	CGImageRef inImage = self.CGImage;
	CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
	
    CGImageRef overlayCGI = overlayImg.CGImage;
	CFDataRef m_DataRefOvr = CGDataProviderCopyData(CGImageGetDataProvider(overlayCGI));
    UInt8 * m_PixelBufOvr = (UInt8 *) CFDataGetBytePtr(m_DataRefOvr);
    
    long length = CFDataGetLength(m_DataRef);
    long lengthOvr = CFDataGetLength(m_DataRefOvr);
    
    int width = self.size.width;
    int height = self.size.height;
    
    int ovrWidth = overlayImg.size.width;
    int ovrHeight = overlayImg.size.height;
    
    intersectFilter(m_PixelBuf, m_PixelBufOvr,width, height,ovrWidth,ovrHeight,length,lengthOvr);
	
	CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
											 CGImageGetWidth(inImage),
											 CGImageGetHeight(inImage),
											 CGImageGetBitsPerComponent(inImage),
											 CGImageGetBytesPerRow(inImage),
											 CGImageGetColorSpace(inImage),
											 CGImageGetBitmapInfo(inImage)
											 );
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CFRelease(m_DataRef);
    
	CFRelease(m_DataRefOvr);
    
	return finalImage;
	
}


#pragma mark Filters
-(UIImage*) freshGreenFilter
// this function calculate mapping matrix [0 255] before use each image filter
{
    id temp = self;
    float x[5], y[5];
    float coefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 85 ; y[2] = 15;
    x[3] = 210; y[3] = 150;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 60 ; y[2] = 65;
    x[3] = 170; y[3] = 222;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 125; y[2] = 50;
    x[3] = 200; y[3] = 125;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}
/*
 -(UIImage*) greenFilter_OLD
 {
 //contrast first
 id temp = self;
 float x[5], y[5], result[4];
 
 x[1] = 0  ; y[1] = 0;
 x[2] = 70 ; y[2] = 85;
 x[3] = 150; y[3] = 210;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 x[2] = 110; y[2] = 70;
 x[3] = 185; y[3] = 135;
 x[4] = 255; y[4] = 155;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Blue context:result];
 
 x[1] = 0  ; y[1] = 0;
 x[2] = 85 ; y[2] = 40;
 x[3] = 190; y[3] = 210;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 
 temp = [temp applyFilter:curves4RGB context:result];
 return temp;
 }
 */
-(UIImage*) greenFilter
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    id temp = self;
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 40 ; y[2] = 30;
    x[3] = 170; y[3] = 190;
    x[4] = 255; y[4] = 255;
    //    x[1] = 0  ; y[1] = 0;
    //    x[2] = 85 ; y[2] = 40;
    //    x[3] = 190; y[3] = 210;
    //    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 65 ; y[2] = 20;
    x[3] = 170; y[3] = 90;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 70 ; y[2] = 85;
    x[3] = 180; y[3] = 225;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 100; y[2] = 20;
    x[3] = 190; y[3] = 60;
    x[4] = 255; y[4] = 128;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}
/*
 -(UIImage*) lightGreenFilter_OLD
 {
 id temp;
 //    NSLog(@"Green filter");
 float x[5], y[5], result[4];
 x[1] = 0  ; y[1] = 65;
 x[2] = 78 ; y[2] = 115;
 x[3] = 148; y[3] = 192;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [self applyFilter:curves4Red context:result];
 
 x[1] = 0  ; y[1] = 54;
 x[2] = 76 ; y[2] = 156;
 x[3] = 130; y[3] = 208;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 x[1] = 0  ; y[1] = 27;
 x[2] = 111; y[2] = 40;
 x[3] = 186; y[3] = 114;
 x[4] = 255; y[4] = 211;
 linearEquation4Unknown(x, y, result);
 return [temp applyFilter:curves4Blue context:result];
 }
 */
-(UIImage*) lightGreenFilter
// this function calculate mapping matrix [0 255] before use each image filter
{
    id temp = self;
    float x[5], y[5];
    float coefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    x[1] = 0  ; y[1] = 65;
    x[2] = 78 ; y[2] = 115;
    x[3] = 148; y[3] = 192;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[1] = 0  ; y[1] = 54;
    x[2] = 76 ; y[2] = 156;
    x[3] = 130; y[3] = 208;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[1] = 0  ; y[1] = 27;
    x[2] = 111; y[2] = 40;
    x[3] = 186; y[3] = 114;
    x[4] = 255; y[4] = 211;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}

-(UIImage*) saltLemonFilter
{
    id temp = self;
    float x[5], y[5];
    float coefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 85 ; y[2] = 70;
    x[3] = 170; y[3] = 215;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[1] = 0  ; y[1] = 45;
    x[2] = 60 ; y[2] = 85;
    x[3] = 160; y[3] = 222;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 90 ; y[2] = 30;
    x[3] = 210; y[3] = 105;
    x[4] = 255; y[4] = 165;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    return temp;
}
/*
 -(UIImage*) lemonFilter_OLD
 {
 id temp = self;
 //    NSLog(@"Lemon");
 float x[5], y[5], result[4];
 x[1] = 0  ; y[1] = 35;
 x[2] = 105; y[2] = 150;
 x[3] = 150; y[3] = 200;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 
 temp = [temp applyFilter:curves4Red context:result];
 x[1] = 0  ; y[1] = 50;
 x[2] = 107; y[2] = 148;
 x[3] = 160; y[3] = 210;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 x[1] = 0  ; y[1] = 28;
 x[2] = 140; y[2] = 75;
 x[3] = 202; y[3] = 150;
 x[4] = 255; y[4] = 202;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Blue context:result];
 
 
 // add RGB curves layer to adjust contrast
 x[1] = 0  ; y[1] = 0;
 x[2] = 80 ; y[2] = 100;
 x[3] = 140; y[4] = 150;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4RGB context:result];
 
 return temp;
 }
 */
-(UIImage*) lemonFilter
// this function calculate mapping matrix [0 255] before use each image filter
{
    NSDate *start = [NSDate date];
    
    id temp = self;
    float x[5], y[5];
    x[1] = 0  ; y[1] = 35;
    x[2] = 105; y[2] = 150;
    x[3] = 150; y[3] = 200;
    x[4] = 255; y[4] = 255;
    float coefficient[4];
    linearEquation4Unknown(x, y, coefficient);
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[1] = 0  ; y[1] = 50;
    x[2] = 107; y[2] = 148;
    x[3] = 160; y[3] = 210;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[1] = 0  ; y[1] = 28;
    x[2] = 140; y[2] = 75;
    x[3] = 202; y[3] = 150;
    x[4] = 255; y[4] = 202;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 80 ; y[2] = 100;
    x[3] = 140; y[4] = 150;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRGB context:space];
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time red scale new: %f", timeInterval);
    return temp;
}

-(UIImage*) CPGreenFilter
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    
    id temp = self;
    float x[5], y[5];
    float CPcoefficient[4], channelCoefficient[4], RGBCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // Cross Processing
    x[1] = 0  ; y[1] = 0;
    x[2] = 64 ; y[2] = 32;
    x[3] = 192; y[3] = 224;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, CPcoefficient);
    
    x[2] = 40 ; y[2] = 30;
    x[3] = 170; y[3] = 190;
    linearEquation4Unknown(x, y, RGBCoefficient);
    
    x[2] = 65 ; y[2] = 20;
    x[3] = 170; y[3] = 90;
    linearEquation4Unknown(x, y, channelCoefficient);
    
    curvesSpaceTransformThreeFunction(CPcoefficient, channelCoefficient, RGBCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    //Green and blue channel has 3 filters
    // Cross Processing
    x[1] = 0  ; y[1] = 0;
    x[2] = 64 ; y[2] = 48;
    x[3] = 192; y[3] = 224;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, CPcoefficient);
    
    //green
    x[2] = 70 ; y[2] = 85;
    x[3] = 180; y[3] = 225;
    linearEquation4Unknown(x, y, channelCoefficient);
    //contrast
    curvesSpaceTransformThreeFunction(CPcoefficient, channelCoefficient, RGBCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    
    // Cross Processing
    x[2] = 64 ; y[2] = 96;
    x[3] = 192; y[3] = 160;
    linearEquation4Unknown(x, y, CPcoefficient);
    //blue
    x[2] = 100; y[2] = 20;
    x[3] = 190; y[3] = 60;
    x[4] = 255; y[4] = 128;
    linearEquation4Unknown(x, y, channelCoefficient);
    
    curvesSpaceTransformThreeFunction(CPcoefficient, channelCoefficient, RGBCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}

-(UIImage*) CPredFilter
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    NSDate *start = [NSDate date];
    
    id temp = self;
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // Cross Processing
    x[1] = 0  ; y[1] = 0;
    x[2] = 64 ; y[2] = 32;
    x[3] = 192; y[3] = 224;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 55 ; y[2] = 140;
    x[3] = 175; y[3] = 245;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    // Cross Processing
    x[2] = 64 ; y[2] = 48;
    x[3] = 192; y[3] = 224;
    linearEquation4Unknown(x, y, coefficient);
    
    x[2] = 65; y[2] = 90;
    x[3] = 190; y[3] = 185;
    linearEquation4Unknown(x, y, otherCoefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    // Cross Processing
    x[2] = 64 ; y[2] = 96;
    x[3] = 192; y[3] = 160;
    linearEquation4Unknown(x, y, coefficient);
    
    x[2] = 105; y[2] = 85;
    x[3] = 180; y[3] = 195;
    linearEquation4Unknown(x, y, otherCoefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time red scale new: %f", timeInterval);
    return temp;
}

-(UIImage*) redscaleFilter
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    NSDate *start = [NSDate date];
    
    id temp = self;
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 30 ; y[2] = 24;
    x[3] = 170; y[3] = 195;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[1] = 0  ; y[1] = 0;
    x[2] = 60 ; y[2] = 75;
    x[3] = 155; y[3] = 200;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    //    NSLog(@"redscale red channel:");
    //    [self printArray:space withSize:256];
    x[2] = 115; y[2] = 88;
    x[3] = 205; y[3] = 169;
    x[4] = 255; y[4] = 210;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    //    NSLog(@"redscale green channel:");
    //    [self printArray:space withSize:256];
    
    x[2] = 165; y[2] = 60;
    x[3] = 190 ; y[3] = 90;
    x[4] = 255; y[4] = 175;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    //    NSLog(@"redscale blue channel:");
    //    [self printArray:space withSize:256];
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time red scale new: %f", timeInterval);
    return temp;
}

-(UIImage*) redscaleFilter_1
// this function calculate mapping matrix [0 255] before use each image filter
{
    NSDate *start = [NSDate date];
    
    id temp = self;
    float x[5], y[5];
    x[1] = 0  ; y[1] = 0;
    x[2] = 60 ; y[2] = 75;
    x[3] = 155; y[3] = 200;
    x[4] = 255; y[4] = 255;
    float coefficient[4];
    linearEquation4Unknown(x, y, coefficient);
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 115; y[2] = 88;
    x[3] = 205; y[3] = 169;
    x[4] = 255; y[4] = 210;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 165; y[2] = 60;
    x[3] = 190 ; y[3] = 90;
    x[4] = 255; y[4] = 175;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 30 ; y[2] = 24;
    x[3] = 170; y[3] = 195;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRGB context:space];
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time red scale new: %f", timeInterval);
    return temp;
}
/*
 //backup redscale before change the way to calculate y = f(x) for curves function
 -(UIImage*) redscaleFilter_OLD
 {
 NSDate *start = [NSDate date];
 id temp = self;
 float x[5], y[5], result[4];
 
 x[1] = 0  ; y[1] = 0;
 x[2] = 60 ; y[2] = 75;
 x[3] = 155; y[3] = 200;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Red context:result];
 
 x[2] = 115; y[2] = 88;
 x[3] = 205; y[3] = 169;
 x[4] = 255; y[4] = 210;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 x[2] = 165; y[2] = 60;
 x[3] = 190 ; y[3] = 90;
 x[4] = 255; y[4] = 175;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Blue context:result];
 
 // add RGB curves layer to adjust contrast
 x[1] = 0  ; y[1] = 0;
 x[2] = 30 ; y[2] = 24;
 x[3] = 170; y[3] = 195;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 //    NSLog(@"%f %f %f %f", result[0],result[1],result[2],result[3]);
 temp = [temp applyFilter:curves4RGB context:result];
 
 NSTimeInterval timeInterval = [start timeIntervalSinceNow];
 NSLog(@"Time red scale old: %f", timeInterval);
 
 return temp;
 }
 
 - (UIImage*) CPBrownFilter_OLD
 {
 id temp = self;
 float x[5], y[5], result[4];
 //    NSLog(@"Cross Process Brown Filter");
 
 //light reduce red channel
 x[1] = 0  ; y[1] = 0;
 x[2] = 95 ; y[2] = 80;
 x[3] = 175; y[3] = 165;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Red context:result];
 
 // reduce green to increase the mangeta
 x[2] = 110; y[2] = 75;
 x[3] = 170; y[3] = 145;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 // increase yellow, decrease blue
 x[2] = 115; y[2] = 65;
 x[3] = 190 ; y[3] = 150;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Blue context:result];
 
 //    NSLog(@"Increase Contrast");
 // add RGB curves layer to adjust contrast
 x[1] = 0  ; y[1] = 0;
 x[2] = 55 ; y[2] = 45;
 x[3] = 170; y[3] = 220;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4RGB context:result];
 
 return temp;
 
 }
 */
-(UIImage*) CPBrownFilter
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    id temp = self;
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 55 ; y[2] = 45;
    x[3] = 170; y[3] = 220;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 95 ; y[2] = 80;
    x[3] = 175; y[3] = 165;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 110; y[2] = 75;
    x[3] = 170; y[3] = 145;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 115; y[2] = 65;
    x[3] = 190 ; y[3] = 150;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}
-(UIImage*) softLightSepia
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    id temp = [self sepia];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 80 ; y[2] = 50;
    x[3] = 200; y[3] = 225;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 100; y[2] = 85;
    x[3] = 165; y[3] = 155;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 110; y[2] = 85;
    x[3] = 190; y[3] = 170;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 80 ; y[2] = 95;
    x[3] = 180 ; y[3] = 155;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}
-(UIImage*) freshSepia
// this function calculate mapping matrix [0 255] for all filter of each channel => number of mapping matrix always is <=3
{
    id temp = [self sepia];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 40 ; y[2] = 35;
    x[3] = 180; y[3] = 205;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] =  55; y[2] = 60;
    x[3] = 200; y[3] = 185;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] =  60; y[2] = 50;
    x[3] = 200; y[3] = 185;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 50 ; y[2] = 45;
    x[3] = 195; y[3] = 170;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    
    return temp;
}
/*
 -(UIImage*) crossProcess
 {
 //    NSLog(@"Cross Process");
 float x[5], y[5], result[4];
 x[1] = 0  ; y[1] = 0;
 x[2] = 64 ; y[2] = 32;
 x[3] = 192; y[3] = 224;
 x[4] = 255; y[4] = 255;
 linearEquation4Unknown(x, y, result);
 
 id temp = [self applyFilter:curves4Red context:result];
 
 x[2] = 64 ; y[2] = 48;
 x[3] = 192; y[3] = 224;
 linearEquation4Unknown(x, y, result);
 temp = [temp applyFilter:curves4Green context:result];
 
 x[2] = 64 ; y[2] = 96;
 x[3] = 192; y[3] = 160;
 linearEquation4Unknown(x, y, result);
 return [temp applyFilter:curves4Blue context:result];
 
 }
 */
-(UIImage*) lowerBW
{
    double amount = 0.5f;
    id temp = [self applyFilter:filterContrast context:&amount];
    return [temp applyFilter:filterGreyscale context:nil];
}
-(UIImage*) lowBW
{
    double amount = 0.7f;
    id temp = [self applyFilter:filterContrast context:&amount];
    return [temp applyFilter:filterGreyscale context:nil];
}

-(UIImage*) hiBW
{
    double amount = 1.5f;
    id temp = [self applyFilter:filterContrast context:&amount];
    return [temp applyFilter:filterGreyscale context:nil];
}
-(UIImage*) higherBW
{
    double amount = 2.0f;
    id temp = [self applyFilter:filterContrast context:&amount];
    return [temp applyFilter:filterGreyscale context:nil];
}
-(UIImage*) highestBW
{
    double amount = 2.5f;
    id temp = [self applyFilter:filterContrast context:&amount];
    return [temp applyFilter:filterGreyscale context:nil];
}

// intersect with other image
-(UIImage *) intersect:(UIImage *)overlayImage
{
    NSLog(@"intersect with other image");
    return [self applyFilterForMergeImages:overlayImage];
}

-(UIImage*)greyscale
{
    //    NSLog(@"grayscale");
	return [self applyFilter:filterGreyscale context:nil];
}
- (UIImage*)darkBrownFilter
{
    id temp = [self sepia];
    //    id temp = [self applyFilter:filterDarkBrown context:nil];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 60 ; y[2] = 40;
    x[3] = 160; y[3] = 205;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 95 ; y[2] = 65;
    x[3] = 185; y[3] = 140;
    x[4] = 255; y[4] = 215;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 120; y[2] = 90;
    x[3] = 195; y[3] = 150;
    x[4] = 255; y[4] = 220;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 108; y[2] = 85;
    x[3] = 188; y[3] = 150;
    x[4] = 255; y[4] = 195;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    return temp;
}

- (UIImage*)cyanSepia
{
    id temp = [self sepia];
    //    id temp = [self applyFilter:filterDarkBrown context:nil];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 60 ; y[2] = 85;
    x[3] = 160; y[3] = 215;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 140; y[2] = 40;
    x[3] = 220; y[3] = 150;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 50; y[2] = 70;
    x[3] = 190; y[3] = 210;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    return temp;
    
}
- (UIImage*)magentaSepia
{
    id temp = [self sepia];
    //    id temp = [self applyFilter:filterDarkBrown context:nil];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 40 ; y[2] = 35;
    x[3] = 185; y[3] = 200;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 40 ; y[2] = 30;
    x[3] = 185; y[3] = 190;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 60 ; y[2] = 65;
    x[3] = 190; y[3] = 180;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 20 ; y[2] = 30;
    x[3] = 165; y[3] = 155;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    return temp;
    
}
- (UIImage*)darkCyanSepia
{
    id temp = [self sepia];
    //    id temp = [self applyFilter:filterDarkBrown context:nil];
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 70 ; y[2] = 105;
    x[3] = 180; y[3] = 200;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 140; y[2] = 40;
    x[3] = 220; y[3] = 150;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    
    x[2] = 105; y[2] = 90;
    x[3] = 190; y[3] = 175;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesGreen context:space];
    
    x[2] = 45 ; y[2] = 50;
    x[3] = 165; y[3] = 155;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    return temp;
    
}
- (UIImage*)sepia
{
	return [self applyFilter:filterSepia context:nil];
}
- (UIImage*)hiSepia
{
    double amount = 1.5f;
    id temp = [self applyFilter:filterContrast context:&amount];
	return [temp applyFilter:filterSepia context:nil];
}
- (UIImage*)hardlight
{
    float x[5], y[5];
    float coefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 105; y[2] = 230;
    x[3] = 128; y[3] = 255;
    x[4] = 255; y[4] = 255;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    return [self applyFilter:curvesRGB context:space];
}
- (UIImage*)softlight
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 1.0);
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [self drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1];
    [self drawInRect:imageRect blendMode:kCGBlendModeSoftLight alpha:1];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
- (UIImage*)saturate:(double)amount
{
	return [self applyFilter:filterSaturate context:&amount];
}

- (UIImage*)brightness:(double)amount
{
	return [self applyFilter:filterBrightness context:&amount];
}

- (UIImage*)gamma:(double)amount
{
	return [self applyFilter:filterGamma context:&amount];
}

- (UIImage*)opacity:(double)amount
{
	return [self applyFilter:filterOpacity context:&amount];
}

- (UIImage*)contrast:(double)amount
{
	return [self applyFilter:filterContrast context:&amount];
}
#pragma mark image processing tool

// overlay image with other image that is other opacity
- (UIImage *)getMergeImageWithOverlay:(UIImage*) foreground withOpacity: (float)opacity
{
    
    UIImage * background =self;
    UIGraphicsBeginImageContextWithOptions(background.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, background.size.width, background.size.height);
    
    [background drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1];
    [foreground drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:opacity];
    // Get the resulting image.
    
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}

/*
 //color balance
 -(UIImage*)colorBalanceCyanRed:(float)cyanRed magentaGreen:(float)magentaGreen yellowBlue:(float)yellowBlue
 {
 NSLog(@"balance color: %f %f %f", cyanRed, magentaGreen, yellowBlue);
 float ref[3];
 ref[0] = cyanRed;
 ref[1] = magentaGreen;
 ref[2] = yellowBlue;
 GPUImageColorBalanceFilter *filter = [[GPUImageColorBalanceFilter alloc] init];
 [filter setShadows:(GPUVector3){ cyanRed, magentaGreen, yellowBlue}];
 filter.preserveLuminosity = NO;
 return [filter imageByFilteringImage:self];
 //    return [self applyFilter:colorBalancePreserveLuminosity context:ref];
 //    return [self applyFilter:colorBalance context:ref];
 }
 */
-(UIImage*)createLinearTwoColorGradientImageWithSize:(CGSize)size
                                          startColor:(UIColor*)startColor
                                            endColor:(UIColor*)endColor
                                          startPoint:(CGPoint)startPoint
                                            endPoint:(CGPoint)endPoint
{
    UIGraphicsBeginImageContext(size);
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    //number of color
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat sRed, sGreen, sBlue, sAlpha, eRed, eGreen, eBlue, eAlpha;
    
    //get color of gradient
    if ([startColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [startColor getRed:&sRed green:&sGreen blue:&sBlue alpha:&sAlpha];
    } else {
        //<ios 5
        const CGFloat *components = CGColorGetComponents(startColor.CGColor);
        sRed = components[0];
        sGreen = components[1];
        sBlue = components[2];
        sAlpha = components[3];
    }
    
    if ([endColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [endColor getRed:&eRed green:&eGreen blue:&eBlue alpha:&eAlpha];
    } else {
        //<ios 5
        const CGFloat *components = CGColorGetComponents(endColor.CGColor);
        eRed = components[0];
        eGreen = components[1];
        eBlue = components[2];
        eAlpha = components[3];
    }
    
    NSLog(@"start color %f %f %f %f %f %f", sRed, sGreen, sBlue, eRed, eGreen, eBlue);
    CGFloat components[8] = { sRed, sGreen, sBlue, sAlpha, eRed, eGreen, eBlue, eAlpha};
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    startPoint = CGPointMake(startPoint.x * size.width, startPoint.y * size.height);
    endPoint = CGPointMake(startPoint.x * size.width, startPoint.y * size.height);
    
    //draw gradient
    CGContextDrawLinearGradient (UIGraphicsGetCurrentContext(), myGradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    UIImage *gradientImg;
    gradientImg = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return gradientImg;
    
}

+(UIImage*)createRadialTwoColorGradientImageWithSize:(CGSize)size
                                          startColor:(UIColor*)startColor
                                            endColor:(UIColor*)endColor
                                              center:(CGPoint)centerPoint
                                              radius:(float)radius
{
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    UIGraphicsBeginImageContext(size);
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    //number of color
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat sRed, sGreen, sBlue, sAlpha, eRed, eGreen, eBlue, eAlpha;
    
    //get color of gradient
    if ([startColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [startColor getRed:&sRed green:&sGreen blue:&sBlue alpha:&sAlpha];
    } else {
        //<ios 5
        const CGFloat *components = CGColorGetComponents(startColor.CGColor);
        sRed = components[0];
        sGreen = components[1];
        sBlue = components[2];
        sAlpha = components[3];
    }
    
    if ([endColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [endColor getRed:&eRed green:&eGreen blue:&eBlue alpha:&eAlpha];
    } else {
        //<ios 5
        const CGFloat *components = CGColorGetComponents(endColor.CGColor);
        eRed = components[0];
        eGreen = components[1];
        eBlue = components[2];
        eAlpha = components[3];
    }
    
    NSLog(@"start color %f %f %f %f %f %f", sRed, sGreen, sBlue, eRed, eGreen, eBlue);
    CGFloat components[8] = { sRed, sGreen, sBlue, sAlpha, eRed, eGreen, eBlue, eAlpha};
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    centerPoint = CGPointMake(centerPoint.x * size.width, centerPoint.y * size.height);
    CGPoint startPoint = centerPoint;
    CGPoint endPoint = centerPoint;
    
    radius = MIN(size.width, size.height) * radius;
    CGFloat startRadius = 0;
    CGFloat endRadius = radius;
    
    //draw gradient
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, startPoint,
                                 startRadius, endPoint, endRadius,
                                 kCGGradientDrawsAfterEndLocation);
    UIImage *gradientImg;
    
    gradientImg = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return gradientImg;
    
}
+(UIImage*)createLinearGradientImageWithSize:(CGSize)size
                           color_stop_number:(int) num_locations
                            color_stop_point:(CGFloat*)locations
                            color_components:(CGFloat*)components
                                  startPoint:(CGPoint)startPoint
                                    endPoint:(CGPoint)endPoint
{
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    UIGraphicsBeginImageContext(size);
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    //number of color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    //draw gradient
    startPoint = CGPointMake(startPoint.x * size.width, startPoint.y * size.height);
    endPoint = CGPointMake(endPoint.x * size.width, endPoint.y * size.height);
    
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), myGradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    UIImage *gradientImg;
    
    gradientImg = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return gradientImg;
    
}
-(UIImage*)createRadialGradientImageWithSize:(CGSize)size
                           color_stop_number:(int) num_locations
                            color_stop_point:(CGFloat*)locations
                            color_components:(CGFloat*)components
                                 startCenter:(CGPoint)startCenter
                                   endCenter:(CGPoint)endCenter
                                 startRadius:(CGFloat)startRadius
                                   endRadius:(CGFloat)endRadius
{
    // Render a radial background
    // http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
    
    UIGraphicsBeginImageContext(size);
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    
    //number of color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    //draw gradient
    startCenter = CGPointMake(startCenter.x * size.width, startCenter.y * size.height);
    endCenter = CGPointMake(endCenter.x * size.width, endCenter.y * size.height);
    
    startRadius = MIN(size.width, size.height) * startRadius;
    endRadius = MIN(size.width, size.height) * endRadius;
    
    CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), myGradient, startCenter, startRadius, endCenter, endRadius, kCGGradientDrawsAfterEndLocation);
    UIImage *gradientImg;
    
    gradientImg = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    return gradientImg;
    
}
-(UIImage*)compositeUnderImage:(UIImage*)foregroundImage withBlendMode:(CGBlendMode)blendMode andOpacity:(float)opacity
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 1.0);
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [self drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1];
    [foregroundImage drawInRect:imageRect blendMode:blendMode alpha:opacity];
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return filteredImage;
}
#pragma -
#pragma mark blend effects
-(UIImage*)violetCoffeeEffect
{
    NSLog(@"violet coffee effect");
    
    
    //get lookup source image
    UIImage *image = [UIImage imageNamed:@"lookup_violet_cafe.png"];
    NSAssert(image, @"missing file lookup_violet_cafe.png");
    
    // create filter loolup
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    // Add lookup image source
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    //Get result by applying filter
    return [lookUpFilter imageByFilteringImage:self];
}
-(UIImage*)frezzingBlueEffect
{
    NSLog(@"frezzing blue");
    UIImage *image = [UIImage imageNamed:@"lookup_frezzing_blue.png"];
    NSAssert(image, @"missing file lookup_frezzing_blue.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}
-(UIImage*)foliageEffect
{
    NSLog(@"foliage");
    UIImage *image = [UIImage imageNamed:@"lookup_foliage.png"];
    NSAssert(image, @"missing file lookup_frezzing_blue.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}

-(UIImage*)coldSummerEffect
{
    NSLog(@"Cold Summer Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_cold_summer.png"];
    NSAssert(image, @"missing file lookup_cold_summer.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}
-(UIImage*)warmSummerEffect
{
    NSLog(@"Warm Summer Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_warm_summer.png"];
    NSAssert(image, @"missing file lookup_warm_summer.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}
-(UIImage*)wildDarkBlueEffect
{
    NSLog(@"Wild Dark Blue Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_wild_dark_blue.png"];
    NSAssert(image, @"missing file lookup_wild_dark_blue.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}
-(UIImage*)romanticPink
{
    NSLog(@"Romantic Pink Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_pink_romantic_part1.png"];
    NSAssert(image, @"missing file lookup_pink_romantic_part1.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
    
}
-(UIImage*)specialBlue
{
    NSLog(@"Special Blue Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_special_blue.png"];
    NSAssert(image, @"missing file lookup_special_blue.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
    
}
-(UIImage*) fearless
{
    NSLog(@"Fearless Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_fearless.png"];
    NSAssert(image, @"missing file lookup_fearless.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *sourceImage = [[GPUImagePicture alloc] initWithImage:self];
    [sourceImage addTarget:lookUpFilter];
    [lookupImage addTarget:lookUpFilter];
    [lookupImage processImage];
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    [lookUpFilter addTarget:sharpenFilter];
    
    [sourceImage processImage];
    [sharpenFilter useNextFrameForImageCapture];
    return [sharpenFilter imageFromCurrentFramebuffer];
    
}
-(UIImage*)warmForrest
{
    NSLog(@"warm forrest Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_warm_forrest.png"];
    NSAssert(image, @"missing file lookup_warm_forrest.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *sourceImage = [[GPUImagePicture alloc] initWithImage:self];
    [sourceImage addTarget:lookUpFilter];
    [lookupImage addTarget:lookUpFilter];
    [lookupImage processImage];
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    [lookUpFilter addTarget:sharpenFilter];
    
    [sourceImage processImage];
    [sharpenFilter useNextFrameForImageCapture];
    return [sharpenFilter imageFromCurrentFramebuffer];
    
}
-(UIImage*)summerForrest
{
    NSLog(@"Magical Cyan Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_summer_forrest.png"];
    NSAssert(image, @"missing file lookup_summer_forrest.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
    
}
-(UIImage*)cyanForrest
{
    /*
     First  : lookup_cyan_forrest_1_curves.png
     Second : gradient, sharpen
     Final  : lookup_cyan_forrest_2_last.png
     */
    
    NSLog(@"Magical Cyan Effect");
    //First:
    
    UIImage *image = [UIImage imageNamed:@"lookup_cyan_forrest_1.png"];
    NSAssert(image, @"missing file lookup_cyan_forrest_1.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *sourceImage = [[GPUImagePicture alloc] initWithImage:self];
    [sourceImage addTarget:lookUpFilter];
    [lookupImage addTarget:lookUpFilter];
    [lookupImage processImage];
    
    //Second:
    //linear gradient
    int num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.5, 1.0};
    CGFloat components[12] =
    {  0  , 0  , 0  , 1,
        78.0/255.0,78.0/255.0,78.0/255.0, 0,
        0  , 0  , 0  , 1 };
    UIImage* linearGradientImg1 = [UIImage createLinearGradientImageWithSize:self.size
                                                           color_stop_number:num_locations
                                                            color_stop_point:locations
                                                            color_components:components
                                                                  startPoint:CGPointMake(0, 0)
                                                                    endPoint:CGPointMake(0, 1)];
    GPUImagePicture *linearGradientPic1 = [[GPUImagePicture alloc] initWithImage:linearGradientImg1];
    GPUImageAlphaBlendFilter *linearGradientBlendFilter1 = [[GPUImageAlphaBlendFilter alloc] init];
    [lookUpFilter addTarget:linearGradientBlendFilter1];
    [linearGradientPic1 addTarget:linearGradientBlendFilter1];
    [linearGradientPic1 processImage];
    
    //radian gradient
    UIImage* radialGradientImg = [UIImage createRadialTwoColorGradientImageWithSize:self.size
                                                                         startColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]
                                                                           endColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]
                                                                             center:CGPointMake(0.5f,0.5f)
                                                                             radius:1.5];
    
    GPUImagePicture *radialGradientPic = [[GPUImagePicture alloc] initWithImage:radialGradientImg];
    GPUImageAlphaBlendFilter *alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    [linearGradientBlendFilter1 addTarget:alphaBlendFilter];
    [radialGradientPic addTarget:alphaBlendFilter];
    alphaBlendFilter.mix = 0.13;
    [radialGradientPic processImage];
    
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    [alphaBlendFilter addTarget:sharpenFilter];
    //final
    
    UIImage *image2 = [UIImage imageNamed:@"lookup_cyan_forrest_2.png"];
    NSAssert(image2, @"missing file lookup_cyan_forrest_2.png");
    
    GPUImageLookupFilter *lookUpFilter2 = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    //[lookUpFilter addTarget:lookUpFilter2];
    [sharpenFilter addTarget:lookUpFilter2];
    [lookupImage2 addTarget:lookUpFilter2];
    [lookupImage2 processImage];
    
    
    [sourceImage processImage];
    [lookUpFilter2 useNextFrameForImageCapture];
    return [lookUpFilter2 imageFromCurrentFramebuffer];
    
}
-(UIImage*)warmLandscape
{
    NSLog(@"Warm Landscape Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_warm_landscape.png"];
    NSAssert(image, @"missing file lookup_warm_landscape.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *sourceImage = [[GPUImagePicture alloc] initWithImage:self];
    [sourceImage addTarget:lookUpFilter];
    [lookupImage addTarget:lookUpFilter];
    [lookupImage processImage];
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    
    [lookUpFilter addTarget:sharpenFilter];
    /*
     [sourceImage processImage];
     return [sharpenFilter imageFromCurrentFramebuffer];
     */
    //Radial Gradient
    int num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0};
    CGFloat components[8] ={  1.0, 1.0, 1.0, 1,
        1.0, 1.0, 1.0, 0 };
    CGPoint startCenter = CGPointMake(0.3, -0.1);
    CGPoint endCenter = startCenter;
    CGFloat startRadius = 0;
    CGFloat endRadius = 0.6;
    UIImage* radialGradientImg = [self createRadialGradientImageWithSize:self.size
                                                       color_stop_number:num_locations
                                                        color_stop_point:locations
                                                        color_components:components
                                                             startCenter:startCenter
                                                               endCenter:endCenter
                                                             startRadius:startRadius
                                                               endRadius:endRadius];
    
    GPUImagePicture *radialGradientPic = [[GPUImagePicture alloc] initWithImage:radialGradientImg];
    GPUImageAlphaBlendFilter *alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    alphaBlendFilter.mix = 1;
    [sharpenFilter addTarget:alphaBlendFilter];
    [radialGradientPic addTarget:alphaBlendFilter];
    [radialGradientPic processImage];
    
    
    [sourceImage processImage];
    [alphaBlendFilter useNextFrameForImageCapture];
    return [alphaBlendFilter imageFromCurrentFramebuffer];
}

-(UIImage*)sexyRed
{
    NSLog(@"Sexy Lips Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_sexy_red.png"];
    NSAssert(image, @"missing file lookup_sexy_red.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}

-(UIImage*)whiteFade
{
    NSLog(@"White Fade Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_white_fade.png"];
    NSAssert(image, @"missing file lookup_white_fade.png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    
    [lookupImage addTarget:lookUpFilter atTextureLocation:1];
    [lookupImage processImage];
    
    return [lookUpFilter imageByFilteringImage:self];
}

-(UIImage*)softWhite
{
    NSLog(@"Soft White Effect");
    UIImage *image = [UIImage imageNamed:@"lookup_soft_white(no highpass 10px).png"];
    NSAssert(image, @"missing file lookup_soft_white(no highpass 10px).png");
    
    GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];
    GPUImagePicture *lookupImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *sourceImage = [[GPUImagePicture alloc] initWithImage:self];
    [sourceImage addTarget:lookUpFilter];
    [lookupImage addTarget:lookUpFilter];
    [lookupImage processImage];
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    sharpenFilter.sharpness = 0.3;
    [lookUpFilter addTarget:sharpenFilter];
    
    [sourceImage processImage];
    [sharpenFilter useNextFrameForImageCapture];
    return [sharpenFilter imageFromCurrentFramebuffer];
    
}
#pragma sampleEffect
-(UIImage*)sampleEffect
{
    NSDate *start = [NSDate date];
    
    id temp = self;
    //1. reduce saturation
    NSLog(@"1.saturation");
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    saturationFilter.saturation = 0.8;
    temp = [saturationFilter imageByFilteringImage:temp];
    
    NSLog(@"2.Curves");
    //2. curves adjustment
    float x[5], y[5];
    float coefficient[4], otherCoefficient[4];
    float space[256];
    int numOfCoe = 4, numOfSpace = 256;
    
    // add RGB curves layer to adjust contrast
    x[1] = 0  ; y[1] = 0;
    x[2] = 130; y[2] = 60;
    x[3] = 195; y[3] = 140;
    x[4] = 255; y[4] = 255;
    
    linearEquation4Unknown(x, y, otherCoefficient);
    
    x[2] = 45 ; y[2] = 90;
    x[3] = 140; y[3] = 180;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransformTwoFunction(coefficient, otherCoefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesRed context:space];
    x[1] = 0  ; y[1] = 30;
    x[2] = 70 ; y[2] = 55;
    x[3] = 190; y[3] = 125;
    x[4] = 255; y[4] = 190;
    linearEquation4Unknown(x, y, coefficient);
    curvesSpaceTransform(coefficient, numOfCoe, space, numOfSpace);
    temp = [temp applyFilter:curvesBlue context:space];
    NSLog(@"gradient");
    
    //3. add viginete with softlight;
    UIImage* gradientImg = [UIImage createRadialTwoColorGradientImageWithSize:self.size
                                                                   startColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]
                                                                     endColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
                                                                       center:CGPointMake(0.5f,0.5f)
                                                                       radius:1];
    ///*
    GPUImageSoftLightBlendFilter *softLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    GPUImagePicture *backgroundImg = [[GPUImagePicture alloc] initWithImage:temp];
    GPUImagePicture *foregroundImg = [[GPUImagePicture alloc] initWithImage:gradientImg];
    [backgroundImg addTarget:softLightBlendFilter];
    [backgroundImg processImage];
    [foregroundImg addTarget:softLightBlendFilter];
    [foregroundImg processImage];
    [softLightBlendFilter useNextFrameForImageCapture];
    temp = [softLightBlendFilter imageFromCurrentFramebuffer];
    //*/
    // temp = [temp compositeUnderImage:gradientImg withBlendMode:kCGBlendModeSoftLight andOpacity:1];
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Time red scale new: %f", timeInterval);
    
    return temp;
}
-(UIImage*) aristocraticYellowBlue
{
    NSDate *start = [NSDate date];
    //    return [self colorBalanceCyanRed:-0.1 magentaGreen:0.6 yellowBlue:0.1];
    
    UIImage *temp = self;
    //1. Curves
    GPUImageToneCurveFilter *curvesFilter = [[GPUImageToneCurveFilter alloc] init];
    curvesFilter.blueControlPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 85.0f/225.0f)], [NSValue valueWithCGPoint:CGPointMake(1, 215.0f/225.0f)],nil];
    temp = [curvesFilter imageByFilteringImage:temp];
    
    //2.solid color
    UIImage *solidColorImg = [UIImage imageWithColor:[UIColor colorWithRed:1 green:220.0/225.0 blue:0 alpha:1] andSize:self.size];
    // and multiply blend mode 15%
    /*
     GPUImageMultiplyBlendFilter *blendFilter = [[GPUImageMultiplyBlendFilter alloc] init];
     GPUImagePicture *backgroundImg = [[GPUImagePicture alloc] initWithImage:temp];
     GPUImagePicture *foregroundImg = [[GPUImagePicture alloc] initWithImage:solidColor];
     [backgroundImg addTarget:blendFilter];
     [backgroundImg processImage];
     [foregroundImg addTarget:blendFilter];
     [foregroundImg processImage];
     temp = [blendFilter imageFromCurrentFramebuffer];
     */
    temp = [temp compositeUnderImage:solidColorImg withBlendMode:kCGBlendModeMultiply andOpacity:0.15];
    //3.color balance
    //    temp = [temp colorBalanceCyanRed:-0.1 magentaGreen:0.6 yellowBlue:0.1];
    //4.black and white
    
    GPUImageGrayscaleFilter *greyFilter = [[GPUImageGrayscaleFilter alloc] init];
    temp = [temp compositeUnderImage:[greyFilter imageByFilteringImage:temp] withBlendMode:kCGBlendModeSoftLight andOpacity:1];
    
    //5.vigenette
    NSLog(@"5. finalize");
    UIImage* gradientImg = [UIImage createRadialTwoColorGradientImageWithSize:self.size
                                                                   startColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]
                                                                     endColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]
                                                                       center:CGPointMake(0.5f,0.5f)
                                                                       radius:1];
    NSLog(@"blend");
    temp = [temp compositeUnderImage:gradientImg withBlendMode:kCGBlendModeSoftLight andOpacity:1];
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@"Xanh quy phai effect: %f", timeInterval);
    return temp;
    
}
+(UIImage*) imageWithColor:(UIColor*)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
/*
 - (UIImage *) flipImageLeftRight
 {
 
 UIImageView *tempImageView = [[UIImageView alloc] initWithImage:self];
 
 UIGraphicsBeginImageContext(tempImageView.frame.size);
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 CGAffineTransform flipVertical = CGAffineTransformMake(
 1, 0,
 0, -1,
 0, tempImageView.frame.size.height);
 CGContextConcatCTM(context, flipVertical);
 
 [tempImageView.layer renderInContext:context];
 
 UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
 flipedImage = [UIImage imageWithCGImage:flipedImage.CGImage scale:1.0 orientation:UIImageOrientationDown];
 UIGraphicsEndImageContext();
 
 return flipedImage;
 }
 */
@end
