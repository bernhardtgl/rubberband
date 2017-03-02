//
//  AddRecipesViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 6/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AddRecipesViewController.h"
#import "RecipesViewDataSource.h"
#import "Recipe.h"
#import "AddObjectTableViewCell.h"

@interface AddRecipesViewController(PrivateMethods)
- (void) signalRecipesChanged;
@end

@implementation AddRecipesViewController

// init and dealloc
- init 
{
	if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Add to Recipes", @"View title");		
		dataSource = [[RecipesViewDataSource alloc] init];		
		dataSource.delegate = self; // so we can control the item cell
		
		recipesInList = [[NSMutableArray alloc] init];
		
		didChangeTheList = NO;
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc AddRecipesViewController");
	tableView.dataSource = nil;
	tableView.delegate = nil;
	[tableView release];
	[dataSource release];
	
	[recipesInList release]; 
	
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
	didChangeTheList = NO;
	
	NSIndexPath* indexPath = [tableView indexPathForSelectedRow];
	if (indexPath != nil) {
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
	[tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	if (didChangeTheList) 
	{
		[self signalRecipesChanged];
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

- (void)toggleRecipeAtIndexPath:(NSIndexPath*)indexPath
{
	Recipe* theRecipe = [dataSource recipeAtIndexPath:indexPath];
	BOOL isAdded = ![recipesInList containsObject:theRecipe];
	
	if (isAdded) // adding an object, add it to the array
	{
		[recipesInList addObject:theRecipe];
	}
	else // removing the object
	{
		[recipesInList removeObject:theRecipe];
	}
	
	AddObjectTableViewCell* cell = (AddObjectTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	[cell configureObject:theRecipe.name isInList:isAdded];
	[cell setNeedsDisplay];
	
	didChangeTheList = YES;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self toggleRecipeAtIndexPath:indexPath];
	[tv deselectRowAtIndexPath:indexPath animated:YES];	
}

- (void)signalRecipesChanged
{
    if (delegate && [delegate respondsToSelector:@selector(didChangeRecipes:)] ) 
	{
        [delegate didChangeRecipes:recipesInList];
    }
}

// delegate from the data source - a little confusing, yes, but this lets us use
// the same data source (lots of shared code) for both Recipes and Adding Recipes
//
- (UITableViewCell*) willCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
	Recipe* recipe = [dataSource recipeAtIndexPath:indexPath];
	AddObjectTableViewCell* cell = [[[AddObjectTableViewCell alloc] initWithFrame:CGRectZero] autorelease];

	BOOL isInList = [recipesInList containsObject:recipe];
	[cell configureObject:recipe.name isInList:isInList];
	
	return cell;
}

// property implementations
- (id <AddRecipesViewControllerDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <AddRecipesViewControllerDelegate>)newDelegate
{
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

- (NSMutableArray*)recipesInList;
{
	return recipesInList;
}

@end
