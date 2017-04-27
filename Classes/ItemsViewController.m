//
//  ItemsViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//
#import "ItemsViewController.h"
#import "RubberbandAppDelegate.h"
#import "GroceryItem.h"
#import "NewItemViewController.h"
#import "ItemTableViewCell.h"
#import "ItemsViewDataSource.h"
#import "GroceryItemsTable.h"
#import "Database.h"
#import "TableViewControllerUserPrefs.h"
#import "SearchBarCell.h"

@interface ItemsViewController(PrivateMethods)
- (void)scrollItemIntoView:(GroceryItem*)theItem;
@end

@implementation ItemsViewController

@synthesize tableView;
@synthesize prefs;

// init and dealloc
- init 
{
	if (self = [super init]) 
	{	
		isSearching = NO;
		
		self.title = NSLocalizedString(@"Items", @"Item view navigation title");
		self.tabBarItem.image = [UIImage imageNamed:@"tab_items.png"];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleNewItem:)
													 name:@"GBCBNewItemNotification"
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleEditItem:)
													 name:@"GBCBEditItemNotification"
												   object:nil];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardOnScreen:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
		dataSource = [[ItemsViewDataSource alloc] init];		
		dataSource.delegate = self;
		dataSource.isDeleteStyle = YES;
	}
	return self;
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [searchCell keyboardShown:keyboardFrame];
}

- (void)dealloc
{	
	NSLog(@"***** dealloc THE ItemViewController");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	
	[addButton release];
	[doneButton release];
	[searchCell release];
	
	[dataSource release];
	[prefs release];
	
    [super dealloc];
}


- (void)loadView 
{		
	NSLog(@"loadView start");
	// setup the parent content view to host the UITableView
	UIView *contentView = [[UIView alloc] 
						   initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
	[contentView setBackgroundColor:[UIColor blackColor]];
	self.view = contentView;
	[contentView autorelease];
	
	// setup our content view so that it auto-rotates along with the UViewController
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UINavigationItem *navItem = self.navigationItem;
	
	// Add the "+" button to the navigation bar
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															  target:self 
															  action:@selector(newAction:)];
	navItem.leftBarButtonItem = addButton;

	// this button is not placed on the Nav bar yet, only when searching is active
	doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", "done searching")
												style:UIBarButtonItemStylePlain 
												 target:self
												action:@selector(doneSearchingAction:)];
	
	// Add the "Edit" button to the navigation bar
    navItem.rightBarButtonItem = self.editButtonItem;

	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds 
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = dataSource;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.allowsSelectionDuringEditing = YES;
	
	tableView.sectionIndexMinimumDisplayRowCount = 1;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self.view addSubview: tableView];

	prefs = [[TableViewControllerUserPrefs alloc] initWithTableView:tableView];
	NSLog(@"loadView end");
}

- (void)newAction:(id)sender
{
	NewItemViewController* newView = [[NewItemViewController alloc] init];
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:newView];
    [self presentViewController:nc animated:YES completion:nil];
	[nc release];
	[newView release];
}

// Invoked when the user hits the edit button.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
	
	[tableView setEditing:editing animated:animated];

	// causes the cells to re-layout, which hides the images for
	// edit mode. Had to change to "reloadData" to get the section index to hide
//	[tableView setNeedsLayout];
	[tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated 
{
	// hack for now
	[dataSource dataHasChanged];
	[self reloadAndReselect:NO];

	[prefs viewWillAppear];
}

// add and remove these notification handlers, because we only want the active 
// view to "hear" the notificaiton
- (void)viewDidAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWantToIncreaseQuantity:)
												 name:@"GBCBIncreaseItemQuantity"
											   object:nil]; 
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:@"GBCBIncreaseItemQuantity" object:nil];	
}

//
//	Tests the specified index path to determine if the row and
//	section index are within the valid range for the table view.
//
- (BOOL)isValidTableViewIndexPath:(NSIndexPath*)testIndexPath
{
	BOOL ret = NO;
	if ((testIndexPath != nil) && ([testIndexPath length] == 2))
	{
		NSInteger testSectionIndex = [testIndexPath indexAtPosition:0];
		NSInteger testRowIndex = [testIndexPath indexAtPosition:1];
		NSInteger numberOfSections = [tableView numberOfSections];
		if ((testSectionIndex >= 0) && (testSectionIndex < numberOfSections))
		{
			NSInteger numberOfRowsinSection = [tableView numberOfRowsInSection:testSectionIndex];
			if ((testRowIndex >= 0) && (testRowIndex < numberOfRowsinSection))
			{
				ret = YES;
			}
		}		
	}
	return ret;
}

// this notification comes from the item cell, when the user taps on the number.
// increases the quantity by 1.
- (void)handleWantToIncreaseQuantity:(NSNotification*)notification
{
	ItemTableViewCell* cell = [notification object];
	GroceryItem* item = [[App_database groceryItems] itemForUid:cell.itemUid];
	
	item.qtyNeeded.amount = item.qtyNeeded.amount + item.qtyUsual.amount;

	// calling into the searchCell to reload its data is a bit of a hack, but
	// I didn't want to rewrite the whole notification infrastructure
	// for quantity tapping to use delegates right before releasing 1.1.
	if (isSearching) 
	{
		[searchCell reloadData];
	}
	else
	{
		[self reloadAndReselect:NO];
	}
}

// does the actual work of adding an item, from either the search bar or the
// dialog
- (void)addNewItem:(GroceryItem*)item
{
	GroceryItemsTable* items = [App_database groceryItems];
	[items addItem:item];
	[item setOwnerTable:items];
	[App_database saveToDisk];
	
	// hack for now
	[dataSource dataHasChanged];
}

