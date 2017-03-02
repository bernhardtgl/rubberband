//
//  AisleTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Aisle;

@interface AisleTableViewCell : UITableViewCell 
{
	Aisle* aisle;
	
	// UI Controls
	UILabel* textLabel;
	UILabel* aisleLabel;	
}

- (void) setAisle:(Aisle*)anAisle;
- (Aisle*) aisle;

@end
