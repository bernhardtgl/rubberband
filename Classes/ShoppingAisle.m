//
//  ShoppingAisle.m
//  Implementation of a shopping aisle object which
//	associates an aisle with the list of grocery items 
//	needed from that aisle.
//
//  Created by Craig on 4/10/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ShoppingAisle.h"


@implementation ShoppingAisle

//
// Initializes a new ShoppingAisle object.
//
- (id) initWithAisle: (Aisle *)refAisle
{
	if (self = [super init])
	{
		aisle = refAisle;
		aisleItems = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc ShoppingAisle");
	[aisle release];
	[aisleItems removeAllObjects];
	[aisleItems release];
	[super dealloc];
}

//
// Get a meaningful text description of this object from debugging and
// logging purposes.
//
- (NSString*) description
{
	return [NSString stringWithFormat:@"%@ %@", [aisle description], [aisleItems description]];
}

//
//	Get the aisle
//
- (Aisle*) aisle
{
	return aisle;
}

//
//	Get the grocery items in the aisle
//
- (NSMutableArray*) aisleItems
{
	return aisleItems;
}

//
//	Find the index of the specified grocery item within 
//	the collection.
//	Returns -1 if the item is not found.
//
- (int) getIndexForItem: (GroceryItem*) item
{
	int ret = -1;
	int i;
	for (i = 0; i < [aisleItems count]; i++)
	{
		GroceryItem* testItem = [aisleItems objectAtIndex:i];
		if (item == testItem)
		{
			ret = i;
			break;
		}
	}
	
	return ret;
}


@end

