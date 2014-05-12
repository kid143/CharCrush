//
//  CharLabel.m
//  CharCrush
//
//  Created by kid143 on 14-5-9.
//  Copyright 2014年 kid143. All rights reserved.
//

#import "CharLabel.h"

#define INDEX 6

static NSArray *characters;
static CharLabel *dummy;

@implementation CharLabel

+ (void)initialize
{
    characters = @[@"☀︎", @"✤", @"❖", @"♣︎", @"✪", @"▲"];
}

+ (instancetype)createAtRow:(int)row column:(int)col
{
    int imgIndex = arc4random() % INDEX;
    CharLabel *newChar = [CharLabel labelWithString:characters[imgIndex]
                                           fontName:@"Arial"
                                           fontSize:30.0f];
    newChar.row = row;
    newChar.col = col;
    newChar.imgIndex = imgIndex;
    newChar.name = @"char";
    return newChar;
}

+ (instancetype)getDummy
{
    if (!dummy) {
        dummy = [[CharLabel alloc] init];
        dummy.imgIndex = -1;
    }
    return dummy;
}

+ (CGFloat)contentWidth
{
    return 30.0f;
}

@end
