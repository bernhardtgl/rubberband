//
//  RecipesViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipesViewDataSource.h"
#import "RubberbandAppDelegate.h"

@class TableViewControllerUserPrefs;

@interface RecipesViewController : UIViewController 
	<UITableViewDelegate, TableViewUserPrefs>
{
	UITableView* tableView;
	RecipesViewDataSource* dataSource;		

	// helper class to load and save prefs for this view
	TableViewControllerUserPrefs* prefs;
}

@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, readonly, retain) TableViewControllerUserPrefs* prefs;

- (BOOL)isValidTableViewIndexPath:(NSIndexPath*)testIndexPath;
- (void)handleWantToViewRecipe:(Recipe*)recipe animated:(BOOL)animated;

- (void)createNewRecipeWithName:(NSString*)name link:(NSString*)link;
- (void)createNewRecipe:(Recipe*)r;

@end
