//
//  NewTextFieldViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/20/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NewTextFieldViewController.h"


@implementation NewTextFieldViewController

- (id)init
{
	if (self = [super init]) 
	{
		nameCell = [[TextTableViewCell alloc] initWithFrame:CGRectZero];
		nameCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		nameCell.delegate = self;
	}
	return self;
}


- (void)loadView
{    
	tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
											 style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;	
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	// setting editing to YES prevents the "magnifying glass" on tap and hold from 
	// hanging and stopping working. Some weird interaction between the UITableView
	// and the UITextField
	tableView.editing = YES;
	
	UINavigationItem* navItem = self.navigationItem;
	
	// Add the "Done" button to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button")
											  style:UIBarButtonItemStyleDone
											 target:self action:@selector(doneAction:)];	
	navItem.rightBarButtonItem = button;
		
	// add it as the parent/content view to this UIViewController
	self.view = tableView;
}

- (void)dealloc
{
	[textValue release];
	[placeholder release];

	[nameCell release];
	[tableView release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview.
	// Release anything that's not essential, such as cached data.
}

- (void)viewWillAppear:(BOOL)animated 
{
	nameCell.textValue = textValue;
	[[nameCell textField] becomeFirstResponder];	
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // hide the keyboard before the view disappears, or nect time it will not
	// be clickable!
	[[nameCell textField] resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}	

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	switch (indexPath.section) 
	{
		case 0: return nameCell;
	}
	return nil;	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)doneAction:(id)sender
{
	// save new item, and notify the launcher of the dialog
	self.textValue = nameCell.textValue;
	
	if (delegate) 
	{
		[delegate didChangeTextField:self.textValue];
	}
	
	[[self navigationController] popViewControllerAnimated:YES];		
}

// called when the user hits "Done" on the text field. We use it to close the
// dialog
- (BOOL)textFieldShouldReturn:(UITextField *)txt 
{
	[self doneAction:nil];
	return YES;
}

- (void) setTextValue: (NSString*)newValue
{
	newValue = [newValue copy];
	[textValue release];
	textValue = newValue;
}
- (NSString*) textValue
{
	return textValue;
}

- (void) setPlaceholder: (NSString*)newValue
{
	newValue = [newValue copy];
	[placeholder release];
	placeholder = newValue;
	nameCell.placeholder = placeholder;
}

- (NSString*) placeholder
{
	return placeholder;
}

- (UIKeyboardType)keyboardType
{
	return keyboardType;
}
- (void)setKeyboardType:(UIKeyboardType)value
{
	keyboardType = value;
	nameCell.keyboardType = keyboardType;
}

- (id <NewTextFieldViewControllerDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <NewTextFieldViewControllerDelegate>)newDelegate
{
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}


@end
