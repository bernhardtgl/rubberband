//
//  AislesViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AislesTable.h"
#import "NewTextFieldViewController.h"

@class Aisle;
@class AislesTable;
@class NewTextFieldViewController;

@interface AislesViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, NewTextFieldViewControllerDelegate>
{
	// this dialog selects an aisle - this is it
	Aisle* selectedAisle;
	
	// list of aisles to choose from
	AislesTable* aisles;
	
	// user interface elements
	UITableView *tableView;
	UIBarButtonItem* doneEditOnlyModeButton;
	
	// dialog for New/Edit
	NewTextFieldViewController* aisleNameVC;
	
	// used so we know which cell to "uncheck" when the user selects a new cell
	NSInteger lastCheckRow;
	
	// remember what's being deleted
	NSIndexPath* deleteAisleIndexPath;
	
	// in Edit mode, keep track of what Aisle the user chose to edit, so we can
	// update the correct one once the Edit dialog does away
	NSInteger editedAisleIndex;
	
	// save to disk if the user edits, on exiting the view
	BOOL saveOnExit;
	
	// editOnlyMode is a special mode which allows aisle reordering, creating and deleting
	BOOL editOnlyMode;
	
}

- (id) initEditOnly;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) Aisle* selectedAisle;
@property (nonatomic, retain) AislesTable* aisles;

@end
