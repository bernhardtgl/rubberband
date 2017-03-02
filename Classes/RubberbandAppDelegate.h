//
//  RubberbandAppDelegate.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/10/08.
//  Copyright GBCB Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Database;
@class ItemsViewController;
@class ShopViewController;
@class RecipesViewController;
@class ShareViewController;
@class TableViewControllerUserPrefs;

// some images we use in various objects. Load 'em once.
extern UIImage* App_dontNeedImage;
extern UIImage* App_needImage;
extern UIImage* App_haveImage;
extern UIImage* App_glowImage;
extern UIImage* App_recipeEmptyImage;
extern UIImage* App_strikethroughImage;

// if the user exits by clicking the email list button, we want to prompt them next
// time they run the app, if they want to clear the list.
extern BOOL App_isEmailing;

// stores file serialization version so we know to make an archival backup
// of the files. Versions: 0 = 1.0.0    1 = 1.1
extern NSInteger App_fileVersion;

// THE one and only database object
extern Database* App_database;

// hacky, but I don't feel like refactoring the sharing stuff into its own class
extern ShareViewController* App_shareViewController;

@protocol UserPrefsInit
- (void)setInitialScrollIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)getCurrentScrollIndexPath;
@end

@protocol TableViewUserPrefs
- (TableViewControllerUserPrefs*) prefs;
@end

@interface RubberbandAppDelegate : NSObject  <UIApplicationDelegate, UIAlertViewDelegate> 
{
    UIWindow *window;
	
	Database *database;
    UITabBarController* tabBarController;
	
	// keep these around so we can reliably release them - see note in the .m
	// file regarding their release
	ItemsViewController*   itemsController;
	ShopViewController*    shopController;
	RecipesViewController* recipesController;
	ShareViewController* shareController;
	
	BOOL isShowingAlertForEmail;
	BOOL isShowingAlertForRecipe;
	BOOL isShowingAlertForRecipeUrlOnly;
	BOOL isShowingAlertForItems;
	
	// only calculate totalAisles once
	BOOL isShowingAlertForAllItems;
	int totalAisles;
	
	// hold on to the URL information while the user is looking at the alert and deciding
	// if they want to add the recipe or items
	NSArray* urlParts;
}

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) Database* database;

- (void) saveUserPreferenceSettings;
- (void) loadUserPreferenceSettings;

// the emailing functions seem to kill us pretty uncerimoniously, so save preferences
// and database in advance
- (void) prepareToTerminate;

@end
