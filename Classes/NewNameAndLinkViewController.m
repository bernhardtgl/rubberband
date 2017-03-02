//
//  NewNameAndLinkViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/27/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NewNameAndLinkViewController.h"
#import "TextTableViewCell.h"

@implementation NewNameAndLinkViewController

@synthesize name;
@synthesize link;

- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:style]) 
	{
		nameCell = [[TextTableViewCell alloc] initWithFrame:CGRectZero];
		nameCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
// TODO: figure out how to make the next key work
//		nameCell.textField.returnKeyType = UIReturnKeyNext;
		linkCell = [[TextTableViewCell alloc] initWithFrame:CGRectZero];
		linkCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		linkCell.keyboardType = UIKeyboardTypeURL;
		linkCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		linkCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
				
		// setting editing to YES prevents the "magnifying glass" on tap and hold from 
		// hanging and stopping working. Some weird interaction between the UITableView
		// and the UITextField
		self.tableView.editing = YES;
		
//		linkCell.textField.returnKeyType = UIReturnKeyNext;
	}
	return self;
}

- (void)dealloc 
{
	[nameCell release];
	[linkCell release];
	
	[super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return (indexPath.row == 0) ? nameCell : linkCell;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];

	UINavigationItem* navItem = self.navigationItem;
	
	// Add the "Done" and "Cancel" buttons to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button")
															   style:UIBarButtonItemStyleDone
															  target:self 
															  action:@selector(doneAction:)];	
	navItem.rightBarButtonItem = button;
	[button release];

	button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
															   style:UIBarButtonItemStylePlain
															  target:self 
															  action:@selector(cancelAction:)];	
	navItem.leftBarButtonItem = button;
	[button release];
	
	nameCell.placeholder = NSLocalizedString(@"Name", "Placeholder for name");
	linkCell.placeholder = NSLocalizedString(@"www.example.com", "Placeholder for recipe web address");
}

- (void)viewWillAppear:(BOOL)animated 
{
	nameCell.textValue = name;
	linkCell.textValue = link;
}

- (void)viewDidAppear:(BOOL)animated 
{
	[[nameCell textField] becomeFirstResponder];	
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // hide the keyboard before the view disappears, or nect time it will not
	// be clickable!
	[[nameCell textField] resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)doneAction:(id)sender
{
	// save new strings, and notify the launcher of the dialog
	self.name = nameCell.textValue;

	// if they just typed www.blah.com, add the http://
	NSString* str = linkCell.textValue;
	BOOL needPrefix = YES;
	@try
	{
		if (([[str substringToIndex:7] isEqual:@"http://"]) ||
			([[str substringToIndex:8] isEqual:@"https://"]))
		{
			needPrefix = NO;
		}
	}
	@catch (NSException* e) //exception thrown if string is less than 8 chars long
	{
		// if not empty, add the prefix
		needPrefix = (str.length > 0);
	}
	if (needPrefix) 
	{
		str = [NSString stringWithFormat:@"http://%@", str];
	}
	self.link = str;
	
	if (delegate && [delegate respondsToSelector:@selector(didChange:)]) 
	{
		[delegate didChange:self];
	}
	
	[[self navigationController] popViewControllerAnimated:YES];		
}

- (void)cancelAction:(id)sender
{
	[[self navigationController] popViewControllerAnimated:YES];		
}

// Property implementations
- (id <NewNameAndLinkViewControllerDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <NewNameAndLinkViewControllerDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end

