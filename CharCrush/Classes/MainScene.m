//
//  IntroScene.m
//  CharCrush
//
//  Created by kid143 on 14-5-7.
//  Copyright kid143 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "MainScene.h"
#import "CharLabel.h"

#define MATRIX_WIDTH 6
#define MATRIX_HEIGHT 8
#define CHAR_GAP 4
#define HORZ_PADDING 65
#define BOTTOM_PADDING 70

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation MainScene

{
    BOOL _isInAction;
    NSMutableArray *_charMatrix;
    NSMutableSet *_previousMove;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MainScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    [self addChild:background];
    
    // Initiate stage
    [self createCharMatrix];
    
    _isInAction = YES;
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)createCharMatrix
{
    _charMatrix = [NSMutableArray arrayWithCapacity:MATRIX_WIDTH];
    for (int i = 0; i < MATRIX_WIDTH; i++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:MATRIX_HEIGHT];
        [_charMatrix addObject:row];
        for (int j = 0; j < MATRIX_HEIGHT; j++) {
            [row addObject:[self createCharAtColumn:i row:j]];
        }
    }
}

// -----------------------------------------------------------------------

- (CharLabel *)createCharAtColumn:(int)col row:(int)row
{
    CharLabel *newChar = [CharLabel createAtRow:row column:col];
    newChar.position = ccp(
                           HORZ_PADDING + col * ([CharLabel contentWidth] + CHAR_GAP) + [CharLabel contentWidth] / 2,
                           self.contentSize.height + [CharLabel contentWidth] / 2);
    [newChar runAction:[CCActionMoveTo actionWithDuration:0.3f
                                                 position:[self charPostionAtRow:row column:col]]];
    [self addChild:newChar];
    return newChar;
}

// -----------------------------------------------------------------------
#pragma mark - Game Logics
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    if (_isInAction) {
        _isInAction = NO;
        for (int i = 0; i < MATRIX_WIDTH; i++) {
            for (int j = 0; j < MATRIX_HEIGHT; j++) {
                CharLabel *charLabel = [[_charMatrix objectAtIndex:i] objectAtIndex:j];
                if ([charLabel numberOfRunningActions] > 0) {
                    _isInAction = YES;
                    break;
                }
            }
        }
    } else {
        [self checkAndRemoveChar];
    }
}

// -----------------------------------------------------------------------

- (void)checkAndRemoveChar
{
    for (int i = 0; i < MATRIX_WIDTH; i++) {
        for (int j = 0; j < MATRIX_HEIGHT; j++) {
            CharLabel *target = [[_charMatrix objectAtIndex:i] objectAtIndex:j];
            if (target.imgIndex == -1) {
                continue;
            }
            
            NSMutableSet *columnChain = [NSMutableSet set];
            [self getColumnChainForChar:target chain:columnChain];
            
            NSMutableSet *rowChain = [NSMutableSet set];
            [self getRowChainForChar:target chain:rowChain];
            
            NSMutableSet *longest = [columnChain count] > [rowChain count] ? columnChain : rowChain;
            if ([longest count] >= 3) {
                [self removeChar:longest];
                return;
            }
        }
    }
}

// -----------------------------------------------------------------------

- (void)getColumnChainForChar:(CharLabel *)charLabel chain:(NSMutableSet *)chain
{
    [chain addObject:charLabel];
    
    int neighborRow = charLabel.row - 1;
    while (neighborRow >= 0) {
        CharLabel *neighbor = [[_charMatrix objectAtIndex:charLabel.col] objectAtIndex:neighborRow];
        if (neighbor.imgIndex != -1 && neighbor.imgIndex == charLabel.imgIndex) {
            [chain addObject:neighbor];
            neighborRow--;
        } else
            break;
    }
    
    neighborRow = charLabel.row + 1;
    while (neighborRow < MATRIX_HEIGHT) {
        CharLabel *neighbor = [[_charMatrix objectAtIndex:charLabel.col] objectAtIndex:neighborRow];
        if (neighbor.imgIndex != -1 && neighbor.imgIndex == charLabel.imgIndex) {
            [chain addObject:neighbor];
            neighborRow++;
        } else
            break;
    }
}

