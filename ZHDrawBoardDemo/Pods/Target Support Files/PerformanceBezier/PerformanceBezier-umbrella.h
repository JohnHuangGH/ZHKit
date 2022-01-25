#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "PerformanceBezier.h"
#import "UIBezierPath+Ahmed.h"
#import "UIBezierPath+Center.h"
#import "UIBezierPath+Clockwise.h"
#import "UIBezierPath+Description.h"
#import "UIBezierPath+Equals.h"
#import "UIBezierPath+FirstLast.h"
#import "UIBezierPath+NSOSX.h"
#import "UIBezierPath+Performance.h"
#import "UIBezierPath+Trim.h"
#import "UIBezierPath+Uncached.h"
#import "UIBezierPath+Util.h"
#import "UIBezierPathProperties.h"

FOUNDATION_EXPORT double PerformanceBezierVersionNumber;
FOUNDATION_EXPORT const unsigned char PerformanceBezierVersionString[];

