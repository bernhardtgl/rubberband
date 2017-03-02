//
//  ShopViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ShopViewController.h"
#import "RubberbandAppDelegate.h"
#import "ItemTableViewCell.h"
#import "AislesTable.h"
#import "Aisle.h"
#import "ShoppingAisle.h"
#import "NewItemViewController.h"
#import "TableViewControllerUserPrefs.h"
#import "AislesViewController.h"
#import "ItemQuantity.h"

@implementation ShopViewController

@synthesize appController;
@synthesize tableView;
@synthesize prefs;

// init and dealloc
- init 
{
	if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Shop", @"Shop view navigation title");
		self.tabBarItem.image = [UIImage imageNamed:@"tab_shop.png"];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleEditItem:)
													 name:@"GBCBEditItemNotification"
												   object:nil];
		
		// create the underlying datamodel for maintaining our shopping list
		shopViewDataSource = [[ShopViewDataSource alloc] initWithDatabase:App_database];
		shopViewDataSource.delegate = self;

		showEasterEgg = NO;
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc THE ShopViewController");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[shopViewDataSource release];
	[prefs release];
	
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
	
	UINavigationItem *navItem = self.navigationItem;
	
	// Add the "Checkout" button to the navigation bar
	checkoutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Check Out", @"Check out button")
													  style:UIBarButtonItemStylePlain
													 target:self action:@selector(checkOutAction:)];
	navItem.leftBarButtonItem = checkoutButton;

	// Add the Aisle edit button to the navigation bar
	aislesButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Aisles", @"Aisle edit button")
													  style:UIBarButtonItemStyleDone
													 target:self action:@selector(aisleEditAction:)];
//!	navItem.leftBarButtonItem = aislesButton;   //TODO - figure how where this button should go.
	
	
	// Add the "Edit" button to the navigation bar
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds 
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = shopViewDataSource;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.allowsSelectionDuringEditing = YES;
	
	tableView.sectionIndexMinimumDisplayRowCount = 1;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self.view addSubview: tableView];
		
	// create the "done shopping" view
	doneShoppingView = [self createDoneShoppingView];
	[self.view addSubview:doneShoppingView];

	prefs = [[TableViewControllerUserPrefs alloc] initWithTableView:tableView];

	[self checkViewState];
}

//
//	Creates and initializes the done shopping view.
//	Caller is responsible for adding this view to the 
//	view controller.
//
- (UIView*) createDoneShoppingView
{
	// create the "done shopping" view
	UIView* dsView = [[UIView alloc] initWithFrame:self.view.bounds];
	[dsView setBackgroundColor:[UIColor whiteColor]];
	
	// add title text
	CGRect titleRect = self.view.bounds;
	titleRect.origin.y = titleRect.size.height/5;  // ~20% down from top
	titleRect.size.height = 70;
	titleRect.origin.x = 10;
	titleRect.size.width = 	titleRect.size.width - 20;	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:titleRect];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	[titleLabel setText:NSLocalizedString(@"You're done shopping", @"")];
	[titleLabel setNumberOfLines:2];
	[titleLabel setLineBreakMode:UILineBreakModeWordWrap];
	UIFont* titleFont = [UIFont boldSystemFontOfSize:20];
	[titleLabel setFont:titleFont];
	[titleLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
	
	[dsView addSubview:titleLabel];
	
	// add sub-title
	titleRect.origin.y = titleRect.origin.y + titleRect.size.height;
	UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:titleRect];
	[subTitleLabel setTextAlignment:UITextAlignmentCenter];
	[subTitleLabel setNumberOfLines:2];
	[subTitleLabel setLineBreakMode:UILineBreakModeWordWrap];
	[subTitleLabel setText:NSLocalizedString(@"Woohoo! You don't need anything\r\nelse today.", @"")];
	UIFont* subTitleFont = [UIFont boldSystemFontOfSize:16];
	[subTitleLabel setFont:subTitleFont];
	[subTitleLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
	[dsView addSubview:subTitleLabel];
	
	return dsView;
}

//
//	Check the view and update buttons and views
//	based on the current state of this screen.
//
- (void)checkViewState
{
	BOOL haveItems = ([[[shopViewDataSource haveShoppingAisle] aisleItems] count] > 0);
	BOOL doneShopping = ([shopViewDataSource shoppingAisleCount] == 0);
	
	if (doneShopping)
	{
		[self.view bringSubviewToFront:doneShoppingView];
		[self.editButtonItem setEnabled:NO];
		[checkoutButton setEnabled:NO]; 
	}
	else
	{
		[self.view bringSubviewToFront:tableView];
		[self.editButtonItem setEnabled:YES];
		[checkoutButton setEnabled:haveItems];
	}	
}

// Invoked when the user hits the edit button.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	UINavigationItem *navItem = self.navigationItem;	
	if (editing)
	{
		// switch the left nav bar button from Checkout to Aisles mode
		navItem.leftBarButtonItem = aislesButton;
	}
	else
	{
		// switch the left nav bar button from Aisles to Checkout mode
		navItem.leftBarButtonItem = checkoutButton;
	}
	
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
	[tableView setEditing:editing animated:animated];
	
	// causes the cells to re-layout, which hides the images for
	// edit mode
	[tableView setNeedsLayout];
}

