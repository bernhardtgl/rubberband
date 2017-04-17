//
//  TableViewControllerUserPrefs.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/19/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "TableViewControllerUserPrefs.h"


@implementation TableViewControllerUserPrefs

- init
{
	return [self initWithTableView:nil];
}
- (id) initWithTableView:(UITableView*)tv
{
	if (self = [super init])
	{
		tableView = tv;
		[tableView retain];
		
		isFirstAppearance = YES;
	}
	return self;
}
- (void) dealloc 
{
	[tableView release];
    [super dealloc];
}

//
//	Tests the specified index path to determine if the row and
//	section index are within the valid range for the table view.
//
- (BOOL)isValidTableViewIndexPath:(NSIndexPath*)testIndexPath
{
	BOOL ret = NO;
	if ((testIndexPath != nil) && ([testIndexPath length] == 2))
	{
		NSInteger testSectionIndex = [testIndexPath indexAtPosition:0];
		NSInteger testRowIndex = [testIndexPath indexAtPosition:1];
		NSInteger numberOfSections = [tableView numberOfSections];
		if ((testSectionIndex >= 0) && (testSectionIndex < numberOfSections))
		{
			NSInteger numberOfRowsinSection = [tableView numberOfRowsInSection:testSectionIndex];
			if ((testRowIndex >= 0) && (testRowIndex < numberOfRowsinSection))
			{
				ret = YES;
			}
		}		
	}
	return ret;
}


- (void)viewWillAppear
{
	if (isFirstAppearance && (initialScrollIndexPath != nil))
	{
		// restore the last remembered scroll position
		if ([self isValidTableViewIndexPath:initialScrollIndexPath])
		{
			[tableView scrollToRowAtIndexPath:initialScrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
	}
	isFirstAppearance = NO;
}

//
//	Set the initial scroll position of the view
//
- (void)setInitialScrollIndexPath:(NSIndexPath*)indexPath;
{
	[initialScrollIndexPath release]; 
	initialScrollIndexPath = indexPath;
	[initialScrollIndexPath retain]; 
}

- (void)savePrefs;
{
	
}

//
//	Get the current scroll position of the view
//
- (NSIndexPath*)currentScrollIndexPath
{
	NSIndexPath* indexPath = nil;
	NSArray* indexPaths = [tableView indexPathsForVisibleRows];
	if ([indexPaths count] > 0)
	{
		indexPath = [indexPaths objectAtIndex:0];  // top item
		[indexPath retain];
	}
	return indexPath;
}

@end
