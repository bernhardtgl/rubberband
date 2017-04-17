//
//  NewItemViewController
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/15/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NewItemViewController.h"
#import "GroceryItem.h"
#import "TextTableViewCell.h"
#import "QuantityTableViewCell.h"
#import "AisleTableViewCell.h"
#import "AislesViewController.h"
#import "RubberbandAppDelegate.h"
#import "AddRecipesViewController.h"
#import "Recipe.h"
#import "ItemQuantity.h"
#import "QuantityViewController.h"

@implementation NewItemViewController

@synthesize tableView;
@synthesize isNewItem;
@synthesize allowAddRecipes;

#define SECTION_NAME 0
#define SECTION_RECIPES 1
#define SECTION_COUNT 2

- (id)init
{
	if (self = [super init]) 
	{
		// Initialize your view controller.
		isNewItem = YES;
		isFirstAppearance = YES;
		allowAddRecipes = YES;
		
		groceryItem = [[GroceryItem alloc] init];
		
		recipesContainingItem = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleAisleChange:)
													 name:@"GBCBAisleChangeNotification"
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleWantQuantityView:)
													 name:@"GBCBWantNumberView"
												   object:nil];
		
		NSLog(@"init NewItemViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"***** dealloc NewItemViewController");
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[groceryItem release];
	[nameCell release];
	[quantityCell release];
	[aisleCell release];
	[doneButton release];
	
	
	[recipesContainingItem release];
	
	[aislesVC release];
	[quantityVC release];
	[recipesVC release];
	
	[super dealloc];
}


- (void)loadView
{
	if (isNewItem) 
	{
		self.title = NSLocalizedString(@"New Item", @"Title for New Item");		
	} 
	else 
	{
		self.title = NSLocalizedString(@"Item", @"Title for Edit Item");		
	}
	
	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
											 style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.editing = YES;
	tableView.allowsSelectionDuringEditing = YES;
	
	UINavigationItem* navItem = self.navigationItem;

	// Add the "Done" button to the navigation bar
	if (isNewItem) 
	{
		doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button")
												  style:UIBarButtonItemStyleDone
												 target:self action:@selector(doneAction:)];
		doneButton.enabled = NO;
	} 
	else 
	{
		doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button")
												  style:UIBarButtonItemStyleDone
												 target:self action:@selector(doneAction:)];
	}
	navItem.rightBarButtonItem = doneButton;
	
	// and a cancel button, for New items only
	if (isNewItem) 
	{
		UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
												  style:UIBarButtonItemStylePlain
												 target:self action:@selector(cancelAction:)];
		navItem.leftBarButtonItem = button;
		[button release];

		// bit of a hack, but we don't want to set qty to 1 if we're adding through
		// the Add Ingredients screen
		if (allowAddRecipes) 
		{
			groceryItem.qtyNeeded.amount = 1;		
		}
	}
	

	// Create the controls
	nameCell = [[TextTableViewCell alloc] initWithFrame:CGRectZero];
	nameCell.placeholder = NSLocalizedString(@"Name", @"Placeholder for item name");
	nameCell.textField.text = self.groceryItem.name;
	nameCell.delegate = self;
	
	quantityCell = [[QuantityTableViewCell alloc] initWithFrame:CGRectZero];
	quantityCell.quantity = self.groceryItem.qtyNeeded;
	quantityCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	quantityCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

	aisleCell = [[AisleTableViewCell alloc] initWithFrame:CGRectZero];
	aisleCell.aisle = self.groceryItem.aisle;
	aisleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	aisleCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// add it as the parent/content view to this UIViewController
	self.view = tableView;
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

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed; scroll to the top of the list
	[tableView reloadData];
	
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] 
						   animated:animated 
					 scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewDidAppear:(BOOL)animated 
{
	// TODO: refactor this a little bit, shouldn't need to know the internals
	// of the nameCell
	if (isNewItem && isFirstAppearance) 
	{		
		[[nameCell textField] becomeFirstResponder];	
	}
	isFirstAppearance = NO;
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // hide the keyboard before the view disappears, or nect time it will not
	// be clickable!
	[[nameCell textField] resignFirstResponder];
}

// called when the Name is changed
- (void)textField:(UITextField *)textField willChangeTo:(NSString*)text;
{
	BOOL willHaveName = (text.length > 0);
	doneButton.enabled = willHaveName;
}

- (void)handleAisleChange:(NSNotification*)notification
{
	// update the item itself and the aisle in the UI cell
	Aisle* aisle = aislesVC.selectedAisle;
	[groceryItem setAisle:aisle];
	[aisleCell setAisle:aisle];
}

- (void)doneAction:(id)sender
{
	// save new item if the user edited the name
	if ([nameCell textValue].length > 0)
	{
		
		[self.groceryItem setName:nameCell.textValue];	
		
		if (self.isNewItem) {
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"GBCBNewItemNotification" object:self];		
		} else {
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"GBCBEditItemNotification" object:self];		
		}
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

