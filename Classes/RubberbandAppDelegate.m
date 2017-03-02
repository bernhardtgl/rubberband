//
//  RubberbandAppDelegate.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 3/10/08.
//  Copyright GBCB Software 2008. All rights reserved.
//

#import "RubberbandAppDelegate.h"
#import "ItemsViewController.h"
#import "ShopViewController.h"
#import "RecipesViewController.h"
#import "ShareViewController.h"
#import "GroceryItem.h"
#import "Database.h"
#import "RecipeViewController.h"
#import "Recipe.h"
#import "TableViewControllerUserPrefs.h"
#import "RecipesTable.h"
#import "HelperFunctions.h"
#import "AislesTable.h"

// user preference setting field names
NSString* UserPrefSelectedAppTab = @"SelectedApplicationTab";
NSString* UserPrefSectionScrollPos = @"SectionScrollPosition";
NSString* UserPrefRowScrollPos = @"RowScrollPosition";
NSString* UserPrefIsRecipeSelected = @"IsRecipeSelected";
NSString* UserPrefSelectedRecipe = @"SelectedRecipe";
NSString* UserPrefDidEmailList = @"EmailList";
NSString* UserPrefFileVersion = @"FileVersion";

UIImage* App_dontNeedImage;
UIImage* App_needImage;
UIImage* App_haveImage;
UIImage* App_glowImage;
UIImage* App_recipeEmptyImage;
UIImage* App_strikethroughImage;
NSInteger App_fileVersion;
BOOL App_isEmailing;

// if the user launches from our JavaScriptlet, these are the name and URL from the
// page they launched from
//
// javascriptlet is: 
//   javascript:location%20=%20'groceryzen://'+document.URL+'&&'+document.title

BOOL App_newRecipeLaunch;
NSString* App_newRecipeName;
NSString* App_newRecipeURL;

Database* App_database;
ShareViewController* App_shareViewController;

@interface RubberbandAppDelegate(PrivateMethods)
- (void) handleNeedCountChanged:(NSNotification*)notification;
- (BOOL) launchAddList:(NSString*)urlInfo;
- (BOOL) launchAddAll:(NSString*)urlInfo;
- (BOOL) launchAddRecipe:(NSString*)urlInfo;
- (BOOL) launchAddRecipeUrlOnly:(NSString*)urlInfo;
@end

@implementation RubberbandAppDelegate

@synthesize window;
@synthesize database;

