//
//  RecipeTableViewCell.m
//  Cell view for recipes which represents a row in a list of recipes.
//	Each row consists of a thumbnail pic, a recipe title (name) and 
//	a preview of the recipe notes.
//
//  Created by Craig on 5/19/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "RecipeTableViewCell.h"
#import "Recipe.h"
#import "RubberbandAppDelegate.h"

@implementation RecipeTableViewCell

//
//	Initializes our table view objects frame and style
//
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		UIView* parentView = [self contentView];
		// thumbnail image
		recipeImageView = [[UIImageView alloc] init];
		recipeImageView.image = App_recipeEmptyImage;
		[parentView addSubview:recipeImageView];
		
		// recipe title text
		nameLabel = [[UILabel alloc] init];
		nameLabel.font = [UIFont boldSystemFontOfSize:16];
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.numberOfLines = 2;
		nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		[parentView addSubview:nameLabel];
				
		// preview of recipe notes text
		notesPreviewLabel = [[UILabel alloc] init];
		notesPreviewLabel.font = [UIFont systemFontOfSize:14];
		notesPreviewLabel.textAlignment = UITextAlignmentLeft;
		notesPreviewLabel.textColor = [UIColor darkGrayColor];
		notesPreviewLabel.backgroundColor = [UIColor clearColor];
		[parentView addSubview:notesPreviewLabel];		
		
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];		
	}
	return self;
}


//
//	Clean up 
//
- (void)dealloc 
{
	[recipeUid release];
	
	[recipeImageView release];
	[nameLabel release];
	[notesPreviewLabel release];
	
    [super dealloc];
}

//
//	Size and position the UI controls within the cell. 
//
- (void)layoutSubviews
{	
	const CGFloat LEFT_IMAGE_INDENT = 0;
	const CGFloat UPPER_MARGIN_IMAGE = 0;
	const CGFloat IMAGE_HEIGHT = 64;
	const CGFloat IMAGE_WIDTH = 64;
	const CGFloat UPPER_MARGIN_TEXT = 3; //6;
	const CGFloat LEFT_TEXT_INDENT = 8;
	const CGFloat RIGHT_TEXT_INDENT = 2;
	const CGFloat NAME_TEXT_HEIGHT_PERCENT = 1.00; //0.62;    
	
	[super layoutSubviews];	
	CGRect frame = [self bounds];
	frame = [[self contentView] bounds];

	// the only way I can figure out whether I'm in Editing mode from the whole view
	// vs. swiping a single row, is checking the frame.size.width. If it's 288.0, then 
	// we're in full view Edit mode. This seems too hacky to use to fix this bug
	// T30:	Swipe delete on recipe moves item over to right
	int leftImageIndent = LEFT_IMAGE_INDENT;
	if (self.editing)
	{
		leftImageIndent += 8;
	}
	
	CGFloat textWidth = frame.size.width - leftImageIndent - IMAGE_WIDTH - LEFT_TEXT_INDENT - RIGHT_TEXT_INDENT;
	// Place the subviews appropriately.
	CGRect imageFrame = CGRectMake(frame.origin.x + leftImageIndent, 
								   frame.origin.y + UPPER_MARGIN_IMAGE, 
								   IMAGE_WIDTH, 
								   IMAGE_HEIGHT);	
	CGRect nameFrame = CGRectMake(frame.origin.x + leftImageIndent + IMAGE_WIDTH + LEFT_TEXT_INDENT, 
								  frame.origin.y + UPPER_MARGIN_TEXT, 
								  textWidth, 
								  (frame.size.height - UPPER_MARGIN_TEXT) * NAME_TEXT_HEIGHT_PERCENT);
	CGRect notesPreviewFrame = CGRectMake(frame.origin.x + leftImageIndent + IMAGE_WIDTH + LEFT_TEXT_INDENT, 
										  frame.origin.y + nameFrame.size.height, 
										  textWidth, 
										  frame.size.height - nameFrame.size.height);
	
	
	recipeImageView.frame = imageFrame;
	nameLabel.frame = nameFrame;
	notesPreviewLabel.frame = notesPreviewFrame;
	
	// GLB: decided I don't like the notes in this view
	notesPreviewLabel.hidden = YES;
}

//
//	Sets the recipe to be displayed by this cell.
//
- (void) configureRecipe:(Recipe*)recipe
{
	if (recipe != nil)
	{
		if (recipe.image != nil) {
			recipeImageView.image = recipe.image;
		}
		nameLabel.text = recipe.name;
		notesPreviewLabel.text = recipe.notes;
		
		recipeUid = recipe.uid;
		[recipeUid retain];		
	}
}

@end
