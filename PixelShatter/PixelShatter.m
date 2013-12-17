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

#import "PixelShatter.h"


@implementation PixelShatter

@synthesize subShatterPercent;
@synthesize gravity;

+ (id)shatterWithSprite:(CCSprite*)sprite piecesX:(NSInteger)piecesX piecesY:(NSInteger)piecesY speed:(float)speedVar rotation:(float)rotVar radial:(Boolean)radial {
    return [[self alloc] initWithSprite:sprite piecesX:piecesX piecesY:piecesY speed:speedVar rotation:rotVar radial:radial];
}
- (id)initWithSprite:(CCSprite*)sprite piecesX:(NSInteger)piecesX piecesY:(NSInteger)piecesY speed:(float)speedVar rotation:(float)rotVar radial:(Boolean)radialIn {
    self = [super init];
    if (self) {
        // Initialization code here.
		radial = radialIn;
        shatterSpeedVar = speedVar;
        shatterRotVar = rotVar;
        subShatterPercent = 0;
		[self shatterSprite:sprite piecesX:piecesX piecesY:piecesY speed:speedVar rotation:rotVar radial:radialIn];
        //[self setOpacityModifyRGB:YES];
		
		[self scheduleUpdate];
    }
    
    return self;
}

- (void)shatterSprite:(CCSprite*)sprite piecesX:(NSInteger)piecesX piecesY:(NSInteger)piecesY speed:(float)speedVar rotation:(float)rotVar radial:(Boolean)radialIn {
	[self setTexture:sprite.texture];
	
	//Sizey thingys
	float	texX = sprite.textureRect.origin.x/sprite.texture.contentSize.width;
	float	texY = sprite.textureRect.origin.y/sprite.texture.contentSize.height;
	float	wid = sprite.textureRect.size.width/sprite.texture.contentSize.width;
	float	hgt = sprite.textureRect.size.height/sprite.texture.contentSize.height;
	
	float	pieceXsize = (sprite.textureRect.size.width/(float)piecesX);
	float	pieceYsize = (sprite.textureRect.size.height/(float)piecesY);
	float	texXsize = (wid/(float)piecesX);
	float	texYsize = (hgt/(float)piecesY);
    
    texY = texY + hgt;
	
	_contentSize = sprite.contentSize;
	
	ccColor4B		color4 = {self.color.r, self.color.g, self.color.b, self.opacity };
	BoxColors		boxColor4 = { color4, color4, color4, color4, color4, color4 };

	numVertices = 0;
	for (float x=0; x<piecesX; x++) {
		for (float y=0; y<piecesY; y++) {
			if (numVertices>=PIXSHATTER_VERTEX_MAX-1) {
				NSLog(@"NeedABiggerArray!");
				return;
			}
			
			vdelta[numVertices] =  ccp(CCRANDOM_MINUS1_1()*speedVar, CCRANDOM_MINUS1_1()*speedVar);
			adelta[numVertices] = CCRANDOM_MINUS1_1()*rotVar;
			colorArray[numVertices] = boxColor4;
            active[numVertices] = YES;

			vertices[numVertices] = box(ccp(x*pieceXsize, y*pieceYsize), ccp((x+1)*pieceXsize, (y+1)*pieceYsize));
			texCoords[numVertices] = box(ccp(texX + x*texXsize, texY - y*texYsize), ccp(texX + (x+1)*texXsize, texY - (y+1)*texYsize));
			centerPt[numVertices] = ccp((x+0.5)*pieceXsize, (y+0.5)*pieceYsize);
			numVertices++;
		}
	}
}

