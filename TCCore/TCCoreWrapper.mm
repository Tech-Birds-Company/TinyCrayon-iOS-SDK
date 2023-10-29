//
//  TCCoreWrapper.m
//  TinyCrayon
//
//  Created by Xin Zeng on 10/31/15.
//  Copyright © 2015 Xin Zeng. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TCCoreWrapper.h"

#include "TCCoreLibs0.h"
#include "improc.hpp"
#import <cstring>

typedef uint8_t uchar;
typedef uint16_t ushort;
typedef unsigned int uint;

@implementation TCCore

+(void) arrayCopy:(uchar *)dst src:(const uchar *)src count:(NSInteger)count {
    //arrcpy(dst, src, (int)count);
    std::memcpy(dst, src, (int)count);
}

//+(void) arrayCopy:(ushort *)dst src:(const uchar *)src length:(NSInteger)length {
//    arrcpy(dst, src, (int)length);
//}

+(Boolean) arrayCheckAll:(const uchar *)arr value:(uchar)value count:(NSInteger)count {
    for (int i = 0; i < count; i++)
        if (arr[i] != value)
            return false;
    return true;
}

//+(Boolean) arrayCheckAny:(const uchar *)arr value:(uchar)value count:(NSInteger)count {
//    return arrckany(arr, value, (int)count);
//}

+(void) arrayResize:(uchar *)dst src:(const uchar *)src dstSize:(CGSize)dstSize srcSize:(CGSize)srcSize {
    int dstWidth = dstSize.width;
    int dstHeight = dstSize.height;
    int srcWidth = srcSize.width;
    int srcHeight = srcSize.height;
    for (int y = 0; y < dstHeight; ++y)
    {
        for (int x = 0; x < dstWidth; ++x)
        {
            float srcX = x * (srcWidth - 1) / static_cast<float>(dstWidth - 1);
            float srcY = y * (srcHeight - 1) / static_cast<float>(dstHeight - 1);

            int srcX0 = std::floor(srcX);
            int srcY0 = std::floor(srcY);
            int srcX1 = std::ceil(srcX);
            int srcY1 = std::ceil(srcY);

            float xWeight = srcX - srcX0;
            float yWeight = srcY - srcY0;

            uchar pixel00 = src[srcY0 * srcWidth + srcX0];
            uchar pixel01 = src[srcY0 * srcWidth + srcX1];
            uchar pixel10 = src[srcY1 * srcWidth + srcX0];
            uchar pixel11 = src[srcY1 * srcWidth + srcX1];

            uchar interpolatedPixel = static_cast<uchar>((1 - xWeight) * (1 - yWeight) * pixel00 +
                                                         xWeight * (1 - yWeight) * pixel01 +
                                                         (1 - xWeight) * yWeight * pixel10 +
                                                         xWeight * yWeight * pixel11);

            dst[y * dstWidth + x] = interpolatedPixel;
        }
    }
}

//// convert from UIImage to cv::Mat or vise versa
//// http://docs.opencv.org/2.4.8/doc/tutorials/ios/image_manipulation/image_manipulation.html
//
// convert UIImage to color cv::Mat
+(cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);

    return cvMat;
}

//+(cv::Mat)cvMatFromUIImage:(UIImage *)image rect:(CGRect)rect {
//    CGImageRef cgimage = CGImageCreateWithImageInRect(image.CGImage, rect);
//    UIImage *img = [UIImage imageWithCGImage:cgimage];
//    cv::Mat mat = [self cvMatFromUIImage:img];
//    CGImageRelease(cgimage);
//    return mat;
//}

// convert UIImage to gray cv::Mat
//+(cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
//{
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
//    CGFloat cols = image.size.width;
//    CGFloat rows = image.size.height;
//
//    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
//
//    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
//                                                    cols,                       // Width of bitmap
//                                                    rows,                       // Height of bitmap
//                                                    8,                          // Bits per component
//                                                    cvMat.step[0],              // Bytes per row
//                                                    colorSpace,                 // Colorspace
//                                                    kCGImageAlphaNoneSkipLast |
//                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
//
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
//    CGContextRelease(contextRef);
//
//    return cvMat;
//}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    return [self UIImageFromCVMat: cvMat alphaInfo: kCGImageAlphaPremultipliedLast];
}

// convert cv::Mat to UIImage
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat alphaInfo:(CGImageAlphaInfo)alphaInfo
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        alphaInfo|kCGBitmapByteOrderDefault,        // bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );


    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}

+(UIImage *) imageWithAlpha:(UIImage *)image alpha:(const uchar *)alphaData compact:(BOOL)compact offset:(CGPoint*)offset {
    cv::Mat img = [self cvMatFromUIImage:image];
    cv::Mat result;
    cv::Point off;

    if (!improcImageWithAlpha(img, alphaData, compact, off, result)) {
        return nil;
    }

    *offset = CGPointMake(off.x, off.y);
    return [self UIImageFromCVMat:result alphaInfo:kCGImageAlphaLast];
}

