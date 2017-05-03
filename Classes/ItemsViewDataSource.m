//
//  ItemsViewDataSource.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/12/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ItemsViewDataSource.h"
#import "GroceryItemsTable.h"
#import "RubberbandAppDelegate.h"
#import "Database.h"
#import "ItemTableViewCell.h"
#import "Protocols.h"
#import "SearchBarCell.h"

//  private methods
@interface ItemsViewDataSource(PrivateMethods)
- (NSString*) firstLetterForItem:(GroceryItem*)item;
@end

@implementation ItemsViewDataSource

@synthesize isSearching;
@synthesize isDeleteStyle;

// Initializes a shopping list using the 
// global Database object.
- init
{
	return [self initWithDatabase:App_database];
}

// Initializes a new shopping list using the specified
// database 
- (id) initWithDatabase:(Database*)database
{
	if (self = [super init])
	{
		isSearching = NO;
		isDeleteStyle = YES;
		items = [database groceryItems];
		[items retain];
		
		NSString* arrayString = @"{search}";
		arrayString = [arrayString stringByAppendingString:
			NSLocalizedString(@":A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:#", 
							  @"titles for section letters on Items screen. Start with a :. Matches the list in the Contacts application")];
		sectionArray = [[arrayString componentsSeparatedByString:@":"] retain];

		NSString* arrayLookup = @"{search}:";
		arrayLookup = [arrayLookup stringByAppendingString:
					   NSLocalizedString(@"A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:#", 
										 @"same as section letters, but instead of the • include the letter that tapping on it should scroll the user to")];
		sectionLookupArray = [[arrayLookup componentsSeparatedByString:@":"] retain];
		
		NSString* fullArrayString = 
			NSLocalizedString(@"A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z", 
			@"all the sections that can show up in the list, in alphabetical order, except for 123");
		fullSectionArray = [[fullArrayString componentsSeparatedByString:@":"] retain];
		
		lastSectionName = [NSString stringWithFormat:@"%@%@",
						   [fullSectionArray lastObject], [fullSectionArray lastObject]];
		[lastSectionName retain];
		
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc ItemsViewDataSource");
	[itemNameIndexDict release];
	[itemNameIndexArray release];
	[items release];
	[sectionArray release];
	[sectionLookupArray release];
	[fullSectionArray release];
	[lastSectionName release];
	
    [super dealloc];
}

// TODO: listen to the GroceryItemsTable to see if things have changed, 
// rather than relying on the view to call this method
- (void) dataHasChanged
{
	if (itemNameIndexDict == nil) {
		itemNameIndexDict = [[NSMutableDictionary alloc] init];
	}
	[itemNameIndexDict removeAllObjects];
	
	// iterate over the values in the grocery items table. Create a dictionary
	// where the Key is the first letter, and the object is an array of all the
	// items beginning with that letter
	NSLog(@"Start data changed");
	for (GroceryItem* eachItem in items)
	{		
		NSString* firstLetter = [self firstLetterForItem:eachItem];
		
		// if an array already exists in the name index dictionary
		// simply add the element to it, otherwise create an array
		// and add it to the name index dictionary with the letter as the key
		NSMutableArray* existingArray = [itemNameIndexDict valueForKey:firstLetter];
		if (existingArray)
		{
			[existingArray addObject:eachItem];
		} else 
		{
			NSMutableArray* newArray = [NSMutableArray array]; // will be retained by dict
			[itemNameIndexDict setObject:newArray forKey:firstLetter];
			[newArray addObject:eachItem];
		}
	}
	NSLog(@"- Finish loop");

	// create an array of all the first letters, sorted
	// so they go "A", "B", "C", etc... ending with "Z" and "ZZ"
	// "ZZ" will become the "everything else" bucket
	[itemNameIndexArray release];
	itemNameIndexArray = [[itemNameIndexDict allKeys] 
			sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[itemNameIndexArray retain];
	NSLog(@"- Finish create arrays");
	
	// get ready to sort by creating a descriptor
	NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"name"
										ascending:YES 
										selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray* descriptors = [NSArray arrayWithObject:nameDescriptor];

	// now sort the "A" items, the "B" items, etc...
	for (NSString* eachInitialLetter in itemNameIndexArray) 
	{
		[[itemNameIndexDict objectForKey:eachInitialLetter] 
			sortUsingDescriptors:descriptors];
	}

	[nameDescriptor release];
	NSLog(@"Finish data changed");
}
- (NSString*) firstLetterForItem:(GroceryItem*)item
{
	// get the element's initial letter, special handling if it's not one
	// of the letters that will be one of the section titles
	NSString* firstLetter = [[item.name substringToIndex:1] uppercaseString];
	
	BOOL foundIt = NO;
	NSComparisonResult cr = [firstLetter localizedCompare:[fullSectionArray objectAtIndex:0]];
	if (cr != NSOrderedAscending)
	{
		NSString* prevSectionLetter = lastSectionName; // ZZ
		for (NSString* sectionLetter in fullSectionArray)
		{
			if ([firstLetter localizedCompare:sectionLetter] == NSOrderedAscending)
			{
				return prevSectionLetter;
			}
			prevSectionLetter = sectionLetter;
		}
		if ([firstLetter localizedCompare:[fullSectionArray lastObject]] == NSOrderedSame)
		{
			return [fullSectionArray lastObject];
		}
	}
	
	// was either before the first letter of after the last letter
	if (!foundIt) firstLetter = lastSectionName;
	return firstLetter;
}

// Standard table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
	// 1 more for the search cell
    return [itemNameIndexDict count] + 1; 
}


- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
	{
		return 1; // search cell
	}
	else
	{
		NSString* sectionName = [itemNameIndexArray objectAtIndex:section - 1];
		NSArray* sectionItems = [itemNameIndexDict objectForKey:sectionName];
		return [sectionItems count];
	}
}

