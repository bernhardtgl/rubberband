//
//  ShopViewDataSource.m
//  Implementation of the shopping list view.  This data model
//	object filters and organizes ailes and grocery items to be
//	viewed in the ShopViewController.
//
//  Created by Craig on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ShopViewDataSource.h"
#import "RubberbandAppDelegate.h"  // TODO: craig, this is cheezy; fix it by putting the Database global somewhere else
#import "GroceryItem.h"
#import "ItemTableViewCell.h"
#import "ItemQuantity.h"

@implementation ShopViewDataSource

//
// Initializes a shopping list using the 
// global Database object.
//
- init
{
	return [self initWithDatabase:App_database];
}

//
// Initializes a new shopping list using the specified
// database and generate the shopping list data model
// that we will use to in the shop view.
//
- (id) initWithDatabase: (Database*)database;
{
	if (self = [super init])
	{
		myDatabase = database;
		aislesArray = [[NSMutableArray alloc] init];
		aislesIndex = [[NSMutableDictionary alloc] init];
		[self rebuildShoppingList]; //TODO: don't need to do this yet
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc ShopViewDataSource");
	[aislesArray removeAllObjects];
	[aislesIndex removeAllObjects];	
	[aislesArray release];
	[aislesIndex release];
	[haveShoppingAisle release];
	[noneShoppingAisle release];
    [super dealloc];
}

// 
// Description is what is returned when the object is printed to the log
//
- (NSString*) description
{
	return [aislesArray description];
}

//
// Enumeration method. Manditory method to support "for each" language constructs.
//
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [aislesArray countByEnumeratingWithState:state objects:stackbuf count:len];
}

//
// Generates the shopping list data model
// that we will use to in the shop view.
//
- (void) rebuildShoppingList
{
	// Clean up and dealloc prior to recreating collections
	[aislesArray removeAllObjects];
	[aislesIndex removeAllObjects];	
	[haveShoppingAisle release];
	[noneShoppingAisle release];	
 
	// create the special "none" aisle and add to the beginning of the collection
	Aisle* na = [[Aisle alloc] init];
	[na setName:NSLocalizedString(@"None",@"Unspecified aisle")];
	noneShoppingAisle = [[ShoppingAisle alloc] initWithAisle:na];
	[self addShoppingAisle:noneShoppingAisle];
				
	// add the real aisles		
	for (Aisle* eachAisle in [myDatabase aisles])
	{
		if (eachAisle != nil)
		{
			// create a new shopping aisle and add it to the collection
			ShoppingAisle* sa = [[ShoppingAisle alloc] initWithAisle:eachAisle];
			[self addShoppingAisle:sa];
		}
	}		
		
	// create the special "have" aisle and add to the end of the collection
	Aisle* ha = [[Aisle alloc] init];
	[ha setName:NSLocalizedString(@"Have", @"Name of 'aisle' for completed items.")];
	haveShoppingAisle = [[ShoppingAisle alloc] initWithAisle:ha];
	[self addShoppingAisle:haveShoppingAisle];
	
	// add the "needed" grocery items to the list
	for (GroceryItem* eachItem in [myDatabase groceryItems])
	{
		if (eachItem != nil)
		{
			if (eachItem.qtyNeeded.amount > 0)
			{
				if ([eachItem haveItem])
				{
					// add to the special "have" aisle
					[[haveShoppingAisle aisleItems] addObject:eachItem];
				}
				else
				{
					// add to the proper aisle
					NSString* aisleUid = [eachItem aisleUid];
					ShoppingAisle* shoppingAisle = [self shoppingAisleForUid:aisleUid];
					if (shoppingAisle != nil)
					{
						[[shoppingAisle aisleItems] addObject:eachItem];
					}
					else
					{
						[[noneShoppingAisle aisleItems] addObject:eachItem];
					}
				}
			}
		}
	}

	// get ready to sort by creating a descriptor
	NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"name"
										ascending:YES 
										selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray* descriptors = [NSArray arrayWithObject:nameDescriptor];
		
	// Filter and remove any empty shopping aisles
	// Sort the items in the remaining aisles alphabetically
	long i;
	for (i = [self shoppingAisleCount] - 1; i >= 0; i--)
	{
		ShoppingAisle* sa = [self shoppingAisleAtIndex:i];
		if ([[sa aisleItems] count] == 0)
		{
			[self removeShoppingAisleAtIndex:i];
		}
		else
		{
			[[sa aisleItems] sortUsingDescriptors:descriptors];
		}
	}
	[nameDescriptor release];
		
}

