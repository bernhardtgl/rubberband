//
//  ShareViewController.h
//  View controller screen for the share screen.
//
//  Created by Craig on 9/14/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ShareViewController.h"
#import "ShopViewDataSource.h"
#import "Database.h"
#import "ShoppingAisle.h"
#import "GroceryItem.h"
#import "ItemQuantity.h"
#import "RubberbandAppDelegate.h"
#import "RecipesTable.h"
#import "Recipe.h"
#import "Base64.h"
#import "HelperFunctions.h"
#import "UIImageHelper.h"
#import "EmailRecipeViewController.h"

@interface ShareViewController(PrivateMethods)
- (NSString*)addRecipeUrlCreate:(Recipe*)r imageString:(NSString*)encodedImage;
- (NSString*)itemEmailStringFor:(NSMutableArray*)itemsArray recipe:(Recipe*)r;
@end

@implementation ShareViewController

@synthesize appController;

- init 
{
	if (self = [super init]) 
	{
		self.title = NSLocalizedString(@"Share", @"Share view navigation title");
        self.tabBarItem.image = [UIImage imageNamed:@"share-unselected.png" inBundle:nil compatibleWithTraitCollection:nil];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"share-selected.png" inBundle:nil compatibleWithTraitCollection:nil];
	}
	return self;
}

- (void)dealloc 
{	
	NSLog(@"***** dealloc THE ShareViewController");
	
    [super dealloc];
}

