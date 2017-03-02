//
//  ItemTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/23/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroceryItem;

@interface ItemTableViewCell : UITableViewCell 
{
	// UI Controls
	UILabel* nameLabel;
	UIButton* quantityButton;

	UIImageView* imageView;
	UIImageView* strikeView;
	
	CGFloat fullWidth;
	CGFloat shortWidth;
	
	BOOL isNumberDrawn;
	NSString* itemUid;
}

- (void) configureItem:(GroceryItem*)item;
- (NSString*) itemUid;

@end
