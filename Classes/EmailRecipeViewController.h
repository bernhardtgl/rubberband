//
//  EmailRecipeViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 2/1/09.
//  Copyright 2009 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class Recipe;

@interface EmailRecipeViewController : UITableViewController 
{
	id <DialogDelegate> delegate;

	Recipe* recipe;
}
- (id <DialogDelegate>)delegate;
- (void)setDelegate:(id <DialogDelegate>)newDelegate;

@property (readonly, retain) Recipe* recipe;


@end
