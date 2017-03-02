//
//  NumberTableViewCell.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NumberTableViewCell : UITableViewCell <UITextFieldDelegate> {
	UITextField* numberField;
	NSUInteger numberValue;
}

@end
