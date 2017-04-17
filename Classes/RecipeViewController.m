//
//  RecipeViewController.m
//  View controller screen for the recipe details view.
//
//  Created by Craig on 6/7/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "RecipeViewController.h"
#import "RubberbandAppDelegate.h"
#import "Recipe.h"
#import "GroceryItem.h"
#import "ItemTableViewCell.h"
#import "NameAndPictureView.h"
#import "Database.h"
#import "GroceryItemsTable.h"
#import "NewRecipeViewController.h"
#import "ItemQuantity.h"
#import "ShareViewController.h"

@implementation RecipeViewController

- (id)init
{
	if (self = [super init]) 
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleEditRecipe:)
													 name:@"GBCBEditRecipeNotification"
												   object:nil];
	}
	return self;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[niView release];
	[tableView release];
	[nameAndPictureHeader release];
	
	[super dealloc];
}

//
//	Getter/setter for Recipe to be viewed
//
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
//	self.title = NSLocalizedString(@"Recipe", @"Title for View Recipe");		
	self.title = recipe.name;
	
	UIView* backgroundView = [[UIView alloc] initWithFrame:
							   [[UIScreen mainScreen] applicationFrame]];
	self.view = backgroundView;
	[backgroundView autorelease];
	
	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:[backgroundView bounds] 
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.editing = NO;
	tableView.allowsSelectionDuringEditing = NO;
	tableView.sectionIndexMinimumDisplayRowCount = 1;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
	
	// Add the "Edit" button to the navigation bar
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] 
								   initWithTitle:NSLocalizedString(@"Edit", @"Button")
										   style:UIBarButtonItemStylePlain
										  target:self 
										  action:@selector(editAction:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	// recipe detail header
	CGRect controlFrame = CGRectMake(0, 0, 320, 84); 
	nameAndPictureHeader = [[NameAndPictureView alloc] initWithFrame:controlFrame];
	nameAndPictureHeader.editing = NO;
	nameAndPictureHeader.parentVC = self;
	nameAndPictureHeader.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1.0];
	nameAndPictureHeader.image = recipe.image;
	nameAndPictureHeader.name = recipe.name;
	nameAndPictureHeader.notes = recipe.notes;
	nameAndPictureHeader.link = recipe.link;
	nameAndPictureHeader.delegate = self;
	
	// create the "done shopping" view
	niView = [[UIView alloc] initWithFrame:CGRectMake(0, 84, 320, 
													  backgroundView.bounds.size.height - 84)];
	[niView setBackgroundColor:[UIColor whiteColor]];
	
	// add title text
	CGRect titleRect = niView.bounds;
	titleRect.origin.y = titleRect.origin.y + 60; 
	titleRect.size.height = 30;
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:titleRect];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setText:NSLocalizedString(@"No ingredients", @"")];
	UIFont* titleFont = [UIFont boldSystemFontOfSize:20];
	[titleLabel setFont:titleFont];
	[titleLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
	[niView addSubview:titleLabel];
	
	// add sub-title
	CGRect subTitleRect = niView.bounds;
	subTitleRect.origin.y = subTitleRect.origin.y + 90; 
	subTitleRect.size.height = 60;
	UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:subTitleRect];
	[subTitleLabel setTextAlignment:NSTextAlignmentCenter];
	[subTitleLabel setNumberOfLines:2];
	[subTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[subTitleLabel setText:NSLocalizedString(@"Tap on 'Edit' to add some.", @"")];
	UIFont* subTitleFont = [UIFont boldSystemFontOfSize:16];
	[subTitleLabel setFont:subTitleFont];
	[subTitleLabel setTextColor:[UIColor colorWithWhite:0.1 alpha:0.4]];
	[niView addSubview:subTitleLabel];
	
	niView.hidden = YES;
	
	// add it as the parent/content view to this UIViewController
	[backgroundView addSubview:tableView];
	[backgroundView addSubview:niView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}
 
- (void)viewWillAppear:(BOOL)animated 
{
	[tableView reloadData];
	
	BOOL hasIngredients = (recipe.itemsInRecipe.count > 0);
	niView.hidden = hasIngredients;
	tableView.scrollEnabled = hasIngredients;
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

// this notification comes from the item cell, when the user taps on the number.
// increases the quantity by 1.
- (void)handleWantToIncreaseQuantity:(NSNotification*)notification
{
	ItemTableViewCell* cell = [notification object];
	GroceryItem* item = [[App_database groceryItems] itemForUid:cell.itemUid];
	
	item.qtyNeeded.amount = item.qtyNeeded.amount + item.qtyUsual.amount;
	[tableView reloadData];
}


// **************************************************************************************
// Table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0) {
		return 1;
	} else {
		return recipe.itemsInRecipe.count + 1;
	}
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}	

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		return nameAndPictureHeader.frame.size.height;
	} else {
		return 45.0; // the default
	}
}

