//
//  AddIngredientsViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/24/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "SearchBarCell.h"

@class ItemsViewDataSource;

@protocol AddIngredientsViewControllerDelegate <NSObject>
- (void)didChangeIngredients:(NSMutableArray*)itemsInRecipe;
@end

@interface AddIngredientsViewController : UIViewController 
	<UITableViewDelegate, TableViewDataSourceDelegate, SearchBarCellDelegate>
{
    id <AddIngredientsViewControllerDelegate> delegate;

	UITableView *tableView;	
	ItemsViewDataSource* dataSource;

	// keep track of the total list of GroceryItem ingredients. For the index, the UID
	// of the GroceryItem is the key
	NSMutableArray* itemsInList;
	
	// used to know when the user is returning from the New Item screen
	// set to YES before the New screen is shown, cleared when this view appears
	// prevents sending the "didChangeIngredients" message until the user is *really*
	// done
	BOOL isAddingNewIngredient;
	
	// set to YES when the user makes a change, so we don't have to update the
	// list if they do nothing
	BOOL didChangeTheList;
	
	UIBarButtonItem* addButton;    // left hand + button
	UIBarButtonItem* doneButton;   // right hand Done button
	UIBarButtonItem* doneSearchingButton;  // right hand Done button for search mode
	SearchBarCell* searchCell;	  // search cell, containing the text box
	
	BOOL isSearching;
}

- (id <AddIngredientsViewControllerDelegate>)delegate;
- (void)setDelegate:(id <AddIngredientsViewControllerDelegate>)newDelegate;

- (NSMutableArray*)itemsInList;

@end
