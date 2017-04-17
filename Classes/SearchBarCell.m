//
//  SearchBarCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 8/9/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "SearchBarCell.h"
#import "GroceryItem.h"
#import "ItemTableViewCell.h"

@implementation SearchBarCell

@synthesize fullList, editingStyle;

const CGFloat RIGHT_MARGIN = 30;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		editingStyle = UITableViewCellEditingStyleDelete;
		
		// don't get in the way of user's typing
		theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320 - RIGHT_MARGIN, 44)];
		theSearchBar.placeholder = NSLocalizedString(@"Search", @"Placeholder");
		theSearchBar.delegate = self;
		theSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		theSearchBar.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		
		navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		addButton = [[UIBarButtonItem alloc] 
					 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
					 target:self 
					 action:@selector(addAction:)];
		UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@""];
		navItem.hidesBackButton = YES;
		[navBar pushNavigationItem:navItem animated:NO];
		[navItem release];
		
		[self addSubview:navBar];
		[self addSubview:theSearchBar];	
		
		// the gray semi-transparent "overlay", and the filter tableview (both are hidden now)
		// will eventually added to a superview (the UITableView's parent)
		searchOverlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 44, 320, 400)];
		searchOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
		[searchOverlay addTarget:self 
						  action:@selector(overlayAction:) 
				forControlEvents:UIControlEventTouchUpInside];
		searchOverlay.hidden = YES;
		
		filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 156)];
		filterTableView.dataSource = self;
		filterTableView.delegate = self;
		filterTableView.hidden = YES;
		filterTableView.allowsSelectionDuringEditing = YES;
		
		filteredList = [[NSMutableArray alloc] init];
		
		isFiltered = NO;
		isSearching = NO;
	}
	return self;
}

- (void)dealloc 
{
	[theSearchBar release];
	[addButton release];
	[navBar release];
	
	[searchOverlay release];
	[filterTableView release];

	[filteredList removeAllObjects];
	[filteredList release];
	
	[super dealloc];
}

// ========================================================================================
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	isSearching = YES;
	
	// only show the status bar's Add button while searching
	[UIView beginAnimations:@"test" context:nil];
	theSearchBar.frame = CGRectMake(0, 0, 320 - RIGHT_MARGIN - 8, 44);
	navBar.topItem.rightBarButtonItem = addButton;
	addButton.enabled = NO;
	[UIView commitAnimations];

	UITableView* parentTV = (UITableView*)[self superview];
	UIView* grandpaView = [parentTV superview];
	
	// this is a bit hacky, to assume that the UITableView's parent is the parent
	// we want, but the overlay and new view need to be added one level higher up 
	// else it doesn't draw correctly
	[grandpaView addSubview:searchOverlay];		
	[grandpaView addSubview:filterTableView];		

	// show the gray box and set up the search control
	searchOverlay.hidden = NO;
	parentTV.scrollEnabled = NO;
	[parentTV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
					   atScrollPosition:UITableViewScrollPositionTop animated:NO];
	
	filterTableView.editing = parentTV.editing;
	
	if ((delegate) && ([delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]))
	{
		[delegate searchBarTextDidBeginEditing:self];
	}

	// the user may edit items. When he comes back, we want to show the keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleEditItem:)
												 name:@"GBCBEditItemNotification"
											   object:nil];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	// in SDK 3.x, hitting the "X" button in the search bar tries to end searching - this
	// will prevent it
	return isEndingSearching;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	if (isSelectingCell) {
		return;
	}

	[UIView beginAnimations:@"test" context:nil];
	theSearchBar.frame = CGRectMake(0, 0, 320 - RIGHT_MARGIN, 44);
	navBar.topItem.rightBarButtonItem = nil;
	[UIView commitAnimations];
	
	searchOverlay.hidden = YES;
	UITableView* parentTV = (UITableView*)[self superview];
	parentTV.scrollEnabled = YES;
	
	isSearching = NO;
	isEndingSearching = NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if ((delegate) && ([delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]))
	{
		[delegate searchBarTextDidEndEditing:self];
	}
}

