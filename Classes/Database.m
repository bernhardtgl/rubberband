//
//  Database.m
//  Implementation of the object database which is responsible
//	for loading and saving items to and from the file system.
//
//  Created by Craig on 3/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//
#import <uuid/uuid.h>
#import "Database.h"
#import "GroceryItem.h"
#import "Aisle.h"
#import "Recipe.h"
#import "GroceryItemsTable.h"
#import "AislesTable.h"
#import "RecipesTable.h"

//NSString* GBCBSymbolLetter = @"ZZ"; // use this instead of "#" for first letter, so it sorts at end

//  private methods
@interface Database(mymethods)
- (NSString*)groceryItemsFilePath:(BOOL)wantBackupFileName;
- (NSString*)aislesFilePath:(BOOL)wantBackupFileName;
- (NSString*)recipesFilePath:(BOOL)wantBackupFileName;
- (NSString*)groceryItemsFilePathArchiveForVersion:(NSInteger)version;
- (NSString*)aislesFilePathArchiveForVersion:(NSInteger)version;
- (NSString*)recipesFilePathArchiveForVersion:(NSInteger)version;

- (BOOL) loadFromDiskFromBackup:(BOOL)fromBackup loadSampleDataOnError:(BOOL)loadSampleDataOnError;
- (void) populateItemsSampleData;
- (void) populateAislesSampleData;
- (void) populateRecipesTableSampleData;
@end

@implementation Database

// implementation

//
// Generates a new unique identifier to be used as a key to manage
// relationships between objects.
// Note: this is a class method (aka static)
//
+ (NSString*) generateUid
{
	uuid_t newId;
	uuid_generate(newId);
	char cStr[32];
	uuid_unparse_lower(newId, cStr);
	NSString* str = [NSString stringWithCString:cStr encoding:NSASCIIStringEncoding];
	return str;
}

//
// Initializes a new database object.
//
- init
{
	if (self = [super init])
	{
	}
	return self;
}

- (void) dealloc 
{
	NSLog(@"***** dealloc THE Database");
	NSLog(@"  release aisles:  %lu", (unsigned long)[aisles retainCount]);
	[aisles release];
	NSLog(@"  release recipes: %lu", (unsigned long)[recipes retainCount]);
	[recipes release];
	NSLog(@"  release items:   %lu", (unsigned long)[items retainCount]);
	[items release];
	
    [super dealloc];
}

// description is what is returned when the object is printed to the log
- (NSString*) description
{
	return [NSString stringWithFormat:@"Database"];
}

- (void) backupFiles:(BOOL)restore
{
	NSString* filePath;
	NSString* backupPath;
	NSFileManager* manager = [NSFileManager defaultManager];
	NSError* err;
	
	filePath = [self groceryItemsFilePath:restore];
	backupPath = [self groceryItemsFilePath:!restore];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];
	
	filePath = [self aislesFilePath:restore];
	backupPath = [self aislesFilePath:!restore];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];

	filePath = [self recipesFilePath:restore];
	backupPath = [self recipesFilePath:!restore];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];
}

- (void) backupFilesArchiveForVersion:(NSInteger)version 
{
	NSString* filePath;
	NSString* backupPath;
	NSFileManager* manager = [NSFileManager defaultManager];
	NSError* err;
	
	filePath = [self groceryItemsFilePath:NO];
	backupPath = [self groceryItemsFilePathArchiveForVersion:version];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];
	
	filePath = [self aislesFilePath:NO];
	backupPath = [self aislesFilePathArchiveForVersion:version];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];
	
	filePath = [self recipesFilePath:NO];
	backupPath = [self recipesFilePathArchiveForVersion:version];
	[manager removeItemAtPath:backupPath error:&err];
	[manager copyItemAtPath:filePath toPath:backupPath error:&err];	
}

//
// Save the specified items to disk
//
- (void) saveToDisk
{
	// backup, if the files are going to change
	BOOL willSaveSomething = (items.isDirty) || (aisles.isDirty) || (recipes.isDirty);
	if (willSaveSomething) {
		[self backupFiles:NO];
	}
	
	// save changes to disk
	if ([items isDirty])
	{
		[NSKeyedArchiver archiveRootObject:items toFile:[self groceryItemsFilePath:NO]];
	}
	if ([aisles isDirty])
	{
		[NSKeyedArchiver archiveRootObject:aisles toFile:[self aislesFilePath:NO]];
	}
	if ([recipes isDirty])
	{
		[NSKeyedArchiver archiveRootObject:recipes toFile:[self recipesFilePath:NO]];
	}
}

