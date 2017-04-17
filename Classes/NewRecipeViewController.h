//
//  NewRecipeViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddIngredientsViewController.h"//
#import "NotesViewController.h"//
#import "Protocols.h"

@class Recipe;
@class TextTableViewCell;
@class NotesTableViewCell;
@class NameAndPictureView;
@class QuantityViewController;
@class NotesViewController;
@class AddIngredientsViewController;

@interface NewRecipeViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, AddIngredientsViewControllerDelegate,
	NotesViewDelegate, DialogDelegate>
{
	// this dialog creates or edits a recipe - this is it
	Recipe* recipe;
	BOOL isNewItem;
	BOOL isFirstAppearance;
	BOOL didRecipeImageChange;
	BOOL returningFromNotesScreen;
	
	// user interface elements
	UITableView *tableView;
	
	NotesTableViewCell* notesCell;
	NameAndPictureView* nameAndPictureHeader;
	
	// other view controllers
	AddIngredientsViewController* ingredientsVC;
	NotesViewController* notesVC;
	QuantityViewController* quantityVC;
}

-(Recipe*)recipe;
-(void)setRecipe:(Recipe*)newValue;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) BOOL isNewItem;

@end
