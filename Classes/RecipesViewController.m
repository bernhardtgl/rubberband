//
//  RecipesViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "RecipesViewController.h"
#import "RubberbandAppDelegate.h"
#import "RecipeTableViewCell.h"
#import "NewRecipeViewController.h"
#import "RecipeViewController.h"
#import "RecipesTable.h"
#import "Recipe.h"
#import "Database.h"
#import "TableViewControllerUserPrefs.h"

@implementation RecipesViewController

@synthesize tableView;
@synthesize prefs;

// init and dealloc
- init 
{
	if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Recipes", @"Recipes view navigation title");
		self.tabBarItem.image = [UIImage imageNamed:@"tab_recipes.png"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleNewRecipe:)
													 name:@"GBCBNewRecipeNotification"
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleEditRecipe:)
													 name:@"GBCBEditRecipeNotification"
												   object:nil];
		
		dataSource = [[RecipesViewDataSource alloc] initWithDatabase:App_database];
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc THE RecipesViewController");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[dataSource release];
	[prefs release];
	
    [super dealloc];
}

- (void)loadView 
{
	// setup the parent content view to host the UITableView
	UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[view setBackgroundColor:[UIColor blackColor]];
	self.view = view;
	[view release];
	
	UINavigationItem *navItem = self.navigationItem;
	
	// Add the "+" button to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															  target:self 
															  action:@selector(newAction:)];
	
	navItem.leftBarButtonItem = button;	
	// Add the "Edit" button to the navigation bar
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds 
											 style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = dataSource;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.rowHeight = 65;
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableView.allowsSelectionDuringEditing = YES;	
	
	prefs = [[TableViewControllerUserPrefs alloc] initWithTableView:tableView];
	[self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[prefs viewWillAppear];
	
	NSIndexPath* selPath = [tableView indexPathForSelectedRow];
	if (selPath != nil)
	{
		[tableView deselectRowAtIndexPath:selPath animated:NO];
	}		
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

//
//	Invokes the recipe dialog allowing the user to view
//	and edit an existing item.
//
- (void)handleWantToEditRecipe:(Recipe*)recipe 
{
	if (recipe != nil)
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
}

//
//	Invokes the recipe dialog allowing the user to view
//	an existing recipe.
//
- (void)handleWantToViewRecipe:(Recipe*)recipe animated:(BOOL)animated;
{
	if (recipe != nil)
	{
		RecipeViewController* recipeView = [[RecipeViewController alloc] init];
		recipeView.recipe = recipe;
		
//!		UINavigationController* nc = [[UINavigationController alloc] 
//!									  initWithRootViewController:recipeView];
//!		[self presentModalViewController:nc animated:YES];
//!		[nc release];
//!		[recipeView release];
		[[self navigationController] pushViewController:recipeView animated:animated];
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

- (void)scrollIntoView:(Recipe*)theRecipe
{
	// scroll the new item into view
	NSIndexPath* path = [dataSource indexPathForRecipe:theRecipe];
	[tableView scrollToRowAtIndexPath:path 
					 atScrollPosition:UITableViewScrollPositionMiddle 
							 animated:YES];
}

#pragma mark Actions

- (void)newAction:(id)sender
{
	[self createNewRecipeWithName:@"" link:@""];
}

- (void)createNewRecipe:(Recipe*)r;
{
	NewRecipeViewController* newView = [[NewRecipeViewController alloc] init];
	[newView setRecipe:r];

	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:newView];
	[self presentViewController:nc animated:YES completion: nil];
	[nc release];
	[newView release];
}

- (void)createNewRecipeWithName:(NSString*)name link:(NSString*)link
{
	NewRecipeViewController* newView = [[NewRecipeViewController alloc] init];
	[newView recipe].name = name;
	[newView recipe].link = link;
	
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:newView];
	[self presentViewController:nc animated:YES completion: nil];
	[nc release];
	[newView release];
}

- (void)handleNewRecipe:(NSNotification*)notification 
{
	NewRecipeViewController* rvc = [notification object];
	Recipe* theRecipe = [rvc recipe];
	
	RecipesTable* recipes = [App_database recipes];
	[recipes addRecipe:theRecipe];
	[App_database saveToDisk];
//TODO	[theRecipe setOwnerTable:recipes];
	
	[dataSource dataHasChanged];
	[tableView reloadData];
	[self scrollIntoView:theRecipe];
}

- (void)handleEditRecipe:(NSNotification*)notification 
{
	// shouldn't have to do anything, because I've already edited the item
	[App_database saveToDisk];

	[dataSource dataHasChanged];
	[tableView reloadData];

	NewRecipeViewController* rvc = [notification object];
	Recipe* theRecipe = [rvc recipe];
	[self scrollIntoView:theRecipe];
}


// **************************************************************************************
// UITableViewDelegate methods

// Invoked when the user hits the edit button.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
	[tableView setEditing:editing animated:animated];
	
	// causes the cells to re-layout
	[tableView setNeedsLayout];
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv 
//		 accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//	return (self.editing) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
//}

- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	

	Recipe* recipe = [dataSource recipeAtIndexPath:indexPath];
	if (self.editing) 
	{
		[self handleWantToEditRecipe:recipe];
	} 
	else
	{
		[self handleWantToViewRecipe:recipe animated:YES];
	}
}


@end
