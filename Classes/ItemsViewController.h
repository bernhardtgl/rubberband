//
//  ItemsViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RubberbandAppDelegate.h"
#import "SearchBarCell.h"

@class ItemsViewDataSource;
@class TableViewControllerUserPrefs;

@interface ItemsViewController : UIViewController 
	<UITableViewDelegate, TableViewUserPrefs, SearchBarCellDelegate>
{
	UITableView *tableView;	
	ItemsViewDataSource* dataSource;

	// helper class to load and save prefs for this view
	TableViewControllerUserPrefs* prefs;

	UIBarButtonItem* addButton;   // left hand + button
	UIBarButtonItem* doneButton;  // right hand Done button for search mode
	SearchBarCell* searchCell;	  // search cell, containing the text box
	
	BOOL isSearching;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, readonly, retain) TableViewControllerUserPrefs* prefs;

- (BOOL)isValidTableViewIndexPath:(NSIndexPath*)testIndexPath;
- (void)reloadAndReselect:(BOOL)animated;
- (void)handleNewItem:(NSNotification*)notification;
- (void)updateList;

@end
