//
//  TextTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextTableViewCellDelegate <NSObject>
@optional
  - (BOOL)textFieldShouldReturn:(UITextField *)textField; 
  - (void)textField:(UITextField *)textField willChangeTo:(NSString*)text;
@end

@interface TextTableViewCell : UITableViewCell 
	<UITextFieldDelegate> 
{
	UITextField* textField;
	
	id <TextTableViewCellDelegate> delegate;
}

@property (nonatomic, retain) UITextField* textField;

- (void) setKeyboardType: (UIKeyboardType)value;
- (UIKeyboardType) keyboardType;

- (void) setTextValue: (NSString*)value;
- (NSString*) textValue;

- (void) setPlaceholder: (NSString*)value;
- (NSString*) placeholder;

- (id <TextTableViewCellDelegate>)delegate;
- (void)setDelegate:(id <TextTableViewCellDelegate>)newDelegate;

@end

