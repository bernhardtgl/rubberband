//
//  GroceryItem.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/10/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemQuantity.h"

@class GroceryItemsTable;
@class Aisle;

@interface GroceryItem : NSObject <NSCoding, ItemQuantityDelegate>
{
	GroceryItemsTable* ownerTable;
	NSString* uid;
	NSString* aisleUid;
	NSString* name;	
	Aisle* aisle;	

	ItemQuantity* qtyNeeded;
	ItemQuantity* qtyUsual;

	BOOL haveItem;
}
- (id) initWithUid: (NSString*)uid;

- (void) setOwnerTable:(GroceryItemsTable*)owner;
- (NSComparisonResult)compareGroceryItem:(GroceryItem*)item;

- (NSMutableArray*)recipesContainingItem;

// property methods
- (NSString *) uid;
- (NSString*) aisleUid;
- (Aisle*) aisle;
- (void) setAisle:(Aisle*)newAisle;
- (NSString*) name;
- (void) setName:(NSString*)newName;

- (ItemQuantity*) qtyNeeded;
- (ItemQuantity*) qtyUsual;

- (BOOL) haveItem;
- (void) setHaveItem:(BOOL)newValue;
- (BOOL) needItem; // combination of qty > 0 and don't have

@end
