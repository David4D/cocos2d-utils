/*
 * ModalAlert – Customizable popup dialogs/alerts for Cocos2D
 * For details, visit the Rombos blog:
 * http://rombosblog.wordpress.com/2012/02/28/modal-alerts-for-cocos2d/
 *
 * Copyright (c) 2012 Hans-Juergen Richstein, Rombos
 * http://www.rombos.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the “Software”), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * Update by David DUTOUR (better animations and add ShowAlert with Sprites)
 * https://github.com/David4D/cocos2d-utils/tree/master/ModalAlert
 *
 */

#import "cocos2d.h"
#import "ModalAlert.h"


#define kDialogTag 1234
#define kAnimationTime 0.25f
#define kDialogImg @"dialogBox.png"
#define kButtonImg @"dialogButton.png"
#define kFontName @"MarkerFelt-Thin"

// class that implements a black colored layer that will cover the whole screen
// and eats all touches except within the dialog box child
@interface CoverLayer : CCLayerColor {
}
@end
@implementation CoverLayer
- (id)init {
    self = [super initWithColor:ccc4(0,0,0,0)
                          width:[CCDirector sharedDirector].winSize.width
                         height:[CCDirector sharedDirector].winSize.height];
    if (self) {
        [self setTouchEnabled:YES];
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace: touch];
    CCNode *dialogBox = [self getChildByTag: kDialogTag];
    
    // eat all touches outside of dialog box
    return !CGRectContainsPoint(dialogBox.boundingBox, touchLocation);
}

- (void) registerWithTouchDispatcher {
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}
@end

@implementation ModalAlert

+ (void) CloseAlert: (CCSprite*) alertDialog onCoverLayer: (CCLayer*) coverLayer executingBlock: (void(^)())block {
    // shrink dialog box
    
    id fadeIn = [CCFadeOut actionWithDuration:kAnimationTime];
    id scaleTo = [CCScaleTo actionWithDuration:kAnimationTime scale:0.1];
    [alertDialog runAction:[CCSpawn actionOne:fadeIn two:scaleTo]];
    
    // in parallel, fadeout and remove cover layer and execute block
    // (note: you can’t use CCFadeOut since we don’t start at opacity 1!)
    [coverLayer runAction:[CCSequence actions:
                           [CCFadeTo actionWithDuration:kAnimationTime opacity:0.1],
                           [CCCallBlock actionWithBlock:^{
        [coverLayer removeFromParentAndCleanup:YES];
        if (block) block();
    }],
                           nil]];
}

+ (void) ShowAlert: (NSString*) message onLayer: (CCLayer *) layer
          withOpt1: (NSString*) opt1 withOpt1Block: (void(^)())opt1Block
           andOpt2: (NSString*) opt2 withOpt2Block: (void(^)())opt2Block {
    
    // create the cover layer that “hides” the current application
    CCLayerColor *coverLayer = [CoverLayer new];
    [layer addChild:coverLayer z:INT_MAX]; // put to the very top to block application touches
    [coverLayer runAction:[CCFadeTo actionWithDuration:kAnimationTime opacity:80]]; // smooth fade-in to dim with semi-transparency
    
    // open the dialog
    CCSprite *dialog = [CCSprite spriteWithFile:kDialogImg];
    dialog.tag = kDialogTag;
    dialog.position = ccp(coverLayer.contentSize.width/2, coverLayer.contentSize.height/2);
    dialog.opacity = 220; // make it a bit transparent for a cooler look
    
    // add the alert text
    CGSize msgSize = CGSizeMake(dialog.contentSize.width * 0.9, dialog.contentSize.height * 0.55);
    float fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?42:30;
    
    CCLabelTTF *dialogMsg = [CCLabelTTF labelWithString:message
                                               fontName:kFontName
                                               fontSize:fontSize
                                             dimensions:msgSize
                                             hAlignment:kCCTextAlignmentCenter ];
    
    //dialogMsg.anchorPoint = ccp(0, 0);
    dialogMsg.position = ccp(dialog.contentSize.width/2, dialog.contentSize.height * 0.6);
    dialogMsg.color = ccBLACK;
    [dialog addChild: dialogMsg];
    
    // add one or two buttons, as needed
    CCMenuItemSprite *opt1Button = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:kButtonImg]
                                                           selectedSprite:[CCSprite spriteWithFile: kButtonImg]
                                                                    block:^(id sender) {
                                                                        [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt1Block];
                                                                    }];
    
    opt1Button.position = ccp(dialog.textureRect.size.width * (opt1 ? 0.27f:0.5f), opt1Button.contentSize.height * 0.8f);
    
    CCLabelTTF *opt1Label = [CCLabelTTF labelWithString:opt1 fontName:kFontName fontSize:fontSize dimensions:opt1Button.contentSize hAlignment:kCCTextAlignmentCenter ];
    
    opt1Label.anchorPoint = ccp(0, 0.1);
    opt1Label.color = ccBLACK;
    [opt1Button addChild: opt1Label];
    
    // create second button, if requested
    CCMenuItemSprite *opt2Button = nil;
    if (opt2) {
        
        opt2Button = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:kButtonImg]
                                             selectedSprite:[CCSprite spriteWithFile: kButtonImg]
                                                      block:^(id sender) {
                                                          [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt2Block];
                                                      }];
        
        opt2Button.position = ccp(dialog.textureRect.size.width * 0.73f, opt2Button.contentSize.height * 0.8f);
        
        CCLabelTTF *opt2Label = [CCLabelTTF labelWithString:opt2 fontName:kFontName fontSize:fontSize dimensions:opt2Button.contentSize hAlignment:kCCTextAlignmentCenter ];
        
        opt2Label.anchorPoint = ccp(0, 0.1);
        opt2Label.color = ccBLACK;
        [opt2Button addChild: opt2Label];
    }
    
    CCMenu *menu = [CCMenu menuWithItems:opt1Button, opt2Button, nil];
    menu.position = CGPointZero;
    
    [dialog addChild:menu];
    [coverLayer addChild:dialog z:0];
    
    // open the dialog with a nice popup-effect
    
    id fadeIn = [CCFadeIn actionWithDuration:0.1];
    id scale1 = [CCSpawn actions:fadeIn, [CCScaleTo actionWithDuration:0.15 scale:1.1], nil];
    id scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.9];
    id scale3 = [CCScaleTo actionWithDuration:0.05 scale:1.0];
    id pulse = [CCSequence actions:scale1, scale2, scale3, nil];
    [dialog runAction:pulse];
}