//
// Load saved items from disk
//
- (BOOL) loadFromDiskFromBackup:(BOOL)fromBackup loadSampleDataOnError:(BOOL)loadSampleDataOnError
{
	NSLog(@"loadFromDisk");

	// release the old tables, and reset their pointers
	[items release];
	[aisles release];
	[recipes release];
	items = nil;
	aisles = nil;
	recipes = nil;
	
	BOOL aislesLoaded = YES;
	BOOL recipesLoaded = YES;
	BOOL itemsLoaded = YES;
	
	// Rehydrate all 3 tables
	@try
	{
		aisles = [NSKeyedUnarchiver unarchiveObjectWithFile:[self aislesFilePath:fromBackup]];
		[aisles retain];

		// if no file exists, it's the first run, so load the sample data
		if (aisles == nil)
		{
			aisles = [[AislesTable alloc] init];		
			[self populateAislesSampleData];
		}
	}
	@catch (NSException* e) 
	{
		NSLog(@"Exception occurred loading aisles from disk: %@", e);
		aislesLoaded = NO;
		[aisles release];
		aisles = nil;
		if (loadSampleDataOnError)
		{
			aisles = [[AislesTable alloc] init];		
			[self populateAislesSampleData];
		}
	}
	
	@try
	{
		items = [NSKeyedUnarchiver unarchiveObjectWithFile:[self groceryItemsFilePath:fromBackup]];
		[items retain];

		// if no file exists, it's the first run, so load the sample data
		if (items == nil)
		{
			items = [[GroceryItemsTable alloc] init];
			[self populateItemsSampleData];
		}
	}
	@catch (NSException* e) 
	{
		NSLog(@"Exception occurred loading items from disk: %@", e);
		itemsLoaded = NO;
		[items release];
		items = nil;
		if (loadSampleDataOnError)
		{
			items = [[GroceryItemsTable alloc] init];
			[self populateItemsSampleData];
		}
	}
	items.delegate = self;
	
	@try
	{
		recipes = [NSKeyedUnarchiver unarchiveObjectWithFile:[self recipesFilePath:fromBackup]];
		[recipes retain];
		
		// if no file exists, it's the first run, so load the sample data
		if (recipes == nil)
		{
			recipes = [[RecipesTable alloc] init];	
			[self populateRecipesTableSampleData];
		}
	}
	@catch (NSException* e) 
	{
		NSLog(@"Exception occurred loading recipes from disk: %@", e);
		recipesLoaded = NO;
		[recipes release];
		recipes = nil;
		if (loadSampleDataOnError)
		{
			recipes = [[RecipesTable alloc] init];	
			[self populateRecipesTableSampleData];
		}
	}
	
	return (itemsLoaded && aislesLoaded && recipesLoaded);
}

- (BOOL) loadFromDisk
{
	BOOL success = [self loadFromDiskFromBackup:NO loadSampleDataOnError:NO];
	if (!success) 
	{
		[self loadFromDiskFromBackup:YES loadSampleDataOnError:YES];		

		// restore the backup to the main set of files, so next time we don't have
		// this problem
		[self backupFiles:YES];
	}
	return success;
}

//
// Property accessors; get a reference to the 
// main collections.
//
- (GroceryItemsTable*) groceryItems
{
	return items;
}
- (AislesTable*) aisles
{
	return aisles;
}
- (RecipesTable*) recipes
{
	return recipes;
}

// get filepaths where we make a copy before we upgrade, for in case of a bad bug
- (NSString*)groceryItemsFilePathArchiveForVersion:(NSInteger)version
{
	NSString* fileName = [NSString stringWithFormat:@"rbgroceryitems_backup_%ld.dat", (long)version];
	return [[self baseFilePath] stringByAppendingPathComponent:fileName];
}
- (NSString*)aislesFilePathArchiveForVersion:(NSInteger)version
{
	NSString* fileName = [NSString stringWithFormat:@"rbaisles_backup_%ld.dat", (long)version];
	return [[self baseFilePath] stringByAppendingPathComponent:fileName];
}
- (NSString*)recipesFilePathArchiveForVersion:(NSInteger)version
{
	NSString* fileName = [NSString stringWithFormat:@"rbrecipes_backup_%ld.dat", (long)version];
	return [[self baseFilePath] stringByAppendingPathComponent:fileName];
}