- init 
{
	if (self = [super init]) 
	{
		database = [[Database alloc]init];
		App_database = database;
		App_dontNeedImage = [[UIImage imageNamed:@"checkbox_dontneed.png"] retain];
		App_needImage = [[UIImage imageNamed:@"checkbox_need.png"] retain];
		App_haveImage = [[UIImage imageNamed:@"checkbox_have.png"] retain];
		App_glowImage = [[UIImage imageNamed:@"glow.png"] retain];
		App_recipeEmptyImage = [[UIImage imageNamed:@"RecipeNone.png"] retain];
		App_strikethroughImage = [[UIImage imageNamed:@"strikethrough.png"] retain];
		
		App_newRecipeLaunch = NO; // set to yes when launched thru our javascriptlet
		App_isEmailing = NO;
	}
	return self;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{   
	// for debugging this code
	/* BOOL more = YES;
	while (more) {
		[NSThread sleepForTimeInterval:1.0]; // Set break point on this line
	}
	 */
    // You should be extremely careful when handling URL requests.
    // You must take steps to validate the URL before handling it.
	
    if (!url) 
	{
        // The URL is nil. There's nothing more to do.
        return NO;
    }
    
    NSString* urlString = [url absoluteString];
	
	// strip off the "launcher" prefix
	if (urlString.length < 13) // ours all start with groceryzen://
	{
		return NO;
	}
	NSString* urlInfo = [urlString substringFromIndex:13];

	// check to see which command is being run
	
	if ([urlInfo hasPrefix:@"addlist?"])
	{
		return [self launchAddList:[urlInfo substringFromIndex:8]];
	}
	else if ([urlInfo hasPrefix:@"addrecipe?"])
	{
		return [self launchAddRecipe:[urlInfo substringFromIndex:10]];
	}
	else if ([urlInfo hasPrefix:@"addall?"])
	{
		return [self launchAddAll:[urlInfo substringFromIndex:7]];
	}
	else
	{
		return [self launchAddRecipeUrlOnly:urlInfo];
	}
}

- (BOOL) launchAddList:(NSString*)urlInfo;
{
	// store for later
	[urlParts release];
	urlParts = [[urlInfo componentsSeparatedByString:@"&"] retain];

	// there are 4 parts to the URL for each item to be added. 
	int totalItems = urlParts.count / 4;

	if (totalItems == 0) {
		return NO;
	}
	
	NSString* message = (totalItems == 1) ? 
		NSLocalizedString(@"Do you want to add one item to your shopping list?", @"add from email - singular")
		:
		[NSString stringWithFormat:NSLocalizedString(@"Do you want to add %d items to your shopping list?", @"add from email"), totalItems];

	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@"GroceryZen"
						  message:message
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Cancel",@"button")
						  otherButtonTitles:NSLocalizedString(@"Add to List",@"THIS NEEDS TO BE SHORT - button when adding from email"), 
						  nil];	
	[alert show];
	[alert release];
	isShowingAlertForItems = YES;
	
    // Do you want to add 24 items to your shopping list?
	return YES;	
}

- (BOOL) launchAddAll:(NSString*)urlInfo;
{
	// store for later
	[urlParts release];
	urlParts = [[urlInfo componentsSeparatedByString:@"&"] retain];

	for (totalAisles = 0; totalAisles < urlParts.count; totalAisles++) 
	{
		if ([[urlParts objectAtIndex:totalAisles] isEqualToString:@"-----"])
		{
			break;
		}
	}
	
	// there are 6 parts to the URL for each item to be added after the blank aisle
	int totalItems = (urlParts.count - totalAisles - 1) / 6;
	
	if (totalItems == 0) {
		return NO;
	}
	
	NSString* message = [NSString stringWithFormat:NSLocalizedString(
		@"Do you want to add %d aisles and %d items to GroceryZen?", 
		@"Add all from email"), totalAisles, totalItems];
	
	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@"GroceryZen"
						  message:message
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Cancel",@"button")
						  otherButtonTitles:NSLocalizedString(@"Add Items",@"THIS NEEDS TO BE SHORT - button when adding all aisles and items from email"), 
						  nil];	
	[alert show];
	[alert release];
	isShowingAlertForAllItems = YES;
	
    // Show the message
	return YES;	
}

