//
//  NewTextFieldViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/20/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextTableViewCell.h"

@protocol NewTextFieldViewControllerDelegate <NSObject>
- (void)didChangeTextField:(NSString*)newValue;
@end

@interface NewTextFieldViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource, TextTableViewCellDelegate>
{
    id <NewTextFieldViewControllerDelegate> delegate;

	// text is the current and user edited value of the dialog
	NSString* textValue;
	// what kind of keyboard should be used
	UIKeyboardType keyboardType;
	// placeholder for text
	NSString* placeholder;
	
	// user interface elements
	UITableView *tableView;
	TextTableViewCell* nameCell;
}
- (id  <NewTextFieldViewControllerDelegate>)delegate;
- (void)setDelegate:(id  <NewTextFieldViewControllerDelegate>)newDelegate;

- (void) setKeyboardType: (UIKeyboardType)newValue;
- (UIKeyboardType) keyboardType;

- (void) setTextValue: (NSString*)newValue;
- (NSString*) textValue;

- (void) setPlaceholder: (NSString*)newValue;
- (NSString*) placeholder;

@end
