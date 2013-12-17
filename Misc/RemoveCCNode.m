//
//  RemoveNode.m
//  oBulle
//
//  Created by Looky on 16/12/2013.
//  Copyright (c) 2013 David DUTOUR. All rights reserved.
//

#import "RemoveCCNode.h"

@implementation RemoveCCNode

-(void) startWithTarget:(id)target {
    [super startWithTarget:target];
    [((CCNode *)_target) removeFromParentAndCleanup:YES];
}

@end
