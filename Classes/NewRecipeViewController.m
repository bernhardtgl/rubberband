//
//  NewRecipeViewController
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/17/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NewRecipeViewController.h"
#import "Recipe.h"
#import "NameAndPictureView.h"
#import "NotesTableViewCell.h"
#import "ItemQtyTableViewCell.h"
#import "RubberbandAppDelegate.h"
#import "AddIngredientsViewController.h"
#import "QuantityViewController.h"
#import "GroceryItem.h"
#import "NotesViewController.h"

@implementation NewRecipeViewController

@synthesize tableView;
@synthesize isNewItem;
 
- (id)init
{
	if (self = [super init]) 
	{
		// Initialize your view controller.
		isNewItem = YES;
		isFirstAppearance = YES;
		didRecipeImageChange = NO;
		returningFromNotesScreen = NO;
		recipe = [[Recipe alloc] init];
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"***** dealloc NewRecipeViewController");
//	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[recipe release];

	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];

	[notesCell release];
	[nameAndPictureHeader release];

	[ingredientsVC release];
	[notesVC release];
	[quantityVC release];
	
	[super dealloc];
}

-(Recipe*)recipe
{
	return recipe;
}
-(void)setRecipe:(Recipe*)newValue
{
	[newValue retain];
	[recipe release];
	recipe = newValue;
}


- (void)loadView
{
	if (isNewItem) 
	{
		self.title = NSLocalizedString(@"New Recipe", @"Title for New Recipe");		
	} 
	else 
	{
		self.title = NSLocalizedString(@"Recipe", @"Title for Edit Recipe");		
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
	UIBarButtonItem* button;
	if (isNewItem) 
	{
		button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button")
												  style:UIBarButtonItemStyleDone
												 target:self action:@selector(doneAction:)];
	} 
	else 
	{
		button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button")
												  style:UIBarButtonItemStyleDone
												 target:self action:@selector(doneAction:)];
	}
	navItem.rightBarButtonItem = button;
	
	// and a cancel button, for New items only
	if (isNewItem) 
	{
		button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
												  style:UIBarButtonItemStylePlain
												 target:self action:@selector(cancelAction:)];
		navItem.leftBarButtonItem = button;
	}
	
	notesCell = [[NotesTableViewCell alloc] initWithFrame:CGRectZero];
	notesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	notesCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	notesCell.notes = recipe.notes;

	// the name and picture bar is actually a header, not a cell
	nameAndPictureHeader = [[NameAndPictureView alloc] initWithFrame:CGRectZero];
	nameAndPictureHeader.image = recipe.image;
	nameAndPictureHeader.parentVC = self;
	nameAndPictureHeader.placeholder = NSLocalizedString(@"Name", @"Placeholder name for recipe");
	nameAndPictureHeader.name = recipe.name;
	nameAndPictureHeader.link = recipe.link;

	// add it as the parent/content view to this UIViewController
	self.view = tableView;
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return nameAndPictureHeader;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return 90.0;
	} else {
		return 0;
	}
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

- (void)viewWillAppear:(BOOL)animated 
{
	[tableView reloadData];

	if (returningFromNotesScreen)
	{
		// show the notes, since they just entered them
		NSIndexPath* notesPath = [NSIndexPath indexPathForRow:0 inSection:1];
		[tableView scrollToRowAtIndexPath:notesPath
						 atScrollPosition:UITableViewScrollPositionBottom 
								 animated:NO];
		[tableView deselectRowAtIndexPath:notesPath animated:YES];
		
	}
	else
	{
		NSIndexPath* selPath = [tableView indexPathForSelectedRow];
		if (selPath != nil)
		{
			[tableView deselectRowAtIndexPath:selPath animated:NO];
		}		
	}
}

- (void)viewDidAppear:(BOOL)animated 
{
	// don't need to put the focus anywhere for this dialog, let the user start
	// wherever she wants
	isFirstAppearance = NO;
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // hide the keyboard before the view disappears, or next time it will not
	// be clickable!
}

// ================================================================================
// Actions 
//
- (void)doneAction:(id)sender
{
	[self.recipe setName:nameAndPictureHeader.name];	
	[self.recipe setLink:nameAndPictureHeader.link];	
	if (nameAndPictureHeader.didImageChange)
	{
		[self.recipe setImage:nameAndPictureHeader.image];
	}
	
	if (self.isNewItem) 
	{
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:@"GBCBNewRecipeNotification" object:self];		
	} 
	else 
	{
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:@"GBCBEditRecipeNotification" object:self];		
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancelAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark UITableViewDelegate and data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}
 
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
	{
		return recipe.itemsInRecipe.count + 1;
	}
	else
	{
		// one notes field
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}	

