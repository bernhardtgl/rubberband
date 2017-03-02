//
//  EmailRecipeViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 2/1/09.
//  Copyright 2009 GBCB Software. All rights reserved.
//

#import "EmailRecipeViewController.h"
#import "Recipe.h"
#import "RecipesViewDataSource.h"
#import "RubberbandAppDelegate.h"

@implementation EmailRecipeViewController

@synthesize recipe;

- (id)initWithStyle:(UITableViewStyle)style 
{
    if (self = [super initWithStyle:style]) 
	{
		self.title = NSLocalizedString(@"Email Recipe", @"Title of view");
		self.tableView.dataSource = [[RecipesViewDataSource alloc] initWithDatabase:App_database];
		self.tableView.rowHeight = 65;
    }
    return self;
}

- (void)dealloc 
{
	[recipe release];
	
    [super dealloc];
}


- (void)viewDidLoad 
{
    [super viewDidLoad];

	// Add the "Done" and "Cancel" buttons to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] 
							   initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
							   style:UIBarButtonItemStylePlain
							   target:self 
							   action:@selector(cancelAction:)];	
	self.navigationItem.rightBarButtonItem = button;
	[button release];
}

- (void)cancelAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	RecipesViewDataSource* ds = (RecipesViewDataSource*)tableView.dataSource;
	
	Recipe* newRecipe = [[ds recipeAtIndexPath:indexPath] retain];
	[recipe release];
	recipe = newRecipe;
	
	if (delegate && [delegate respondsToSelector:@selector(didSave:)]) 
	{
		[delegate didSave:self];
	}
	[self dismissModalViewControllerAnimated:YES];	
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv 
		 accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}

#pragma mark Properties
- (id <DialogDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <DialogDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end

