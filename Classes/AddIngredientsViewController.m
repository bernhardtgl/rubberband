//
//  AddIngredientsViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/24/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AddIngredientsViewController.h"
#import "ItemsViewDataSource.h"
#import "GroceryItem.h"
#import "AddObjectTableViewCell.h"
#import "NewItemViewController.h"
#import "RubberbandAppDelegate.h"
#import "Database.h"
#import "SearchBarCell.h"
#import "ItemQuantity.h"

@interface AddIngredientsViewController(PrivateMethods)
- (void) signalIngredientsChanged;
@end

@implementation AddIngredientsViewController

// init and dealloc
- init 
{
	if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Add Ingredients", @"View title");		
		dataSource = [[ItemsViewDataSource alloc] init];		
		dataSource.delegate = self; // so we can control the item cell
		dataSource.isDeleteStyle = NO;
		[dataSource dataHasChanged]; // bit of a hack for now

		itemsInList = [[NSMutableArray alloc] init];

		isAddingNewIngredient = NO;
		didChangeTheList = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleNewItem:)
													 name:@"GBCBNewItemNotification"
												   object:nil];
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc AddIngredientsViewController");
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[dataSource release];
	
	[addButton release];
	[doneButton release];
	[doneSearchingButton release];
	[searchCell release];

	[itemsInList release]; 
	
    [super dealloc];
}

- (void)loadView 
{

	// setup the parent content view to host the UITableView
	UIView *contentView = [[UIView alloc] 
						   initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setBackgroundColor:[UIColor blackColor]];
	self.view = contentView;
	[contentView autorelease];
	
	// setup our content view so that it auto-rotates along with the UViewController
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
			
	// Add the "+" and "Done" buttons to the navigation bar
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															  target:self 
															  action:@selector(newAction:)];
	doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", "Done button")
															  style:UIBarButtonItemStyleDone
															  target:self 
															  action:@selector(doneAction:)];
	self.navigationItem.leftBarButtonItem = addButton;
	self.navigationItem.rightBarButtonItem = doneButton;

	
	// this button is not placed on the Nav bar yet, only when searching is active
	doneSearchingButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", "done searching")
												  style:UIBarButtonItemStylePlain 
												 target:self
												 action:@selector(doneSearchingAction:)];
	
	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds 
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = dataSource;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.allowsSelectionDuringEditing = YES;
	tableView.editing = YES;
	tableView.sectionIndexMinimumDisplayRowCount = 1;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self.view addSubview: tableView];
}


