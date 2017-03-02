//
//  Recipe.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//


#import "Recipe.h"
#import "Database.h"
#import "RecipesTable.h"
#import "RubberbandAppDelegate.h" // for the globals
#import "GroceryItem.h"
#import "GroceryItemsTable.h"
#import "ItemQuantity.h"

@implementation Recipe

//
// Initializes a brand new object with a 
// new unique id.
//
- init
{
	return [self initWithUid:[Database generateUid]];
}

//
// Initializes a new aisle object with a known or 
// existing unique id.
//
- (id) initWithUid: (NSString*)newUid
{
	if (self = [super init])
	{
		uid = [newUid copy];
		name = @"";
		notes = @"";
		link = @"";
		image = nil;
		itemsInRecipe = [[NSMutableArray alloc] init]; 
		itemUidsInRecipe = [[NSMutableArray alloc] init]; 
		itemQuantitiesInRecipe = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"***** dealloc Recipe %@", name);
	[name release];
	[notes release];
	[link release];
	[image release];
	[itemsInRecipe release];
	[itemUidsInRecipe release];
	[itemQuantitiesInRecipe release];
	[super dealloc];
}

//
//	Set the collection that this item is contained by.
//	This is called when the item is added to the parent collection.
- (void) setOwnerContainer:(NSObject*)container
{
	ownerContainer = container;
}

//
//	Set the isDirty flag to YES to indicate that the aisle
//	has changed since it was loaded from disk.
//
- (void) markDirty
{
	if (ownerContainer != nil)
	{
		RecipesTable* rs = (RecipesTable*)ownerContainer;
		[rs markDirty];
	}
}

//
// get the unique id of this object 
//
- (NSString*) uid
{
	return uid;
}

// set, get recipe name
- (void) setName: (NSString *)newValue
{
	NSString *n = [newValue copy];
	[name release];
	name = n;
	[self markDirty];
}
- (NSString*) name
{
	return name;
}

// set, get recipe notes
- (void) setNotes: (NSString *)newValue
{
	NSString *n = [newValue copy];
	[notes release];
	notes = n;
	[self markDirty];
}
- (NSString*) notes
{
	return notes;
}

// set, get recipe link
- (void) setLink: (NSString *)newValue
{
	NSString *n = [newValue copy];
	[link release];
	link = n;
	[self markDirty];
}
- (NSString*) link
{
	return link;
}


- (NSString*)imageFileName
{
	// the file name is the UID of the recipe, plus a JPG extension. 
	// TODO: can photos in the library be anything other than JPGs?	
	NSString* filePath = [App_database baseFilePath];
	NSString* fileName = [NSString stringWithFormat:@"%@.jpg", uid];	
	return [filePath stringByAppendingPathComponent:fileName];	
}

- (void)loadImages
{
	[image release];
	image = [UIImage imageWithContentsOfFile:[self imageFileName]];
	[image retain];
}

- (void)saveImages
{
	NSData* data = UIImageJPEGRepresentation (image, 1.0);
	[data writeToFile:[self imageFileName] atomically:YES];
}

- (void) deleteImages;
{
	NSError* err = nil;
	NSFileManager* manager = [NSFileManager defaultManager];
	[manager removeItemAtPath:[self imageFileName] error:&err];	
	// don't really care if it fails
}

// set, get recipe image
- (void) setImage:(UIImage*)newValue
{
	[newValue retain];
	[image release];
	image = newValue;
	
	// we save the image separately, in its own file, which is why we don't
	// mark the recipe object dirty here

	[self saveImages];
}

- (UIImage*)image
{
	// TODO: optimize this a bit more later, don't need to load every time
	if (image == nil)
	{
		[self loadImages];
	}
	return image;
}

- (NSMutableArray*) itemsInRecipe
{
	return itemsInRecipe;
}

// if item is already in the recipe, do nothing. If recipeQty is nil, use the "usual"
// quantity for the item
- (void) addItemToRecipe:(GroceryItem*)item withQuantity:(ItemQuantity*)recipeQty; 
{
	ItemQuantity* qtyObj = [itemQuantitiesInRecipe objectForKey:item.uid];

	// if item doesn't already exist in the recipe, add it
	if (qtyObj == nil)
	{
		// doesn't exist in the recipe yet, add it to the array
		[itemUidsInRecipe addObject:item.uid];
		[itemsInRecipe addObject:item];
		
		// use the amount specified by the caller, or the usual amount if 
		// unspecified. Copy into a new object in case the caller ever changes
		// the one he passed in
		qtyObj = [[ItemQuantity alloc] init];
		if (recipeQty == nil)
		{
			qtyObj.amount = item.qtyUsual.amount;
			qtyObj.type = item.qtyUsual.type;
		}
		else
		{
			qtyObj.amount = recipeQty.amount;
			qtyObj.type = recipeQty.type;
		}
		
		[itemQuantitiesInRecipe setObject:qtyObj forKey:item.uid];			
		[qtyObj release]; // held by the dictionary

		[self markDirty];
	}
}

