/*
 * ModalAlert - Customizable popup dialogs/alerts for Cocos2D
 *
 * For details, visit the Rombos blog:
 * http://rombosblog.wordpress.com/2012/02/28/modal-alerts-for-cocos2d/ 
 *
 * Copyright (c) 2012 Hans-Juergen Richstein, Rombos
 * http://www.rombos.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface ModalAlert : NSObject
+ (void) Ask: (NSString *) question onLayer: (CCLayer *) layer yesBlock: (void(^)())yesBlock noBlock: (void(^)())noBlock;
+ (void) Confirm: (NSString *) question onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock cancelBlock: (void(^)())cancelBlock;
+ (void) Tell: (NSString *) statement onLayer: (CCLayer *) layer okBlock: (void(^)())okBlock;
+ (void) ShowAlert: (NSString*) message onLayer: (CCLayer *) layer withSpriteOK: (CCSprite*)spriteOk withOKBlock: (void(^)())opt1Block withSpriteKO: (CCSprite*)spriteKo withKOBlock: (void(^)())opt2Block;
@end