// Provide a title for the section
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	if (section == 0)
	{
		return @""; // no header for search cell
	}
	else
	{
		NSString* sectionName = [itemNameIndexArray objectAtIndex:section - 1];
		if (sectionName.length == 2) // use the last letter twice (ZZ) so it sorts to the end
		{
			sectionName = NSLocalizedString(@"123", @"Section header for non A-Z items");
		}
		return sectionName;
	}
}	

- (GroceryItem*) itemAtIndexPath:(NSIndexPath*)indexPath
{
	if ((indexPath == nil) || (indexPath.section == 0)) // search cell is not an item
	{	
		return nil;
	}
	
	NSString* sectionName = [itemNameIndexArray objectAtIndex:indexPath.section - 1];
	NSArray* sectionItems = [itemNameIndexDict objectForKey:sectionName];
	return [sectionItems objectAtIndex:indexPath.row];	
}

 - (NSIndexPath*) indexPathForItem:(GroceryItem*)item
{
	// figure out which section array the item is in
	NSString* firstLetter = [self firstLetterForItem:item];

	BOOL foundIt = NO;
	int section = 1; // skip search cell
	for (NSString* eachLetter in itemNameIndexArray)
	{
		if ([eachLetter isEqual:firstLetter]) 
		{
			foundIt = YES;
			break;
		}
		section++;
	}	
	if (!foundIt) {
		return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
	}
	
	// we found the section (as expected), now find the row
	foundIt = NO;
	NSArray* sectionItems = [itemNameIndexDict objectForKey:firstLetter];
	
	NSInteger row = 0;
	for (GroceryItem* eachItem in sectionItems)
	{
		if (eachItem == item) 
		{
			foundIt = YES;
			break;
		}
		row++;
	}
	if (!foundIt) {
		row = NSNotFound;
	}
	
	return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	// want to hide the section index when searching, and when in edit mode (but not in
	// add ingredients, which is also considered edit mode). We don't know in this class
	//if we are an "add" style or "delete" style list, so that's set from the outside.
	if (isSearching || (tableView.editing && isDeleteStyle))
	{
		return nil;
	}
	else 
	{
		return sectionArray;	
	}
}
- (NSInteger)tableView:(UITableView *)tableView 
		sectionForSectionIndexTitle:(NSString *)title 
		atIndex:(NSInteger)index
{
	if ([title isEqual:@"{search}"])
	{
		return 0; // search cell
	}
	else
	{
		// if the title was #, the index will be the last one
		if ([title isEqual:@"#"])
		{
			return itemNameIndexArray.count;
		}
				
		// replace the bullet if one exists for the country with the letter it should
		// scroll the user to. This is a "W" in Danish
		NSUInteger sectionIndex = [sectionArray indexOfObject:title];
		title = [sectionLookupArray objectAtIndex:sectionIndex];
		
		int n;
		for (n = 0; n < itemNameIndexArray.count; n++) 
		{
			NSString* currentTitle = [itemNameIndexArray objectAtIndex:n];
			
			NSComparisonResult res = [currentTitle localizedCaseInsensitiveCompare:title];
			if ((res == NSOrderedDescending) || (res == NSOrderedSame))
			{
				// Current index is at or after the desired letter - that's the one
				// we want
				break;
			}
		}
		
		// if we made it all the way to the end of the loop (looking for "Z", but last 
		// index is "T") for example, n will be one more than # of sections. Deal with it.
		if (n == itemNameIndexArray.count) {
			n--;
		}
		
		// add one to the sections, because the search cell is the first section
		return n + 1;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return !((indexPath.row == 0) && (indexPath.section == 0));
}

// actually performs the deletion of an item. Eventually will check to see if that
// item is used in recipes and give the user a chance to change his mind
- (BOOL)shouldDeleteGroceryItem:(GroceryItem*)item
{
	BOOL shouldDelete = YES;
	
	NSMutableArray* recipeNames = [NSMutableArray array];
	NSUInteger count = [App_database countOfRecipesUsingItem:item withNames:recipeNames];
	
	if (count > 0)
	{
		NSLog(@"TODO: Warn user. Used in recipes %@", recipeNames);
		// TODO: warn user. In beta 7, calling reloadData is the only way
		// to get the table to redraw properly, which occasionally causes 
		// an EXC_BAD_ACCESS later. Calling setNeedsLayout or setNeedsDisplay
		// doesn't redraw properly.
	}
	[items removeItem:item];
	[App_database saveToDisk];
	
	[self dataHasChanged];
	
	return shouldDelete;
}

- (void)tableView:(UITableView *)tv
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		if ([self shouldDeleteGroceryItem:[self itemAtIndexPath:indexPath]])
		{
			// Animate the deletion from the table.
			// Note: there are bugs in this with deleting the last item in a section (beta 8)
			// as well as the final item crashing the app. Hopefully this will be fixed or 
			// we'll have to avoid deleting the last item.
			if ([tv numberOfRowsInSection:indexPath.section] == 1)
			{
				[tv deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] 
				  withRowAnimation:UITableViewRowAnimationFade];			
			} 
			else
			{
				[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						  withRowAnimation:UITableViewRowAnimationFade];
			}
		}
    }
	else if (editingStyle == UITableViewCellEditingStyleInsert) 
	{
		if (delegate && [delegate respondsToSelector:@selector(didCommitInsert:)] ) 
		{
			[delegate didCommitInsert:indexPath];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{	
	UITableViewCell* cell = nil;
	if ( [delegate respondsToSelector:@selector(willCreateCellForRowAtIndexPath:)] ) 
	{
		cell = [delegate willCreateCellForRowAtIndexPath:indexPath];
	}

	// no delegate, or delegate returned nil
	if (cell == nil)
	{
		// Get the object to display and set the value in the cell	
		GroceryItem* item = [self itemAtIndexPath:indexPath];
		
		// see if there's a cell we can reuse
		cell = (ItemTableViewCell*) [tv dequeueReusableCellWithIdentifier:@"GBCBItem"];
		if (cell == nil)
		{
			cell = [[[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											 reuseIdentifier:@"GBCBItem"] autorelease];
		}
		[(ItemTableViewCell*)cell configureItem:item];
	}
	return cell;
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}
@end
