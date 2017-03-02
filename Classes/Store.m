//
//  Store.m
//  Implementation of the object store which is responsible
//	for loading and saving items to and from the file system.
//
//  Created by Craig on 3/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "Store.h"
#import "GroceryItem.h"

NSString* GBCBSymbolLetter = @"ZZ"; // use this instead of "#" for first letter, so it sorts at end

// private methods
@interface Store(mymethods)
- (void) presortItemInitialLetterIndexes;
- (void) presortItemNamesForInitialLetter:(NSString *)aKey;
- (void) populateSampleGroceryItems;
- (void) populateIndexes;
@end

@implementation Store

//properties
@synthesize items;
@synthesize itemNameIndexes;
@synthesize itemsDictionary;
@synthesize itemNameIndexArray;

// implementation

- (void) dealloc 
{
	NSLog(@"***** dealloc Store");
	[itemNameIndexes release];
	[itemsDictionary release];
	[items release];
    [super dealloc];
}

//
// Save the specified items to disk
//
- (void) saveItemsToDisk
{
	// serialize to disk
	[NSKeyedArchiver archiveRootObject:items toFile:[self path]];
}

//
// Load saved items from disk
//
- (void) loadItemsFromDisk
{
	NSLog(@"load: %@", self);
	[items release];
	items = nil;
	
	// GLB: Commented out for now as it is "causing" the crash on add
//	items = [NSKeyedUnarchiver unarchiveObjectWithFile:[self path]];
	if (items == nil)
	{
		// initialize sample grocery items
		[self populateSampleGroceryItems];
	}
	[self populateIndexes];
	isItemArrayDirty = NO;
}

//
// Get the data file path to load and save serialized items
//
- (NSString *)path
{
	NSString *userFolder = @"~/";
	userFolder = [userFolder stringByExpandingTildeInPath];
	
	// In the Aspen simulator, the user path will evaluate to the following path Mac system path:
	//		"/Users/<name>/Library/Application Support/Aspen Simulator/User/..."
	NSString *filePath = [userFolder stringByAppendingPathComponent: @"rbgroceryitems.dat"];
	
// On the iPhone, this is supposed to be the proper way of determine your application path.
// Unfortunately, this method doesn't work in the Aspen Simulator since the simulator.
//
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
//	NSString *documentsDirectory = [paths objectAtIndex:0]; 
//	if (!documentsDirectory) 
//	{ 
//		NSLog(@"Documents directory not found!"); 
//	} 
//	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"rbgroceryitems.dat"];
	
	NSLog(@"%@", filePath);
	return filePath;
}

//
//	Populates the serializable item array with sample grocery items
//
- (void) populateSampleGroceryItems {
	items = [[NSMutableArray alloc] init];	
	
	// create the array of items
	GroceryItem* item = nil;
	
	item = [[GroceryItem alloc] init];
	item.name = @"Apple";
	[items addObject:item];
	[item release];
	
	item = [[GroceryItem alloc] init];
	item.name = @"Tomatoes, can 20 oz";
	[items addObject:item];
	[item release];
	
	item = [[GroceryItem alloc] init];
	item.name = @"- List me last";
	[items addObject:item];
	[item release];
	
	item = [[GroceryItem alloc] init];
	item.name = @"Cream Cheese";
	[items addObject:item];
	[item release];
	
	item = [[GroceryItem alloc] init];
	item.name = @"Bananas";
	[items addObject:item];
	[item release];

	item = [[GroceryItem alloc] init];
	item.name = @"cauliflower";
	[items addObject:item];
	[item release];

	item = [[GroceryItem alloc] init];
	item.name = @"Cereal";
	[items addObject:item];
	[item release];

	item = [[GroceryItem alloc] init];
	item.name = @"Beef, ground chuck";
	[items addObject:item];
	[item release];

	item = [[GroceryItem alloc] init];
	item.name = @"1 other thing";
	[items addObject:item];
	[item release];
}

//
//	Add a grocery item to the items collection
//
- (void) addItem:(GroceryItem*)newItem
{
	NSLog(@"add: %@", self);
	[items addObject:newItem];
//	[newItem release];	
	
	isItemArrayDirty = YES;
	[self populateIndexes];
}

- (void) populateIndexes
{
	if (self.itemsDictionary == nil) {
		self.itemsDictionary = [NSMutableDictionary dictionary];
	}
	if (self.itemNameIndexes == nil) {
		self.itemNameIndexes = [NSMutableDictionary dictionary];
	}
	[self.itemsDictionary removeAllObjects];
	[self.itemNameIndexes removeAllObjects];
	
	// iterate over the values in the raw elements dictionary
	for (GroceryItem* eachItem in items)
	{		
		// store that item in the elements dictionary with the name as the key
		[itemsDictionary setObject:eachItem forKey:eachItem.name];
				
		// get the element's initial letter
		NSString *firstLetter = [[eachItem.name substringToIndex:1] uppercaseString];
		if (([firstLetter localizedCompare:@"A"] == NSOrderedAscending) || 
			([firstLetter localizedCompare:@"Z"] == NSOrderedDescending))
		{	
			firstLetter = @"ZZ";
		}
		NSMutableArray *existingArray;
		
		// if an array already exists in the name index dictionary
		// simply add the element to it, otherwise create an array
		// and add it to the name index dictionary with the letter as the key
		if (existingArray = [itemNameIndexes valueForKey:firstLetter]) 
		{
			[existingArray addObject:eachItem];
		} else {
			//TODO: make sure it begins with A to Z, otherwise put it in the # bucket
			NSMutableArray *tempArray = [NSMutableArray array];
			[itemNameIndexes setObject:tempArray forKey:firstLetter];
			[tempArray addObject:eachItem];
		}
		
		// release the item, it is held by the various collections
		//[eachItem release];		
	}
	[self presortItemInitialLetterIndexes];
}

- (void)presortItemInitialLetterIndexes 
{
	self.itemNameIndexArray = [[itemNameIndexes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

	// eachNameIndex will be something like "A", "B", or "#" (everything else)
	for (NSString* eachNameIndex in itemNameIndexArray) {
		[self presortItemNamesForInitialLetter:eachNameIndex];
	}
}

- (void)presortItemNamesForInitialLetter:(NSString *)aKey 
{
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
																   ascending:YES
																	selector:@selector(localizedCaseInsensitiveCompare:)] ;
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	[[itemNameIndexes objectForKey:aKey] sortUsingDescriptors:descriptors];
	[nameDescriptor release];
}

@end