- (void)viewWillAppear:(BOOL)animated 
{	
	NSIndexPath* indexPath = [tableView indexPathForSelectedRow];
	if (indexPath != nil) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	}

	// first time displaying, reset that no changes have been made
	if (!isAddingNewIngredient) 
	{
		didChangeTheList = NO;
	}
	isAddingNewIngredient = NO;
	
	[tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	if (didChangeTheList && !isAddingNewIngredient) 
	{
		[self signalIngredientsChanged];
	}	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;			
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

- (void)toggleItem:(GroceryItem*)item inCell:(AddObjectTableViewCell*)cell
{
	BOOL isAdded = ![itemsInList containsObject:item];
	
	if (isAdded) // adding an item, add it to the array, test
	{
		[itemsInList addObject:item];
	}
	else // removing the item
	{
		[itemsInList removeObject:item];
	}
	
	[cell configureObject:item.name isInList:isAdded];
	[cell setNeedsDisplay];
	
	didChangeTheList = YES;
}

- (void)toggleItemAtIndexPath:(NSIndexPath*)indexPath
{
	GroceryItem* theItem = [dataSource itemAtIndexPath:indexPath];
	AddObjectTableViewCell* cell = (AddObjectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

	[self toggleItem:theItem inCell:cell];
}

// called back from data source when user clicks on the + sign
- (void) didCommitInsert:(NSIndexPath*)indexPath;
{
	[self toggleItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (!((indexPath.section == 0) && (indexPath.row == 0)))
	{
		[self toggleItemAtIndexPath:indexPath];
		[tv deselectRowAtIndexPath:indexPath animated:YES];	
	}
}

- (void)signalIngredientsChanged
{
    if (delegate && [delegate respondsToSelector:@selector(didChangeIngredients:)]) 
	{
        [delegate didChangeIngredients:itemsInList];
    }
}

// delegate from the data source - a little confusing, yes, but this lets us use
// the same data source (lots of shared code) for both Items and Adding Ingredients
//
- (UITableViewCell*) willCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	if ((indexPath.row == 0) && (indexPath.section == 0))
	{
		if (searchCell == nil)
		{
			searchCell = [[SearchBarCell alloc] initWithFrame:CGRectZero];
			searchCell.delegate = self;
			searchCell.editingStyle = UITableViewCellEditingStyleInsert;
		}
		searchCell.fullList = [[App_database groceryItems] allItems];
		return searchCell;
	}
	else 
	{
		GroceryItem* item = [dataSource itemAtIndexPath:indexPath];
		AddObjectTableViewCell* cell = [[[AddObjectTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

		BOOL isInList = [itemsInList containsObject:item];
		[cell configureObject:item.name isInList:isInList];
		
		return cell;
	}
}

// user clicks on the "+" button, show the new dialog. Don't let them add recipes, though
// we don't want the user getting lost too deep in the dialogs
- (void)newAction:(NSNotification*)notification
{
	NewItemViewController* newView = [[NewItemViewController alloc] init];
	newView.allowAddRecipes = NO;
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:newView];
	
	isAddingNewIngredient = YES; // reset to NO when the view re-appears
	
    [self presentViewController:nc animated:YES completion:nil];
	[nc release];
	[newView release];
}

- (void)doneAction:(NSNotification*)notification
{
	// the work of notifying the calling view is done in the viewWillDisappear event
	[[self navigationController] popViewControllerAnimated:YES];		
}

// does the actual work of adding an item, from either the search bar or the
// dialog
- (void)addNewItem:(GroceryItem*)item
{
	// The main Items view will handle the GBCBNewItemNotification message, 
	// and add the item to the database.
	// we just need to redraw our tableview and add it to the ingredients list
	[dataSource dataHasChanged];
	[tableView reloadData];
	
	NSIndexPath* path = [dataSource indexPathForItem:item];
	
	[self toggleItemAtIndexPath:path];
	
	[tableView scrollToRowAtIndexPath:path 
					 atScrollPosition:UITableViewScrollPositionMiddle 
							 animated:YES];
}

- (void)handleNewItem:(NSNotification*)notification 
{
	NewItemViewController* itemView = [notification object];
	[self addNewItem:itemView.groceryItem];
}

// =======================================================================================
#pragma mark SearchBarCell related code

- (void)searchBarTextDidBeginEditing:(SearchBarCell*)searchBarCell;
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.rightBarButtonItem = doneSearchingButton;
	
	isSearching = YES;
	dataSource.isSearching = YES;
	
	// reload, so the section index is hidden
	[tableView reloadData];
	
	// hack: in 3.1, the tableView section indexes don't get reloded in this case - 
	// couldn't make it happen. So I'm manually hiding the section index titles during
	// searching
	for (UIView* v in [tableView subviews])
	{
		if([[[v class] description] isEqualToString:@"UITableViewIndex"])
		{
			v.hidden = YES;
		}
	}	
}

- (void)searchBarTextDidEndEditing:(SearchBarCell*)searchBarCell;
{
	self.navigationItem.hidesBackButton = NO;
	self.navigationItem.leftBarButtonItem = addButton;
	self.navigationItem.rightBarButtonItem = doneButton;
 	
	isSearching = NO;
	dataSource.isSearching = NO;
	
	// reload, in case the user changed one of the visible items
	[tableView reloadData];

	// hack: see above in searchBarTextDidBeginEditing
	for (UIView* v in [tableView subviews])
	{
		if([[[v class] description] isEqualToString:@"UITableViewIndex"])
		{
			v.hidden = NO;
		}
	}	
}

- (void) didSelectGroceryItem:(GroceryItem*)item inCell:(UITableViewCell*)cell;
{
	[self toggleItem:item inCell:(AddObjectTableViewCell*)cell];
}

// user wants to add an item, by clicking the + icon on the search bar
- (void)addNewItemWithName:(NSString*)name
{
	GroceryItem* item = [[GroceryItem alloc] init];
	item.name = name;
	item.qtyNeeded.amount = 0; // since we are adding to recipe, don't NEED the item yet
	
	GroceryItemsTable* items = [App_database groceryItems];
	[items addItem:item];
	[item setOwnerTable:items];
	[App_database saveToDisk];

	[itemsInList addObject:item];
	[dataSource dataHasChanged];
	didChangeTheList = YES;
	
	searchCell.fullList = [[App_database groceryItems] allItems];
}

// clicks the "Done" (searching) button - pass that along to the search cell
- (void)doneSearchingAction:(NSNotification*)notification
{
	[searchCell endSearching];
}

// create the cells for the search filter view
- (UITableViewCell*) createCellInTableView:(UITableView*) tv 
								   forItem:(GroceryItem*) item;
{
	AddObjectTableViewCell* cell = (AddObjectTableViewCell*)
			[tv dequeueReusableCellWithIdentifier:@"GBCBIngredientSearch"];
	
	if (cell == nil)
	{
		cell = [[[AddObjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:@"GBCBIngredientSearch"] autorelease];
	}
	
	BOOL isInList = [itemsInList containsObject:item];
	[cell configureObject:item.name isInList:isInList];
	return cell;
}

// =======================================================================================
#pragma mark Properties

- (id <AddIngredientsViewControllerDelegate>)delegate 
{
    return delegate;
}
- (void)setDelegate:(id <AddIngredientsViewControllerDelegate>)newDelegate 
{
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

- (NSMutableArray*)itemsInList
{
	return itemsInList;
}

@end