// 
// gets the filepath to where the grocery items are serialized to.
//
- (NSString*)groceryItemsFilePath:(BOOL)wantBackupFileName
{
	NSString* filePath;
	if (wantBackupFileName) {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbgroceryitems_backup.dat"];
	} else {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbgroceryitems.dat"];
	}
	return filePath;
}

// 
// gets the filepath to where the aisles are serialized to.
//
- (NSString*)aislesFilePath:(BOOL)wantBackupFileName
{
	NSString* filePath;
	if (wantBackupFileName) {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbaisles_backup.dat"];
	} else {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbaisles.dat"];
	}
	return filePath;
}
// gets the filepath to where the recipes are serialized to.
//
- (NSString*)recipesFilePath:(BOOL)wantBackupFileName
{
	NSString* filePath;
	if (wantBackupFileName) {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbrecipes_backup.dat"];
	} else {
		filePath = [[self baseFilePath] stringByAppendingPathComponent:@"rbrecipes.dat"];
	}
	return filePath;
}
- (NSString*)recipeImageFilePath:(Recipe*)r
{
	NSString* filePath = [[self baseFilePath] 
			stringByAppendingPathComponent: @"r_%@.dat"];
	return filePath;
}

//
// Get the data file path to load and save serialized items
//
- (NSString*)baseFilePath
{
	if ((documentsDirectory == nil) || ([documentsDirectory length] == 0))
	{
		// On the iPhone, our base file path is the documents directory of the application. 
		// Within the Aspen simulator, the documents directory for the application maps to the 
		// following path:
		// /Users/<name>/Library/Application Support/iPhone Simulator/User/Applications/<app guid>/Documents 
		// test
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* docsdir = [paths objectAtIndex:0]; 
		documentsDirectory = [docsdir copy];
/*		
		// since the Simulator changes the app GUID every time it runs, we
		// will temporarily just use the Mac's user directory 
		// /Users/<name>
		NSString* mypath = @"~/";
		mypath = [mypath stringByExpandingTildeInPath];
		NSArray* pcs = [mypath pathComponents];
		if ([pcs count] >= 3)
		{
			mypath = @"";
			int i;
			for (i = 0; i < 3; i++)
			{
				NSString* pc = [pcs objectAtIndex:i];
				mypath = [mypath stringByAppendingPathComponent:pc];
			}
			documentsDirectory = [mypath copy];
		}
 */
	}
	return documentsDirectory;
}

- (void) populateAislesSampleData
{
	NSString* thePath = [[NSBundle mainBundle]  pathForResource:@"Aisles" ofType:@"plist"];
	NSArray* rawArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	Aisle* aisle;
	NSDictionary* eachAisleDict;
	
	for (eachAisleDict in rawArray)
	{
		aisle = [[Aisle alloc] init];
		aisle.name = [eachAisleDict objectForKey:@"Name"];
		
		// add to the real aisles table
		[aisles addAisle:aisle];
		
		[aisle release];
	}
	[rawArray release];	
}

