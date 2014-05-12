//
//  CharLabel.h
//  CharCrush
//
//  Created by kid143 on 14-5-9.
//  Copyright 2014年 kid143. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CharLabel : CCLabelTTF

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int col;
@property (nonatomic, assign) NSUInteger imgIndex;

+ (instancetype)createAtRow:(int)row column:(int)col;
+ (CGFloat)contentWidth;
+ (instancetype)getDummy;

@end
