//
//  ShopViewDataSource.h
//  Interface definition for the shopping list view.  This data model
//	object filters and organizes ailes and grocery items to be
//	viewed in the ShopViewController.
//
//  Created by Craig on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import "ShoppingAisle.h"

@protocol ShopViewDataSourceDelegate <NSObject>
- (void) didDeleteLastItem;
@end

@interface ShopViewDataSource : NSObject <UITableViewDataSource>
{
	id <ShopViewDataSourceDelegate> delegate;

	Database* myDatabase;
	NSMutableArray* aislesArray;
	NSMutableDictionary* aislesIndex;
	
	// special well-known shopping aisles		
	ShoppingAisle* haveShoppingAisle;
	ShoppingAisle* noneShoppingAisle;
}
- (id <ShopViewDataSourceDelegate>)delegate;
- (void)setDelegate:(id <ShopViewDataSourceDelegate>)newDelegate;

- (id) initWithDatabase: (Database*)database;
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (void) rebuildShoppingList;
- (void) checkout;
- (void) clearList;

- (int) getShoppingAisleIndexForGroceryItem:(GroceryItem*)item;

- (NSUInteger) shoppingAisleCount;
- (ShoppingAisle*) shoppingAisleAtIndex:(NSInteger)index;
- (ShoppingAisle*) shoppingAisleForUid: (NSString*)uid;
- (ShoppingAisle*) noneShoppingAisle;
- (ShoppingAisle*) haveShoppingAisle;
- (void) addShoppingAisle:(ShoppingAisle*)shoppingAisleToAdd;
- (ShoppingAisle*) removeShoppingAisleAtIndex:(NSInteger)index;

- (GroceryItem*)groceryItemAtIndexPath:(NSIndexPath *)indexPath;  
- (GroceryItem*)removeGroceryItemAtIndexPath:(NSIndexPath*)indexPath;

@end
