//
//  SearchBarCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 8/9/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroceryItem;
@class ItemTableViewCell;
@class SearchBarCell;

@protocol SearchBarCellDelegate <NSObject>
- (void)didSelectGroceryItem:(GroceryItem*)item inCell:(UITableViewCell*)cell;
- (UITableViewCell*) createCellInTableView:(UITableView*) tv forItem:(GroceryItem*) item;
@optional
- (void)addNewItemWithName:(NSString*)name;
- (BOOL)shouldDeleteGroceryItem:(GroceryItem*)item;
- (BOOL)shouldAddGroceryItem:(GroceryItem*)item;
- (void)searchBarTextDidBeginEditing:(SearchBarCell*)searchBarCell;
- (void)searchBarTextDidEndEditing:(SearchBarCell*)searchBarCell;
@end

@interface SearchBarCell : UITableViewCell 
	<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
	id <SearchBarCellDelegate> delegate;

	UINavigationBar* navBar;		// the nav bar sits on the face of the cell
	UISearchBar* theSearchBar;		// its subviews are these two
	UIBarButtonItem* addButton;
	
	UIControl* searchOverlay;		// owned by the parent UITableView, because they
	UITableView* filterTableView;			// draw on top of it when the user searches
	
	NSArray*		fullList;		// the master content
	NSMutableArray* filteredList;	// the filtered content as a result of the search
	
	UITableViewCellEditingStyle editingStyle;
	
	BOOL isFiltered;
	BOOL isSearching;
	BOOL isSelectingCell;
	BOOL isClearingTextAfterAdd;
	BOOL isEndingSearching;

}

- (id <SearchBarCellDelegate>)delegate;
- (void)setDelegate:(id <SearchBarCellDelegate>)newDelegate;

@property (nonatomic, retain) NSArray* fullList;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;

- (void) endSearching;

// this method is a bit of a hack, but it's called by the ItemsViewController when the
// user increases item quantity. I didn't want to rewrite the whole notification infrastructure
// for quantity tapping to use delegates right before releasing 1.1.
- (void) reloadData;

@end
