//
// Based on "SlidingMenuGrid" work by Brandon Reynolds
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScale9Sprite.h"

@protocol SlidingMenuExit <NSObject>

-(void) quitMenu:(NSArray *) items;

@end

@interface SlidingMenuGrid : CCLayer {
	tCCMenuState state; // State of our menu grid. (Eg. waiting, tracking touch, cancelled, etc)
	CCMenuItem *selectedItem; // Menu item that was selected/active.
	
    int _cols;
    int _rows;
    
    CCScale9Sprite *_background;
    
    CCMenuItemImage *_OKButton;
    BOOL _useButton;
    
    
	CGPoint padding; // Padding in between menu items. 
	CGPoint menuOrigin; // Origin position of the entire menu grid.
	CGPoint touchOrigin; // Where the touch action began.
	CGPoint touchStop; // Where the touch action stopped.
	
	int _iPageCount; // Number of pages in this grid.
	int _iCurrentPage; // Current page of menu items being viewed.
    int iOldPage; // Ancienne Current page
	
	bool bMoving; // Is the grid currently moving?
	bool bSwipeOnlyOnMenu; // Causes swiping functionality to only work when siping on top of the menu items instead of entire screen.
	bool bVerticalPaging; // Disabled by default. Allows for pages to be scrolled vertically instead of horizontal.
    
	float fMoveDelta; // Distance from origin of touch and current frame.
	float fMoveDeadZone; // Amount they need to slide the grid in order to move to a new page.
}

@property int iCurrentPage;
@property (readonly) int iPageCount;

-(void) moveToCurrentPage;

-(id) initWithArray:(NSMutableArray*)items 
               cols:(int)cols 
               rows:(int)rows 
           position:(CGPoint)pos 
            padding:(CGPoint)pad 
     verticalPaging:(bool)vertical;

-(id) initWithArray:(NSMutableArray*)items
               cols:(int)cols
               rows:(int)rows
           position:(CGPoint)pos
            padding:(CGPoint)pad
         background:(NSString *)backgroundImage
          useButton:(BOOL)useButton
     verticalPaging:(bool)vertical;

+(id) menuWithArray:(NSMutableArray*)items 
               cols:(int)cols 
               rows:(int)rows 
           position:(CGPoint)pos 
            padding:(CGPoint)pad;

+(id) menuWithArray:(NSMutableArray*)items
               cols:(int)cols
               rows:(int)rows
           position:(CGPoint)pos
            padding:(CGPoint)pad
            verticalPages:(bool)vercital;

+(id) menuWithArray:(NSMutableArray*)items cols:(int)cols rows:(int)rows position:(CGPoint)pos padding:(CGPoint)pad background:(NSString *)backgroundImage useButton:(BOOL)useButton  verticalPages:(bool)vertical;


@end
