//
//  GroceryItems.m
//  Implementation of collection of grocery item objects.
//
//  Created by Craig on 3/30/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "GroceryItemsTable.h"
#import "Aisle.h"

@implementation GroceryItemsTable

//
// Initializes a brand new grocery items collection.
//
- init
{
	if (self = [super init])
	{
		itemsArray = [[NSMutableArray alloc] init];
		itemsUidIndex = [[NSMutableDictionary alloc] init];
		isDirty = NO;
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"***** dealloc THE GroceryItemsTable");
	[itemsArray release];
	[itemsUidIndex release];
	[super dealloc];
}

// 
// Description is what is returned when the object is printed to the log
//
- (NSString*) description
{
	return [itemsArray description];
}

//
// Enumeration method. Manditory method to support "for each" language constructs.
//
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [itemsArray countByEnumeratingWithState:state objects:stackbuf count:len];
}

//
// Get the current GroceryItemsTableDelegate object
//
- (id)delegate 
{
    return delegate;
}
 
//
// Set the current GroceryItemsTableDelegate object
//
- (void)setDelegate:(id)newDelegate 
{
    delegate = newDelegate;
}

//
//	Fires and event through the attached delegate indicating
//	that the specified GroceryItem properties have changed.
//
- (void)signalItemChanged:(GroceryItem*)item
{
    if ( delegate && [delegate respondsToSelector:@selector(groceryItemDidChange:)] ) 
	{
        [delegate groceryItemDidChange:item];
    }
}

- (void)signalItemWillDelete:(GroceryItem*)item
{
    if ( delegate && [delegate respondsToSelector:@selector(groceryItemWillDelete:)] ) 
	{
        [delegate groceryItemWillDelete:item];
    }
}

//
// Determine whether the array has changed (isDirty) is 
// it was re-hydrated from disk.
//
- (bool) isDirty
{
	return isDirty;
}

//
//	Set the isDirty flag to YES to indicate that the collection
//	has changed since it was loaded from disk.
//
- (void) markDirty
{
	isDirty = YES;
}

//
//	Returns the number of items in the collection.
//
- (NSUInteger) count
{
	return [itemsArray count];
}

//
//	Add an item to the collection
//
- (void) addItem:(GroceryItem*)newItem
{
	if (newItem != nil)
	{
		// add the item to the array
		[itemsArray addObject:newItem];
		[newItem setOwnerTable:self];
		
		// add the item to the index
		[itemsUidIndex setObject:newItem forKey:newItem.uid];
	
		// increase the total count, if needed
		if ([newItem needItem]) {
			[self updateNeedCount:1];
		}
		[self markDirty];
	}	
}

//
//	Gets the item at the specified index within
//	the collection.
//
- (GroceryItem*) itemAtIndex:(int)index
{
	GroceryItem* item = nil;
	if ((index >= 0) && (index < [itemsArray count]))
	{
		item = (GroceryItem*)[itemsArray objectAtIndex:index];
	}
	return item;
}

//
//	Remove the specified object from the collection.
//
- (void) removeItem:(GroceryItem*)anItem;
{
	if (anItem != nil)
	{
		// decrease the total count, if needed
		if ([anItem needItem]) {
			[self updateNeedCount:-1];
		}
		[self signalItemWillDelete:anItem];

		// now actually remove it
		[itemsUidIndex removeObjectForKey:[anItem uid]];
		[itemsArray removeObject:anItem];
		[self markDirty];
	}
}

//
//	Look up item by its unique Id
//
- (GroceryItem*) itemForUid: (NSString*)uid
{
	return [itemsUidIndex objectForKey:uid];
} 

//
//	NSCoding method - called to save the collection to file.
//
- (void) encodeWithCoder: (NSCoder*)coder
{
	[coder encodeObject:itemsArray];
}

//
// NSCoding method - called to rehydrate the collection from file.
//
- (id) initWithCoder: (NSCoder*)coder
{
	if (self = [self init])
	{
		NSMutableArray* rehydratedArray = (NSMutableArray*)[coder decodeObject];
		if (rehydratedArray != nil)
		{
			// GLB: strangely, rehydratedArray has a retainCount of 2 here, before this
			// retain call - seems like it should be 1, and in the autorelease pool
			[rehydratedArray retain]; 
			[itemsArray release];
			itemsArray = rehydratedArray;
			
			// rebuild the uid index
			[itemsUidIndex removeAllObjects];			
			
			// rebuild the uid index
			for (GroceryItem* eachItem in itemsArray)
			{
				if (eachItem != nil)
				{
					[eachItem setOwnerTable:self];
					[itemsUidIndex setObject:eachItem forKey:[eachItem uid]];
					
					if ([eachItem needItem]) {
						[self updateNeedCount:1];
					}					
				}
			}		
			
		}
	}
	return self;
}

- (NSUInteger) countItemsHavingAisle:(Aisle*)aisle
{
	int total = 0;
	for (GroceryItem* eachItem in itemsArray)
	{
		if (eachItem.aisle == aisle) {
			total++;
		}
	}
	return total;
}

- (void) resetItemsAisleToNone:(Aisle*)aisle
{
	for (GroceryItem* eachItem in itemsArray)
	{
		if (eachItem.aisle == aisle) {
			eachItem.aisle = nil;
		}
	}
}

- (void) updateNeedCount:(int)byAmount
{
	countOfNeededItems += byAmount;
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"GBCBNeedCountChanged" object:self];		
}

- (NSUInteger) countOfNeededItems
{
	return countOfNeededItems;
}

- (NSArray*) allItems;
{
	return itemsArray;
}

@end