- (void) removeAllItemsFromRecipe
{
	[itemUidsInRecipe removeAllObjects];
	[itemsInRecipe removeAllObjects];
	[itemQuantitiesInRecipe removeAllObjects];	
	[self markDirty];
}

- (void) removeItemFromRecipe:(GroceryItem*)item
{
	[itemUidsInRecipe removeObject:item.uid];
	[itemsInRecipe removeObject:item];
	[itemQuantitiesInRecipe removeObjectForKey:item.uid];	
	[self markDirty];
}

- (ItemQuantity*) quantityForItem:(GroceryItem*)item
{
	ItemQuantity* ret = nil;
	
	if (item != nil)
	{
		ret = [itemQuantitiesInRecipe objectForKey:item.uid];
	}
	return ret;
}

// description is what is returned when the object is printed to the log
- (NSString*) description
{
	// description is what is returned when the object is printed to the log
	return [NSString stringWithFormat:@"%@ %@\r\n%@\r\n%@", uid, name, itemsInRecipe, itemQuantitiesInRecipe];
}

//
//	NSCoding method - called to save the save the object to file.
//
- (void) encodeWithCoder: (NSCoder*)coder
{
	[coder encodeInt:1 forKey:@"version"];

	// note the recipe image is not stored in this method. It is stored separately
	[coder encodeObject:uid forKey:@"uid"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:notes forKey:@"notes"];
	[coder encodeObject:link forKey:@"link"];
	[coder encodeObject:itemUidsInRecipe forKey:@"itemUidsInRecipe"];

	// added in version 1 of object (1.1.0)
	[coder encodeObject:itemQuantitiesInRecipe forKey:@"itemQuantitiesInRecipe"];
	
	// Note: in version 0 of object (1.0.0), encoded an unused quantity-related object
	//[coder encodeObject:quantityInRecipeIndex forKey:@"quantityInRecipeIndex"];
}

//
// NSCoding method - called to rehydrate the object from file.
//
- (id) initWithCoder: (NSCoder*)coder
{
	if (self = [super init])
	{
		// 0 = original version (1.0.0)
		// 1 = when we got rid of quantityInRecipeIndex and added itemQuantitiesInRecipe
		
		// don't need to decode it though, because we don't need it yet
		// commented out so no compiler warning
//		int version = [coder decodeIntForKey:@"version"];

		uid = [[coder decodeObjectForKey:@"uid"] copy];
		name = [[coder decodeObjectForKey:@"name"] copy];
		notes = [[coder decodeObjectForKey:@"notes"] copy];
		link = [[coder decodeObjectForKey:@"link"] copy];
		itemUidsInRecipe = [[coder decodeObjectForKey:@"itemUidsInRecipe"] retain];
		
		// added in version 1, if converting from version 0, this will be nil
		// and is handled below
		itemQuantitiesInRecipe = [[coder decodeObjectForKey:@"itemQuantitiesInRecipe"] retain];

		// in case the array/dictionary didn't exist, create them so that we can
		// later add to them
		if (itemUidsInRecipe == nil)
		{
			itemUidsInRecipe = [[NSMutableArray alloc] init]; 
		}
		if (itemQuantitiesInRecipe == nil)
		{
			// convert from version 0
			itemQuantitiesInRecipe = [[NSMutableDictionary alloc] init];
			for (NSString* eachUid in itemUidsInRecipe)
			{
				ItemQuantity* qtyObj = [[ItemQuantity alloc] init];
				qtyObj.amount = 1;
				qtyObj.type = QuantityTypeNone;
				[itemQuantitiesInRecipe setObject:qtyObj forKey:eachUid];
				[qtyObj release];
			}
		}
		
		itemsInRecipe = [[NSMutableArray alloc] init]; 
		GroceryItemsTable* itemsTable = [App_database groceryItems];
		// load array of items from array of uids
		for (NSString* eachUid in itemUidsInRecipe)
		{
			GroceryItem* item = [itemsTable itemForUid:eachUid];
			if (item != nil)
			{
				[itemsInRecipe addObject:item];
			}
		}
	}
	return self;
}

@end