- (GroceryItem*)itemAtIndexPath:(NSIndexPath*)indexPath
{
	if ((indexPath.row == 0) || (indexPath.section == 0))
	{
		return nil;
	} else {
		return [recipe.itemsInRecipe objectAtIndex:indexPath.row - 1];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	switch (indexPath.section) 
	{
		case 0:
		{
			UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
			[cell addSubview:nameAndPictureHeader];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
		case 1:
		{
			if (indexPath.row == 0)
			{
				UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
				cell.textLabel.text = NSLocalizedString(@"Add all ingredients", @"Add all ingredients to recipe");			
				cell.indentationWidth = 16;
				cell.indentationLevel = 1; // iPhone SDK 3.x
				return cell;
			}
			else 
			{
				GroceryItem* item = [self itemAtIndexPath:indexPath];
				ItemTableViewCell* cell = [[[ItemTableViewCell alloc] initWithFrame:CGRectZero] autorelease];
				[(ItemTableViewCell*)cell configureItem:item];				
				return cell;
			}
		}	
	}
	return nil;	
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 0)
	{		
		GroceryItem* item = [self itemAtIndexPath:indexPath];
		if (item == nil)
		{
			// Add all ingredients
			NSUInteger count = [recipe.itemsInRecipe count];
			NSUInteger n;
			NSString* msg = NSLocalizedString(@"You're trying to use two different units of measurement. Couldn't add these ingredients:\r\n",
											  @"Message when can't add two things together like pounds + liters");
			BOOL showMessage = NO;
			
			for (n = 0; n < count; n++)
			{
				item = [recipe.itemsInRecipe objectAtIndex:n];
				ItemQuantity* qtyInRecipe = [recipe quantityForItem:item];
				
				// add the quantity from the recipe
				BOOL increaseOK = [item.qtyNeeded increaseQuantityBy:qtyInRecipe];
				if (!increaseOK) 
				{
					msg = [msg stringByAppendingFormat:@"\r\n%@: %@",
						   item.name, qtyInRecipe.abbreviation];
					showMessage = YES;
				} 
				item.haveItem = NO;
				
				ItemTableViewCell* cell = (ItemTableViewCell*)[tableView 
															   cellForRowAtIndexPath:[NSIndexPath indexPathForRow:n+1 inSection:1]];
				[cell configureItem:item];
				[cell setNeedsLayout];
			}
			
			if (showMessage)
			{
				UIAlertView *alert = [[UIAlertView alloc]  
									  initWithTitle:@"" 
									  message:msg
									  delegate:nil 
									  cancelButtonTitle:NSLocalizedString(@"Close", @"Button text")
									  otherButtonTitles:nil];				
				[alert show];
				[alert release];
				
			}
		}
		else // toggle a single ingredient
		{
			ItemQuantity* qtyInRecipe = [recipe quantityForItem:item];

			if (item.qtyNeeded.amount == 0) 
			{
				item.qtyNeeded.amount = qtyInRecipe.amount;
				item.qtyNeeded.type = qtyInRecipe.type;
				item.haveItem = NO;
			}
			else {
				item.qtyNeeded.amount = 0;
				item.haveItem = NO;
			}
			
			ItemTableViewCell* cell = (ItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
			[cell configureItem:item];
			[cell setNeedsLayout];
		}
		[tv deselectRowAtIndexPath:indexPath animated:YES];	
	}
}

//
//	Invokes the recipe dialog allowing the user to view
//	and edit the recipe.
//
- (void)editAction:(NSNotification*)notification
{
	NewRecipeViewController* editView = [[NewRecipeViewController alloc] init];
	editView.recipe = recipe;
	editView.isNewItem = NO;
	
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:editView];
	[self presentViewController:nc animated:YES completion: nil];
	[nc release];
	[editView release];
}

- (void)handleEditRecipe:(NSNotification*)notification 
{
	// need to update the Name and Picture view, with the recipe's new settings
	nameAndPictureHeader.image = recipe.image;
	nameAndPictureHeader.name = recipe.name;
	nameAndPictureHeader.notes = recipe.notes;
	nameAndPictureHeader.link = recipe.link;
}

// **************************************************************************************
#pragma mark NameAndPictureViewDelegate

// called back from the NameAndPictureView when the uesr wants to email the recipe.
// That view doesn't know which recipe it's dealing with - we do
- (void)didWantToEmail;
{
	[App_shareViewController emailRecipe:recipe];
} 

@end
