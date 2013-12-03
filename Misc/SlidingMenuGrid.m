
#import "SlidingMenuGrid.h"
#import "PRPDebug.h"

@implementation SlidingMenuGrid

@synthesize iCurrentPage = _iCurrentPage, iPageCount = _iPageCount;

CGSize winSize;

-(void) buildGrid:(int)cols rows:(int)rows {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    _cols = cols;
    _rows = rows;
    _iPageCount = 0;

	int col = 0, row = 0;
	for (CCMenuItem* item in self.children) {
		// Calculate the position of our menu item. 
		item.position = CGPointMake(self.position.x + col * padding.x + (_iPageCount * winSize.width), 
                                    self.position.y - row * padding.y);
		
		// Increment our positions for the next item(s).
        ++col;
		if (col == cols) {
			col = 0;
            ++row;
            if(row == rows) {
                col = 0;
                row = 0;
                _iPageCount++;
            }
		}
	}
    
    if ([self.children count]%(_cols*_rows)>0) {
        _iPageCount++;
    }
}

-(void) buildGridVertical:(int)cols rows:(int)rows {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    	
	int col = 0, row = 0;
	for (CCMenuItem* item in self.children) {
		// Calculate the position of our menu item. 
		item.position = CGPointMake(self.position.x + col * padding.x , 
                                    self.position.y - row * padding.y + (_iPageCount * winSize.height));
		
		// Increment our positions for the next item(s).
        ++col;
		if (col == cols) {
			col = 0;
            ++row;
			if(row == rows ) {
				col = 0;
				row = 0;
			}
		}
	}
    _iPageCount = [self.children count]/(_cols*_rows);
    if ([self.children count]%(_cols*_rows)>0) {
        _iPageCount++;
    }
}

- (CGPoint) GetPositionOfCurrentPage {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    	
	return (bVerticalPaging) ?
    CGPointMake(menuOrigin.x,menuOrigin.y-(_iCurrentPage*winSize.height))
    : CGPointMake((menuOrigin.x-(_iCurrentPage*winSize.width)),menuOrigin.y);
}

- (CGPoint) GetPositionOfCurrentPageWithOffset:(float)offset {
	return (bVerticalPaging) ?
	CGPointMake(menuOrigin.x,menuOrigin.y-(_iCurrentPage*winSize.height)+offset)
	: CGPointMake((menuOrigin.x-(_iCurrentPage*winSize.width)+offset),menuOrigin.y);
}

// Run the action necessary to slide the menu grid to the current page.
-(void) moveToCurrentPage {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    float time = 8.f*sqrtf(fabsf(iOldPage-_iCurrentPage))/sqrtf((1+fabsf(fMoveDelta)));
    if (fMoveDelta==0) {
        time = 0.5+sqrtf(fabsf(iOldPage-_iCurrentPage));
    }
    
	id action = [CCMoveTo actionWithDuration:(time*0.40) position:[self GetPositionOfCurrentPage]];
	[self runAction:action];
}

-(CCMenuItem*) GetItemWithinTouch:(UITouch*)touch {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	// Get the location of touch.
	CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
	
	// Parse our menu items and see if our touch exists within one.
	for (CCNode *item in [self children]) {
        if ([item isKindOfClass:[CCMenuItem class]]) {
            CGPoint local = [item convertToNodeSpace:touchLocation];
		
            CGRect r = [item boundingBox];
            r.origin = CGPointZero;
            
            // If the touch was within this item. Return the item.
            if (CGRectContainsPoint(r, local)) {
                return (CCMenuItem *)item;
            }
        }
	}
	
	// Didn't touch an item.
	return nil;
}