//It can break a square into 4 smaller squares...
- (void)subShatter {
	int		i = rand()%numVertices;
	
	if (numVertices+3>=PIXSHATTER_VERTEX_MAX-1) return;
    
    BoxVertices     t = vertices[i];
    CGPoint         l = ccp((t.pt1.x+t.pt2.x)/2, (t.pt1.y+t.pt2.y)/2);
    CGPoint         r = ccp((t.pt6.x+t.pt5.x)/2, (t.pt6.y+t.pt5.y)/2);
    CGPoint         u = ccp((t.pt1.x+t.pt6.x)/2, (t.pt1.y+t.pt6.y)/2);
    CGPoint         b = ccp((t.pt2.x+t.pt3.x)/2, (t.pt2.y+t.pt3.y)/2);
    CGPoint         c = ccp((t.pt1.x+t.pt3.x)/2, (t.pt1.y+t.pt3.y)/2);    
    BoxVertices     v0 = box4(t.pt1, l, c, u);
    BoxVertices     v1 = box4(l, t.pt2, b, c);
    BoxVertices     v2 = box4(u, c, r, t.pt6);
    BoxVertices     v3 = box4(c, b, t.pt3, r);
    
    t = texCoords[i];
    l = ccp((t.pt1.x+t.pt2.x)/2, (t.pt1.y+t.pt2.y)/2);
    r = ccp((t.pt6.x+t.pt5.x)/2, (t.pt6.y+t.pt5.y)/2);
    u = ccp((t.pt1.x+t.pt6.x)/2, (t.pt1.y+t.pt6.y)/2);
    b = ccp((t.pt2.x+t.pt3.x)/2, (t.pt2.y+t.pt3.y)/2);
    c = ccp((t.pt1.x+t.pt3.x)/2, (t.pt1.y+t.pt3.y)/2);
    BoxVertices     t0 = box4(t.pt1, l, c, u);
    BoxVertices     t1 = box4(l, t.pt2, b, c);
    BoxVertices     t2 = box4(u, c, r, t.pt6);
    BoxVertices     t3 = box4(c, b, t.pt3, r);
	   
	//Update the original one.
	vertices[i] = v0;
	centerPt[i] = ccp((v0.pt1.x + v0.pt3.x)/2.0, (v0.pt1.y + v0.pt3.y)/2.0);
	texCoords[i] = t0;
	
	//Shattering again changes it's rotation & direction
	CGPoint		originalVDelta = vdelta[i];
	if (radial) {
		vdelta[i] = ccp(originalVDelta.x + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0, originalVDelta.y + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0);
	} else {
		vdelta[i] = ccp(CCRANDOM_MINUS1_1()*shatterSpeedVar, CCRANDOM_MINUS1_1()*shatterSpeedVar);
	}
	adelta[i] = CCRANDOM_MINUS1_1()*shatterRotVar;
	
	//Shift up to insert the new one in the next spot.
	//So overlapping things look right--ones behind break and don't jump forward.
	numVertices += 3;
	for (int j=numVertices-1; j>i+3; j--) {
		vdelta[j] = vdelta[j-3];
		adelta[j] = adelta[j-3];
		colorArray[j] = colorArray[j-3];
		
		vertices[j] = vertices[j-3];
		centerPt[j] = centerPt[j-3];
		texCoords[j] = texCoords[j-3];
	}
	
	//And add the new other 3 squares...
	vertices[i+1] = v1;
	centerPt[i+1] = ccp((v1.pt1.x + v1.pt3.x)/2.0, (v1.pt1.y + v1.pt3.y)/2.0);
	texCoords[i+1] = t1;
	vertices[i+2] = v2;
	centerPt[i+2] = ccp((v2.pt1.x + v2.pt3.x)/2.0, (v2.pt1.y + v2.pt3.y)/2.0);
	texCoords[i+2] = t2;
	vertices[i+3] = v3;
	centerPt[i+3] = ccp((v3.pt1.x + v3.pt3.x)/2.0, (v3.pt1.y + v3.pt3.y)/2.0);
	texCoords[i+3] = t3;
	
	if (radial) {
		vdelta[i+1] = ccp(originalVDelta.x + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0, originalVDelta.y + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0);
		vdelta[i+2] = ccp(originalVDelta.x + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0, originalVDelta.y + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0);
		vdelta[i+3] = ccp(originalVDelta.x + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0, originalVDelta.y + CCRANDOM_MINUS1_1()*shatterSpeedVar/4.0);
	} else {
		vdelta[i+1] = ccp(CCRANDOM_MINUS1_1()*shatterSpeedVar, CCRANDOM_MINUS1_1()*shatterSpeedVar);
		vdelta[i+2] = ccp(CCRANDOM_MINUS1_1()*shatterSpeedVar, CCRANDOM_MINUS1_1()*shatterSpeedVar);
		vdelta[i+3] = ccp(CCRANDOM_MINUS1_1()*shatterSpeedVar, CCRANDOM_MINUS1_1()*shatterSpeedVar);
	}
	adelta[i+1] = CCRANDOM_MINUS1_1()*shatterRotVar;
	adelta[i+2] = CCRANDOM_MINUS1_1()*shatterRotVar;
	adelta[i+3] = CCRANDOM_MINUS1_1()*shatterRotVar;
	colorArray[i+1] = colorArray[i];
	colorArray[i+2] = colorArray[i];
	colorArray[i+3] = colorArray[i];
}

