//
//  TCCoreWrapper.h
//  TinyCrayon
//
//  Created by Xin Zeng on 10/31/15.
//  Copyright © 2015 Xin Zeng. All rights reserved.
//

#ifndef TCCoreWrapper_h
#define TCCoreWrapper_h

#import <UIKit/UIKit.h>
#import "TCCoreLibs.h"

typedef uint8_t uchar;
typedef uint16_t ushort;

@interface TCCore : NSObject {
    
}

+(void) arrayCopy:(uchar *)dst src:(const uchar *)src count:(NSInteger)count;
+(void) arrayCopy:(ushort *)dst src:(const uchar *)src length:(NSInteger)length;

+(Boolean) arrayCheckAll:(const uchar *)array value:(uchar)value count:(NSInteger)count;

+(void) arrayResize:(uchar *)dst src:(const uchar *)src dstSize:(CGSize)dstSize srcSize:(CGSize)srcSize;

+(UIImage *) imageWithAlpha:(UIImage *)image alpha:(const uchar *)alphaData compact:(BOOL)compact offset:(CGPoint*)offset;

+(UIImage *) imageFromMask:(const uchar *)mask alpha:(const uchar *)alpha size:(CGSize)size rect:(CGRect)rect;

+(UIImage *) imageFromAlpha:(const uchar *)alpha size:(CGSize)size;
+(UIImage *) imageFromAlpha:(const uchar *)alpha size:(CGSize)size rect:(CGRect)rect;

+(void) pushMaskLog:(const uchar *)mask log:(unsigned short *)log count:(NSInteger)count offset:(NSInteger)offset;

+(void) popMaskLog:(uchar *)mask log:(const unsigned short *)log count:(NSInteger)count offset:(NSInteger)offset;

+(void) updateMask:(uchar *)mask alpha:(const uchar *)alpha region:(const uchar *)region count:(NSInteger)count;

+(Boolean) drawRadialGradientOnAlpha:(uchar *)alpha size:(CGSize)size center:(CGPoint)center startValue:(uchar)startValue startRadius:(CGFloat)startRadius endValue:(uchar)endValue endRadius:(CGFloat)endRadius outRect:(CGRect *)outRect add:(Boolean)add;

+(void) invertAlpha:(uchar *)alpha count:(NSInteger)count;

+(void) invertMask:(uchar *)mask count:(NSInteger)count;

+(Boolean) logEncodeArray:(const uchar *)array count:(NSInteger)count buf:(uint *)buf bufLen:(int)bufLen processed:(int *)processed offset:(int *)offset;

+(Boolean) logEncodeDiffFrom:(const uchar *)from to:(const uchar *)to count:(NSInteger)count buf:(uint *)buf bufLen:(int)bufLen processed:(int *)processed offset:(int *)offset;

+(void) logDecodeArray:(uchar *)decoded encoded:(const uint *)encoded decodedCount:(NSInteger)decodedCount encodedCount:(NSInteger)encodedCount;

+(void) logDecodeDiffTo:(uchar *)to from:(const uchar*)from diff:(const uint *)diff count:(NSInteger)count diffCount:(NSInteger)diffCount;
@end


#endif /* TCCoreWrapper_h */