// Standard table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (allowAddRecipes) {
		return SECTION_COUNT;
	} else {
		return SECTION_COUNT - 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == SECTION_RECIPES)
	{
		return [recipesContainingItem count] + 1;
	}
	else 
	{
		return 3;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}	

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	switch (indexPath.section) {
		case SECTION_NAME: 
		{
			if (indexPath.row == 0) {
				return nameCell;
			}
			else if (indexPath.row == 1) {
				return aisleCell;
			}
			else if (indexPath.row == 2) {
				return quantityCell;
			}
		}
		case SECTION_RECIPES:
		{
			UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
			if (indexPath.row == recipesContainingItem.count)
			{
				cell.textLabel.text = NSLocalizedString(@"Add to recipes",@"");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else 
			{
				GroceryItem* item = [recipesContainingItem objectAtIndex:indexPath.row];
				cell.textLabel.text = item.name;
			}
			return cell;
		}
	}
	return nil;	
}

- (NSIndexPath *)tableView:(UITableView *)tv 
		willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (([indexPath section] == 0) && ([indexPath row] == 0))
	{	
	}
	else
	{
		[[nameCell textField] resignFirstResponder];
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if ((indexPath.section == SECTION_NAME) && (indexPath.row == 1))
	{
		// Create the detail view lazily
		if (aislesVC == nil) 
		{
			aislesVC = [[AislesViewController alloc] init];
			aislesVC.selectedAisle = groceryItem.aisle;
			aislesVC.aisles = [App_database aisles];
		}
		[[self navigationController] pushViewController:aislesVC animated:YES];
	}
	else if ((indexPath.section == SECTION_NAME) && (indexPath.row == 2))
	{
		// Create the detail view lazily
		if (quantityVC == nil) 
		{
			quantityVC = [[QuantityViewController alloc] init];
			quantityVC.delegate = self;
		}
		quantityVC.qtyNeeded = groceryItem.qtyNeeded;
		quantityVC.qtyUsual = groceryItem.qtyUsual;
		[[self navigationController] pushViewController:quantityVC animated:YES];
	}
	else if (indexPath.section == SECTION_RECIPES)
	{
		// if it's the "Add" button
		if (indexPath.row == recipesContainingItem.count) 
		{
			// Create the detail view lazily
			if (recipesVC == nil) 
			{
				recipesVC = [[AddRecipesViewController alloc] init];
				recipesVC.delegate = self;
			}

			// set up the initial list of recipes, turns those rows green
			NSMutableArray* recipesInList = recipesVC.recipesInList;
			[recipesInList removeAllObjects];
			for (Recipe* each in recipesContainingItem)
			{
				[recipesInList addObject:each];
			}
			
			[[self navigationController] pushViewController:recipesVC animated:YES];
		}
	}	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == SECTION_RECIPES)
	{
		if (indexPath.row < recipesContainingItem.count) {
			return UITableViewCellEditingStyleDelete;
		} else {
			return UITableViewCellEditingStyleInsert;			
		}
	}
	else 
	{
		return UITableViewCellEditingStyleNone;
	}
}

- (BOOL)tableView:(UITableView *)tv shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.section == SECTION_RECIPES);
}

- (void)tableView:(UITableView *)tv
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		Recipe* recipeToRemove = [recipesContainingItem objectAtIndex:indexPath.row];
		[recipeToRemove removeItemFromRecipe:groceryItem];
		[recipesContainingItem removeObject:recipeToRemove];
		
        // Animate the deletion from the table.
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
				  withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		// user clicked on the "+" sign
		[self tableView:tv didSelectRowAtIndexPath:indexPath];
	}
}

- (void)setGroceryItem:(GroceryItem*)item
{
	[item retain];
	[groceryItem release];
	groceryItem = item;
	
	// reload the array of recipes that this item is an ingredient in
	[recipesContainingItem release];
	recipesContainingItem = [groceryItem.recipesContainingItem retain];
}

- (GroceryItem*)groceryItem
{
	return groceryItem;
}

- (void)didChangeRecipes:(NSMutableArray*)newRecipesList
{
	// first clear out any recipes that have been removed
	for (Recipe* eachOld in recipesContainingItem)
	{
		if (![newRecipesList containsObject:eachOld])
		{
			[eachOld removeItemFromRecipe:groceryItem];
		}
	}
	[recipesContainingItem removeAllObjects];
	
	// now add the item to all the new recipes
	for (Recipe* eachNew in newRecipesList)
	{
		[eachNew addItemToRecipe:groceryItem withQuantity:nil];
		[recipesContainingItem addObject:eachNew];
	}
}

// **************************************************************************************
#pragma mark DialogDelegate
- (void)didSave:(UITableViewController*)dialogController;
{
	// User saved from the quantity dialog. Update the appropriate properties
	// on the groceryItem
	if (dialogController == quantityVC)
	{
		groceryItem.qtyNeeded.type = quantityVC.qtyNeeded.type;
		groceryItem.qtyNeeded.amount = quantityVC.qtyNeeded.amount;
		groceryItem.qtyUsual.type = quantityVC.qtyUsual.type;
		groceryItem.qtyUsual.amount = quantityVC.qtyUsual.amount;
	}
} 

@end
