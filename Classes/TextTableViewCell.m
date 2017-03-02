//
//  UITextTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TextTableViewCell.h"

@implementation TextTableViewCell

@synthesize textField;

- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		
		// Create label views to contain the various pieces of text that make up the cell.
		// Add these as subviews.
		textField = [[UITextField alloc] initWithFrame:CGRectZero]; // layoutSubViews will decide the final frame
		textField.borderStyle = UITextBorderStyleNone;
		textField.textColor = [UIColor blackColor];
		textField.font = [UIFont systemFontOfSize:18];
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.minimumFontSize = 14.0;
		textField.adjustsFontSizeToFitWidth = YES;
		textField.delegate = self;
		textField.returnKeyType = UIReturnKeyDone;

		// prevents the cell from turning blue
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self addSubview:textField];		

	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"***** dealloc TextTableViewCell");
	[textField release];
    [super dealloc];
}

- (void)layoutSubviews
{
	const CGFloat LEFT_INDENT = 18;
	const CGFloat RIGHT_INDENT = 10;

	[super layoutSubviews];
	CGRect contentRect = [self bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    CGRect frame = CGRectMake(contentRect.origin.x + LEFT_INDENT, 
							  contentRect.origin.y, 
							  contentRect.size.width - LEFT_INDENT - RIGHT_INDENT,
							  contentRect.size.height);
	textField.frame = frame;

// For debugging...
//	textField.backgroundColor = [UIColor redColor];
}

- (NSString*)textValue
{
	return [textField text];
}
- (void)setTextValue:(NSString*)value
{
	textField.text = value;
}

- (NSString*) placeholder
{
	return textField.placeholder;
}

- (void) setPlaceholder: (NSString*)value
{
	textField.placeholder = value;
}

- (UIKeyboardType)keyboardType
{
	return textField.keyboardType;
}

- (void)setKeyboardType:(UIKeyboardType)value
{
	textField.keyboardType = value;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)txt
{
	return YES;
}

- (BOOL)textField:(UITextField *)txt shouldChangeCharactersInRange:(NSRange)range 
	replacementString:(NSString *)string
{
	if (delegate && [delegate respondsToSelector:@selector(textField:willChangeTo:)]) 
	{
		// kind of weird that I have to figure out what the new string is going
		// to be this way
		NSString* newText = [txt.text stringByReplacingCharactersInRange:range withString:string];
		[delegate textField:txt willChangeTo:newText];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)txt 
{
	BOOL retVal = YES;
	if (delegate && [delegate respondsToSelector:@selector(textFieldShouldReturn:)])  
	{
		retVal = [delegate textFieldShouldReturn:txt];
	}
	
    [textField resignFirstResponder];
    return retVal;
}

- (id <TextTableViewCellDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <TextTableViewCellDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end
