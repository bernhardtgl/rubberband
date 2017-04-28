//
//  QuantityTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "QuantityTableViewCell.h"
#import "ItemQuantity.h"

@implementation QuantityTableViewCell

@synthesize quantity;
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// default
		self.label = NSLocalizedString(@"Quantity", @"Quantity label");

		textLabel = [[UILabel alloc] init];
		textLabel.font = [UIFont systemFontOfSize:18];
		textLabel.highlightedTextColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:textLabel];
		
		qtyLabel = [[UILabel alloc] init];
		qtyLabel.font = [UIFont systemFontOfSize:18];
		qtyLabel.textAlignment = NSTextAlignmentRight;
		qtyLabel.textColor = [UIColor darkGrayColor];
		qtyLabel.highlightedTextColor = [UIColor whiteColor];
		qtyLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:qtyLabel];		
	}
	return self;
}

- (void)dealloc 
{
	[quantity release];
	
	[textLabel release];
	[qtyLabel release];
	
	[super dealloc];
}

- (void)layoutSubviews
{	
	const CGFloat LEFT_INDENT = 18;
	
	[super layoutSubviews];	
	CGRect frame = [[self contentView] bounds];

	textLabel.text = self.label;
	[textLabel sizeToFit];
	CGFloat labelWidth = textLabel.bounds.size.width;
	
    // when there is an accessory, the bounds already have a proper right indent included, so don't need to add that
    int rightIndent = 0;
    if (self.accessoryType == UITableViewCellAccessoryNone) rightIndent = 14;
    
	// Place the subviews appropriately.
    CGRect textFrame = CGRectMake(frame.origin.x + LEFT_INDENT,
                                  frame.origin.y + 2,
                                  labelWidth,
                                  frame.size.height - 4);
	CGRect qtyFrame  = CGRectMake(frame.origin.x + LEFT_INDENT + labelWidth,
								   frame.origin.y + 2, 
								   frame.size.width - labelWidth - LEFT_INDENT - rightIndent,
								   frame.size.height - 4);
	
	textLabel.frame = textFrame;
    qtyLabel.frame = qtyFrame;
	
// For debugging...
//		textLabel.backgroundColor = [UIColor redColor];
//		qtyLabel.backgroundColor = [UIColor blueColor];
	

	if (quantity == nil)
	{
		qtyLabel.text = @"0";
		qtyLabel.textColor = [UIColor darkGrayColor];
	}
	else 
	{
		qtyLabel.text = [quantity abbreviation];
		UIColor* color = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		qtyLabel.textColor = color;
	}
	
}


@end
