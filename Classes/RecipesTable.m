//
//  RecipesTable.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/8/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "RecipesTable.h"
#import "Recipe.h"

@implementation RecipesTable

//
// Initializes a brand new Recipe collection.
//
- init
{
	if (self = [super init])
	{
		recipesArray = [[NSMutableArray alloc] init];
		recipesIndex = [[NSMutableDictionary alloc] init];
		isDirty = NO;
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"***** dealloc THE RecipesTable");
	[recipesIndex release];
	[recipesArray release];
	[super dealloc];
}

// 
// Description is what is returned when the object is printed to the log
//
- (NSString*) description
{
	return [recipesArray description];
}

//
// Enumeration method. Manditory method to support "for each" language constructs.
//
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [recipesArray countByEnumeratingWithState:state objects:stackbuf count:len];
}

//
// Determine whether the array has changed (isDirty) is 
// it was re-hydrated from disk.
//
- (bool) isDirty
{
	return isDirty;
}

//
//	Set the isDirty flag to YES to indicate that the collection
//	has changed since it was loaded from disk.
//
- (void) markDirty
{
	isDirty = YES;
}

//
//	Returns the number of recipes in the collection.
//
- (NSUInteger) count
{
	return [recipesArray count];
}

//
//	Add an recipe to the collection
//
- (void) addRecipe:(Recipe*)newRecipe
{
	if (newRecipe != nil)
	{
		// add the item to the array
		[recipesArray addObject:newRecipe];
		
		// add the item to the index
		[recipesIndex setObject:newRecipe forKey:newRecipe.uid];
		
		[self markDirty];
	}	
}

//
//	Gets the recipe at the specified index within
//	the collection.
//
- (Recipe*) recipeAtIndex:(NSInteger)index
{
	Recipe* recipe = nil;
	if ((index >= 0) && (index < [recipesArray count]))
	{
		recipe = (Recipe*)[recipesArray objectAtIndex:index];
	}
	return recipe;
}

//
//	Remove the recipe at the specified index from this
//	collection.
//	Returns the items removed from the collection.
//
- (Recipe*) removeRecipeAtIndex:(NSInteger)index
{
	Recipe* recipe = nil;
	if ((index >= 0) && (index < [recipesArray count]))
	{
		recipe = (Recipe*)[recipesArray objectAtIndex:index];
		
		// remove from array
		[recipesArray removeObjectAtIndex:index];
		
		if (recipe != nil)
		{
			[recipe deleteImages];
			// remove from index hash
			[recipesIndex removeObjectForKey:recipe.uid];
		}
		[self markDirty];
	}
	return recipe;
}

//
//	Removes the specified recipe from this collection.
//
- (void) removeRecipe:(Recipe*)aRecipe;
{
	if (aRecipe != nil)
	{
		[aRecipe deleteImages];
		[recipesIndex removeObjectForKey:[aRecipe uid]];
		[recipesArray removeObject:aRecipe];		
		[self markDirty];
	}
}

//
// Removes all Recipes from this collection.
//
- (void) clear
{
	long i;
	for (i = [recipesArray count] - 1; i >= 0; i--)
	{
		Recipe* recipe = [self removeRecipeAtIndex:i];
		
		// TODO: should we dealloc the object here?
		(void) recipe;
	}
}

//
//	Look up recipe by its unique Id
//
- (Recipe*) recipeForUid: (NSString*)uid
{
	return [recipesIndex objectForKey:uid];
} 

//
//	NSCoding method - called to save the collection to file.
//
- (void) encodeWithCoder: (NSCoder*)coder
{
	[coder encodeObject:recipesArray];
}

//
// NSCoding method - called to rehydrate the collection from file.
//
- (id) initWithCoder: (NSCoder*)coder
{
	if (self = [self init])
	{
		NSMutableArray* rehydratedArray = (NSMutableArray*)[coder decodeObject];
		if (rehydratedArray != nil)
		{
			// GLB: strangely, rehydratedArray has a retainCount of 2 here, before this
			// retain call - seems like it should be 1, and in the autorelease pool
			[rehydratedArray retain]; 
			[recipesArray release];
			recipesArray = rehydratedArray;
			
			// rebuild the uid index
			[recipesIndex removeAllObjects];			
			for (Recipe* eachRecipe in recipesArray)
			{
				if (eachRecipe != nil)
				{
					[eachRecipe setOwnerContainer:self];				
					[recipesIndex setObject:eachRecipe forKey:[eachRecipe uid]];
				}
			}		
			
		}
	}
	return self;
}

- (NSArray*)recipesArray
{
	return recipesArray;
}

@end
