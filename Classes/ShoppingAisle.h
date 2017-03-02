//
//  ShoppingAisle.h
//  Interface definition for a shopping aisle object which
//	associates an aisle with the list of grocery items 
//	needed from that aisle.
//
//  Created by Craig on 4/10/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aisle.h"
#import "GroceryItemsTable.h"


@interface ShoppingAisle : NSObject 
{
	Aisle* aisle;
	NSMutableArray* aisleItems;
}
- (id) initWithAisle: (Aisle*)aisle;

- (Aisle*) aisle;
- (NSMutableArray*) aisleItems;

- (int) getIndexForItem: (GroceryItem*) item;

@end