- (void)reloadAndReselect;
{
	[tableView reloadData];
	[self checkViewState];
}

//
//	Sent to the controller before the view appears and any animations begin.
//	See UIViewController.
//
- (void)viewWillAppear:(BOOL)animated
{
	// rebuild our shopping list each time we enter the shopping view
	[shopViewDataSource rebuildShoppingList];
	[self reloadAndReselect];
	NSLog(@"::Item viewWillAppear");

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
		int testSectionIndex = [testIndexPath indexAtPosition:0];
		int testRowIndex = [testIndexPath indexAtPosition:1];
		int numberOfSections = [tableView numberOfSections];
		if ((testSectionIndex >= 0) && (testSectionIndex < numberOfSections))
		{
			int numberOfRowsinSection = [tableView numberOfRowsInSection:testSectionIndex];
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
	[self reloadAndReselect];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
	// Release anything that's not essential, such as cached data.
}

//
//	Event handler called when the user taps the item to check it off.
//
- (void)handleWantToCheckItem:(GroceryItem*)item atIndexPath:(NSIndexPath*)indexPath
{
	if (item != nil)
	{
		item.haveItem = !item.haveItem;
		
		if ([item.name isEqual: 
				NSLocalizedString(@"Broccoli", @"Easter egg item: set to the item you like least")])
		{
			showEasterEgg = (item.haveItem);
		}

		// toggle the look of the cell, in place, then set a timer to move it in a
		// few tenths of a second
		ItemTableViewCell* cell = (ItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
		[cell configureItem:item];
		[cell setNeedsLayout];

		[NSTimer scheduledTimerWithTimeInterval:0.30 
										 target:self 
									   selector:@selector(onTimer:) 
									   userInfo:nil 
										repeats:NO];		
	}	
}
- (void)onTimer:(NSTimer*)timer
{
	[shopViewDataSource rebuildShoppingList];
	[self reloadAndReselect];
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
		[self presentModalViewController:nc animated:YES];
	}
}

- (void)handleEditItem:(NSNotification*)notification 
{
	// TODO: don't think I need this
	[shopViewDataSource rebuildShoppingList];
	
	// shouldn't have to do anything, because I've already edited the item
	[self reloadAndReselect];
}

// **************************************************************************************
// actions

//
//	Event handler called when the user clicks the checkout button.
//	"Checking out" amounts to reseting the quantityNeed to zero for items
//	that have previously been flagged as "haveItem".
//
- (void)checkOutAction:(id)sender
{
	NSString* msg;
	
	if (showEasterEgg)
	{
		msg = NSLocalizedString(@"This will reset all the items you have purchased.\r\nEwwww, you bought broccoli!",
								@"Easter egg checkout message");
		showEasterEgg = NO;
	}
	else
	{
		msg = NSLocalizedString(@"This will reset all the items you have purchased.",@"");
	}
	
	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@"" 
						  message:msg
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
						  otherButtonTitles:nil];
	[alert addButtonWithTitle:NSLocalizedString(@"Check Out", @"Check out button")];
	
	[alert show];
	[alert release];
}

//
//	Event handler called when the user clicks the aisles button.
//	Switch to the aisle editing screen to allow a user to reorganize the aisle order.
//
- (void)aisleEditAction:(id)sender
{
	AislesViewController* aislesVC = [[AislesViewController alloc] initEditOnly];
	aislesVC.aisles = [App_database aisles];
	
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:aislesVC];
	[self presentModalViewController:nc animated:YES];
	[nc release];
	[aislesVC release];
	
	// rebuild our shopping list
	[shopViewDataSource rebuildShoppingList];
	[self reloadAndReselect];	
}

- (void)updateList;
{
	[shopViewDataSource rebuildShoppingList];
	[self reloadAndReselect];	
}

- (void)clearList;
{
	[shopViewDataSource clearList];
	[self reloadAndReselect];
}

- (void)checkOut;
{
	[shopViewDataSource checkout];
	[self reloadAndReselect];
}
//
//	Called by the UIAlertView (confirmation dialog) that was launched when 
//	the user tapped the checkout button. We displayed the confirmation 
//	dialog and now the user has tapped either the "Check Out" or "Cancel" 
//	buttons.
//
- (void)modalView:(UIAlertView *)modalView 
		didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// if the user said "Check Out" (button 1), commit the delete
	if (buttonIndex == 1)
	{
		[self checkOut];
	}
}

// **************************************************************************************
// UITableViewDelegate methods

// check or edit the item when the row is selected
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	GroceryItem* item = [shopViewDataSource groceryItemAtIndexPath:indexPath];
	if (self.editing) 
	{
		[self handleWantToEditItem:item];
	} 
	else 
	{
		[self handleWantToCheckItem:item atIndexPath:indexPath];
	}
	[tv deselectRowAtIndexPath:indexPath animated:YES];	
}

// **************************************************************************************
- (void)didDeleteLastItem;
{
	self.editing = NO;
	[self reloadAndReselect];
} 

@end
