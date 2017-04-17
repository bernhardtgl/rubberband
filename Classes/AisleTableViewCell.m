//
//  AisleTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AisleTableViewCell.h"
#import "Aisle.h"

@implementation AisleTableViewCell

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
		textLabel = [[UILabel alloc] init];
		textLabel.text = NSLocalizedString(@"Aisle", @"Aisle label");
		textLabel.font = [UIFont systemFontOfSize:18];
		textLabel.highlightedTextColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:textLabel];
		
		aisleLabel = [[UILabel alloc] init];
		aisleLabel.text = NSLocalizedString(@"None", @"Aisle name if not selected");
		aisleLabel.font = [UIFont systemFontOfSize:18];
		aisleLabel.textAlignment = NSTextAlignmentRight;
		aisleLabel.textColor = [UIColor darkGrayColor];
		aisleLabel.highlightedTextColor = [UIColor whiteColor];
		aisleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:aisleLabel];		
		
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return self;
}

- (void)dealloc
{
	[aisle release];
	
	[textLabel release];
	[aisleLabel release];
	
    [super dealloc];
}

- (void)layoutSubviews
{	
	const CGFloat LEFT_INDENT = 18;
	const CGFloat RIGHT_INDENT = 14;
	const CGFloat TEXT_WIDTH = 80;
	
	[super layoutSubviews];	
	CGRect frame = [[self contentView] bounds];
	
	// Place the subviews appropriately.
	CGRect textFrame = CGRectMake(frame.origin.x + LEFT_INDENT, 
								   frame.origin.y + 2, 
								   TEXT_WIDTH, 
								   frame.size.height - 4);
	CGRect aisleFrame = CGRectMake(frame.origin.x + LEFT_INDENT + TEXT_WIDTH, 
								   frame.origin.y + 2, 
								   frame.size.width - TEXT_WIDTH - RIGHT_INDENT, 
								   frame.size.height - 4);

	textLabel.frame = textFrame;
	aisleLabel.frame = aisleFrame;

// For debugging...
//	textLabel.backgroundColor = [UIColor redColor];
//	aisleLabel.backgroundColor = [UIColor blueColor];
}

- (void) setAisle:(Aisle*)anAisle
{
	[anAisle retain];
	[aisle release];
	aisle = anAisle;
	
	if (aisle == nil)
	{
		aisleLabel.text = NSLocalizedString(@"None", @"Aisle name if not selected");
		aisleLabel.textColor = [UIColor darkGrayColor];
	}
	else 
	{
		aisleLabel.text = aisle.name;
		// TODO: refactor color constants
		UIColor* color = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		aisleLabel.textColor = color;
	}
}

- (Aisle*) aisle
{
	return aisle;
}
@end