- (void) populateItemsSampleData
{
	NSLocale* loc = [NSLocale currentLocale];
	NSNumber* metricNumber = [loc objectForKey:NSLocaleUsesMetricSystem];
	BOOL metric = [metricNumber boolValue];
	
	// make a quick lookup dictionary by aisle name. key=name object=aisle
	NSMutableDictionary* aisleByNameDict = [NSMutableDictionary dictionary]; // autoreleased object	
	for (Aisle* eachAisle in aisles) {
		[aisleByNameDict setObject:eachAisle forKey:eachAisle.name];
	}
	
	NSString* thePath = [[NSBundle mainBundle]  pathForResource:@"GroceryItems" ofType:@"plist"];
	NSArray* rawArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	GroceryItem* item;
	NSDictionary* eachItemDict;
	for (eachItemDict in rawArray)
	{
		item = [[GroceryItem alloc] init];
		item.name = [eachItemDict objectForKey:@"Name"];
		
		NSString* aisleName = [eachItemDict objectForKey:@"Aisle"];
		if (aisleName != nil) 
		{
			item.aisle = [aisleByNameDict objectForKey:aisleName];
		}

		NSString* usualString = [eachItemDict objectForKey:@"Usual"];
		if (usualString != nil) 
		{
			// Note: this method is somewhat of a hack, but if you look below at how
			// I was planning to implement it the right way, I figured that was riskier
			if ([usualString isEqual:@"0.5 lb"])
			{
				item.qtyUsual.type = (metric ? QuantityTypeGram : QuantityTypePound);
				item.qtyUsual.amount = (metric ? 250.0 : 0.5);
			}
			else if ([usualString isEqual:@"1 lb"])
			{
				item.qtyUsual.type = (metric ? QuantityTypeGram : QuantityTypePound);
				item.qtyUsual.amount = (metric ? 500.0 : 1.0);
			}
			else if ([usualString isEqual:@"5 lb"])
			{
				item.qtyUsual.type = (metric ? QuantityTypeKilogram : QuantityTypePound);
				item.qtyUsual.amount = (metric ? 2.0 : 5.0);
			}
			else if ([usualString isEqual:@"1 gal"]) 
			{
				item.qtyUsual.type = (metric ? QuantityTypeLiter : QuantityTypeGallon);
				item.qtyUsual.amount = (metric ? 1.0 : 1.0);
			}
			else if ([usualString isEqual:@"1 pt"])
			{
				item.qtyUsual.type = (metric ? QuantityTypeLiter : QuantityTypePint);
				item.qtyUsual.amount = (metric ? 0.5 : 1.0);
			}
			else if ([usualString isEqual:@"8 oz"])
			{
				item.qtyUsual.type = (metric ? QuantityTypeGram : QuantityTypeOunce);
				item.qtyUsual.amount = (metric ? 250.0 : 8.0);
			}

			// was going to code it this way, but it was getting to risky, thinking
			// about localized formats of numbers and such. The above method is hackier
			// but effective. We just need to make sure we always use the above strings
			// when localizing items
			
/*			NSArray* parts = [usualString componentsSeparatedByString:@" "];
			if (parts.count == 2)
			{
				// TODO: check on locale for this
				NSNumberFormatter* fmt = [NSNumberFormatter alloc] init];
				NSNumber* numUsual = [fmt numberFromString:[parts objectAtIndex:0]]; 
				
				NSString* 
			}
*/
		}
		
		[items addItem:item];
		[item release];
	}
	
	[rawArray release];
}

//
//	Populate the recipes table with sample data.
//
- (void) populateRecipesTableSampleData
{
	NSLocale* loc = [NSLocale currentLocale];
	NSNumber* metricNumber = [loc objectForKey:NSLocaleUsesMetricSystem];
	BOOL metric = [metricNumber boolValue];

	NSString* thePath = [[NSBundle mainBundle]  pathForResource:@"Recipes" ofType:@"plist"];
	NSArray* rawRecipeArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	Recipe* recipe;
	NSDictionary* eachRecipeDict;
	for (eachRecipeDict in rawRecipeArray)
	{
		recipe = [[Recipe alloc] init];
		recipe.name = [eachRecipeDict objectForKey:@"Name"];
		recipe.notes = [eachRecipeDict objectForKey:@"Notes"];
		recipe.link = [eachRecipeDict objectForKey:@"Link"];

		// load up the image, if it exists
		NSString* imageName = [eachRecipeDict objectForKey:@"Image"];
		if (imageName != nil)
		{
			recipe.image = [UIImage imageNamed:imageName];
		}
		
		NSArray* rawIngredientArray = [eachRecipeDict objectForKey:@"Ingredients"];
		NSDictionary* eachIngredientDict;
		for (eachIngredientDict in rawIngredientArray)
		{
			NSString* ingredientName = [eachIngredientDict objectForKey:@"Name"];
			
			// TODO: redo the quantity part to work like items
			
			// find the ingredient or add it
			GroceryItem* ingredientGroceryItem = nil;
			GroceryItem* groceryItem;
			for (groceryItem in [self groceryItems])
			{
				if ([groceryItem.name compare:ingredientName] == 0)
				{
					// found it!
					ingredientGroceryItem = groceryItem;
					[ingredientGroceryItem retain];   // extra retain, since we have a blanket release below
					break;
				}
			}
			
			// add the ingredient since it wasn't already in the list
			if (ingredientGroceryItem == nil)
			{
				ingredientGroceryItem = [[GroceryItem alloc] init];
				ingredientGroceryItem.name = ingredientName;
				[[self groceryItems] addItem:ingredientGroceryItem];
			}
			
			// read the quantity, if it exists. If not, use 1.
			NSString* amountString = [eachIngredientDict objectForKey:@"Amount"];
			ItemQuantity* quantityInRecipe = [[ItemQuantity alloc] init];
			quantityInRecipe.amount = 1;
			
			if (amountString != nil) 
			{
				// Note: this method is somewhat of a hack, see populateItems... for an
				// explanation
				if ([amountString isEqual:@"0.25 lb"])
				{
					quantityInRecipe.type = (metric ? QuantityTypeGram : QuantityTypePound);
					quantityInRecipe.amount = (metric ? 100.0 : 0.25);
				}
				else if ([amountString isEqual:@"0.5 lb"])
				{
					quantityInRecipe.type = (metric ? QuantityTypeGram : QuantityTypePound);
					quantityInRecipe.amount = (metric ? 250.0 : 0.5);
				}
				else if ([amountString isEqual:@"1 lb"])
				{
					quantityInRecipe.type = (metric ? QuantityTypeGram : QuantityTypePound);
					quantityInRecipe.amount = (metric ? 500.0 : 1.0);
				}
				else if ([amountString isEqual:@"2 lb"])
				{
					quantityInRecipe.type = (metric ? QuantityTypeKilogram : QuantityTypePound);
					quantityInRecipe.amount = (metric ? 1.0 : 1.0);
				}
			}
			
			[recipe addItemToRecipe:ingredientGroceryItem withQuantity:quantityInRecipe];
			[ingredientGroceryItem release];
			[quantityInRecipe release];
		}
		[rawIngredientArray release];	
			
		[recipes addRecipe:recipe];
		[recipe release];
	}
//!	[rawRecipeArray release];	// craig!6.03.08 -- blowing up when we add more than one recipe; note sure why... commented release out for now.
}

