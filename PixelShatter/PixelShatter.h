/*
 * PixelShatter
 *
 * Copyright (c) 2013 Michael Burford  (http://www.headlightinc.com)
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
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//Will do up to 32x32 blocks...
//could be dynamic arrays if you have different sizes, but this is the size I needed for them all
#define PIXSHATTER_VERTEX_MAX	1024

//Some things to help handle boxes easier
typedef struct _BoxVertices {
	CGPoint		pt1;
	CGPoint		pt2;
	CGPoint		pt3;
	CGPoint		pt4;
	CGPoint		pt5;
	CGPoint		pt6;
} BoxVertices;

static inline BoxVertices
box(CGPoint	pt1, CGPoint pt2) {
	BoxVertices b;
	b.pt1 = pt1;
	b.pt2 = ccp(pt1.x, pt2.y);
	b.pt3 = pt2;
	b.pt4 = pt1;
	b.pt5 = pt2;
	b.pt6 = ccp(pt2.x, pt1.y);
	return b;
}

static inline BoxVertices
box4(CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4) {
	BoxVertices b;
	b.pt1 = pt1;
	b.pt2 = pt2;
	b.pt3 = pt3;
	b.pt4 = pt1;
	b.pt5 = pt3;
	b.pt6 = pt4;
	return b;
}

typedef struct _BoxColors {
	ccColor4B		c1;
	ccColor4B		c2;
	ccColor4B		c3;
	ccColor4B		c4;
	ccColor4B		c5;
	ccColor4B		c6;
} BoxColors;


@interface PixelShatter : CCSprite {
	BoxVertices			vertices[PIXSHATTER_VERTEX_MAX];
    BoxVertices			texCoords[PIXSHATTER_VERTEX_MAX];
    BoxColors			colorArray[PIXSHATTER_VERTEX_MAX];
	NSInteger			numVertices;
	
	float				adelta[PIXSHATTER_VERTEX_MAX];
	CGPoint				vdelta[PIXSHATTER_VERTEX_MAX];
	CGPoint				centerPt[PIXSHATTER_VERTEX_MAX];

    Boolean             active[PIXSHATTER_VERTEX_MAX];
    CGPoint             gravity;

	Boolean				radial;
	Boolean				doneFirstUpdate;
	float				shatterSpeedVar, shatterRotVar;
    NSInteger           subShatterPercent;
    NSInteger           delayPercent;
}
@property (assign) NSInteger	subShatterPercent;
@property (assign) CGPoint      gravity;

+ (id)shatterWithSprite:(CCSprite*)sprite piecesX:(NSInteger)piecesX piecesY:(NSInteger)piecesY speed:(float)speedVar rotation:(float)rotVar radial:(Boolean)radial;
- (id)initWithSprite:(CCSprite*)sprite piecesX:(NSInteger)piecesX piecesY:(NSInteger)piecesY speed:(float)speedVar rotation:(float)rotVar radial:(Boolean)radialIn;

@end

