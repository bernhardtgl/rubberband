//
//  GroceryItem
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/10/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "GroceryItem.h"
#import "GroceryItemsTable.h"
#import "Database.h"
#import "RubberbandAppDelegate.h"  // TODO: craig, this is cheezy; fix it by putting the Database global somewhere else
#import "Aisle.h"
#import "AislesTable.h"
#import "Recipe.h"

@implementation GroceryItem

//
// Initializes a brand new grocery item with a 
// new unique id.
//
- init
{
	return [self initWithUid:[Database generateUid]];
}

//
// Initializes a new grocery items with a known or 
// existing unique id.
//
- (id) initWithUid: (NSString *)newUid
{
	if (self = [super init])
	{
		uid = [newUid copy];
		aisleUid = @"";
		self.name = @"";
		self.haveItem = NO;
		
		qtyNeeded = [[ItemQuantity alloc] init];
		qtyUsual = [[ItemQuantity alloc] init];
		qtyUsual.amount = 1;

		qtyNeeded.delegate = self;
		qtyUsual.delegate = self;
		
		aisle = nil;
	}
	return self;
}
/*
- (id)retain
{
	[super retain];
	if ([[self name] isEqual:@"Bananas"]) {
		NSLog(@"+++Retain: %d %@", [self retainCount], [self name]);
	}
	return self;
}
- (oneway void)release
{
	if ([[self name] isEqual:@"Bananas"]) {
		NSLog(@"---Releas: %d %@", [self retainCount] - 1, [self name]);
	}
	[super release];
}
*/
- (void)dealloc 
{
	NSLog(@"***** dealloc GroceryItem: %@", [self name]);
	[name release];
	[uid release];
	[aisleUid release];
	[qtyNeeded release];
	[qtyUsual release];
	[super dealloc];
}

//
//	Set the GroceryItems collection that this item is contained by.
//	This is called when the grocery item is added to the collection.
//
- (void) setOwnerTable:(GroceryItemsTable*)owner
{
	ownerTable = owner;
}

//
//	Set the isDirty flag to YES to indicate that the item
//	has changed since it was loaded from disk.
//
- (void) markDirty
{
	if (ownerTable != nil)
	{
		[ownerTable markDirty];
		[ownerTable signalItemChanged:self];
	}
}

//
// get the unique id of this grocery item 
//
- (NSString*) uid
{
	return uid;
}

//
//	Get the uid of the aisle where this item is located.
//
- (NSString*) aisleUid
{
	return aisleUid;
}

//
//	Get the aisle associated with this grocery item
//
- (Aisle*) aisle
{
	// lazy load the aisle from the aisles collection using the uid
	if (aisle == nil)
	{
		AislesTable* aisles = [App_database aisles];
		aisle = [aisles aisleForUid:aisleUid];
	}
	return aisle;
}

//
//	Set the aisle where this grocery item is located
//
- (void)setAisle: (Aisle*)newAisle
{
//	if (aisle != nil) [aisle release];
	
	[aisleUid release];
	if (newAisle == nil)
	{
		aisleUid = @"";
	}
	else
	{
		aisleUid = [[newAisle uid] copy];
	}
	aisle = newAisle;
	[self markDirty];
}

//
//	Get the name of the grocery item; like "Yams"
//
- (NSString*) name
{
	return name;
}

//
//	Set the name of the grocery item; for example "Potato chips"
//
- (void) setName: (NSString *)newName
{
	newName = [newName copy];
	[name release];
	name = newName;
	[self markDirty];
}

- (ItemQuantity*) qtyNeeded
{
	return qtyNeeded;
}
- (ItemQuantity*) qtyUsual
{
	return qtyUsual;
}
/* TODO: update quantity total when changed
- (int) quantityNeeded
{
	return quantityNeeded;
}

- (void) setQuantityNeeded:(int)newValue 
{
	if (quantityNeeded != newValue )
	{
		if (ownerTable != nil) 
		{
 			GroceryItemsTable* items = ownerTable;
			if (newValue == 0) 
			{
				[items updateNeedCount:-1];
			} 
			else if ((newValue > 0) && (quantityNeeded == 0))
			{
				[items updateNeedCount:1];
			}
		}
		
		quantityNeeded = newValue;
		[self markDirty];
	}
}
*/
- (BOOL) haveItem
{
	return haveItem;
}
- (void) setHaveItem:(BOOL)newValue
{
	if (haveItem != newValue)
	{
		haveItem = newValue;
		[self markDirty];
		if (ownerTable != nil)
		{
			GroceryItemsTable* items = ownerTable;
			[items updateNeedCount:haveItem ? -1 : 1];
		}
	}
}

