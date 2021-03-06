//
//  IntroScene.h
//  CharCrush
//
//  Created by kid143 on 14-5-7.
//  Copyright kid143 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The intro scene
 *  Note, that scenes should now be based on CCScene, and not CCLayer, as previous versions
 *  Main usage for CCLayer now, is to make colored backgrounds (rectangles)
 *
 */
@interface MainScene : CCScene

// -----------------------------------------------------------------------

+ (MainScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end