//
//  NewItemViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddRecipesViewController.h"
#import "NewTextFieldViewController.h"
#import "Protocols.h"

@class GroceryItem;
@class TextTableViewCell;
@class AisleTableViewCell;
@class AislesViewController;
@class QuantityTableViewCell;
@class QuantityViewController;

@interface NewItemViewController : UIViewController 
	<UITableViewDelegate, 
     UITableViewDataSource, 
	 AddRecipesViewControllerDelegate,
	 TextTableViewCellDelegate,
	 DialogDelegate // for Quantity dialog
	 >
{
	// this dialog creates a new item - this is it
	GroceryItem* groceryItem;
	BOOL isNewItem;
	BOOL isFirstAppearance;
	BOOL allowAddRecipes;
	
	// cache of the recipes using this item
	NSMutableArray* recipesContainingItem;
	
	// user interface elements
	UITableView *tableView;
	TextTableViewCell* nameCell;
	QuantityTableViewCell* quantityCell;
	AisleTableViewCell* aisleCell;
	UIBarButtonItem* doneButton;
	
	// additional subviews
	AislesViewController* aislesVC;
	QuantityViewController* quantityVC;
	AddRecipesViewController* recipesVC;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) BOOL isNewItem;
@property (nonatomic, assign) BOOL allowAddRecipes;

- (void)setGroceryItem:(GroceryItem*)item;
- (GroceryItem*)groceryItem;

@end