- (void)loadView 
{
	// setup the parent content view
	UIView *contentView = [[UIView alloc] 
						   initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[contentView setBackgroundColor:[UIColor whiteColor]];
	self.view = contentView;
	[contentView autorelease];
	
	CGRect bounds = self.view.bounds;
	
	// add the e-mail list button
	UIButton* emailListButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[emailListButton setTitle:NSLocalizedString(@"Email List", @"E-mail shopping list button title") forState: UIControlStateNormal];
	[emailListButton addTarget:self action:@selector(emailListAction:) forControlEvents: UIControlEventTouchUpInside];
	CGRect buttonRect = self.view.bounds;
	buttonRect.size.height = 40;
	buttonRect.size.width = 280;
	buttonRect.origin.x = bounds.size.width / 2 - buttonRect.size.width / 2;
	buttonRect.origin.y = bounds.size.height * 0.20;  // 10% down from top
	emailListButton.frame = buttonRect;
	[contentView addSubview:emailListButton];

	// add the e-mail recipe button
	UIButton* emailRecipeButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[emailRecipeButton setTitle:NSLocalizedString(@"Email Recipe", @"E-mail recipe button title") forState: UIControlStateNormal];
	[emailRecipeButton addTarget:self action:@selector(emailRecipeAction:) forControlEvents: UIControlEventTouchUpInside];
	buttonRect = CGRectMake(buttonRect.origin.x, buttonRect.origin.y + 60.0, 280.0, 40.0);
	emailRecipeButton.frame = buttonRect;
	[contentView addSubview:emailRecipeButton];

	// add the e-mail recipe button
//	UIButton* emailAllButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
//	[emailAllButton setTitle:NSLocalizedString(@"Email All Items", @"E-mail all items button title") forState: UIControlStateNormal];
//	[emailAllButton addTarget:self action:@selector(emailAllAction:) forControlEvents: UIControlEventTouchUpInside];
//	buttonRect = CGRectMake(buttonRect.origin.x, buttonRect.origin.y + 60.0, 280.0, 40.0);
//	emailAllButton.frame = buttonRect;
//	[contentView addSubview:emailAllButton];
	
	// setup our content view so that it auto-rotates along with the UViewController
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


// **************************************************************************************
#pragma mark Actions

// Event handler called when the user clicks the e-mail list button.
//
// URL format to add to list is:
// - Apple       (1)   (produce aisle)
// - Ground Beef (2lb) (meat aisle)
//
// groceryzen://addlist?Apple&Produce&1&0&Ground%20Beef&Meat&2&1
//
// Last number for an item is the enum value for the unit type
//
- (void)emailListAction:(id)sender
{
	ShopViewDataSource* sds = [[ShopViewDataSource alloc] initWithDatabase:App_database];
	[sds rebuildShoppingList];

	// quote the subject line text
	NSString* subject = NSLocalizedString(@"Shopping list", @"e-mail subject line for Shopping list");
	subject = encodeUrlString(subject);
	NSString* mailToUrl = [NSString stringWithFormat:@"%@%@%@", @"mailto:?subject=", 
						   subject, @"&body="];
	
	NSString* listText = @"";
	NSString* linkText = @"groceryzen://addlist?";
	
	NSUInteger aisleCount = [sds shoppingAisleCount];
	int i;
	for (i = 0; i < aisleCount; i++)
	{
		ShoppingAisle* sa = [sds shoppingAisleAtIndex:i];
		if (sa == [sds haveShoppingAisle])
		{
			continue;  // skip the 'Have' shopping aisle
		}
		
		// add the aisle name to the text
		Aisle* a = [sa aisle];		
		if (sa != [sds noneShoppingAisle])
		{
			NSString* newText = [NSString stringWithFormat:@"<b>%@</b><br/>", a.name];
			listText = [listText stringByAppendingString:newText];
		}
		// add all of the items within the shopping aisle (in a bulleted list)
		NSString* itemText = [self itemEmailStringFor:[sa aisleItems] recipe:nil];
		listText = [listText stringByAppendingString:itemText];
		
		for (GroceryItem* item in [sa aisleItems])
		{
			// since we're calling stringWithFormat, instead of localizedStringWithFormat
			// the floating point "amount" will always be formatted as 1.00000 - NOT locale
			// specific. This is handy for when we want to parse it later, since we can always
			// count on the decimal symbol to be "."
			ItemQuantity* qty = [item qtyNeeded];
			linkText = [NSString stringWithFormat:@"%@%@&%@&%f&%d&",
						linkText,
						encodeUrlString([item name]),
						encodeUrlString([a name]),
						[qty amount],
						[qty type]];
			
		}
	}
	// generate a hyperlink in the email that includes the list in a parsable format
	// to add back to GroceryZen
	NSString* buttonImageFile = NSLocalizedString(@"add_button.png", @"DON'T CHANGE THIS - localized button name");
	NSString* bodyText = [NSString stringWithFormat:@"<p align=\"center\" style=\"margin-top:0px; margin-bottom:14px\"><a href=\"%@\" style=\"color:white\"><img src=\"http://www.groceryzen.com/images/%@\"></img></a></p><p>%@</p>",
						  linkText,
						  buttonImageFile,
						  listText];
	
	bodyText = encodeUrlString(bodyText);
	mailToUrl = [mailToUrl stringByAppendingString:bodyText];

	NSURL *url = [[NSURL alloc] initWithString:mailToUrl];	
	
	// clean up prior to invoking the sharedApplication
	[sds release];
	// we don't clean up listText or mailToUrl or the interop code will blow up
	App_isEmailing = YES;
	
	// make sure preferences get saved
	RubberbandAppDelegate* app = (RubberbandAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app prepareToTerminate];
	
	// go, this will cause our application to terminate and switch to the iPhone e-mail application
	if (![[UIApplication sharedApplication] openURL:url])
	{
		showAlert(NSLocalizedString(@"The mail application could not be opened - this happens sometimes.\r\n\r\nIf it keeps happening, change the list slightly and try again.",@"Message if emailing a list doesn't work."));
	}
	
	// this is only here so localizers will translate it - we use it in the button image 
	// hosted on the website
	NSLog(NSLocalizedString(@"Add to GroceryZen", "button in email"), "");
}

// Event handler called when the user clicks the e-mail ALL Items button.
//
// URL format to add to list is:
// - all the aisles in order
// - && to separate aisles from items
// - Apple       (1)   (1)    (produce aisle)
// - Ground Beef (2lb) (1lb)  (meat aisle)
//
// (spaces added for readability)
// groceryzen://addall? Produce & Meat &&
//						Apple & Produce & 1.0000 & 0 & 1.0000 & 0 & 
//                      Ground%20Beef & Meat & 2.0000 & 1 & 1.0000 & 1
//
// Same as the email list, except we also send the "usual" quantity so we
// can recreate the item completely.
//
- (void)emailAllAction:(id)sender
{
	// quote the subject line text
	NSString* subject = NSLocalizedString(@"Item list", @"e-mail subject line for Item list");
	subject = encodeUrlString(subject);
	NSString* mailToUrl = [NSString stringWithFormat:@"%@%@%@", @"mailto:?subject=", 
						   subject, @"&body="];
	
	NSString* listText = NSLocalizedString(@"Here are all the items I use in GroceryZen.", @"email message contents");
	NSString* linkText = @"groceryzen://addall?";
	
	for (Aisle* a in [App_database aisles])
	{
		linkText = [NSString stringWithFormat:@"%@%@&",
					linkText,
					encodeUrlString([a name])
					];
	}
	
	// separate the aisles from the items
	linkText = [linkText stringByAppendingString:@"&-----&"];
	
	for (GroceryItem* item in [App_database groceryItems])
	{
		// since we're calling stringWithFormat, instead of localizedStringWithFormat
		// the floating point "amount" will always be formatted as 1.00000 - NOT locale
		// specific. This is handy for when we want to parse it later, since we can always
		// count on the decimal symbol to be "."
		ItemQuantity* qtyN = [item qtyNeeded];
		ItemQuantity* qtyU = [item qtyUsual];
		Aisle* a = [item aisle];
		linkText = [NSString stringWithFormat:@"%@%@&%@&%f&%d&%f&%d&",
					linkText,
					encodeUrlString([item name]),
					encodeUrlString([a name]),
					[qtyN amount],
					[qtyN type],
					[qtyU amount],
					[qtyU type]
				   ];
		
	}
	
	// generate a hyperlink in the email that includes the list in a parsable format
	// to add back to GroceryZen
	NSString* buttonImageFile = NSLocalizedString(@"add_button.png", @"DON'T CHANGE THIS - localized button name");
	NSString* bodyText = [NSString stringWithFormat:@"<p align=\"center\" style=\"margin-top:0px; margin-bottom:14px\"><a href=\"%@\" style=\"color:white\"><img src=\"http://www.groceryzen.com/images/%@\"></img></a></p><p>%@</p>",
						  linkText,
						  buttonImageFile,
						  listText];
	
	bodyText = encodeUrlString(bodyText);
	mailToUrl = [mailToUrl stringByAppendingString:bodyText];
	
	NSURL *url = [[NSURL alloc] initWithString:mailToUrl];	
	
	// we don't clean up listText or mailToUrl or the interop code will blow up
	App_isEmailing = YES;
	
	// make sure preferences get saved
	RubberbandAppDelegate* app = (RubberbandAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app prepareToTerminate];
	
	// go, this will cause our application to terminate and switch to the iPhone e-mail application
	if (![[UIApplication sharedApplication] openURL:url])
	{
		showAlert(NSLocalizedString(@"The mail application could not be opened - this happens sometimes.\r\n\r\nIf it keeps happening, change the list slightly and try again.",@"Message if emailing a list doesn't work."));
	}
}

// Event handler called when the user clicks the e-mail recipe button.
//
// Last number for an item is the enum value for the unit type
//
- (void)emailRecipeAction:(id)sender
{
    EmailRecipeViewController* newView = [[EmailRecipeViewController alloc] init];
	newView.delegate = self;
	
	UINavigationController* nc = [[UINavigationController alloc] 
								  initWithRootViewController:newView];
	[self presentViewController:nc animated:YES completion: nil];
	[nc release];
	[newView release];
	
	// execution will continue below, at didSave
}

- (void)didSave:(UITableViewController*)dialogController;
{	
	Recipe* r = [(EmailRecipeViewController*)dialogController recipe];
	[self emailRecipe:r];
}

// once a recipe has been selected, this mails it
- (void)emailRecipe:(Recipe*)r
{
	// create the subject line
	NSString* subject = [NSString stringWithFormat:NSLocalizedString(@"Here's my shopping list for \"%@\"", @"e-mail subject line for recipe"),
						 r.name];

	// base-64 encode the image, and generate the URL to add the recipe
	NSString* encodedImageEmail;
	NSString* encodedImageLink;
	
	if (r.image == nil)
	{
		NSData* data = UIImageJPEGRepresentation(App_recipeEmptyImage, 1.0);	
		encodedImageEmail = [data base64Encoding];
		encodedImageLink = @"";
	}
	else
	{
		UIImage* smallImage;
		NSLog(@"%f %f", r.image.size.width, r.image.size.height);
		if (r.image.size.height > 64.0)
		{
			CGSize newSize = CGSizeMake(64.0, 64.0);
			smallImage = [UIImage imageWithImage:r.image scaledToSize:newSize];
		}
		else
		{
			smallImage = r.image;
		}
		NSData* data = UIImageJPEGRepresentation(smallImage, 1.0);	
		encodedImageEmail = [data base64Encoding];
		encodedImageLink = encodedImageEmail;
	}

	NSString* urlAddRecipe = [self addRecipeUrlCreate:r imageString:encodedImageLink];
	NSString* itemList = [self itemEmailStringFor:r.itemsInRecipe recipe:r];
		
	// load up the HTML-ish file that contains the email template
	NSError* err = [[[NSError alloc] init] autorelease];
	NSBundle* currBundle = [NSBundle mainBundle];
	NSString* path = [currBundle pathForResource:@"EmailRecipe" ofType:@"html"];
	NSString* bodyFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];

	bodyFile = [bodyFile stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	bodyFile = [bodyFile stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	bodyFile = [bodyFile stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	
	// from the HTML file, here are the items that need to be substituted
	/* 
	<!-- 
	 (1) groceryzen: URL
	 (2) "add_button.png"
	 (3) image (base64)
	 (4) name
	 (5) "Shopping list:"
	 (6) "bulleted list of items"
	 (7) <p>Notes: blah</p> (or nothing if no notes)
	 (8) full recipe URL
	 (9) short recipe URL
	 (10) "Don't have GroceryZen?"
	--> */
		
	NSString* buttonImageFile = NSLocalizedString(@"add_button.png", @"DON'T CHANGE THIS - localized button name");
	NSString* shortLink = @"";
	if ((r.link != nil) && (![r.link isEqual:@""]))
	{
		NSURL* linkUrl = [NSURL URLWithString:r.link];
		if (linkUrl != nil)
		{
			shortLink = linkUrl.host;
		}
	}
	
	NSString* notesHtml = @""; 
	if ((r.notes != nil) && (![r.notes isEqual:@""]))
	{
		notesHtml = [NSString stringWithFormat:@"<p><b>%@</b><br/>%@</p>",
					 NSLocalizedString(@"Notes:", @"text in recipe email"),
					 r.notes];
	}
	
	NSString* body = [NSString stringWithFormat:bodyFile, 
					  urlAddRecipe,
					  buttonImageFile,
					  encodedImageEmail,
					  r.name,
					  NSLocalizedString(@"Shopping list:", @"text in recipe email"),
					  itemList,
					  notesHtml,
					  r.link,
					  NSLocalizedString(@"Recipe website", @"link text for site when emailing a recipe"),
					  NSLocalizedString(@"Don't have GroceryZen?", @"text in recipe email")
					  ];
	
	// encode each part before it's added to the URL
	subject = encodeUrlString(subject);
	body = encodeUrlString(body);
	
	NSString* urlString = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", subject, body];
	NSURL* url = [[NSURL alloc] initWithString:urlString];	

	// make sure preferences get saved
	RubberbandAppDelegate* app = (RubberbandAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app prepareToTerminate];
		
	// we don't clean up url or the interop code will blow up
	// go, this will cause our application to terminate and switch to the iPhone e-mail application
	if (![[UIApplication sharedApplication] openURL:url])
	{
		showAlert(NSLocalizedString(@"The mail application could not be opened - this happens sometimes.\r\n\r\nIf it keeps happening, change the recipe slightly and try again.",@"Message if emailing a recipe doesn't work."));
	}	
}

// Generates a bulleted list of items, with quantities, for use in emailing a list
// or recipe. If "r" is nil, use the "neededQty", otherwise use the quantity in the recipe
- (NSString*)itemEmailStringFor:(NSMutableArray*)itemsArray recipe:(Recipe*)r;
{
	NSString* listText = @"";
	
	for (GroceryItem* item in itemsArray)
	{
		listText = [listText stringByAppendingString:@"• "];  // bullet for grocery items
		listText = [listText stringByAppendingString:[item name]];

		// get the qty either from the recipe or the item
		ItemQuantity* qty = (r == nil) ? [item qtyNeeded] : [r quantityForItem:item];
		
		// if just '1 item', then don't include quantity info
		if (([qty type] != QuantityTypeNone) || ([qty amount] != 1))
		{
			NSString* qtyText = [NSString stringWithFormat:@" %@%@%@", @"(", [qty abbreviation], @")"];
			listText = [listText stringByAppendingString:qtyText];
		}
		
		listText = [listText stringByAppendingString:@"\n\r"];
	}
	
	return listText;
}
	
#pragma mark URL functions

// generate the URL that will add the recipe. The base-64 enocded image is passed in
// so we don't have to generate it twice
//
// URL format to add to list is:
//
// groceryzen://addrecipe?<<recipename>>&<<url>>&<<notes>>&<<image base64 encoded>>&
//   <<ingredientname>>&<<aislename>>&<<quantity>>&<<unittype>>
//   <<ingredientname>>&<<aislename>>&<<quantity>>&<<unittype>> ... etc.
//
- (NSString*)addRecipeUrlCreate:(Recipe*)r imageString:(NSString*)encodedImage;
{
	// First the recipe part, then all the ingredients, then munge together
	NSString* urlRecipeBase = [NSString stringWithFormat:@"%@&%@&%@&%@&", 
							   encodeUrlString(r.name),
							   encodeUrlString(r.link),
							   encodeUrlString(r.notes),
							   encodedImage
							   ];
	
	NSString* urlRecipeItems = @"";
	for (GroceryItem* item in r.itemsInRecipe)
	{
		NSString* aisleName = (item == nil) ? @"" : item.aisle.name;
		ItemQuantity* qty = [r quantityForItem:item];
		
		urlRecipeItems = [urlRecipeItems stringByAppendingString:
						  [NSString stringWithFormat:@"%@&%@&%f&%d&",
						   encodeUrlString([item name]),
						   encodeUrlString(aisleName),
						   [qty amount],
						   [qty type]
						   ]];		
	}
	
	return [NSString stringWithFormat:@"groceryzen://addrecipe?%@%@",
				urlRecipeBase, urlRecipeItems];
}

- (BOOL) addRecipeUrlCheck:(NSArray*)urlParts;
{
	// there are 4 parts to the URL for the recipe, and 4 more for each item to be added. 
	// It _is_ possible, but unlikely, for there to be 0 items in a recipe
	
	// not enough parts to make up the base recipe
	if (urlParts.count < 4)
	{
		return NO;
	}

	// SWI sanity check - if more than 1,000 items this is a bogus recipe
	NSInteger totalItems = (urlParts.count - 4) / 4;
	if (totalItems > 1000) {
		return NO;
	}	
	
	return YES;
}

// unencode the recipe from the parts created above. We can assume it has already 
// passed the Check function, so it's a "good" URL
//
// If a recipe with the same name already exists, that's OK, we'll just make another one
// If the user cancels adding the recipe, we'll still keep the items that were added as 
// part of adding the recipe
- (Recipe*) addRecipeUrlComplete:(NSArray*)urlParts;
{
	Recipe* r = [[[Recipe alloc] init] autorelease];
	
	// 1. Fill in the basics of the recipe
	r.name = unencodeUrlString([urlParts objectAtIndex:0]);
	r.link = unencodeUrlString([urlParts objectAtIndex:1]);
	r.notes = unencodeUrlString([urlParts objectAtIndex:2]); 
	
	NSString* imageString = [urlParts objectAtIndex:3]; // base64 encoding doesn't require URL unencoding
	if (imageString.length > 0)
	{
		NSData* imageData = [NSData dataWithBase64EncodedString:imageString];
		r.image = [UIImage imageWithData:imageData];
	}
	
	// 2. Fill in the ingredient list. Any items that don't already exist will be created
	// with the suggested aisle (if it exists)
	
	if (urlParts.count > 5)
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
		
		// there are 4 parts to each item in the list. Start at position 4, to skip
		// the 4 urlParts that were the recipe name, link, notes, and image
		int i;
		for (i = 4; i < urlParts.count - 4; i = i + 4)
		{
			NSString* itemName = unencodeUrlString([urlParts objectAtIndex:i]);
			NSString* aisleName = unencodeUrlString([urlParts objectAtIndex:i + 1]);
			NSString* itemQtyStr = [urlParts objectAtIndex:i + 2];
			double itemQty = [itemQtyStr doubleValue];
			NSString* itemQtyTypeStr = [urlParts objectAtIndex:i + 3];
			QuantityType itemQtyType = [itemQtyTypeStr intValue];
			// TODO: try too high itemQtyType or text
			ItemQuantity* qtyForRecipe = [[ItemQuantity alloc] init];
			qtyForRecipe.amount = itemQty;
			qtyForRecipe.type = itemQtyType;
			
			if ([itemName isEqual:@""]) {
				continue;
			}
			
			GroceryItem* theItem = [itemByNameDict objectForKey:itemName];
			if (theItem == nil)
			{
				// create a new item. Use the aisle name passed in if it exists, otherwise
				// use no aisle. We don't create any aisles as part of this process. If there's
				// more than one item with the same name, this will choose the first one.
				// Quantities needed and usual are kept at their defaults, because just because
				// a recipe calls for 1 Tbsp of Flour doesn't mean that's the usual amount
				theItem = [[GroceryItem alloc] init];
				theItem.name = itemName;
				// sets to nil if doesn't exist
				theItem.aisle = [aisleByNameDict objectForKey:aisleName];
				theItem.haveItem = NO;
				[App_database.groceryItems addItem:theItem];
				[theItem release];
			}
			
			// add the item to the recipe, with the specified quantity
			[r addItemToRecipe:theItem withQuantity:qtyForRecipe];
			[qtyForRecipe release];
		}
	}
	return r;
}

- (NSString*) addRecipeUrlPrompt:(NSArray*)urlParts;
{
	NSString* recipeName = unencodeUrlString([urlParts objectAtIndex:0]);
	NSString* message = [NSString stringWithFormat:NSLocalizedString(
					@"Do you want to add a new recipe?\r\n\r\n%@",
					@"Message when user launches from a email to add a recipe"), 
				    recipeName];
	return message;
}

@end
