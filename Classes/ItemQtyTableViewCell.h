//
//  ItemQtyTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 10/4/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroceryItem;
@class ItemQuantity;

@interface ItemQtyTableViewCell : UITableViewCell 
{
	// UI Controls
	UILabel* nameLabel;
	UILabel* quantityLabel;
}

- (void) configureItem:(GroceryItem*)item withQuantity:(ItemQuantity*)quantity;

@end