- (void)updateColor {
	//Update the color array...
	ccColor4B		color4 = {self.color.r, self.color.g, self.color.b, self.opacity };
	BoxColors		boxColor4 = { color4, color4, color4, color4, color4, color4 };
	for (int i=0; i<numVertices; i++) {
		colorArray[i] = boxColor4;
	}
}

- (void)update:(ccTime)delta {
	//Really for slow-motion...
	//So [CCScheduler sharedScheduler].timeScale works
	delta *= 60.0;
	
	//FIRST one always use the correct step, in case creating this made a long calculation, so this won't jump.  (BounceBash Menu fix)
	if (!doneFirstUpdate) {
		doneFirstUpdate = YES;
		delta = 1.0;  //1/60th sec *60
	}
	
	//Move all the triangles.
	for (int i = 0; i<numVertices; i++) {
        CGPoint	vd = ccp(vdelta[i].x*delta, vdelta[i].y*delta);
        float	ad = adelta[i]*delta;
        
        vertices[i].pt1 = ccpAdd(vertices[i].pt1, vd);
        vertices[i].pt2 = ccpAdd(vertices[i].pt2, vd);
        vertices[i].pt3 = ccpAdd(vertices[i].pt3, vd);
        vertices[i].pt4 = ccpAdd(vertices[i].pt4, vd);
        vertices[i].pt5 = ccpAdd(vertices[i].pt5, vd);
        vertices[i].pt6 = ccpAdd(vertices[i].pt6, vd);
        centerPt[i] = ccpAdd(centerPt[i], vd);
        
        //vertices[i] = box(ccpRotateByAngle(vertices[i].pt1, centerPt[i], ad), ccpRotateByAngle(vertices[i].pt3, centerPt[i], ad));
        vertices[i].pt1 = ccpRotateByAngle(vertices[i].pt1, centerPt[i], ad);
        vertices[i].pt2 = ccpRotateByAngle(vertices[i].pt2, centerPt[i], ad);
        vertices[i].pt3 = ccpRotateByAngle(vertices[i].pt3, centerPt[i], ad);
        vertices[i].pt4 = ccpRotateByAngle(vertices[i].pt4, centerPt[i], ad);
        vertices[i].pt5 = ccpRotateByAngle(vertices[i].pt5, centerPt[i], ad);
        vertices[i].pt6 = ccpRotateByAngle(vertices[i].pt6, centerPt[i], ad);
        
        vdelta[i] = ccpAdd(vdelta[i], gravity);
	}

    delayPercent++;
    if (delayPercent==250) {
        for (int i=0; i<numVertices; i++) {
            active[i] = YES;
        }
    }
    
	if (arc4random()%100<subShatterPercent) [self subShatter];
}

- (void)draw {
	//Everything is the same for different OpenGL versions except the draw code...
#if COCOS2D_VERSION >= 0x00020000
	//OpenGL ES 2
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"PixelShatter - draw");
	
	CC_NODE_DRAW_SETUP();
	
	ccGLBlendFunc(_blendFunc.src, _blendFunc.dst);
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, colorArray);
	
	ccGLBindTexture2D([_texture name]);
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(GL_TRIANGLES, 0, numVertices*6);
	
	CHECK_GL_ERROR_DEBUG();
	
	CC_INCREMENT_GL_DRAWS(1);
	
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"PixelShatter - draw");

#else
	//OpenGL ES 1
	CC_ENABLE_DEFAULT_GL_STATES();
	
	glTexCoordPointer(2, osGL_FLOAT, 0, texCoords);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorArray);
	
	if (shadowed) {
		glBindTexture(GL_TEXTURE_2D, shadowTexture.name);
		glVertexPointer(2, osGL_FLOAT, 0, shadowVertices);
		glDrawArrays(GL_TRIANGLES, 0, numVertices*3);
	}
    
    glBindTexture(GL_TEXTURE_2D, _texture.name);
	glVertexPointer(2, osGL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLES, 0, numVertices*3);
	
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	CC_ENABLE_DEFAULT_GL_STATES();
#endif
}

@end