//
//	Performs a checkout action which resets the 
//	Grocery item's "haveItem" flag and "quantityNeeded".
//
- (void) checkout
{
	// reset items that we have
	for (GroceryItem* eachItem in [myDatabase groceryItems])
	{
		if ([eachItem haveItem])
		{
			eachItem.qtyNeeded.amount = 0;
			eachItem.qtyNeeded.type = eachItem.qtyUsual.type;
			eachItem.haveItem = NO;
		}
	}
	
	[self rebuildShoppingList];
}

- (void) clearList
{
	// reset items that we have, and that we need. For after emailing the list
	for (GroceryItem* eachItem in [myDatabase groceryItems])
	{
		if (eachItem.haveItem || (eachItem.qtyNeeded.amount != 0))
		{
			eachItem.qtyNeeded.amount = 0;
			eachItem.qtyNeeded.type = eachItem.qtyUsual.type;
			eachItem.haveItem = NO;
		}
	}
	
	[self rebuildShoppingList];
}

//
//	Find the index of the shopping aisle that contains the 
//	specified grocery item.  
//	Returns -1 if the item cannot be found.
//
- (int) getShoppingAisleIndexForGroceryItem:(GroceryItem*)item;
{
	int ret = -1;
	int i;
	for (i = 0; i < [aislesArray count]; i++)
	{
		ShoppingAisle* shoppingAisle = [aislesArray objectAtIndex:i];
		int itemNdx = [shoppingAisle getIndexForItem:item];
		if (itemNdx >= 0)
		{
			ret = i;
			break;
		}
	}
	return ret;
}

//
//	Returns the number of aisles in the collection.
//
- (NSUInteger) shoppingAisleCount
{
	return [aislesArray count];
}

//
//	Gets the shopping aisle at the specified index.
//
- (ShoppingAisle*) shoppingAisleAtIndex:(NSInteger)index
{
	ShoppingAisle* shoppingAisle = nil;
	if ((index >= 0) && (index < [aislesArray count]))
	{
		shoppingAisle = (ShoppingAisle*)[aislesArray objectAtIndex:index];
	}
	return shoppingAisle;
}

//
//	Look up shopping aisle by the aisle's unique Id
//
- (ShoppingAisle*) shoppingAisleForUid: (NSString*)uid
{
	return [aislesIndex objectForKey:uid];
}

//
//	Get the special "none" shopping aisle
//
- (ShoppingAisle*) noneShoppingAisle;
{
	return noneShoppingAisle;
}

//
//	Get the special "have" shopping aisle
//
- (ShoppingAisle*) haveShoppingAisle;
{
	return haveShoppingAisle;
}

//
//	Internal method which adds an aisle to the shopping list.
//
- (void) addShoppingAisle:(ShoppingAisle*)shoppingAisleToAdd
{
	if (shoppingAisleToAdd != nil)
	{
		// add the item to the array
		[aislesArray addObject:shoppingAisleToAdd];
	
		// add the item to the index
		Aisle* aisle = [shoppingAisleToAdd aisle];
		[aislesIndex setObject:shoppingAisleToAdd forKey:aisle.uid];
	}	
}

//
//	Internal method which removes the aisle, specified by the 
//	index, from the shopping list.
//
- (ShoppingAisle*) removeShoppingAisleAtIndex:(NSInteger)index
{
	ShoppingAisle* shoppingAisle = nil;
	if ((index >= 0) && (index < [aislesArray count]))
	{
		shoppingAisle = (ShoppingAisle*)[aislesArray objectAtIndex:index];
		
		// remove from array
		[aislesArray removeObjectAtIndex:index];

		if (shoppingAisle != nil)
		{
			// remove from index hash
			Aisle* aisle = [shoppingAisle aisle];
			[aislesIndex removeObjectForKey:aisle.uid];
		}
	}
	return shoppingAisle;
}