- (void)updateFilteredList
{
	[filteredList removeAllObjects];	// clear the filtered array first
	
	if (isFiltered)
	{
		// search the table content for cell titles that match "searchText"
		// if found add to the mutable array and force the table to reload
		//
		NSString* searchText = theSearchBar.text;
		NSString* name;
		for (GroceryItem* item in fullList)
		{
			name = item.name;
			NSRange range = [name rangeOfString:searchText 
										options:NSCaseInsensitiveSearch];
			if (range.location != NSNotFound)
			{
				[filteredList addObject:item];
			}
		}
		
		// get ready to sort by creating a descriptor
		NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] 
											initWithKey:@"name"
											ascending:YES 
											selector:@selector(localizedCaseInsensitiveCompare:)];
		[filteredList sortUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
		[nameDescriptor release];
			
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if (isClearingTextAfterAdd) return;
	
	isFiltered = (searchBar.text.length > 0);
	
	searchOverlay.hidden = isFiltered;
	filterTableView.hidden = !isFiltered;
	addButton.enabled = isFiltered;
	
	[self updateFilteredList];
	
	if (isFiltered)
	{
		[filterTableView reloadData];
		if (filteredList.count > 0)
		{
			[filterTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
								   atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
	}
	else
	{
		// reload the parent view because the user may have changed its state
		UITableView* parentTV = (UITableView*)[self superview];
		[parentTV reloadData];
	}
 
}

// ========================================================================================
#pragma mark Actions

- (void)addAction:(NSNotification*)notification
{
	if ((delegate) && ([delegate respondsToSelector:@selector(addNewItemWithName:)]))
	{
		[delegate addNewItemWithName:theSearchBar.text];
	}
	[self updateFilteredList];
	[filterTableView reloadData];

	// user probably wants to add another item
	isClearingTextAfterAdd = YES;
	theSearchBar.text = @"";	
	isClearingTextAfterAdd = NO;
	
	// now the text will be blank, so disable the add button (don't want to add an empty item)
	addButton.enabled = NO;
}

// cancel when the user clicks on the transparent gray overlay (only shown when there
// is no text in the search box. This mimics how iPhone contacts works.
- (void)overlayAction:(NSNotification*)notification
{
	[self endSearching];
}

- (void) endSearching;
{
	isFiltered = NO;
	isEndingSearching = YES;
	searchOverlay.hidden = YES;
	filterTableView.hidden = YES;
	
	if ([theSearchBar isFirstResponder])
	{	
		[theSearchBar resignFirstResponder];
	}
	theSearchBar.text = @"";
}

- (void)handleEditItem:(NSNotification*)notification 
{
	[theSearchBar becomeFirstResponder];
	[self updateFilteredList];
	[filterTableView reloadData];
}

- (void)reloadData;
{
	[filterTableView reloadData];	
}

// ==========================================================================================
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return filteredList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	GroceryItem* item = [filteredList objectAtIndex:indexPath.row];
	if (delegate)
	{		
		return [delegate createCellInTableView:tableView forItem:item];	
	}
	else
	{
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)es 
	forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	GroceryItem* item = [filteredList objectAtIndex:indexPath.row];

    // If row is deleted, remove it from the list.
    if (es == UITableViewCellEditingStyleDelete) 
	{
		BOOL commit = YES;
		if ((delegate) && ([delegate respondsToSelector:@selector(shouldDeleteGroceryItem:)]))
		{
			commit = [delegate shouldDeleteGroceryItem:item];
		}
		
		if (commit)
		{
			// shortcut to rebuilding the entire filteredList. The fullList should
			// get changed by the delegate
			[filteredList removeObject:item];
			// Animate the deletion from the table.
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
					  withRowAnimation:UITableViewRowAnimationFade];
		}
    }
	else if (es == UITableViewCellEditingStyleInsert) 
	{
		// clicking the + sign does not change the list in any way
		if ((delegate) && ([delegate respondsToSelector:@selector(shouldAddGroceryItem:)]))
		{
			[delegate shouldAddGroceryItem:item];
		}
	}
}
// ==========================================================================================
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// don't do all the work to end search mode if the user Edits an item
	isSelectingCell = YES;
	@try 
	{
		GroceryItem* item = [filteredList objectAtIndex:indexPath.row];
		ItemTableViewCell* cell = (ItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
		
		if (delegate) 
		{
			[delegate didSelectGroceryItem:item inCell:cell];
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	@finally 
	{
		isSelectingCell = NO;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return editingStyle;			
}

// ==========================================================================================
#pragma mark Properties

- (id <SearchBarCellDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <SearchBarCellDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end
