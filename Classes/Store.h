//
//  Store.h
//  Interface definition for the object store which is responsible
//	for loading and saving items to and from the file system.
//
//  Created by Craig on 3/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* GBCBSymbolLetter;
@class GroceryItem;

@interface Store : NSObject {
	// the actual item objects
	NSMutableArray *items;
	BOOL isItemArrayDirty;
	
	// sorted array of the first letters in names A,B,C,..Z,#. May not contain all the
	// letters. For example, if there are no items that begin with "Q"
	NSArray *itemNameIndexArray; 
	
	// dictionary of sorted NSArrays one for all the "A"s, "B"s, etc
	NSMutableDictionary *itemNameIndexes;
	
	//dictionary of Items with item name as key
	NSMutableDictionary *itemsDictionary;

}

@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic,retain) NSArray *itemNameIndexArray;
@property (nonatomic,retain) NSMutableDictionary *itemNameIndexes;
@property (nonatomic,retain) NSMutableDictionary *itemsDictionary;

- (void) saveItemsToDisk;
- (void) loadItemsFromDisk;
- (NSString *)path;
- (void) addItem:(GroceryItem*)newItem;

@end