- (BOOL) launchAddRecipe:(NSString*)urlInfo;
{
	// store for later. Released with the class later
	[urlParts release];
	urlParts = [[urlInfo componentsSeparatedByString:@"&"] retain];

	if (![shareController addRecipeUrlCheck:urlParts])
	{
		return NO;
	}
	
	NSString* message = [shareController addRecipeUrlPrompt:urlParts];
		
	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@"GroceryZen"
						  message:message
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Cancel",@"button")
						  otherButtonTitles:NSLocalizedString(@"Add Recipe",@"THIS NEEDS TO BE SHORT - button when adding from email"), 
						  nil];	
	[alert show];
	[alert release];
	isShowingAlertForRecipe = YES;
		
	return YES;	
}
- (BOOL) launchAddRecipeUrlOnly:(NSString*)urlInfo;
{
	urlParts = [[urlInfo componentsSeparatedByString:@"&&"] retain];

	if (urlParts.count != 2)
	{
		return NO;
	}

	App_newRecipeURL = [[urlParts objectAtIndex:0] retain];
	App_newRecipeName = [[[urlParts objectAtIndex:1] 
				stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
	App_newRecipeLaunch = YES;
	
	// Check if the URL and name is longer than we expect. Stop servicing it.
    if (([App_newRecipeName length] > 100) || ([App_newRecipeURL length] > 1000))
	{
        return NO;
    }
	
	NSString* message = [NSString stringWithFormat:NSLocalizedString(@"Do you want to add a new recipe?\r\n\r\n%@",
						 @"Message when user launches from a website to add a recipe"), 
						 App_newRecipeName];
	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@"GroceryZen"
						  message:message
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Cancel",@"button")
						  otherButtonTitles:NSLocalizedString(@"Add Recipe",@"THIS NEEDS TO BE SHORT - button when adding from email"), 
						  nil];	
	[alert show];
	[alert release];
	isShowingAlertForRecipeUrlOnly = YES;
	
    return YES;
}

// Does the actual work of adding items. Uses the urlParts array set above. Called after
// the user says "OK" to the message confirming they really want to do it
- (void) addItemsFromUrl;
{
	// make a quick lookup dictionary by aisle name. key=name object=aisle
	NSMutableDictionary* aisleByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (Aisle* eachAisle in [App_database aisles]) {
		[aisleByNameDict setObject:eachAisle forKey:eachAisle.name];
	}
	// make a quick lookup dictionary by item name.
	NSMutableDictionary* itemByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (GroceryItem* eachItem in [App_database groceryItems]) {
		[itemByNameDict setObject:eachItem forKey:eachItem.name];
	}
	
	BOOL addedSomething = NO;
	
	// there are 4 parts to each item in the list
	int i;
	for (i = 0; i < urlParts.count - 4; i = i + 4)
	{
		NSString* itemName = unencodeUrlString([urlParts objectAtIndex:i]);
		NSString* aisleName = unencodeUrlString([urlParts objectAtIndex:i + 1]);
		NSString* itemQtyStr = [urlParts objectAtIndex:i + 2];
		double itemQty = [itemQtyStr doubleValue];
		NSString* itemQtyTypeStr = [urlParts objectAtIndex:i + 3];
		QuantityType itemQtyType = [itemQtyTypeStr intValue];
		
		if ([itemName isEqual:@""]) {
			continue;
		}
		
		GroceryItem* theItem = [itemByNameDict objectForKey:itemName];
		if (theItem != nil)
		{
			// already exists - update its quantity, and make sure we "need" it
			theItem.haveItem = NO;
			theItem.qtyNeeded.type = itemQtyType;
			theItem.qtyNeeded.amount = itemQty;
		}
		else
		{
			// create a new item. Use the aisle name passed in if it exists, otherwise
			// use no aisle. We don't create any aisles as part of this process. If there's
			// more than one item with the same name, this will choose the one of them.
			theItem = [[GroceryItem alloc] init];
			theItem.name = itemName;
			// sets to nil if doesn't exist
			theItem.aisle = [aisleByNameDict objectForKey:aisleName];
			theItem.haveItem = NO;
			theItem.qtyNeeded.type = itemQtyType;
			theItem.qtyNeeded.amount = itemQty;
			theItem.qtyUsual.type = itemQtyType;
			theItem.qtyUsual.amount = itemQty;
			[App_database.groceryItems addItem:theItem];
			[theItem release];
		}
		addedSomething = YES;
	}

	// show the "Shop" tab, since that's where stuff just got added to...
	if (addedSomething)
	{
		tabBarController.selectedIndex = 3;
		[shopController updateList];
	}
	
	// TODO: catch A problem occurred while adding the items to your shopping list. 	
}

// Does the actual work of adding ALL items.
- (void) addAllItemsFromUrl;
{
	isShowingAlertForAllItems = NO;
	
	// make a quick lookup dictionary by aisle name. key=name object=aisle
	NSMutableDictionary* aisleByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (Aisle* eachAisle in [App_database aisles]) {
		[aisleByNameDict setObject:eachAisle forKey:eachAisle.name];
	}
	
	// loop through the newly received aisles, and merge them with the existing aisles
	int newPos = 0;
	int mergePos = 0;
	AislesTable* tbl = [App_database aisles];
	
	for (newPos = 0; newPos < totalAisles; newPos++)
	{
		NSString* newAisleName = unencodeUrlString([urlParts objectAtIndex:newPos]);
		Aisle* existingAisle = [aisleByNameDict objectForKey:newAisleName];
		if (existingAisle != nil)
		{
			int currentIndex = [tbl indexOfAisle:existingAisle];
			if (currentIndex < mergePos)
			{
				[tbl moveAisleAtIndex:currentIndex toIndex:mergePos];
				mergePos++;
			}
			else
			{
				// otherwise leave it where it is, but merge additional aisles after it
				mergePos = currentIndex + 1;
			}
		}
		else
		{
			// create a new aisle, we received one we didn't already have
			Aisle* newAisle = [[Aisle alloc] init];
			newAisle.name = newAisleName;
			[tbl addAisle:newAisle];
			[tbl moveAisleAtIndex:[tbl count] - 1 toIndex:mergePos];
			[newAisle setOwnerContainer:tbl];
			[newAisle release];
			mergePos++;
		}
	}

	// reload the aisle dictioary, since we've changed the aisles
	aisleByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (Aisle* eachAisle in [App_database aisles]) {
		[aisleByNameDict setObject:eachAisle forKey:eachAisle.name];
	}
	
	// make a quick lookup dictionary by item name.
	NSMutableDictionary* itemByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (GroceryItem* eachItem in [App_database groceryItems]) {
		[itemByNameDict setObject:eachItem forKey:eachItem.name];
	}
		
	// there are 6 parts to each item in the list, start after the aisles, plus 1 for the ----- separator
	int i;
	for (i = totalAisles + 1; i < urlParts.count - 6; i = i + 6)
	{
		NSString* itemName = unencodeUrlString([urlParts objectAtIndex:i]);
		NSString* aisleName = unencodeUrlString([urlParts objectAtIndex:i + 1]);
		
		NSString* itemQtyStr = [urlParts objectAtIndex:i + 2];
		double itemQty = [itemQtyStr doubleValue];
		NSString* itemQtyTypeStr = [urlParts objectAtIndex:i + 3];
		QuantityType itemQtyType = [itemQtyTypeStr intValue];
		
		NSString* itemUsualStr = [urlParts objectAtIndex:i + 4];
		double itemUsual = [itemUsualStr doubleValue];
		NSString* itemUsualTypeStr = [urlParts objectAtIndex:i + 5];
		QuantityType itemUsualType = [itemUsualTypeStr intValue];
		
		if ([itemName isEqual:@""]) {
			continue;
		}
		
		GroceryItem* theItem = [itemByNameDict objectForKey:itemName];
		if (theItem == nil)
		{
			// create a new item, add it to the ItemsTable
			theItem = [[GroceryItem alloc] init];
			theItem.name = itemName;
			[App_database.groceryItems addItem:theItem];
			[theItem release];
		}

		// set everything in the item to match what we received
		theItem.aisle = [aisleByNameDict objectForKey:aisleName];
		theItem.qtyNeeded.type = itemQtyType;
		theItem.qtyNeeded.amount = itemQty;
		theItem.qtyUsual.type = itemUsualType;
		theItem.qtyUsual.amount = itemUsual;
	}
	
	tabBarController.selectedIndex = 0;
	[itemsController updateList];
	
	// TODO: catch A problem occurred while adding the items to your shopping list. 	
}

// when the app is launched via a "groceryzen://" link we always prompt the user to 
// make sure they want to continue. This handles their response to the prompt.
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// user clicked the "Cancel"-equivalent button. Do nothing
	if (buttonIndex == 0) {
		isShowingAlertForRecipeUrlOnly = NO;
		isShowingAlertForRecipe = NO;
		isShowingAlertForItems = NO;
		isShowingAlertForAllItems = NO;
		isShowingAlertForEmail = NO;
		return;
	}
	
	if (isShowingAlertForRecipeUrlOnly || isShowingAlertForRecipe)
	{
		// set the tab to recipes, to prepare to add a new one - select the recipes tab
		// and make sure we are at the root view (recipes, not a single recipe's ingredients)
		tabBarController.selectedIndex = 1;
		UINavigationController* navVC = (UINavigationController*)[tabBarController selectedViewController];
		UIViewController* visibleVC = [navVC visibleViewController];
		
		if ([visibleVC isKindOfClass:[RecipeViewController class]])
		{
			[navVC popToRootViewControllerAnimated:NO];
		}
		
		if (isShowingAlertForRecipeUrlOnly) {
			isShowingAlertForRecipeUrlOnly = NO;
			[recipesController createNewRecipeWithName:App_newRecipeName link:App_newRecipeURL];			
		}
		else 
		{
			isShowingAlertForRecipe = NO;
			Recipe* r = [shareController addRecipeUrlComplete:urlParts];
			[recipesController createNewRecipe:r];			
		}
	}
	else if (isShowingAlertForItems)
	{
		isShowingAlertForItems = NO;
		[self addItemsFromUrl];
	}
	else if (isShowingAlertForAllItems)
	{
		isShowingAlertForAllItems = NO;
		[self addAllItemsFromUrl];
	}
	else if (isShowingAlertForEmail)
	{
		isShowingAlertForEmail = NO;
		[shopController clearList];
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{		
    // Set up the window and content view
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// load collections from file
	BOOL loadedSuccessfully = [database loadFromDisk];
 
	// Create a tab bar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray* viewControllers = [[NSMutableArray alloc] initWithCapacity:3];

	// 1. Set up the ITEMS view controller, add it to the nav controller, then to the 
	// array of controllers
    itemsController = [[ItemsViewController alloc] init];
	
	UINavigationController* navigationController = [[UINavigationController alloc] 
							initWithRootViewController:itemsController];
	[viewControllers addObject:navigationController];
	
	[navigationController release];

	// 2. Set up the RECIPES view controller, add it to the nav controller, then to the 
	// array of controllers
	recipesController = [[RecipesViewController alloc] init];
	
	navigationController = [[UINavigationController alloc] 
							initWithRootViewController:recipesController];
	[viewControllers addObject:navigationController];
	
	[navigationController release];
	
	// 3. Set up the SHARE view controller, add it to the nav controller, then to the 
	// array of controllers
	shareController = [[ShareViewController alloc] init];
	shareController.appController = self;
	App_shareViewController = shareController;
	
	navigationController = [[UINavigationController alloc] 
							initWithRootViewController:shareController];
	[viewControllers addObject:navigationController];
	
	[navigationController release];

	// 4. Set up the SHOP view controller, add it to the nav controller, then to the 
	// array of controllers
    shopController = [[ShopViewController alloc] init];
	shopController.appController = self;
	
	navigationController = [[UINavigationController alloc] 
							initWithRootViewController:shopController];
	[viewControllers addObject:navigationController];
	
	[navigationController release];
	
	
	// Add the array of controllers to the tab bar, than add it to the window
	tabBarController.viewControllers = viewControllers;
	[viewControllers release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNeedCountChanged:)
												 name:@"GBCBNeedCountChanged"
											   object:nil];
	
	// make sure the badge gets updated
	[self handleNeedCountChanged:nil];
	
	[window addSubview:tabBarController.view];
//    [window setRootViewController:tabBarController]; // GLB
	[window makeKeyAndVisible];

	[self loadUserPreferenceSettings];
	
	if (!loadedSuccessfully)
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
			NSLocalizedString(@"GroceryZen had trouble loading the information from your most recent changes. If this keeps happening, please contact our technical support.", @"Load failure")
			delegate:nil cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[actionSheet showInView:tabBarController.view];
		[actionSheet release];		
	}

	// make a backup of the files first thing, if we are upgrading from an earlier version
	// Note: this will run on first ever install of the app, but will do nothing, since
	// the files to backup won't be there
	if (App_fileVersion == 0)
	{
		[database backupFilesArchiveForVersion:0];
	}

	// Uncomment this to test launching with a URL
//	[self application:application handleOpenURL:
//		[NSURL URLWithString:
		// @"groceryzen://addlist?WrongFormat"
		// @"groceryzen://addlist?&&&&&&"
		// @"groceryzen://addlist?Pork%20%26%20Beans&Canned%20Goods&2.000000&1&Baby%20food&Baby&1.000000&0&Kumquats&Produce&3.000000&1&"
		// @"groceryzen://http://www.yahoo.com&&A%20great%20recipe"
		
		 // valid: with picture
		 //@"groceryzen://addrecipe?Proscuitto-Wrapped%20XXXXX%20with%20Blackberry%20Mint%20Sauce&http://seattlefoodgeek.com/2008/04/27/proscuitto-wrapped-shrimp-with-blackberry-mint-sauce/&Makes:%204%20self-defense%20skewers.%20%0A%09%09Total%20kitchen%20time:%2020%20minutes.%0A%09%09From:%20seattlefoodgeek.com&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&Shrimpylicious&*%20Fish%20market&3.500000&1&Prosciutto&Missing%20Aisle&0.250000&1&Bamboo%20skewers&Ethnic%20foods&1.000000&0&Mace&Spices&1.000000&0&White%20pepper&Spices&1.000000&0&Blackberry%20preserves&Condiments&1.000000&0&Mint%20leaves&Produce&1.000000&0&Port%20wine&Beverages&1.000000&0&Sea%20salt&Spices&1.000000&0&"
		
		 // @"groceryzen://addrecipe?TestNoLinkNoPic&&SmallNote&&"
		 
		 // valid: name only 
		 // @"groceryzen://addrecipe?Super%20simple&&&&"
		 
		 // INVALID: contains a garbage image and the wrong # of items for an ingredient
		 // @"groceryzen://addrecipe?Bad%20image%20and%20ingredients&&&****&ItemName&"
		 
		 // INVALID: contains a good ingredient and a bad one.
		 // - bad ingredient has non-# for qty and invalid enum value
		 //@"groceryzen://addrecipe?Bad%20image%20and%20ingredients&&&&ItemName&AisleName&****&25&Goodone&&1&0&"
	
		 // valid: add alls
		 //@"groceryzen://addall?aisle1&aisle2&-----&Pork%20%26%20Beans&Canned%20Goods&2.000000&1&1.000000&0&Baby%20food&Baby&1.000000&0&1.000000&0&"
//		 @"groceryzen://addall?Produce&Deli/Cheese&Meat&Cereal&Baking&Condiments&Soup&Frozen&Household&Prepared%20foods&Canned%20vegetables/pasta&Canned%20fruit&Spices&Ethnic%20foods&Baby&Personal%20Care&Pets&Snacks&Beverages&Dairy&Bakery&Check-Out&*%20Fish%20market&*%20Specialty%20store&-----&Allspice&Spices&0.000000&0&1.000000&0&Almonds&Baking&0.000000&0&1.000000&0&"
//		 ]];
	 
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if (App_isEmailing)
	{
		UIAlertView *alert = [[UIAlertView alloc]  
							  initWithTitle:@"" 
							  message:NSLocalizedString(@"Since you emailed your list, do you want to clear it now?",@"Message after user has emailed list.")
							  delegate:self 
							  cancelButtonTitle:NSLocalizedString(@"Keep List", @"Must be short! Button after user has emailed list.")
							  otherButtonTitles: NSLocalizedString(@"Clear List", @"Must be short! Button after user has emailed list."),
							  nil];
		[alert show];
		[alert release];
		isShowingAlertForEmail = YES;
		App_isEmailing = NO;
		[self saveUserPreferenceSettings];
	}
	
}