// new item coming back from the dialog
- (void)handleNewItem:(NSNotification*)notification 
{
	NewItemViewController* itemView = [notification object];
	GroceryItem* theItem = itemView.groceryItem;

	[self addNewItem:theItem];
	[self reloadAndReselect:NO];
	[self scrollItemIntoView:theItem];
}

- (void)handleEditItem:(NSNotification*)notification 
{
	NewItemViewController* itemView = [notification object];
	GroceryItem* theItem = itemView.groceryItem;
	[App_database saveToDisk];

	// hack for now
	[dataSource dataHasChanged];

	// if we are searching, the view will get redrawn when it's shown again
	// this check prevents scrolling flicker
	if (!isSearching)
	{
		// shouldn't have to do anything, because I've already edited the item
		[self scrollItemIntoView:theItem];
	}
}

- (void)scrollItemIntoView:(GroceryItem*)theItem
{
	// scroll the new item into view
	NSIndexPath* path = [dataSource indexPathForItem:theItem];
	[tableView scrollToRowAtIndexPath:path 
					 atScrollPosition:UITableViewScrollPositionMiddle 
							 animated:YES];
}

- (void)handleWantToEditItem:(GroceryItem*)item 
{
	if (item != nil)
	{
		NewItemViewController* editView = [[NewItemViewController alloc] init];
		editView.groceryItem = item;
		editView.isNewItem = NO;

		UINavigationController* nc = [[UINavigationController alloc] 
									  initWithRootViewController:editView];
        [self presentViewController:nc animated:YES completion:nil];
		[nc release];
		[editView release];
	}
}

- (void)updateList;
{
	[dataSource dataHasChanged];
	[self reloadAndReselect:NO];
}

- (void)reloadAndReselect:(BOOL)animated 
{
	NSLog(@"RR Called");
	[tableView reloadData]; // don't call setNeedsDisplay or setNeedsLayout - causes crash
//    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
//					 atScrollPosition:UITableViewScrollPositionTop 
//							 animated:animated];

//    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] 
//						   animated:animated 
//					 scrollPosition:UITableViewScrollPositionNone];	
}

- (void) didSelectGroceryItem:(GroceryItem*)item inCell:(UITableViewCell*)cell;
{
	ItemTableViewCell* itemCell = (ItemTableViewCell*)cell;
	if (self.editing) 
	{
		[self handleWantToEditItem:item];
	} 
	else 
	{
		// update the quantities
		if (item.qtyNeeded.amount == 0) 
		{
			item.qtyNeeded.amount = item.qtyUsual.amount;
			item.qtyNeeded.type = item.qtyUsual.type;
			item.haveItem = NO;
		}
		else {
			item.qtyNeeded.amount = 0;
			item.haveItem = NO;
		}
		
		[itemCell configureItem:item];
		[itemCell setNeedsLayout];
	}	
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{		
	if (!((indexPath.section == 0) && (indexPath.row == 0)))
	{
		ItemTableViewCell* cell = (ItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
		[self didSelectGroceryItem:[dataSource itemAtIndexPath:indexPath]
							inCell:cell];
	}
	[tv deselectRowAtIndexPath:indexPath animated:YES];	
}

- (UITableViewCell*) willCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	// take care of creating the Search cell, so we can set its delegate to this
	// object
	if ((indexPath.row == 0) && (indexPath.section == 0))
	{
		if (searchCell == nil)
		{
			searchCell = [[SearchBarCell alloc] initWithFrame:CGRectZero];
			searchCell.delegate = self;
		}
		searchCell.fullList = [[App_database groceryItems] allItems];
		return searchCell;
	}
	else 
	{
		return nil;
	}
}

// =======================================================================================
#pragma mark SearchBarCell related code

- (void)searchBarTextDidBeginEditing:(SearchBarCell*)searchBarCell;
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = doneButton;
	
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
	self.navigationItem.leftBarButtonItem = addButton;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

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

// called when the search view wants to delete an item. This view is responsible
// for actually deleting it, and will use the data source to do it...
- (BOOL)shouldDeleteGroceryItem:(GroceryItem*)item;
{
	BOOL shouldDelete = [dataSource shouldDeleteGroceryItem:item];
	
	// update the list of items held by the search cell
	if (shouldDelete)
	{
		searchCell.fullList = [[App_database groceryItems] allItems];
	}
	return shouldDelete;
}

// user wants to add an item, by clicking the + icon on the search bar
- (void)addNewItemWithName:(NSString*)name
{
	GroceryItem* item = [[GroceryItem alloc] init];
	item.name = name;
	item.qtyNeeded.amount = item.qtyUsual.amount;
	item.qtyNeeded.type = item.qtyUsual.type;
	
	[self addNewItem:item];
	
	searchCell.fullList = [[App_database groceryItems] allItems];
}

// clicks the "Done" (searching) button - pass that along to the search cell
- (void)doneSearchingAction:(NSNotification*)notification
{
	[searchCell endSearching];
}

- (UITableViewCell*) createCellInTableView:(UITableView*) tv 
								   forItem:(GroceryItem*) item;
{
	ItemTableViewCell* cell = (ItemTableViewCell*)
			[tv dequeueReusableCellWithIdentifier:@"GBCBItemSearch"];
	
	if (cell == nil)
	{
		cell = [[[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:@"GBCBItemSearch"] autorelease];
	}
	
	[cell configureItem:item];
	return cell;
}

@end
