//
//  Recipe.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroceryItem;
@class ItemQuantity;

@interface Recipe : NSObject <NSCoding>
{
	// the basic attributes of a recipe
	NSObject* ownerContainer;
	NSString* uid;
	NSString* name;
	NSString* notes;
	NSString* link;
	UIImage* image;
	
	// which items are in the recipe, and at what quantity. The itemQuantitiesInRecipe
	// is a dictionary containing the Uid of the item as the key, and the ItemQuantity
	// as its object. 
	// itemsInRecipe is a cache. itemUidsInRecipe is the array that is actually saved
	NSMutableArray* itemsInRecipe;
	NSMutableArray* itemUidsInRecipe;
	NSMutableDictionary* itemQuantitiesInRecipe;
}

- (id) initWithUid: (NSString*)uid;
- (void) setOwnerContainer:(NSObject*)container;

- (NSString*) uid;
- (void) setName: (NSString*)newValue;
- (NSString*) name;
- (void) setNotes: (NSString*)newValue;
- (NSString*) notes;
- (void) setLink: (NSString*)newValue;
- (NSString*) link;
- (void) setImage: (UIImage*)newValue;
- (UIImage*) image;

- (NSMutableArray*) itemsInRecipe;

- (ItemQuantity*) quantityForItem:(GroceryItem*)item;

// if item is already in the recipe, do nothing. If recipeQty is nil, use the "usual"
// quantity for the item
- (void) addItemToRecipe:(GroceryItem*)item withQuantity:(ItemQuantity*)recipeQty; 

- (void) removeItemFromRecipe:(GroceryItem*)item;
- (void) removeAllItemsFromRecipe;

// when a recipe is deleted, its stored images should be, too
- (void) deleteImages;

@end
