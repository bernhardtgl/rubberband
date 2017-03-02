//
//  GroceryItems.h
//  Interface definition for a collection of grocery items.
//
//  Created by Craig on 3/30/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryItem.h"
@class Aisle;

@protocol GroceryItemsTableDelegate <NSObject>
- (void)groceryItemDidChange:(GroceryItem*)item;
- (void)groceryItemWillDelete:(GroceryItem*)item;
@end

@interface GroceryItemsTable : NSObject
{
    id <GroceryItemsTableDelegate> delegate;
	NSMutableArray* itemsArray;
	NSMutableDictionary* itemsUidIndex;
	bool isDirty;
	
	NSUInteger countOfNeededItems;
}
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (void)signalItemChanged:(GroceryItem*)item;

- (bool) isDirty;
- (void) markDirty;
- (NSUInteger) count;
- (void) addItem:(GroceryItem*)newItem;
- (GroceryItem*) itemAtIndex:(int)index;
- (void) removeItem:(GroceryItem*)anItem;

- (GroceryItem*) itemForUid: (NSString*)uid;
- (NSArray*) allItems;

// used for deleting aisles, to see how many times the aisle is in use
// and to clean up the related aisles back to nil
- (NSUInteger) countItemsHavingAisle:(Aisle*)aisle;
- (void) resetItemsAisleToNone:(Aisle*)aisle;

// should only be called by one of the items when its need/have state changes
- (void) updateNeedCount:(int)byAmount;

// the running count of need items for the badge
- (NSUInteger) countOfNeededItems;

@end