/*
//
//	Populate the recipes table with sample
//	data.
//
- (void) populateRecipesTableSampleData_old
{
	// Populate sample recipe data using these well-known uids
	// Note, I used the Aisle uid's and changed the first 2 digits to 11
	//
	//    11a6b6d0-38b4-4263-ae32-edbf8a93 Hamburgers,
	//    11d8d24f-a0a4-494b-8722-5480ad3b Tacos,
	//    1186fc7d-b432-4e99-bf37-b32601b2 Grilled Portabello Mushroom Salad,
	
	Recipe* a = nil;
	
	a = [[Recipe alloc] initWithUid:@"11a6b6d0-38b4-4263-ae32-edbf8a93"]; 
	a.name = @"Hamburgers";
	a.image = [UIImage imageNamed:@"Recipe1.jpg"];
	[recipes addRecipe:a];
	[a release];
	
	a = [[Recipe alloc] initWithUid:@"11d8d24f-a0a4-494b-8722-5480ad3b"]; 
	a.name = @"Tacos";
	a.image = [UIImage imageNamed:@"Recipe2.jpg"];
	[recipes addRecipe:a];
	[a release];
	
	a = [[Recipe alloc] initWithUid:@"1186fc7d-b432-4e99-bf37-b32601b2"]; 
	a.name = @"Grilled Portabello Mushroom Salad";
	a.image = [UIImage imageNamed:@"RecipeNone.png"];
	[recipes addRecipe:a];
	[a release];
}
*/
 
// **************************************************************************************
// GroceryItemsTableDelegate methods


- (void)groceryItemDidChange:(GroceryItem*)item
{
	NSLog(@"groceryItemChanged");
}

// need to remove the item from any recipes that use it 
- (void)groceryItemWillDelete:(GroceryItem*)item;
{
	for (Recipe* r in recipes)
	{
		if ([r.itemsInRecipe containsObject:item])
		{
			[r removeItemFromRecipe:item];
		}
	}
}

// how many recipes use this item (before deleting it) and what are they 
// named, so we can inform the user
- (NSUInteger)countOfRecipesUsingItem:(GroceryItem*)item withNames:(NSMutableArray*)names;
{
	NSUInteger objectCount = 0;
	[names removeAllObjects];
	for (Recipe* r in recipes)
	{
		if ([r.itemsInRecipe containsObject:item])
		{
			objectCount++;
			[names addObject:r.name];
		}
	}
	return objectCount;
}

@end
