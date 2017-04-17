//
//  AddObjectTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/24/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AddObjectTableViewCell.h"

@implementation AddObjectTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.font = [UIFont boldSystemFontOfSize:20];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:nameLabel];
		
		quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		quantityLabel.font = [UIFont boldSystemFontOfSize:16];
		quantityLabel.textColor = [UIColor colorWithRed:0.016 green:0.561 blue:0.004 alpha:1.0];
		quantityLabel.textAlignment = NSTextAlignmentCenter;
		quantityLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:quantityLabel];
	}
    return self;
}

- (void)dealloc
{
	NSLog(@"***** dealloc Ingredient cell: %@", [nameLabel text]);
	[nameLabel release];
	[quantityLabel release];
	
    [super dealloc];
}

- (void)layoutSubviews 
{	
	const CGFloat LEFT_OFFSET = 42;
	const CGFloat RIGHT_OFFSET = -40;
	const CGFloat QTY_WIDTH = 30;
	const CGFloat QTY_HEIGHT = 30;
	
    [super layoutSubviews];
	CGRect contentRect = [[self contentView] bounds];
		
	CGRect frame;
	
	fullWidth = contentRect.size.width - LEFT_OFFSET - RIGHT_OFFSET;
	shortWidth = contentRect.size.width - QTY_WIDTH - LEFT_OFFSET - RIGHT_OFFSET; 
	
	frame = CGRectMake(contentRect.origin.x + LEFT_OFFSET, 
					   contentRect.origin.y + 2, 
					   isNumberDrawn ? shortWidth : fullWidth, 
					   contentRect.size.height - 2);
	nameLabel.frame = frame;
	
	frame = CGRectMake(contentRect.origin.x + contentRect.size.width - QTY_WIDTH - RIGHT_OFFSET, 
					   contentRect.origin.y + 7, 
					   QTY_WIDTH, 
					   QTY_HEIGHT);
	quantityLabel.frame = frame;
}

- (void) configureObject:(NSString*)name isInList:(BOOL)isInList;
{
	if (name != nil)
	{
		nameLabel.text = name;
		quantityLabel.hidden = YES;

		if (isInList) 
		{
			nameLabel.textColor = [UIColor colorWithRed:0.016 green:0.561 blue:0.004 alpha:1.0];;
		}
		else
		{
			nameLabel.textColor = [UIColor darkTextColor];
		}	
		
/*		isNumberDrawn = (quantity > 0);
		quantityLabel.hidden = !isNumberDrawn;
		
		if (isNumberDrawn) 
		{
			quantityLabel.text = [NSString stringWithFormat:@"%d", quantity];
			nameLabel.textColor = [UIColor colorWithRed:0.016 green:0.561 blue:0.004 alpha:1.0];;
		}
		else
		{
			nameLabel.textColor = [UIColor darkTextColor];
		}	
*/	}

}

@end