//+(UIImage *) imageFromMask:(const uchar *)mask alpha:(const uchar *)alpha size:(CGSize)size rect:(CGRect)rect {
//    cv::Rect cvRect = cv::Rect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
//    cv::Mat img;
//
//    improcMaskToImage(mask, alpha, cv::Size(size.width, size.height), cvRect, img);
//
//    return [self UIImageFromCVMat:img];
//}

+(Boolean) imageSelect:(const uchar *)imageData size:(CGSize)size mask:(uchar*)mask region:(const uchar *)region opacity:(uchar *)opacity mode:(NSInteger)mode edgeDetection:(Boolean)edgeDetection rect:(CGRect)rect outRect:(CGRect *)outRect {

    cv::Rect cvRect = cv::Rect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    cv::Size cvSize = cv::Size(size.width, size.height);
    cv::Rect cvOutRect;

    if (improcImageSelect(imageData, cvSize, mask, region, opacity, (int)mode, edgeDetection, cvRect, cvOutRect)) {
        *outRect = CGRectMake(cvOutRect.x, cvOutRect.y, cvOutRect.width, cvOutRect.height);
        return true;
    }
    else {
        *outRect = CGRectMake(0, 0, 0, 0);
        return false;
    }
}

+(UIImage *) imageFromAlpha:(const uchar *)alpha size:(CGSize)size rect:(CGRect)rect {
    cv::Mat img;
    cv::Size cvSize = cv::Size(size.width, size.height);
    cv::Rect cvRect = cv::Rect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    if (cvRect.width == 0 || cvRect.height == 0)
        return nil;

    improcAlphaToImage(alpha, cvSize, cvRect, img);
    return [self UIImageFromCVMat:img];
}

+(UIImage *) imageFromAlpha:(const uchar *)alpha size:(CGSize)size {
    return [self imageFromAlpha:alpha size:size rect:CGRectMake(0, 0, size.width, size.height)];
}

+(void) maskFromAlpha:(const uchar *)alpha mask:(uchar *)mask size:(CGSize)size {
    cv::Size cvSize(size.width, size.height);
    cv::Rect cvRect(0, 0, cvSize.width, cvSize.height);
    improcAlphaToMask(alpha, mask, cvSize, cvRect);
}

//+(void) pushMaskLog:(const uchar *)mask log:(unsigned short *)log count:(NSInteger)count offset:(NSInteger)offset{
//    improcPushMaskLog(mask, log, (int)count, (int)offset);
//}
//
//+(void) popMaskLog:(uchar *)mask log:(const unsigned short *)log count:(NSInteger)count offset:(NSInteger)offset {
//    improcPopMaskLog(mask, log, (int)count, (int)offset);
//}

//+(void) updateMask:(uchar *)mask alpha:(const uchar *)alpha region:(const uchar *)region count:(NSInteger)count {
//    improcUpdateMask(mask, alpha, region, (int)count);
//}

+(Boolean) drawRadialGradientOnAlpha:(uchar *)alpha size:(CGSize)size center:(CGPoint)center startValue:(uchar)startValue startRadius:(CGFloat)startRadius endValue:(uchar)endValue endRadius:(CGFloat)endRadius outRect:(CGRect *)outRect add:(Boolean)add {
    cv::Size cvSize(size.width, size.height);
    cv::Point cvCenter(center.x, center.y);
    cv::Rect cvOutRect;

    bool retval = improcDrawRadialGradient(alpha, cvSize, cvCenter, startValue, startRadius, endValue, endRadius, cvOutRect, add);

    *outRect = CGRectMake(cvOutRect.x, cvOutRect.y, cvOutRect.width, cvOutRect.height);

    return retval;
}

+(void) invertAlpha:(uchar *)alpha count:(NSInteger)count {
    improcInvertAlpha(alpha, (int)count);
}

//+(void) invertMask:(uchar *)mask count:(NSInteger)count {
//    improcInvertMask(mask, (int)count);
//}

+(Boolean) logEncodeArray:(const uchar *)array count:(NSInteger)count buf:(uint *)buf bufLen:(int)bufLen processed:(int *)processed offset:(int *)offset {
    return improcLogEncodeArray(array, (int)count, buf, bufLen, processed, offset);
}

+(Boolean) logEncodeDiffFrom:(const uchar *)from to:(const uchar *)to count:(NSInteger)count buf:(uint *)buf bufLen:(int)bufLen processed:(int *)processed offset:(int *)offset {
    return improcLogEncodeDiff(from, to, (int)count, buf, bufLen, processed, offset);
}

//+(void) logDecodeArray:(uchar *)decoded encoded:(const uint *)encoded decodedCount:(NSInteger)decodedCount encodedCount:(NSInteger)encodedCount {
//    improcLogDecodeArray(decoded, encoded, (int)decodedCount, (int)encodedCount);
//}

+(void) logDecodeDiffTo:(uchar *)to from:(const uchar*)from diff:(const uint *)diff count:(NSInteger)count diffCount:(NSInteger)diffCount {
    improcLogDecodeDiff(to, from, diff, (int)count, (int)diffCount);
}

@end
