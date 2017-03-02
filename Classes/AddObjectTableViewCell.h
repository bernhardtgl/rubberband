//
//  AddObjectTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/24/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddObjectTableViewCell : UITableViewCell 
{
	// UI Controls
	UILabel* nameLabel;
	UILabel* quantityLabel;
	
	CGFloat fullWidth;
	CGFloat shortWidth;
	
	BOOL isNumberDrawn;
}

- (void) configureObject:(NSString*)name isInList:(BOOL)isInList;

@end
