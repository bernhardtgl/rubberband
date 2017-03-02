//
//  ItemTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/23/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "GroceryItem.h"
#import "RubberbandAppDelegate.h"
#import "ItemQuantity.h"

@implementation ItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
	{
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.font = [UIFont boldSystemFontOfSize:20];
		
		[self addSubview:nameLabel];

		// quantity is a "button" so the user can tap it to increase the quantity
		UIColor* color = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		quantityButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[quantityButton setTitleColor:color forState:UIControlStateHighlighted];
		[quantityButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[quantityButton setBackgroundImage:App_glowImage forState:UIControlStateHighlighted];
		[quantityButton addTarget:self action:@selector(quantityAction:) forControlEvents:UIControlEventTouchUpInside];
		quantityButton.adjustsImageWhenHighlighted = NO;
		quantityButton.titleLabel.font = [UIFont systemFontOfSize:16];
		quantityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
		[self addSubview:quantityButton];
				
		imageView = [[UIImageView alloc] initWithImage:App_dontNeedImage];
		[self addSubview:imageView];

		strikeView = [[UIImageView alloc] initWithImage:App_strikethroughImage];
		strikeView.hidden = YES;
		[self addSubview:strikeView];

		// For debugging
		//quantityButton.backgroundColor = [UIColor redColor];
		//nameLabel.backgroundColor = [UIColor blueColor];		
	}
    return self;
}

- (void)dealloc
{
	NSLog(@"***** dealloc Item Cell: %@", [nameLabel text]);
	[nameLabel release];
	[quantityButton release];
	[itemUid release];

	[imageView release];
	[strikeView release];
	
    [super dealloc];
}

- (void)layoutSubviews 
{	
	const CGFloat LEFT_OFFSET = 42;
	const CGFloat LEFT_OFFSET_EDITING = 42;
	const CGFloat RIGHT_OFFSET = 6;
	const CGFloat RIGHT_OFFSET_EDITING = -26; // GLB: There's a bug with contentView, check in later beta
	const CGFloat QTY_MIN_WIDTH = 30;
	const CGFloat QTY_HEIGHT = 30;
	
    [super layoutSubviews];
	CGRect contentRect = [[self contentView] bounds];
	
	CGFloat leftOffset = (self.editing) ? LEFT_OFFSET_EDITING : LEFT_OFFSET;	
	CGFloat rightOffset = (self.editing) ? RIGHT_OFFSET_EDITING : RIGHT_OFFSET;	
		
	CGRect frame;
			
	fullWidth = contentRect.size.width - leftOffset - rightOffset;

	// width of quantity should be at least 30px to have a decent sized hit target
	// the text of the number shouldn't be cut off either
	[quantityButton sizeToFit];
	CGFloat fitWidth = quantityButton.frame.size.width;
	CGFloat finalQtyWidth = (fitWidth < QTY_MIN_WIDTH ? QTY_MIN_WIDTH : fitWidth);
	
	frame = CGRectMake(fullWidth - finalQtyWidth + leftOffset, 
					   contentRect.origin.y + 7, 
					   finalQtyWidth, 
					   QTY_HEIGHT);
	quantityButton.frame = frame;
	
	// the name label makes up the rest of the width
	frame = CGRectMake(contentRect.origin.x + leftOffset, 
					   contentRect.origin.y + 1, 
					   isNumberDrawn ? fullWidth - finalQtyWidth - 4 : fullWidth, 
					   contentRect.size.height - 2);
	nameLabel.frame = frame;
		
	frame = CGRectMake(contentRect.origin.x + leftOffset - 4, 
					   contentRect.origin.y + 9, 
					   fullWidth + 8, 
					   25);
	strikeView.frame = frame;
	
	if (!self.editing)
	{
		frame = [imageView frame];
		frame.origin.x = contentRect.origin.x + 9.0;
		frame.origin.y =  contentRect.origin.y + 10.0;
		imageView.frame = frame;
	}
	imageView.hidden = (self.editing);
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
//{	
	// don't call the superclass, 
	// TODO: may want to mess with the look of the cell when it's selected
	
	/* // Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  
	// To show selection properly, however, the views need to be transparent 
	// (so that the selection color shows through).  	
	UIColor *backgroundColor = nil;
	if (selected) {
		backgroundColor = [UIColor clearColor];
	} else {
		backgroundColor = [UIColor whiteColor];
	}

	NSArray *labelArray = [[NSArray alloc] initWithObjects:nameLabel, quantityLabel, nil];
	for (UILabel *label in labelArray) 
	{
		label.backgroundColor = backgroundColor;
		label.highlighted = selected;
		label.opaque = !selected;
	}	
	[super setSelected:selected animated:animated];
*/	
//}

- (void) configureItem:(GroceryItem*)item
{
	if (item != nil)
	{
		ItemQuantity* qty = item.qtyNeeded;
		
		nameLabel.text = item.name;
		isNumberDrawn = (qty.amount > 0);
		itemUid = item.uid;
		[itemUid retain];
		
		strikeView.hidden = YES;
		nameLabel.textColor = [UIColor darkTextColor];

		if (isNumberDrawn) 
		{
			NSString* text = qty.abbreviation;
			
			// add a couple spaces at the end of the string when it is just a number to
			// give a larger hit target
			if ([qty type] == QuantityTypeNone)
			{
				text = [text stringByAppendingString:@"  "];
			}
			
			[quantityButton setTitle:text
							forState:UIControlStateNormal];
			quantityButton.hidden = NO;
			if (item.haveItem) 
			{
				imageView.image = App_haveImage;
				strikeView.hidden = NO;
				nameLabel.textColor = [UIColor grayColor];
			} 
			else 
			{
				imageView.image = App_needImage;
			}
		}
		else
		{
			quantityButton.hidden = YES;
			imageView.image = App_dontNeedImage;
		}	
	}
}

- (void)quantityAction:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"GBCBIncreaseItemQuantity" object:self];			
}

 - (NSString*) itemUid
{
	return itemUid;
}

@end
