//
//  RecipeViewController.h
//  View controller screen for the recipe details view.
//
//  Created by Craig on 6/7/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RubberbandAppDelegate.h"
#import "NameAndPictureView.h"

@class Recipe;

@interface RecipeViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, NameAndPictureViewDelegate>
{
	Recipe* recipe;
	
	// user interface elements
	UITableView *tableView;
	UIView* niView;								// no ingredients message
	NameAndPictureView* nameAndPictureHeader;
}

-(Recipe*)recipe;
-(void)setRecipe:(Recipe*)newValue;

@end
