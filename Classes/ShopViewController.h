//
//  ShopViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopViewDataSource.h"
#import "RubberbandAppDelegate.h"

@class TableViewControllerUserPrefs;
@class AislesViewController;

@interface ShopViewController : UIViewController 
	<UITableViewDelegate, TableViewUserPrefs, ShopViewDataSourceDelegate>
{
	UITableView* tableView;
	UIView* doneShoppingView;
	RubberbandAppDelegate* appController;
	ShopViewDataSource* shopViewDataSource;	
	UIBarButtonItem* checkoutButton;
	UIBarButtonItem* aislesButton;
	
	// helper class to load and save prefs for this view
	TableViewControllerUserPrefs* prefs;
	
	BOOL showEasterEgg;
}

@property (nonatomic, assign) RubberbandAppDelegate* appController;
@property (nonatomic, retain) UITableView* tableView;
@property (nonatomic, readonly, retain) TableViewControllerUserPrefs* prefs;

- (BOOL)isValidTableViewIndexPath:(NSIndexPath*)testIndexPath;
- (UIView*) createDoneShoppingView;
- (void)checkViewState;

- (void)didDeleteLastItem;
- (void)clearList;
- (void)updateList;

@end
