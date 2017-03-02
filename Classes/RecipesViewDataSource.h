//
//  RecipesViewDataSource.h
//  Data source for the recipes list view.  This data model
//	provides organized access to the recipes displayed in 
//	the RecipesViewController.
//
//  Created by Craig on 5/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class Recipe;
@class Database;

@interface RecipesViewDataSource : NSObject <UITableViewDataSource>
{
	id <TableViewDataSourceDelegate> delegate;

	Database* myDatabase;

	// a cache of the recipes, sorted alphabetically like the view likes it
	// call dataHasChanged if someone external changes a recipe, so we can
	// reload the cache
	NSArray* recipesSortedArray; 
}

- (id) initWithDatabase: (Database*)database;
- (void) dataHasChanged;

- (Recipe*)recipeAtIndexPath:(NSIndexPath *)indexPath;  
- (NSIndexPath*)indexPathForRecipe:(Recipe*)theRecipe;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

@end
