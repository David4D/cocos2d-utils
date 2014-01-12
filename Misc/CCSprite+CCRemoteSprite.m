//
// CCSprite+CCRemoteSprite.h
//
// Remote Async update Texture CCSprite for cocos2d
//
// Copyright (c) 2013 David DUTOUR https://github.com/david4d/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "CCSprite+CCRemoteSprite.h"

@implementation CCSprite (CCRemoteSprite)

<<<<<<< HEAD

//	return [[[self alloc] initWithFile:filename] autorelease];

+(id) initWithURL:(NSURL *)imageURL placeholder:(NSString *)placeholder {
   return [[self alloc] initWithURL:imageURL placeholder:placeholder];
}

-(id) initWithURL:(NSURL *)imageURL placeholder:(NSString *)placeholder {
	NSAssert(imageURL != nil, @"Invalid imageURL for sprite");
   CGRect rect = CGRectZero;
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[imageURL absoluteString]];
	if( tex ) {
      rect.size = tex.contentSize;
      [self setTexture:tex];
      [self setTextureRect: rect];
	}
   else {
      tex = [[CCTextureCache sharedTextureCache] addImage:placeholder];
      rect.size = tex.contentSize;
      [self setTexture:tex];
      [self setTextureRect: rect];
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
         
         dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
               CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[imageURL absoluteString]];
               if (!tex) {
                  tex = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:[imageURL absoluteString]];
                  NSLog(@"%@ loaded.", [imageURL absoluteString]);
               }
               [self setTexture:tex];
            }
         });
      });
   }
   return [self initWithTexture:tex rect:rect];
}

/** update in background texute
 * @param imageURL Image URL * MUST BE * the same size of placeholder Image
 */
-(void) updateTextureWithURL:(NSURL *)imageURL {
   CGRect rect = CGRectZero;
   CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[imageURL absoluteString]];
   if (tex) {
      rect.size = tex.contentSize;
      [self setTexture:tex];
      [self setTextureRect: rect];
      
   }
   else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
         
         dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
               CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[imageURL absoluteString]];
               if (!tex) {
                  tex = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:[imageURL absoluteString]];
                  NSLog(@" text loaded from : %@", [imageURL absoluteString]);
               }
               [self setTexture:tex];
            }
         });
      });
   }
}


=======
/** update in background texute
 * @param imageURL Image URL * MUST BE * the same size of placeholder Image
 */
-(void) updateTextureWithURL:(NSURL *)imageURL {
   CGRect rect = CGRectZero;
   CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[imageURL absoluteString]];
   if (tex) {
      rect.size = tex.contentSize;
      [self setTexture:tex];
      [self setTextureRect: rect];
      
   }
   else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
         
         dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            UIImage *image = [UIImage imageWithData:imageData];
            CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addCGImage:image.CGImage forKey:[imageURL absoluteString]];
            [self setTexture:tex];
            NSLog(@" text loaded from : %@", [imageURL absoluteString]);
         });
      });
   }
}


>>>>>>> eb3eec311762c0f220f89ecd2d2c01be786d0537
@end
