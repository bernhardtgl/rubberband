//
//  SmallNumberTableViewCell
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/22/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "SmallNumberTableViewCell.h"
#import "NewTextFieldViewController.h"

@interface SmallNumberTableViewCell(PrivateMethods)
- (void) configureNumberControl;
@end

@implementation SmallNumberTableViewCell

const int SEGMENT_NUMBERS = 4;

- (id)initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:frame])
	{
		ignoreChangeEvent = NO;
		
		NSArray* segmentObjects = [NSArray arrayWithObjects: 
								   @"", // blank, to be overlayed later with label
								   @"0", @"1", @"2", @"3", 
								   [UIImage imageNamed:@"segment_arrow.png"], nil];

		numberControl = [[UISegmentedControl alloc] initWithItems:segmentObjects];		
		[numberControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		numberControl.segmentedControlStyle = UISegmentedControlStylePlain;
		[self addSubview:numberControl];

//		UIColor* color = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		labelControl = [[UILabel alloc] init];
		labelControl.font = [UIFont systemFontOfSize:18];
		[self addSubview:labelControl];

// For debugging:
//		self.contentView.backgroundColor = [UIColor redColor];
	}
	return self;
}

- (void)dealloc
{
	// release controls
	[numberControl release];
	[labelControl release];
	
	// release property objects
	[text release];
	
    [super dealloc];
}

- (void)layoutSubviews
{	
	const CGFloat LEFT_INDENT = 9;
	const CGFloat RIGHT_INDENT = 9;
	const CGFloat LABEL_WIDTH = 110;

	[super layoutSubviews];		
	CGRect frame = [self bounds];
	
	// Place the subviews appropriately.
    CGRect numberFrame = CGRectMake(frame.origin.x + LEFT_INDENT, 
									frame.origin.y, 
									frame.size.width - LEFT_INDENT - RIGHT_INDENT, 
									frame.size.height);
	numberControl.frame = numberFrame;
	[numberControl setWidth:LABEL_WIDTH forSegmentAtIndex:0]; 
	[numberControl setEnabled:NO forSegmentAtIndex:0];
	
    CGRect labelFrame = CGRectMake(frame.origin.x + LEFT_INDENT + 8, 
								   frame.origin.y + 2, 
								   LABEL_WIDTH - 20, 
								   frame.size.height - 4);
	labelControl.frame = labelFrame;
	labelControl.backgroundColor = [UIColor clearColor];

}

- (void)segmentAction:(id)sender
{
	if (ignoreChangeEvent) return;
	
	int index = [sender selectedSegmentIndex];

	if (index == SEGMENT_NUMBERS + 1) 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GBCBWantNumberView" 
															object:self];
		[self configureNumberControl];
	}
	else
	{
		// set the value based on the selected index.
		value = index - 1;
		if (delegate) 
		{
			[delegate didChangeValue:value];
		}
		
	}
}

- (NSString*) text
{
	return text;
}
- (void) setText:(NSString*)newText
{
	[newText copy];
	[text release];
	text = newText;

	// TODO: hook up to segments
	labelControl.text = text;
}

- (int) value
{
	return value;
}
- (void) setValue:(int)newValue
{
	// bit of a hack for now
	if (newValue > 999) newValue = 999;
	
	value = newValue;
	[self configureNumberControl];
}

- (void) configureNumberControl
{
	ignoreChangeEvent = YES;
	@try 
	{
		if ((value >= 0) && (value <= SEGMENT_NUMBERS - 2)) {
			[numberControl setSelectedSegmentIndex:value + 1];		
		}
		else {
			NSString* textVal = [NSString stringWithFormat:@"%d", value];
			[numberControl setTitle:textVal forSegmentAtIndex:SEGMENT_NUMBERS];
			[numberControl setSelectedSegmentIndex:UISegmentedControlNoSegment];		
			[numberControl setSelectedSegmentIndex:SEGMENT_NUMBERS];		
		}
	}
	@finally 
	{
		ignoreChangeEvent = NO;
	}
}

- (id <SmallNumberTableViewCellDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <SmallNumberTableViewCellDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

@end
