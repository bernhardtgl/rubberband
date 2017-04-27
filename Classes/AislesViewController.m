//
//  AislesViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AislesViewController.h"
#import "Aisle.h"
#import "NewTextFieldViewController.h"
#import "RubberbandAppDelegate.h"
#import "Database.h"
#import "GroceryItemsTable.h"
#import "AisleTableViewCell.h"

@interface AislesViewController(PrivateMethods)
- (void) selectCell:(UITableViewCell*)cell isSelected:(BOOL)isSelected;
- (void)deleteAisle:(NSIndexPath *)indexPath;
@end

@implementation AislesViewController

@synthesize tableView;
@synthesize selectedAisle;
@synthesize aisles;

- (id)init
{
    if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Aisle", @"Title for Select Aisle");
		editedAisleIndex = -1;
		saveOnExit = NO;
    }
    return self;
}


/*
 *	Initialize view controller in edit only mode.  
 *	This mode only allows reordering aisle, creating new aisles, 
 *	and deleting existing aisles.
 */
- (id) initEditOnly
{
	if (self = [self init])
	{
		editOnlyMode = YES;
		self.title = NSLocalizedString(@"Edit Aisles", @"Title for Edit Aisle screen");
	}
	return self;
}


- (void)dealloc
{
	NSLog(@"***** dealloc AISLESVIEWCONTROLLER");
	tableView.dataSource = nil;
	tableView.delegate = nil;
	
	[tableView release];
	[selectedAisle release];
	[aisles release];
	[doneEditOnlyModeButton release];
	

	[deleteAisleIndexPath release];
    
	[super dealloc];
}

- (void)loadView
{
	// this is the actual item view
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
											 style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.allowsSelectionDuringEditing = YES;
	
	UINavigationItem *navItem = self.navigationItem;
	if (editOnlyMode)
	{
		doneEditOnlyModeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button")
													  style:UIBarButtonItemStyleDone
													 target:self action:@selector(doneEditOnlyModeAction:)];
		navItem.rightBarButtonItem = doneEditOnlyModeButton;
	}
	else
	{
		// Add the "Edit" button to the navigation bar
		navItem.rightBarButtonItem = self.editButtonItem;
	}
	
	// add it as the parent/content view to this UIViewController
	self.view = tableView;
	
	if (editOnlyMode)
	{
		[self setEditing:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// get rid of the selection, if any, from last time the dialog was launched
	NSIndexPath* path = [tableView indexPathForSelectedRow];
	[tableView deselectRowAtIndexPath:path animated:NO];
}


// **************************************************************************************
// actions


- (void)doneEditOnlyModeAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion: nil];
}

#pragma mark Helper functions to determine whether in Edit-Only mode or not

- (BOOL) isIndexPathAisle:(NSIndexPath*)indexPath
{
	if (editOnlyMode)
	{
		return (indexPath.row != aisles.count);
	}
	else
	{
		return ((indexPath.row != 0) && (indexPath.row != aisles.count + 1));
	}
}

- (NSInteger) rowForNoneAisle
{
	return (editOnlyMode ? -1 : 0);
}
- (NSInteger) rowForAddAisle
{
	return (editOnlyMode ? aisles.count : aisles.count + 1);
}
- (NSInteger) rowForAisleIndex:(NSInteger)index
{
	return (editOnlyMode ? index : index + 1);
}
- (NSInteger) aisleIndexForRow:(NSInteger)row
{
	return (editOnlyMode ? row : row - 1);
}

// **************************************************************************************
#pragma mark Standard table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
	NSUInteger aisleCount = aisles.count;
	aisleCount += (editOnlyMode ? 0 : 1); // +1 for "None", not used in edit only mode
	aisleCount += 1; // +1 for "Add Aisle"
	return aisleCount;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}	

- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// only allow the "real" aisles to be reordered
	return [self isIndexPathAisle:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tv 
	targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	// prevent the user from moving a row to the beginning or end
	if (proposedDestinationIndexPath.row == [self rowForNoneAisle])
	{
		return [NSIndexPath indexPathForRow:[self rowForNoneAisle] + 1 inSection:0];
	} 
	else if (proposedDestinationIndexPath.row == [self rowForAddAisle])
	{
		return [NSIndexPath indexPathForRow:[self rowForAddAisle] - 1 inSection:0];
	}
	else
	{
		return proposedDestinationIndexPath;
	}
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath
{
	NSInteger idxFrom = [self aisleIndexForRow:fromIndexPath.row];
	NSInteger idxTo = [self aisleIndexForRow:toIndexPath.row];
	
	[aisles moveAisleAtIndex:idxFrom toIndex:idxTo];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv 
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((indexPath.row != [self rowForAddAisle]) && (indexPath.row != [self rowForNoneAisle])) 
	{
		return UITableViewCellEditingStyleDelete;
	} 
	else 
	{
		return UITableViewCellEditingStyleNone;
	}
}

// set up the correct accessories for both "normal" view and editing mode
//
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv 
		 accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellAccessoryType ret = UITableViewCellAccessoryNone;
	if (self.editing) 
	{
		ret = UITableViewCellAccessoryDisclosureIndicator;
	} 

	NSInteger row = indexPath.row;
	if (row == [self rowForNoneAisle]) 
	{
		if ((selectedAisle == nil) && (!self.editing)) 
		{
			ret = UITableViewCellAccessoryCheckmark;
		}
		else
		{
			// don't allow users to rename the "None" pseudo-aisle
			ret = UITableViewCellAccessoryNone;
		}
	} 
	else if (row == [self rowForAddAisle]) 
	{
		ret = UITableViewCellAccessoryDisclosureIndicator;
	} 
	else // it's a real aisle
	{
		NSInteger aisleIndex = [self aisleIndexForRow:row];
		Aisle* aisle = [aisles aisleAtIndex:aisleIndex];
		if ((aisle == selectedAisle) && (!self.editing)) 
		{
			ret = UITableViewCellAccessoryCheckmark;
		}
	}
	return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tv 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{	
	UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:@"GBCBAisle"];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"GBCBAisle"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
		
	NSInteger row = indexPath.row;
	if (row == [self rowForNoneAisle]) 
	{
		cell.textLabel.text = NSLocalizedString(@"None", "No aisle");
		if (selectedAisle == nil) 
		{
			[self selectCell:cell isSelected:YES];
			lastCheckRow = 0;
		}
		else
		{
			[self selectCell:cell isSelected:NO];			
		}
	} 
	else if (row ==  [self rowForAddAisle]) 
	{
		cell.textLabel.text = NSLocalizedString(@"Add Aisle", @"Button to add a new aisle");
		[self selectCell:cell isSelected:NO];			
	} 
	else // it's a real aisle
	{
		NSInteger aisleIndex = [self aisleIndexForRow:row];
		Aisle* aisle = [aisles aisleAtIndex:aisleIndex];
		cell.textLabel.text = [aisle name];
		if (aisle == selectedAisle) 
		{
			[self selectCell:cell isSelected:YES];
			lastCheckRow = row;
		}
		else
		{
			[self selectCell:cell isSelected:NO];
		}
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv 
	willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = indexPath.row;
	if (row == [self rowForAddAisle]) 
	{
		// show the New Aisle name dialog
		if (aisleNameVC == nil) {
			aisleNameVC = [[NewTextFieldViewController alloc] init];
			aisleNameVC.delegate = self;
		}
		editedAisleIndex = -1; 
		aisleNameVC.title = NSLocalizedString(@"New Aisle", @"Title for new aisle");
		aisleNameVC.placeholder = NSLocalizedString(@"Name", @"Placeholder for aisle name");
		aisleNameVC.textValue = @"";
		[[self navigationController] pushViewController:aisleNameVC animated:YES];
		return nil;
	}
	else
	{
		if (self.editing)
		{
			// show the Edit Aisle name dialog
			if (aisleNameVC == nil) {
				aisleNameVC = [[NewTextFieldViewController alloc] init];
				aisleNameVC.delegate = self;
			}
			editedAisleIndex = [self aisleIndexForRow:row]; 
			aisleNameVC.textValue = [aisles aisleAtIndex:editedAisleIndex].name;
			aisleNameVC.title = NSLocalizedString(@"Edit Aisle", @"Title for edit aisle");
			[[self navigationController] pushViewController:aisleNameVC animated:YES];
			return nil;
		}
		else
		{
			if (row == [self rowForNoneAisle])
			{
				[selectedAisle release]; // we previously retained this aisle
				selectedAisle = nil;
			}
			else
			{
				Aisle* newSelectedAisle = [aisles aisleAtIndex:[self aisleIndexForRow:row]];
				[newSelectedAisle retain]; // retain the new
				[selectedAisle release];   // ...then release the old aisle
				selectedAisle = newSelectedAisle;
			}

			// check the new row, and uncheck the old row
			[self selectCell:[tv cellForRowAtIndexPath:indexPath] isSelected:YES];
			UITableViewCell* cell = [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastCheckRow inSection:0]];
			[self selectCell:cell isSelected:NO];

			// reload the data in the view, so the check mark shows instantaneously before
			// the view unloads
			[tv reloadData];
			return indexPath;
		}
	}
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Pop the view only. When viewWillDisappear is called, the notification
	// will be posted. This is becase there is a case, when the user deletes
	// the currently checked Aisle, then clicks Back, we want to make sure the
	// view updates, even though technically that's a cancel event.
	[[self navigationController] popViewControllerAnimated:YES];		
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (saveOnExit)
	{
		[App_database saveToDisk];
	}
	
	// post a notification, so we can update the selected aisle in the calling dialog
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"GBCBAisleChangeNotification" object:self];			
}

