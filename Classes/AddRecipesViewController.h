//
//  AddRecipesViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 6/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class RecipesViewDataSource;

@protocol AddRecipesViewControllerDelegate <NSObject>
- (void)didChangeRecipes:(NSMutableArray*)recipesList;
@end

@interface AddRecipesViewController : UIViewController 
	<UITableViewDelegate, TableViewDataSourceDelegate>
{
    id <AddRecipesViewControllerDelegate> delegate;
	
	UITableView *tableView;	
	RecipesViewDataSource* dataSource;
	
	// keep track of the recipes in the list
	NSMutableArray* recipesInList;

	// set to YES when the user makes a change, so we don't have to update the
	// list if they do nothing
	BOOL didChangeTheList;
}

- (id  <AddRecipesViewControllerDelegate>)delegate;
- (void)setDelegate:(id  <AddRecipesViewControllerDelegate>)newDelegate;

- (NSMutableArray*)recipesInList;

@end
