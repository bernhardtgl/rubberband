//
//  NotesViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NotesViewController.h"

@implementation NotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		self.title = NSLocalizedString(@"Edit Notes", @"View name");
	}
	return self;
}
- (void)dealloc 
{
	[textView release];
	[notes release];
	[super dealloc];
}


// create controls programmatically
- (void)loadView 
{
    UIView* contentView = [[UIView alloc]
                           initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	self.view = contentView;
	[contentView autorelease];

    CGRect frame = self.view.frame;
    
	// button is just to give the rounded look
	UIButton* buttonForBorder = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    double height = frame.size.height - 300; // hack - space for the keyboard - need more major work on screen sizing than I want to do now
    CGRect outer = CGRectMake(8, frame.origin.y + 44 + 8, 304, height);
	buttonForBorder.frame = outer;
	buttonForBorder.enabled = NO;
	[self.view addSubview:buttonForBorder];

	// text view holds the notes
    CGRect inner = CGRectInset(outer, 8, 8);
	textView = [[UITextView alloc] initWithFrame:inner];
	textView.font = [UIFont systemFontOfSize:16];
	textView.text = notes;
	[self.view addSubview:textView];
		
	// Add the "Done" and "Cancel" buttons to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] 
				initWithTitle:NSLocalizedString(@"Done", @"Done button")
						style:UIBarButtonItemStyleDone
					   target:self 
					   action:@selector(doneAction:)];	
	self.navigationItem.rightBarButtonItem = button;
	[button release];
	
	button = [[UIBarButtonItem alloc] 
							   initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
							   style:UIBarButtonItemStylePlain
							   target:self 
							   action:@selector(cancelAction:)];	
	self.navigationItem.leftBarButtonItem = button;
	[button release];	
}

- (void)viewDidAppear:(BOOL)animated 
{
	[textView becomeFirstResponder];	
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[textView resignFirstResponder];
}

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)doneAction:(id)sender
{
	// save new item if the user edited the name
	self.notes = textView.text;
	
	if (delegate) 
	{
		[delegate didSaveNotes:notes];
	}
	
	[[self navigationController] popViewControllerAnimated:YES];		
}

- (void)cancelAction:(id)sender //TODO: is this correct signature
{
	[[self navigationController] popViewControllerAnimated:YES];		
}

// property implementations
- (id <NotesViewDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <NotesViewDelegate>)newDelegate
{
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

- (void)setNotes:(NSString *)value;
{
	NSString* n = [value copy];
	[notes release];
	notes = n;
}
- (NSString*) notes;
{
	return notes;
}

@end