- (void)prepareToTerminate;
{	
	// save current collections to file
	[self saveUserPreferenceSettings];
	[database saveToDisk];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self prepareToTerminate];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	NSLog(@"***** applicationWillTerminate");

	[self prepareToTerminate];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[database release];
	database = nil;
	App_database = nil;
		
	NSLog(@"term tbc :%d", [tabBarController retainCount]);
    [tabBarController release];    
	NSLog(@"term win :%d", [window retainCount]);
    [window release];

	NSLog(@"term img :%d", [App_dontNeedImage retainCount]);
	[App_dontNeedImage release];
	[App_needImage release];
	[App_haveImage release];
	[App_glowImage release];
	[App_recipeEmptyImage release];
	[App_strikethroughImage release];
	[App_newRecipeURL release];
	[App_newRecipeName release];
	[urlParts release];
	
	// GLB: I believe there is a leak in UINavigationViewController, which adds
	// an extra retain on to the active view. Since we know we are shutting down
	// at this point, we will forcibly release these objects. Hopefully in a future
	// beta of the SDK, this will get fixed, and we can call release a single time
	// But for now, this will let us see that all of our objects are getting released
	// to test for memory leaks.
	//
	// Only the currently active tab will have a retainCount of 2
	int nCount;
	
	NSLog(@"term itemsController:%d", [itemsController retainCount]);
	nCount = [itemsController retainCount];
	int n;
	for (n = 0; n < nCount; n++) {
		[itemsController release];
	}
	itemsController = nil;
	
	NSLog(@"term shopController:%d", [shopController retainCount]);
	nCount = [shopController retainCount];
	for (n = 0; n < nCount; n++) {
		[shopController release];
	}
	shopController = nil;
	
	NSLog(@"term recipesController:%d", [recipesController retainCount]);
	nCount = [recipesController retainCount];
	for (n = 0; n < nCount; n++) {
		[recipesController release];
	}
	recipesController = nil;

	NSLog(@"term shareController:%d", [shareController retainCount]);
	nCount = [shareController retainCount];
	for (n = 0; n < nCount; n++) {
		[shareController release];
	}
	shareController = nil;
	
	// suicide. If we don't do this our dealloc never gets called
	NSLog(@"term self:%d", [self retainCount]);
    [self release];
}