// -----------------------------------------------------------------------

- (void)getRowChainForChar:(CharLabel *)charLabel chain:(NSMutableSet *)chain
{
    [chain addObject:charLabel];
    
    int neighborCol = charLabel.col - 1;
    while (neighborCol >= 0) {
        CharLabel *neighbor = [[_charMatrix objectAtIndex:neighborCol] objectAtIndex:charLabel.row];
        if (neighbor.imgIndex != -1 && neighbor.imgIndex == charLabel.imgIndex) {
            [chain addObject:neighbor];
            neighborCol--;
        } else
            break;
    }
    
    neighborCol = charLabel.col + 1;
    while (neighborCol < MATRIX_WIDTH) {
        CharLabel *neighbor = [[_charMatrix objectAtIndex:neighborCol] objectAtIndex:charLabel.row];
        if (neighbor.imgIndex != -1 && neighbor.imgIndex == charLabel.imgIndex) {
            [chain addObject:neighbor];
            neighborCol++;
        } else
            break;
    }
}

// -----------------------------------------------------------------------

- (void)removeChar:(NSSet *)chain
{
    _isInAction = YES;
    for (CharLabel *charL in chain) {
        [[_charMatrix objectAtIndex:charL.col] setObject:[CharLabel getDummy] atIndex:charL.row];
        NSLog(@"remove char at col:%d, row:%d, char:%@", charL.col, charL.row, charL.string);
        [charL runAction:[CCActionSequence actionWithArray:@[
                                                             [CCActionScaleTo actionWithDuration:0.3f scale:0.0f],
                                                             [CCActionRemove action]]]];
    }
    
    [self fillVacancies];
}

// -----------------------------------------------------------------------

- (void)fillVacancies
{
    int *colEmptyInfo = (int *)malloc(sizeof(int) * MATRIX_WIDTH);
    
    for (int i = 0; i < MATRIX_WIDTH; i++) {
        int numOfCharDeleted = 0;
        for (int j = 0; j < MATRIX_HEIGHT; j++) {
            CharLabel *charLabel = [[_charMatrix objectAtIndex:i] objectAtIndex:j];
            if (charLabel.imgIndex == -1) {
                numOfCharDeleted++;
            } else {
                if (numOfCharDeleted > 0) {
                    int newRow = j - numOfCharDeleted;
                    [[_charMatrix objectAtIndex:i] setObject:[CharLabel getDummy] atIndex:j];
                    [[_charMatrix objectAtIndex:i] setObject:charLabel atIndex:newRow];
                        
                    charLabel.row = newRow;
                        
                    [charLabel stopAllActions];
                    [charLabel runAction:[CCActionMoveTo actionWithDuration:0.3f position:[self charPostionAtRow:newRow column:i]]];
                }
            }
        }
        colEmptyInfo[i] = numOfCharDeleted;
    }
    
    for (int i = 0; i < MATRIX_WIDTH; i++) {
        for (int j = MATRIX_HEIGHT - colEmptyInfo[i]; j < MATRIX_HEIGHT; j++) {
            [[_charMatrix objectAtIndex:i] setObject:[self createCharAtColumn:i row:j] atIndex:j];
        }
    }
    
    free(colEmptyInfo);
}

// -----------------------------------------------------------------------
#pragma mark - Helper Methods
// -----------------------------------------------------------------------

- (CGPoint)charPostionAtRow:(int)row column:(int)col
{
    CGFloat x = HORZ_PADDING + col * ([CharLabel contentWidth] + CHAR_GAP) + [CharLabel contentWidth] / 2;
    CGFloat y = BOTTOM_PADDING + row * ([CharLabel contentWidth] + CHAR_GAP) + [CharLabel contentWidth] / 2;
    return ccp(x, y);
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------


// -----------------------------------------------------------------------
@end