-(void) registerWithTouchDispatcher {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
    //the swallowsTouches has to be NO, otherwise HUD layer won't get any touch events
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	// Convert and store the location the touch began at.
	touchOrigin = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	// If we weren't in "waiting" state bail out.
	if (state != kCCMenuStateWaiting) {
		return NO;
	}
	
	// Activate the menu item if we are touching one.
	selectedItem = [self GetItemWithinTouch:touch];
    if ([selectedItem isKindOfClass:[CCMenuItem class]])
        [selectedItem selected];
	
	// Only track touch if we are either in our menu system or dont care if they are outside of the menu grid.
	if (!bSwipeOnlyOnMenu || (bSwipeOnlyOnMenu && selectedItem) ) {
		state = kCCMenuStateTrackingTouch;
		return YES;
	}
	
	return NO;
}

// Touch has ended. Process sliding of menu or press of menu item.
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	// User has been sliding the menu.
	if( bMoving ) {
		bMoving = false;
		
		// Do we have multiple pages?
		if( _iPageCount > 1 && (fMoveDeadZone < abs(fMoveDelta))) {
			// Are we going forward or backward?
			bool bForward = (fMoveDelta < 0) ? true : false;
			
			// Do we have a page available?
			if(bForward && (_iPageCount>_iCurrentPage+1)) {
				// Increment currently active page.
                iOldPage = _iCurrentPage;
				_iCurrentPage++;
			}
			else if(!bForward && (_iCurrentPage > 0)) {
				// Decrement currently active page.
                iOldPage = _iCurrentPage;
				_iCurrentPage--;
			}
		}
        
        // fix bug with selected icon stay in selected mode when scrolling to another page
        [selectedItem unselected]; 
        
		// Start sliding towards the current page.
		[self moveToCurrentPage];
		
	}
	// User wasn't sliding menu and simply tapped the screen. Activate the menu item.
	else {
		[selectedItem unselected];
		[selectedItem activate];
	}
    
	// Back to waiting state.
	state = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	[selectedItem unselected];
	
	state = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	// Calculate the current touch point during the move.
	touchStop = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
	// Distance between the origin of the touch and current touch point.
	fMoveDelta = (bVerticalPaging) ? (touchStop.y - touchOrigin.y) : (touchStop.x - touchOrigin.x);
    
	// Set our position.
	[self setPosition:[self GetPositionOfCurrentPageWithOffset:fMoveDelta]];
	bMoving = true;
}

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	return [[self alloc] initWithArray:items cols:cols rows:rows position:pos padding:pad verticalPaging:false];
}

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad verticalPages:(bool)vertical {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	return [[self alloc] initWithArray:items cols:cols rows:rows position:pos padding:pad verticalPaging:vertical];
}

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad background:(NSString *)backgroundImage useButton:(BOOL)useButton  verticalPages:(bool)vertical {
    PRPLog(@"[%@ %@] Start", CLS_STR, CMD_STR);
    
	return [[self alloc] initWithArray:items cols:cols rows:rows position:pos padding:pad background:backgroundImage useButton:useButton verticalPaging:vertical];
}


-(id) initWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad verticalPaging:(bool)vertical {
    return [self initWithArray:items cols:cols rows:rows position:pos padding:pad background:nil useButton:NO verticalPaging:vertical];
}