- (void) dealloc 
{
	// the typical "release" calls you would find in the dealloc function are above
	// in applicationWillTerminate, otherwise they never get called
	NSLog(@"***** dealloc RubberbandAppDelegate");	
    [super dealloc];
}

// Update the badge on th Shop view when the Needed items count changes. This
// can come from any of the views, which is why it is handled here
- (void) handleNeedCountChanged:(NSNotification*)notification
{
	UIViewController* vcWithBadge = [shopController navigationController];
	int count = [[database groceryItems] countOfNeededItems]; 

	if (count > 0) 
	{
		[[vcWithBadge tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", count]];
		[UIApplication sharedApplication].applicationIconBadgeNumber = count;
	} 
	else 
	{
		[[vcWithBadge tabBarItem] setBadgeValue:nil];
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
}


//
//	Save user preference application settings such as 
//	last tab and tableview scroll position.
//
- (void) saveUserPreferenceSettings
{
	// save user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int selectedAppTab = tabBarController.selectedIndex;
	[defaults setInteger:selectedAppTab forKey:UserPrefSelectedAppTab];
		
	// save the last remembered scroll position
	UINavigationController* selectedNavController = [tabBarController.viewControllers objectAtIndex:selectedAppTab];
	UIViewController* selectedRootVC = 
		[[selectedNavController viewControllers] objectAtIndex:0]; 

	if ([selectedRootVC conformsToProtocol:@protocol(TableViewUserPrefs)])
	{
		TableViewControllerUserPrefs* prefs = [(id <TableViewUserPrefs>)selectedRootVC prefs];
		NSIndexPath* path = [prefs currentScrollIndexPath];
		[defaults setInteger:path.row forKey:UserPrefRowScrollPos];
		[defaults setInteger:path.section forKey:UserPrefSectionScrollPos];
	}
	
	// if the user is viewing a particular recipe, let's remember which one it is
	// so we can restore it on relaunch
	UIViewController* visibleVC = [selectedNavController visibleViewController];
	BOOL isRecipeSelected = ([visibleVC isKindOfClass:[RecipeViewController class]]);
	
	[defaults setBool:isRecipeSelected forKey:UserPrefIsRecipeSelected];
	if (isRecipeSelected)
	{
		RecipeViewController* rvc = (RecipeViewController*)visibleVC;		
		[defaults setObject:[rvc recipe].uid forKey:UserPrefSelectedRecipe];
	}
	
	[defaults setBool:App_isEmailing forKey:UserPrefDidEmailList];
	
	// version 1 for all files in 1.1. Original version 1.0 did not set this
	[defaults setInteger:1 forKey:UserPrefFileVersion];
}

//
//	Load user preference application settings such as last tab
//	and tableview scroll position.
//
- (void) loadUserPreferenceSettings
{
	// remember the last selected tab
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int selectedAppTab = [defaults integerForKey:UserPrefSelectedAppTab];
	if ((selectedAppTab < 0) || (selectedAppTab >= [[tabBarController viewControllers] count]))
	{
		selectedAppTab = 0;
	}
	tabBarController.selectedIndex = selectedAppTab;
	
	UINavigationController* selectedNavController = [tabBarController.viewControllers objectAtIndex:selectedAppTab];
	UIViewController* selectedRootVC = 
			[[selectedNavController viewControllers] objectAtIndex:0];

	// set the last remembered scroll position of the root view controller
	// unless special case launch in "Add New Recipe" mode
	if (!App_newRecipeLaunch)
	{
		int rowScrollPosition = [defaults integerForKey:UserPrefRowScrollPos];
		int sectionScrollPosition = [defaults integerForKey:UserPrefSectionScrollPos];
		NSIndexPath* initScrollIndexPath = [NSIndexPath indexPathForRow:rowScrollPosition inSection:sectionScrollPosition];

		if([selectedRootVC conformsToProtocol:@protocol(TableViewUserPrefs)])
		{
			TableViewControllerUserPrefs* prefs = [(id <TableViewUserPrefs>)selectedRootVC prefs];
			[prefs setInitialScrollIndexPath:initScrollIndexPath];
		}
	
		// now load the recipe, if one was visible last time
		if ([defaults boolForKey:UserPrefIsRecipeSelected])
		{
			// the view controller should be Recipes, and we should have a valid recipe
			// ID to send to it to push the new view on the stack
			if ([selectedRootVC isKindOfClass:[RecipesViewController class]])
			{
				RecipesViewController* rvc = (RecipesViewController*)selectedRootVC;
				NSString* recipeUid = [defaults objectForKey:UserPrefSelectedRecipe];
				Recipe* r = [[App_database recipes] recipeForUid:recipeUid];

				if (r != nil) 
				{
					[rvc handleWantToViewRecipe:r animated:NO];
				}
			}
		}
	}
	App_isEmailing = [defaults boolForKey:UserPrefDidEmailList];
	
	// will return 0 if not set, as in version 1.0 files
	App_fileVersion = [defaults integerForKey:UserPrefFileVersion];
}

@end
