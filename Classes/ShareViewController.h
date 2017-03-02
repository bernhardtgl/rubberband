//
//  ShareViewController.h
//  View controller screen for the share screen.
//
//  Created by Craig on 9/14/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RubberbandAppDelegate.h"
#import "Protocols.h"

@class Recipe;

@interface ShareViewController : UIViewController <DialogDelegate>
{
	RubberbandAppDelegate* appController;
	
	
}
@property (nonatomic, assign) RubberbandAppDelegate* appController;

- (BOOL) addRecipeUrlCheck:(NSArray*)urlParts;
- (NSString*) addRecipeUrlPrompt:(NSArray*)urlParts;
- (Recipe*) addRecipeUrlComplete:(NSArray*)urlParts;

- (void)emailRecipe:(Recipe*)r;

@end