// calculated, not stored
- (BOOL) needItem 
{
	return ((qtyNeeded.amount != 0) && !haveItem);
}

// description is what is returned when the object is printed to the log
- (NSString*) description
{
	if ([self aisle] == nil)
	{
		return [NSString stringWithFormat:@"%@ %@ Qty:%@ Aisle:NONE",
				uid, name, qtyNeeded];
	} 
	else 
	{
		return [NSString stringWithFormat:@"%@ %@ Qty:%@ Aisle:%@",
				uid, name, qtyNeeded, self.aisle.name];
	}
}

//
//	NSCoding method - called to save the save the object to file.
//
- (void) encodeWithCoder: (NSCoder *)coder
{
	[coder encodeInt:1 forKey:@"version"];

	[coder encodeObject:uid forKey:@"uid"];
	[coder encodeObject:aisleUid forKey:@"aisleUid"];	
	[coder encodeObject:name forKey:@"name"];	
	[coder encodeBool:haveItem forKey:@"haveItem"];

	// added in version 1 of object (1.1.0)
	[coder encodeObject:qtyNeeded forKey:@"qtyNeeded"];
	[coder encodeObject:qtyUsual forKey:@"qtyUsual"];
	
	// Note: in version 0 of object (1.0.0), encoded an integer quantity
	//[coder encodeInt:quantityNeeded forKey:@"quantityNeeded"];
}

//
// NSCoding method - called to rehydrate the object from file.
//
- (id) initWithCoder: (NSCoder *)coder
{
	if (self = [super init])
	{
		// 0 = original version (1.0.0)
		// 1 = when we got rid of quantityNeeded and added qtyNeeded and qtyUsual
		int version = [coder decodeIntForKey:@"version"];

		uid = [[coder decodeObjectForKey:@"uid"] copy];	
		aisleUid = [[coder decodeObjectForKey:@"aisleUid"] copy];
		[self setName:[coder decodeObjectForKey:@"name"]];

		qtyNeeded = [[coder decodeObjectForKey:@"qtyNeeded"] retain];
		qtyUsual  = [[coder decodeObjectForKey:@"qtyUsual"] retain];
				
		[self setHaveItem:[coder decodeBoolForKey:@"haveItem"]];

		// upgrade from earlier versions of the object
		if (version == 0)
		{
			qtyNeeded = [[ItemQuantity alloc] init];
			qtyUsual = [[ItemQuantity alloc] init];
			qtyUsual.amount = 1;
			qtyNeeded.amount = [coder decodeIntForKey:@"quantityNeeded"];
		}

		qtyNeeded.delegate = self;
		qtyUsual.delegate = self;
	}
	return self;
}

//
// Comparison callback method used to for sorting
//
- (NSComparisonResult)compareGroceryItem:(GroceryItem *)item
{
    return [[self name] compare:[item name]];
}

- (NSMutableArray*)recipesContainingItem
{
	NSMutableArray* array = [NSMutableArray array]; // autoreleased
	RecipesTable* t = [App_database recipes];
	for (Recipe* r in t)
	{
		if ([r quantityForItem:self] != nil)
		{
			[array addObject:r];
		}
	}
	return array;
}

- (void) didChangeItemQuantityType:(ItemQuantity*)itemQuantity oldValue:(QuantityType)oldValue;
{
	[self markDirty];
}

- (void) didChangeItemQuantityAmount:(ItemQuantity*)itemQuantity oldValue:(double)oldValue;
{
	// did the user change the needed quantity, or the "usual" quantity
	if (itemQuantity == qtyNeeded)
	{
		if (ownerTable != nil) 
		{
			// increase the total needed badge number, with this optimized code
			GroceryItemsTable* items = ownerTable;
			if (itemQuantity.amount == 0) 
			{
				[items updateNeedCount:-1];
			} 
			else if ((itemQuantity.amount > 0) && (oldValue == 0))
			{
				[items updateNeedCount:1];
			}
		}
	}

	// either way, we're dirty
	[self markDirty];
}

@end
