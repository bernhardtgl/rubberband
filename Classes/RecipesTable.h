//
//  Recipes.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Recipe;

@interface RecipesTable : NSObject
{
	NSMutableArray* recipesArray;
	NSMutableDictionary* recipesIndex;
	bool isDirty;
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (bool) isDirty;
- (void) markDirty;
- (NSUInteger) count;
- (void) addRecipe:(Recipe*)newRecipe;
- (Recipe*) recipeAtIndex:(NSInteger)index;
- (Recipe*) removeRecipeAtIndex:(NSInteger)index;
- (void) removeRecipe:(Recipe*)aRecipe;
- (void) clear;
- (NSArray*)recipesArray;

- (Recipe*) recipeForUid: (NSString*)uid;

@end