- (void) selectCell:(UITableViewCell*)cell isSelected:(BOOL)isSelected
{
	if (isSelected) 
	{
		// 50, 79, 133
		UIColor* color = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		cell.textLabel.textColor = color;
	} 
	else 
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor darkTextColor];
	}
}

// Invoked when the user hits the edit button.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	saveOnExit = YES;

    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
	[tableView setEditing:editing animated:animated];
	
	// causes the cells to re-layout, which hides the images for
	// edit mode
	[tableView setNeedsLayout];
}

#pragma mark NewTextFieldViewControllerDelegate - edit/add aisle
- (void)didChangeTextField:(NSString*)newValue;
{
	saveOnExit = YES;
	if (editedAisleIndex == -1)
	{
		Aisle* a = [[Aisle alloc] init];
		a.name = newValue;
		[aisles addAisle:a];
		[a release];
		
		NSInteger newRow = [self rowForAddAisle] - 1;
		NSIndexPath* newPath = [NSIndexPath indexPathForRow:newRow inSection:0];
		NSArray* newArray = [[NSArray alloc] initWithObjects:newPath, nil];

		[tableView insertRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationFade];
		[newArray release];
	}
	else 
	{
		// edited the name of an existing aisle
		Aisle* a = [aisles aisleAtIndex:editedAisleIndex];
		a.name = newValue;
		[tableView reloadData];
	}
}

- (void)tableView:(UITableView *)tv 
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self deleteAisle:indexPath];

	// TODO: The UIAlertView initWithTitle is crashing in Beta 6, try again in a 
	// later beta. For now we'll just delete it without warning the user.

}

- (void)deleteAisle:(NSIndexPath *)indexPath
{
	NSInteger deletedAisleIndex = [self aisleIndexForRow:indexPath.row];
	Aisle* a = [aisles aisleAtIndex:deletedAisleIndex];
	GroceryItemsTable* items = [App_database groceryItems];
	
	[items resetItemsAisleToNone:a];
	[aisles removeAisleAtIndex:deletedAisleIndex];
	
	// if the user is removing the currently "checked" aisle, check "none" instead
	if (indexPath.row == lastCheckRow)
	{
		NSIndexPath* lastPath = [NSIndexPath indexPathForRow:lastCheckRow inSection:0];
		[self selectCell:[tableView cellForRowAtIndexPath:lastPath] isSelected:NO];
		NSIndexPath* newPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self selectCell:[tableView cellForRowAtIndexPath:newPath] isSelected:YES];
		
		lastCheckRow = 0;
		[selectedAisle release]; // old Aisle was retained, so release it
		selectedAisle = nil;
	}
	
	// now delete the actual row from the table view
	NSIndexPath* newPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
	NSArray* newArray = [[NSArray alloc] initWithObjects:newPath, nil];
	[tableView deleteRowsAtIndexPaths:newArray withRowAnimation:UITableViewRowAnimationLeft];
	[newArray release];
}

@end
