//
//  TableViewControllerUserPrefs.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/19/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewControllerUserPrefs : NSObject 
{
	UITableView* tableView;
	NSIndexPath* initialScrollIndexPath;
	
	BOOL isFirstAppearance;
}

- (id) initWithTableView:(UITableView*)tableView;

- (void)viewWillAppear;

- (void)setInitialScrollIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)currentScrollIndexPath;
- (void)savePrefs;

@end
