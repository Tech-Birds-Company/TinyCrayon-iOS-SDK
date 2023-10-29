//
//  improc.hpp
//  TinyCrayon
//
//  Created by Xin Zeng on 11/23/15.
//  Copyright © 2015 Xin Zeng. All rights reserved.
//

#ifndef improc_hpp
#define improc_hpp

#import <opencv2/opencv.hpp>

#include <stdio.h>
//#include <cstdint>

using namespace cv;

typedef uint8_t uchar;
typedef uint16_t ushort;
typedef unsigned int uint;

void arrcpy(uchar *dst, const uchar *src, int count);
//void arrcpy(ushort *dst, const uchar *src, int count);

//void arrset(uchar *dst, uchar value, int count);

bool arrckall(const uchar *arr, uchar value, int count);

//bool arrckany(const uchar *arr, uchar value, int count);

void arrresize(uchar* dst, const uchar* src, int dstWidth, int dstHeight, int srcWidth, int srcHeight);

//
//   NAME: improcPushMaskLog
//
//   PARAMETERS:
//        mask      (IN) - mask data
//        log   (IN/OUT) - log data
//        count     (IN) - number of active log count
//        offset    (IN) - offset of current log
//
//   DESCRIPTION:
//        Push mask data to log
//
//   NOTES:
//
//void improcPushMaskLog(const uchar *mask, unsigned short *log, int count, int offset);

//
//   NAME: improcPopMaskLog
//
//   PARAMETERS:
//        mask     (OUT) - mask data
//        log   (IN/OUT) - log data
//        count     (IN) - mask/log length
//        offset    (IN) - offset of current log
//
//   DESCRIPTION:
//        Pop mask data to log
//
//   RETURNS:
//        Nothing
//
//   NOTES:
//        None
//
//void improcPopMaskLog(uchar *mask, const unsigned short *log, int count, int offset);

//
//   NAME: improcUpdateMask
//
//   PARAMETERS:
//        mask  (OUT) - data of mask
//        alpha  (IN) - data of alpha
//        region (IN) - region to apply update
//        count  (IN) - length of mask/alpha
//
//   DESCRIPTION:
//        Update the GC_FLAG_SMOOTH bit of mask
//
//   RETURNS:
//        Nothing
//
//   NOTES:
//        None
//
//void improcUpdateMask(uchar *mask, const uchar *alpha, const uchar *region, int count);


void improcInvertAlpha(uchar *alpha, int count);

//void improcInvertMask(uchar *alpha, int count);

bool improcLogEncodeDiff(const uchar *from, const uchar *to, int count, uint *buf, int bufLen, int *processed, int *offset);

bool improcLogEncodeArray(const uchar *arr, int count, uint *buf, int bufLen, int *processed, int *offset);

void improcLogDecodeDiff(uchar *to, const uchar *from, const uint *diff, int count, int diffCount);

//void improcLogDecodeArray(uchar *decoded, const uint *encoded, int decodedCount, int incodedCount);

bool improcDrawRadialGradient(uchar *alpha, cv::Size size, cv::Point center, int startV, int startR, int endV, int endR, cv::Rect &outRect, bool add);
bool improcImageWithAlpha(const Mat &img, const uchar *alphaData, bool compact, cv::Point &offset, Mat &result, bool argb = false);
//void improcMaskToImage(const uchar *maskData, const uchar *opacityData, cv::Size size, cv::Rect rect, Mat &img);
bool improcImageSelect(const uchar *imageData, cv::Size size, uchar *maskData, const uchar *regionData, const uchar *opacityData, int mode, bool edgeDetection, cv::Rect rect, cv::Rect &outRect);
void improcAlphaToImage(const uchar *alphaData, cv::Size size, cv::Rect rect, cv::Mat &img);
void improcAlphaToMask(const uchar *alpha, uchar *mask, cv::Size size, cv::Rect rect);
//void improcMaskToAlpha(const uchar *mask, const uchar *opacity, uchar *alpha, cv::Size size, cv::Rect rect);

#endif /* improc_hpp */
