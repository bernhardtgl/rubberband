//
//  RecipeTableViewCell.h
//  Cell view for recipes which represents a row in a list of recipes.
//	Each row consists of a thumbnail pic, a recipe title (name) and 
//	a preview of the recipe notes.
//
//  Created by Craig on 5/19/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//
#import <UIKit/UIKit.h>

@class Recipe;

@interface RecipeTableViewCell : UITableViewCell 
{
	NSString* recipeUid;
	
	// UI Controls
	UIImageView* recipeImageView;	
	UILabel* nameLabel;
	UILabel* notesPreviewLabel;		
}

- (void) configureRecipe:(Recipe*)aRecipe;

@end
