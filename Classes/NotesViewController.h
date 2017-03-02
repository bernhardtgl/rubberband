//
//  NotesViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/5/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotesViewDelegate <NSObject>
- (void)didSaveNotes:(NSString*)notes;
@end

@interface NotesViewController : UIViewController 
{
	// the notes
	NSString* notes;

	// UI controls
	UITextView* textView;
	
	// delegate to know when the dialog is closed
	id <NotesViewDelegate> delegate;
}

- (id <NotesViewDelegate>) delegate;
- (void) setDelegate:(id <NotesViewDelegate>)newDelegate;

- (NSString*) notes;
- (void) setNotes:(NSString*)value;

@end