-(id) initWithArray:(NSMutableArray*)items
               cols:(int)cols
               rows:(int)rows
           position:(CGPoint)pos
            padding:(CGPoint)pad
         background:(NSString *)backgroundImage
          useButton:(BOOL) useButton
     verticalPaging:(bool)vertical {
    
    iOldPage = 0;
    
	if ((self = [super init])) {
        [self setTouchEnabled:YES];
        
        winSize = [[CCDirector sharedDirector] winSize];
        _useButton = useButton;
        
		int z = 1;
		for (id item in items) {
			[self addChild:item z:z tag:z];
			++z;
		}
		
		padding = pad;
		_iCurrentPage = 0;
		bMoving = false;
		bSwipeOnlyOnMenu = false;
		menuOrigin = pos;
		fMoveDeadZone = 10;
		bVerticalPaging = vertical;
        
		(bVerticalPaging) ? [self buildGridVertical:cols rows:rows] : [self buildGrid:cols rows:rows];
        

        
        if (backgroundImage) {
            // TODO : Positionner une image par page
            if (bVerticalPaging) {
                _background = [CCScale9Sprite spriteWithFile:backgroundImage];
                _background.preferredSize = CGSizeMake(cols * padding.x, rows * padding.y*_iPageCount);
                _background.anchorPoint = ccp(0,0);
                _background.position = ccp(-padding.x/2, (0.5-rows)*padding.y);
            }
            else {
                _background = [CCScale9Sprite spriteWithFile:backgroundImage];
                _background.preferredSize = CGSizeMake(cols * padding.x*_iPageCount , rows * padding.y);
                _background.anchorPoint = ccp(0,0);
                _background.position = ccp(-padding.x/2, (0.5-rows)*padding.y);
            }
            
            [self addChild:_background z:-1];
        }
		self.position = menuOrigin;
        
        if (_useButton) {
            _OKButton = [CCMenuItemImage itemWithNormalImage:@"stop.png" selectedImage:@"stop.png"];
            //[CC spriteWithFile:@"stop.png"];
            _OKButton.anchorPoint = ccp(0.5, 0.5);
            [self addChild:_OKButton z:INT_MAX];
        }
    }
	
	return self;
}

-(void) visit {
	[super visit];//< Will draw after glPopScene.
	
    if (_useButton) {
        float witdh = padding.x*(_cols);
        float x = _iCurrentPage*witdh;
        float y = -1.0f*_rows*padding.y;
        CGPoint okPosition = ccp(x+5*witdh/8.0f, y); // ccp(x+2*witdh/8.0f, y);
        _OKButton.position = okPosition;
    }
    
    int totalScreens = _iPageCount;
    CGPoint pagesIndicatorPosition;
    if (bVerticalPaging)
        pagesIndicatorPosition = ccp(self.position.y - 0.95f * _rows * padding.x, 0.5f * self.contentSize.height);
    else
        pagesIndicatorPosition = ccp(0.5f * self.contentSize.width, self.position.y - 0.90f * _rows * padding.y);
    ccColor4B pagesIndicatorNormalColor = ccc4(0x96,0x96,0x96,0xFF);
    ccColor4B pagesIndicatorSelectedColor = ccc4(0xFF,0xFF,0xFF,0xFF);
	
    
    // Prepare Points Array
    CGFloat n = (CGFloat)totalScreens; //< Total points count in CGFloat.
    CGFloat pY = pagesIndicatorPosition.y;
    CGFloat d = 16.0f; //< Distance between points.
    CGPoint points[totalScreens];
    for (int i=0; i < totalScreens; ++i) {
        if (bVerticalPaging)
            points[i] = ccp (pY, pagesIndicatorPosition.y + d * ( (CGFloat)i - 0.5f*(n-1.0f) ));
        else
            points[i] = ccp (pagesIndicatorPosition.x + d * ( (CGFloat)i - 0.5f*(n-1.0f) ), pY);
    }
    
    ccGLBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    ccPointSize( 3.0 * CC_CONTENT_SCALE_FACTOR() );
    
    // Draw Gray Points
    ccDrawColor4B(pagesIndicatorNormalColor.r,
                  pagesIndicatorNormalColor.g,
                  pagesIndicatorNormalColor.b,
                  pagesIndicatorNormalColor.a);
    ccDrawPoints( points, totalScreens );
    
    // Draw White Point for Selected Page
    ccDrawColor4B(pagesIndicatorSelectedColor.r,
                  pagesIndicatorSelectedColor.g,
                  pagesIndicatorSelectedColor.b,
                  pagesIndicatorSelectedColor.a);
    ccDrawPoint(points[_iCurrentPage]);
    
    // Restore GL Values
    ccPointSize(1.0f);
    //		glDisable(GL_POINT_SMOOTH);
    
}

@end
