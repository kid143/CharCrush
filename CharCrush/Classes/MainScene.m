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
    
    CharLabel *_firstTouched;
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
    
    self.userInteractionEnabled = YES;
    
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    [self addChild:background];
    
    // Initiate stage
    [self createCharMatrix];
    _previousMove = [NSMutableSet set];
    
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
                
                if ([_previousMove count] > 0) {
                    [_previousMove removeAllObjects];
                }
                
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

- (void)swapPosition:(CharLabel *)one withAnother:(CharLabel *)other
{
    _isInAction = YES;
    
    if ([_previousMove count] > 0) {
        [_previousMove removeAllObjects];
    } else {
        [_previousMove addObject:one];
        [_previousMove addObject:other];
    }
    
    CGPoint onePos = one.position;
    CGPoint otherPos = other.position;
    [one runAction:[CCActionMoveTo actionWithDuration:0.3f position:otherPos]];
    [other runAction:[CCActionMoveTo actionWithDuration:0.3f position:onePos]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int oneCol = one.col;
        int oneRow = one.row;
        one.col = other.col;
        one.row = other.row;
        other.col = oneCol;
        other.row = oneRow;
        [[_charMatrix objectAtIndex:oneCol] setObject:other atIndex:oneRow];
        [[_charMatrix objectAtIndex:one.col] setObject:one atIndex:one.row];
    });
    
    // if the move can not blow up chars then the swap is invalid and should be undone.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([_previousMove count] > 0) {
            NSArray *all = [_previousMove allObjects];
            [self swapPosition:[all firstObject] withAnother:[all lastObject]];
        }
    });
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
#pragma mark - User Interactions
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInWorld];
    
    for (CCNode *target in self.children) {
        if ([target hitTestWithWorldPos:touchLoc]) {
            if ([target.name isEqualToString:@"char"]) {
                if (!_firstTouched) {
                    _firstTouched = (CharLabel *)target;
                    _firstTouched.colorRGBA = [CCColor redColor];
                } else {
                    CharLabel *secondTouched = (CharLabel *)target;
                    _firstTouched.colorRGBA = [CCColor whiteColor];
                    int diff = abs(_firstTouched.row + _firstTouched.col - secondTouched.row - secondTouched.col);
                    if (_firstTouched == secondTouched || diff > 1) {
                        // cancel previous touch if touch the same char or two chars are not neighbors
                        _firstTouched = nil;
                    } else {
                        // swap different
                        [self swapPosition:_firstTouched withAnother:secondTouched];
                        _firstTouched = nil;
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------
@end
