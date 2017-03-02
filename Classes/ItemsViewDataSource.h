//
//  ItemsViewDataSource.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/12/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//
// Holds all the knowledge of the order of items in the table view. The 
// ItemsViewController shouldn't know what order the items are in, it should
// just know at a conceptual level that its table view contains a list of items
// and it should call into this class "itemAtIndexPath" to find out specifics.

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class GroceryItemsTable;
@class GroceryItem;
@class Database;


@interface ItemsViewDataSource : NSObject 
	<UITableViewDataSource> 
{
	id <TableViewDataSourceDelegate> delegate;

	GroceryItemsTable* items;
	
	// sorted array of the first letters in names A,B,C,..Z,#. May not contain all the
	// letters. For example, if there are no items that begin with "Q"
	NSArray* itemNameIndexArray; 
	
	// dictionary of sorted NSArrays one for all the "A"s, "B"s, etc
	NSMutableDictionary* itemNameIndexDict;	
	
	// the section indexes on the right side of the view, A, B, ... Z, # in English
	NSArray* sectionArray;
	// 
	NSArray* sectionLookupArray;
	// all the section titles that can show up for this language A, B, .. Z in English
	NSArray* fullSectionArray;
	// ZZ for english
	NSString* lastSectionName; 
	
	// need to know if searching or not, so we can show or hide the section titles
	// this data source doesn't actually implement the search results - that's inside
	// SearchBarCell, with a separate UITableView
	BOOL isSearching;
	
	BOOL isDeleteStyle;
}
- (id)delegate;
- (void)setDelegate:(id)newDelegate;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL isDeleteStyle;

- (id) initWithDatabase:(Database*)database;

- (BOOL) shouldDeleteGroceryItem:(GroceryItem*)item;
- (void) dataHasChanged;

// figure out which GroceryItem 
- (GroceryItem*) itemAtIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*) indexPathForItem:(GroceryItem*)item;

@end
