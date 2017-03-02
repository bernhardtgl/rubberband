//
//  ItemsTableViewCell.m
//  Rubberband
//
//  Created by Craig on 5/18/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ItemsTableViewCell.h"


@implementation ItemsTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		// Initialization code
		textLabel = [[UILabel alloc] init];
		textLabel.text = NSLocalizedString(@"Items", @"Items label");
		textLabel.font = [UIFont systemFontOfSize:18];
		textLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:textLabel];
		
		itemsLabel = [[UILabel alloc] init];
		itemsLabel.text = NSLocalizedString(@"None", @"Items text if none are selected");
		itemsLabel.font = [UIFont systemFontOfSize:18];
		itemsLabel.textAlignment = UITextAlignmentRight;
		itemsLabel.textColor = [UIColor darkGrayColor];
		itemsLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:itemsLabel];		
		
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	return self;
}


- (void)dealloc 
{
	[textLabel release];
	[itemsLabel release];
		
	[super dealloc];
}


- (void)layoutSubviews
{	
	const CGFloat LEFT_INDENT = 18;
	const CGFloat RIGHT_INDENT = 55;
	const CGFloat TEXT_WIDTH = 80;
	
	[super layoutSubviews];	
	CGRect frame = [self bounds];
	
	// Place the subviews appropriately.
	CGRect textFrame = CGRectMake(frame.origin.x + LEFT_INDENT, 
								  frame.origin.y + 2, 
								  TEXT_WIDTH, 
								  frame.size.height - 4);
	CGRect itemsFrame = CGRectMake(frame.origin.x + LEFT_INDENT + TEXT_WIDTH, 
									 frame.origin.y + 2, 
									 frame.size.width - TEXT_WIDTH - RIGHT_INDENT, 
									 frame.size.height - 4);
	
	textLabel.frame = textFrame;
	itemsLabel.frame = itemsFrame;
}


@end
