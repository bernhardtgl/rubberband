//
//  QuantityTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemQuantity;

@interface QuantityTableViewCell : UITableViewCell 
{
	ItemQuantity* quantity;
	NSString* label;
	
	// UI Controls
	UILabel* textLabel;
	UILabel* qtyLabel;	
}

@property (nonatomic, retain) ItemQuantity* quantity;
@property (nonatomic, copy) NSString* label;

@end