- (UITableViewCell *)tableView:(UITableView *)tv 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	switch (indexPath.section) 
	{
		case 0:
		{
			if (indexPath.row == recipe.itemsInRecipe.count)
			{
				UITableViewCell* cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
				cell.textLabel.text = NSLocalizedString(@"Add ingredients", @"Add item to recipe");			
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return cell;
			}
			else 
			{
				ItemQtyTableViewCell* cell = (ItemQtyTableViewCell*) [tv 
							dequeueReusableCellWithIdentifier:@"GBCBItemQty"];
				if (cell == nil)
				{
					cell = [[[ItemQtyTableViewCell alloc] 
											  initWithFrame:CGRectZero 
											reuseIdentifier:@"GBCBItemQty"] autorelease];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}

				GroceryItem* item = [recipe.itemsInRecipe objectAtIndex:indexPath.row];
				ItemQuantity* qty = [recipe quantityForItem:item];
				[cell configureItem:item withQuantity:qty];
				return cell;
			}
		}	
		case 1: 
		{
			return notesCell;
		}
	}
	return nil;	
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		return [notesCell cellHeight];
	} else {
		return 45.0; // the default
	}
}

- (BOOL) isIndexPathAnIngredient:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0) {
		return (indexPath.row < recipe.itemsInRecipe.count);
	} else{
		return NO;
	}
}
- (BOOL) isIndexPathAddIngredient:(NSIndexPath*)indexPath
{
	return ((indexPath.section == 0) && (indexPath.row == recipe.itemsInRecipe.count));
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		if ([self isIndexPathAnIngredient:indexPath]) {
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
	return (indexPath.section == 0);
}

- (void)tableView:(UITableView *)tv
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		GroceryItem* itemToDelete = [recipe.itemsInRecipe objectAtIndex:indexPath.row];
		[recipe removeItemFromRecipe:itemToDelete];
		
        // Animate the deletion from the table.
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
				  withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		// user clicked on the "+" sign
		[self tableView:tv didSelectRowAtIndexPath: indexPath];
	}
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if ([self isIndexPathAddIngredient:indexPath]) 
	{
		// Create the detail view lazily
		if (ingredientsVC == nil) 
		{
			ingredientsVC = [[AddIngredientsViewController alloc] init];
			ingredientsVC.delegate = self;
		}

		// set up the initial list of ingredients, turns those rows green
		NSMutableArray* itemsList = ingredientsVC.itemsInList;
		[itemsList removeAllObjects];
		for (GroceryItem* eachIngredient in recipe.itemsInRecipe)
		{
			[itemsList addObject:eachIngredient];
		}
		
		[[self navigationController] pushViewController:ingredientsVC animated:YES];
	}
	else if (indexPath.section == 0) // existing ingredients, user can edit the quantity
	{
		if (quantityVC == nil)
		{
			quantityVC = [[QuantityViewController alloc] init];
			quantityVC.delegate = self;
			quantityVC.showUsual = NO;
			quantityVC.neededText = NSLocalizedString(@"Needed for this recipe", @"Quantity for an ingredient in a recipe");
		}
		GroceryItem* item = [recipe.itemsInRecipe objectAtIndex:indexPath.row];
		ItemQuantity* qty = [recipe quantityForItem:item];
		quantityVC.qtyNeeded = qty;

		[[self navigationController] pushViewController:quantityVC animated:YES];
	}
	else if (indexPath.section == 1) // notes
	{
		if (notesVC == nil) 
		{
			notesVC = [[NotesViewController alloc] init];
			notesVC.delegate = self;
		}
		notesVC.notes = recipe.notes;
		[[self navigationController] pushViewController:notesVC animated:YES];
	}
}

- (void)didChangeIngredients:(NSMutableArray*)newIngredients;
{
	// first clear out any recipes that have been removed - need to copy
	// the array so we don't have problems deleting things out from under it
	NSMutableArray* oldItems = [recipe.itemsInRecipe copy];
	for (GroceryItem* eachOldItem in oldItems)
	{
		if (![newIngredients containsObject:eachOldItem])
		{
			[recipe removeItemFromRecipe:eachOldItem];
		}
	}
	[oldItems release];
	
	// now add the new items to the recipe
	for (GroceryItem* eachNewItem in newIngredients)
	{
		if (![recipe.itemsInRecipe containsObject:eachNewItem])
		{
			[recipe addItemToRecipe:eachNewItem withQuantity:nil];
		}
	}
}

- (void)didSaveNotes:(NSString*)notes
{
	recipe.notes = notes;
	notesCell.notes = notes;
	
	returningFromNotesScreen = YES;
}

#pragma mark DialogDelegate (for QuantityViewController)
- (void) didSave:(UITableViewController*)dialogController;
{
	// remember which item's quantity we were editing by what's selected
	NSUInteger selectedRow = [tableView indexPathForSelectedRow].row;
	
	GroceryItem* item = [recipe.itemsInRecipe objectAtIndex:selectedRow];
	ItemQuantity* qty = [recipe quantityForItem:item];
	
	// update the quantity object attached to the recipe
	qty.type = quantityVC.qtyNeeded.type;
	qty.amount = quantityVC.qtyNeeded.amount;
	
}

@end