//
// Gets the grocery item for the specified index path.  
// This method is called by the UI controller code to 
// draw the grocery item cells within each aisle.
//
- (GroceryItem*)groceryItemAtIndexPath:(NSIndexPath*)indexPath
{
	GroceryItem* ret = nil;

	long aisleNdx = [indexPath indexAtPosition:0];  // section
	long itemNdx = [indexPath indexAtPosition:1];
	
	ShoppingAisle* shoppingAisle = [self shoppingAisleAtIndex: aisleNdx];
	NSMutableArray* items = [shoppingAisle aisleItems];
	if ([items count] > itemNdx)
	{
		ret = [items objectAtIndex:itemNdx];	
	}
	
	return ret;
}

//
//	Remove the specified grocery item from this data source.
//
- (GroceryItem*)removeGroceryItemAtIndexPath:(NSIndexPath*)indexPath
{
	GroceryItem* itemToMove = nil;		
	long srcAisleNdx = [indexPath indexAtPosition:0];  // section
	long srcItemNdx = [indexPath indexAtPosition:1];  // grocery item
	ShoppingAisle* srcShoppingAisle = [self shoppingAisleAtIndex: srcAisleNdx];
	NSMutableArray* srcAisleItems = [srcShoppingAisle aisleItems];
	if ([srcAisleItems count] > srcItemNdx)
	{
		// remove the item from the source aisle
		itemToMove = [srcAisleItems objectAtIndex:srcItemNdx];	
		[srcAisleItems removeObjectAtIndex:srcItemNdx];

		// remove empty aisle as needed
		if ([srcAisleItems count] == 0)
		{
			[self removeShoppingAisleAtIndex:srcAisleNdx];
		}
	}
	
	return itemToMove;
}


// **************************************************************************************
// UITableView data source methods

//
//	Called by the UITableView to get the number of sections (aisles) to 
//	display in the table view.  
// 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
	NSInteger ret = [self shoppingAisleCount];
	
	// craig HACK: deal with case where shopping list is empty
	if (ret == 0) ret = 1; 
	
	return ret;
}

//
//	Called by the UITableView to get the number of rows (grocery items) in
//	the specified section (aisle).
//
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	NSInteger ret = 0;
	if ((section >= 0) && (section < [self shoppingAisleCount]))
	{
		ShoppingAisle* shoppingAisle = [self shoppingAisleAtIndex: section];
		if (shoppingAisle != nil)
		{
			ret = [[shoppingAisle aisleItems] count];
		}
	}
	
	// craig HACK: deal with case where shopping list is empty
	if (ret == 0) ret = 1; 
	
	return ret;
}

//
//	Called by the UITableView to get the title text for the specified 
//	section (aisle).
//
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	NSString* sectionName;
	if ((section >= 0) && (section < [self shoppingAisleCount]))
	{
		Aisle* aisle = [[self shoppingAisleAtIndex: section] aisle];
		sectionName = [aisle name];
	}
	else
	{
		// craig HACK: deal with case where shopping list is empty
		sectionName = @"--";
	}
	return sectionName;
}	

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		// first, remove grocery item at index path from the data source
		GroceryItem* itemToDelete = [self removeGroceryItemAtIndexPath:indexPath];		
		
		if (itemToDelete != nil)
		{
			// last, remove the item from the DB table
			[[myDatabase groceryItems] removeItem:itemToDelete];			
		}
		
        // Animate the deletion from the table.
		if ([tv numberOfRowsInSection:indexPath.section] == 1)
		{
			if ([tv numberOfSections] == 1)
			{
				if (delegate) 
				{
					[delegate didDeleteLastItem];
				}
			}
			else
			{
				[tv deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] 
				  withRowAnimation:UITableViewRowAnimationLeft];		
			}
		} 
		else
		{			
			[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
					  withRowAnimation:UITableViewRowAnimationLeft];
		}
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{	
	ItemTableViewCell* cell = (ItemTableViewCell*)
		[tv dequeueReusableCellWithIdentifier:@"GBCBShopItem"];
	
	if (cell == nil)
	{
		cell = [[[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:@"GBCBShopItem"] autorelease];
	}
	
	// Get the object to display and set the value in the cell	
	GroceryItem* item = [self groceryItemAtIndexPath:indexPath];	
	[cell configureItem:item];
	return cell;
}

- (id <ShopViewDataSourceDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <ShopViewDataSourceDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end
