//
//  ItemQtyTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 10/4/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ItemQtyTableViewCell.h"
#import "GroceryItem.h"
#import "ItemQuantity.h"

@implementation ItemQtyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.font = [UIFont boldSystemFontOfSize:17];
        nameLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:nameLabel];
        
        quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        quantityLabel.font = [UIFont systemFontOfSize:16];
        quantityLabel.textAlignment = NSTextAlignmentRight;
        quantityLabel.textColor = [UIColor grayColor];
        quantityLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:quantityLabel];
        
        // For debugging
        //quantityLabel.backgroundColor = [UIColor redColor];
        //nameLabel.backgroundColor = [UIColor blueColor];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;

}
//- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
//{
//}

- (void)dealloc
{
	[nameLabel release];
	[quantityLabel release];
	
    [super dealloc];
}

- (void)layoutSubviews 
{	
	const CGFloat LEFT_OFFSET = 10;
	const CGFloat RIGHT_OFFSET = 6;
	
    [super layoutSubviews];
	
	// note, contentRect doesn't take into account the Edit buttons on the left, so
	// it is shifted to the left of where one would expect it, so offset it to take 
	// this into account
	CGRect contentRect = [[self contentView] bounds];	
	contentRect = CGRectOffset(contentRect, 42, 0);
	
	CGRect frame;
	
	// the text of the quantity shouldn't be cut off
	[quantityLabel sizeToFit];
	CGFloat fitWidth = quantityLabel.frame.size.width;
	CGFloat fullWidth = contentRect.size.width - LEFT_OFFSET - RIGHT_OFFSET;
	
	frame = CGRectMake(contentRect.origin.x + LEFT_OFFSET, 
					   contentRect.origin.y + 1, 
					   fullWidth - fitWidth,
					   contentRect.size.height - 1);
	nameLabel.frame = frame;	
	
	frame = CGRectMake(contentRect.origin.x + LEFT_OFFSET + fullWidth - fitWidth, 
					   contentRect.origin.y + 1, 
					   fitWidth, 
					   contentRect.size.height - 1);
	quantityLabel.frame = frame;
}

- (void) configureItem:(GroceryItem*)item withQuantity:(ItemQuantity*)quantity
{
	if (item != nil && quantity != nil)
	{
		nameLabel.text = item.name;
		quantityLabel.text = quantity.abbreviation;
	}
}

@end
