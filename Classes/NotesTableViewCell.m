//
//  NotesTableViewCell.m
//  Rubberband
//
//  Created by Craig on 5/18/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NotesTableViewCell.h"


@implementation NotesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// Initialization code
		textLabel = [[UILabel alloc] init];
		// Dev: if you change this font size, you need to change the vertical centering
		// code in layoutSubviews
		textLabel.font = [UIFont boldSystemFontOfSize:14];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.highlightedTextColor = [UIColor whiteColor];
		textLabel.numberOfLines = 0; // unlimited
		[self addSubview:textLabel];
				
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	return self;
}


- (void)dealloc 
{
	[textLabel release];
	[snippetLabel release];
	[notes release];
	
    [super dealloc];
}

const CGFloat LEFT_INDENT = 18; 
const CGFloat RIGHT_INDENT = 55;
const CGFloat TOTAL_WIDTH = 320; // bit of a hack, but needed to calculate height of text
								 // before we draw it
const CGFloat MIN_HEIGHT = 45; 

- (void)layoutSubviews
{		
	[super layoutSubviews];	
	CGRect frame = [self bounds];
	
	// Place the subviews appropriately.

	// center the notes vertically if only one line. 
	CGFloat top = ([self cellHeight] == MIN_HEIGHT) ? 14.0 : 8.0;
	CGRect textFrame = CGRectMake(frame.origin.x + LEFT_INDENT, 
								  frame.origin.y + top, 
								  frame.size.width - LEFT_INDENT - RIGHT_INDENT, 
								  frame.size.height - 16);
	
	textLabel.frame = textFrame;

	if ((notes == nil) || ([notes isEqual:@""]))
	{
		textLabel.text = NSLocalizedString(@"Notes", @"Note text if not specified");
		textLabel.textColor = [UIColor grayColor];
	}
	else 
	{
		textLabel.text = notes;
		textLabel.textColor = [UIColor darkTextColor];
	}
	[textLabel sizeToFit];
}

- (CGFloat) cellHeight;
{
	CGSize currentSize = CGSizeMake(TOTAL_WIDTH - LEFT_INDENT - RIGHT_INDENT,
									MIN_HEIGHT);
	CGSize textSize = [textLabel sizeThatFits:currentSize];
	
	// add 10px padding for above and below text
	CGFloat minHeight = textSize.height + 16.0;
	
	// return no less than 45, but more if the text wraps and needs more space
	return (minHeight < MIN_HEIGHT) ? MIN_HEIGHT : minHeight;
}

- (void) setNotes:(NSString*)newNotes
{
	newNotes = [newNotes copy];
	[notes release];
	notes = newNotes;
	
	// need to set this here, so we can determine text height
	textLabel.text = notes;
	[textLabel setNeedsLayout];
}

- (NSString*) notes
{
	return notes;
}

@end
