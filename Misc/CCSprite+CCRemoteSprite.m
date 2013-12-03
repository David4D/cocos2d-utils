//
// CCAsyncRemoteSprite.m
//
// Remote Async CCSprite for cocos2d using UIImageView+AFNetworking. 
// 
// Copyright (c) 2012 Leo Lou (https://github.com/l4u)
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
// TODO #import <objc/runtime.h>

@implementation CCSprite (CCRemoteSprite)

+ (id)spriteWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    return [[self alloc] initWithURLRequest:request placeholderTexture:nil];
}

+ (id)spriteWithURL:(NSURL *)url placeholderTexture:(CCTexture2D *)placeholderTexture {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    return [[self alloc] initWithURLRequest:request placeholderTexture:placeholderTexture];
}

+ (id)spriteWithURLRequest:(NSURLRequest *)request placeholderTexture:(CCTexture2D *)placeholderTexture  {
    return [[self alloc] initWithURLRequest:request placeholderTexture:placeholderTexture];
}


-(id) initWithURLRequest:(NSURLRequest *)request placeholderTexture:(CCTexture2D *)placeholderTexture {
	if( (self = [super init]) ) {
        // set texture as placeholderTexture
        CGRect rect = CGRectZero;
        rect.size = placeholderTexture.contentSize;
        [self setTexture:placeholderTexture];
        [self setTextureRect: rect];
        
        // download image or retrieve it from AFNetworking cache
        // set texture as the downloaded image
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURLRequest:request
                         placeholderImage:nil 
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      CCTexture2D *t = [[CCTextureCache sharedTextureCache] 
                                                        addCGImage:image.CGImage
                                                        forKey:[request.URL absoluteString]];
                                      
                                      CGRect rect = CGRectZero;
                                      rect.size = t.contentSize;
                                      [self setTexture:t];
                                      [self setTextureRect: rect];
                                  } 
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      CCLOG(@"Cannot download image in CCRemoteSprite %@", [error localizedDescription]);
                                  }
         ];
    }
    return self;
}
@end
