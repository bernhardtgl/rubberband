//
//  Database.h
//  Interface definition for the object database which is responsible
//	for loading and saving items to and from the file system.
//
//  Created by Craig on 3/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroceryItemsTable.h"

//extern NSString* GBCBSymbolLetter;

@class GroceryItem;
@class GroceryItemsTable;
@class AislesTable;
@class RecipesTable;

@interface Database : NSObject <GroceryItemsTableDelegate>
{
	NSString* documentsDirectory;

	// main collections for 3 types of objects in the app
	GroceryItemsTable* items;
	AislesTable* aisles;
	RecipesTable* recipes;
}
+ (NSString*) generateUid;

- (NSString*)baseFilePath;

- (void) saveToDisk;
- (BOOL) loadFromDisk; // if returns false, we had to revert to a backup

// save an archival version of the aplication data, in case of a bad bug
- (void) backupFilesArchiveForVersion:(NSInteger)version; 

- (GroceryItemsTable*) groceryItems;
- (AislesTable*) aisles;
- (RecipesTable*) recipes;

- (NSUInteger)countOfRecipesUsingItem:(GroceryItem*)item withNames:(NSMutableArray*)names;

// GroceryItemsTableDelegate methods
- (void)groceryItemDidChange:(GroceryItem*)item;
- (void)groceryItemWillDelete:(GroceryItem*)item;

@end
