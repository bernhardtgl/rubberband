//
//  NewNameAndLinkViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 7/27/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextTableViewCell;
@class NewNameAndLinkViewController;

@protocol NewNameAndLinkViewControllerDelegate <NSObject>
- (void)didChange:(NewNameAndLinkViewController*)controller;
@end

@interface NewNameAndLinkViewController : UITableViewController 
{
    id <NewNameAndLinkViewControllerDelegate> delegate;

	NSString* name;
	NSString* link;
	
	// user interface elements
	TextTableViewCell* nameCell;
	TextTableViewCell* linkCell;
}
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* link;

- (id <NewNameAndLinkViewControllerDelegate>)delegate;
- (void) setDelegate:(id <NewNameAndLinkViewControllerDelegate>)newDelegate;

@end