+ (void) ShowAlert: (NSString*) message onLayer: (CCLayer *) layer
            withSpriteOK: (CCSprite*)spriteOk withOKBlock: (void(^)())opt1Block
            withSpriteKO: (CCSprite*)spriteKo withKOBlock: (void(^)())opt2Block {
    
    // create the cover layer that “hides” the current application
    CCLayerColor *coverLayer = [CoverLayer new];
    [layer addChild:coverLayer z:INT_MAX]; // put to the very top to block application touches
    [coverLayer runAction:[CCFadeTo actionWithDuration:kAnimationTime opacity:80]]; // smooth fade-in to dim with semi-transparency
    
    // open the dialog
    CCSprite *dialog = [CCSprite spriteWithFile:kDialogImg];
    dialog.tag = kDialogTag;
    dialog.position = ccp(coverLayer.contentSize.width/2, coverLayer.contentSize.height/2);
    dialog.opacity = 220; // make it a bit transparent for a cooler look
    
    // add the alert text
    CGSize msgSize = CGSizeMake(dialog.contentSize.width * 0.9, dialog.contentSize.height * 0.55);
    float fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?42:30;
    
    CCLabelTTF *dialogMsg = [CCLabelTTF labelWithString:message
                                               fontName:kFontName
                                               fontSize:fontSize
                                             dimensions:msgSize
                                             hAlignment:kCCTextAlignmentCenter ];
    
    //dialogMsg.anchorPoint = ccp(0, 0);
    dialogMsg.position = ccp(dialog.contentSize.width/2, dialog.contentSize.height * 0.6);
    dialogMsg.color = ccBLACK;
    [dialog addChild: dialogMsg];
    
    
    float unit = dialog.contentSize.width/7.f;
    
    // add one or two buttons, as needed
    CCMenuItemSprite *opt1Button = [CCMenuItemSprite itemWithNormalSprite:spriteOk
                                                           selectedSprite:[CCSprite spriteWithTexture:spriteOk.texture]
                                                                    block:^(id sender) {
                                                                        [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt1Block];
                                                                    }];
    opt1Button.anchorPoint = ccp(0.5, 0.5);
    opt1Button.position = ccp(spriteKo?2*unit:3.5*unit, 0);
    
    // create second button, if requested
    CCMenuItemSprite *opt2Button = nil;
    if (spriteKo) {
        
        opt2Button = [CCMenuItemSprite itemWithNormalSprite:spriteKo
                                             selectedSprite:[CCSprite spriteWithTexture:spriteKo.texture]
                                                      block:^(id sender) {
                                                          [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt2Block];
                                                      }];
        opt2Button.anchorPoint = ccp(0.5, 0.5);
        opt2Button.position = ccp(5*unit, 0);
    }
    
    CCMenu *menu = [CCMenu menuWithItems:opt1Button, opt2Button, nil];
    menu.position = CGPointZero;
    
    [dialog addChild:menu];
    [coverLayer addChild:dialog z:0];
    
    // open the dialog with a nice popup-effect
    
    id fadeIn = [CCFadeIn actionWithDuration:0.1];
    id scale1 = [CCSpawn actions:fadeIn, [CCScaleTo actionWithDuration:0.15 scale:1.1], nil];
    id scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.9];
    id scale3 = [CCScaleTo actionWithDuration:0.05 scale:1.0];
    id pulse = [CCSequence actions:scale1, scale2, scale3, nil];
    [dialog runAction:pulse];
}

+ (void) Ask: (NSString *) question onLayer: (CCLayer *) layer yesBlock: (void(^)())yesBlock noBlock: (void(^)())noBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Yes" withOpt1Block:yesBlock andOpt2:@"No" withOpt2Block:noBlock];
}

+ (void) Confirm: (NSString *) question onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock cancelBlock: (void(^)())cancelBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:@"Cancel" withOpt2Block:cancelBlock];
}

+ (void) Tell: (NSString *) statement onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock {
    [self ShowAlert:statement onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:nil withOpt2Block:nil];
}

@end