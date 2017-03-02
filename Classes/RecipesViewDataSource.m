//
//  RecipesViewDataSource.m
//  Data source for the recipes list view.  This data model
//	provides organized access to the recipes displayed in 
//	the RecipesViewController.
//
//  Created by Craig on 5/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "RecipesViewDataSource.h"
#import "RubberbandAppDelegate.h"
#import "RecipesTable.h"
#import "RecipeTableViewCell.h"
#import "Database.h"

@implementation RecipesViewDataSource

//
// Initializes a recipes list using the 
// global Database object.
//
- init
{
	return [self initWithDatabase:App_database];
}

//
// Initializes a new recipe list using the specified
// database.
//
- (id) initWithDatabase: (Database*)database;
{
	if (self = [super init])
	{
		myDatabase = database;
		[self dataHasChanged];
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc RecipesViewDataSource");
    [super dealloc];
}

- (void) dataHasChanged
{
	[recipesSortedArray release];
	NSArray* recipesArray = myDatabase.recipes.recipesArray;
	
	// get ready to sort by creating a descriptor
	NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"name"
										ascending:YES 
										selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray* descriptors = [NSArray arrayWithObject:nameDescriptor];
	
	recipesSortedArray = [recipesArray sortedArrayUsingDescriptors:descriptors];
	[recipesSortedArray retain];
	
	[nameDescriptor release];
}

//
// Gets the recipe for the specified index path.  
// This method is called by the UI controller code to 
// draw the recipe cells within each aisle.
//
- (Recipe*)recipeAtIndexPath:(NSIndexPath*)indexPath
{
	Recipe* ret = [recipesSortedArray objectAtIndex:indexPath.row];
	return ret;
}

- (NSIndexPath*)indexPathForRecipe:(Recipe*)theRecipe
{
	NSUInteger index = [recipesSortedArray indexOfObject:theRecipe];
	return [NSIndexPath indexPathForRow:index inSection:0];
}

// **************************************************************************************
// UITableView data source methods

//
//	Called by the UITableView to get the number of sections to 
//	display in the table view.  
// 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
	return 1;
}

//
//	Called by the UITableView to get the number of rows (recipes) in
//	the specified section.
//
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	return [recipesSortedArray count];
}

//
//	Called by the UITableView to get the title text for the specified 
//	section.
//
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	return nil;
}	

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{

    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		// first, remove recipe at index path from the data source
		Recipe* recipeToDelete = [self recipeAtIndexPath:indexPath];		
		if (recipeToDelete != nil)
		{
			// last, remove the recipe from the DB table
			[[myDatabase recipes] removeRecipe:recipeToDelete];			
			[myDatabase saveToDisk];
		}
		[self dataHasChanged];
		
        // Animate the deletion from the table.
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
				  withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	// Get the object to display and set the value in the cell	
	Recipe* recipe = [self recipeAtIndexPath:indexPath];
	
	UITableViewCell* cell = nil;
    if ( [delegate respondsToSelector:@selector(willCreateCellForRowAtIndexPath:)] ) 
	{
		cell = [delegate willCreateCellForRowAtIndexPath:indexPath];
	}
	
	// no delegate, or delegate returned nil
	if (cell == nil)
	{
		cell = [[[RecipeTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		[(RecipeTableViewCell*)cell configureRecipe:recipe];
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
