//
//  SmallNumberTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/22/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewTextFieldViewController;

@protocol SmallNumberTableViewCellDelegate <NSObject>
- (void)didChangeValue:(NSUInteger)value;
@end

@interface SmallNumberTableViewCell : UITableViewCell 
{
	id <SmallNumberTableViewCellDelegate> delegate;

	UISegmentedControl* numberControl;
	UILabel* labelControl;
	NewTextFieldViewController* numberVC;
	
	NSString* text;
	int value;
	
	BOOL ignoreChangeEvent;
}

//@property (nonatomic, retain) NSString* text;
//@property (nonatomic, retain) int value;

- (NSString*) text;
- (void) setText:(NSString*)newText;

- (int) value;
- (void) setValue:(int)newValue;

- (id <SmallNumberTableViewCellDelegate>)delegate;
- (void)setDelegate:(id <SmallNumberTableViewCellDelegate>)newDelegate;

@end
