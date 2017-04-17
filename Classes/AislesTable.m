//
//  AislesTable.m
//  Implementation of collection of aisle objects.
//
//  Created by Craig on 3/26/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "AislesTable.h"
#import "Aisle.h"

@implementation AislesTable

//
// Initializes a brand new aisle collection.
//
- init
{
	if (self = [super init])
	{
		aislesArray = [[NSMutableArray alloc] init];
		aislesIndex = [[NSMutableDictionary alloc] init];
		isDirty = NO;
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"***** dealloc THE AislesTable");
	[aislesArray release];
	[aislesIndex release];
	[super dealloc];
}

// 
// Description is what is returned when the object is printed to the log
//
- (NSString*) description
{
	return [aislesArray description];
}

//
// Enumeration method. Manditory method to support "for each" language constructs.
//
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	return [aislesArray countByEnumeratingWithState:state objects:stackbuf count:len];
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
//	Returns the number of aisles in the collection.
//
- (NSUInteger) count
{
	return [aislesArray count];
}

//
//	Add an aisle to the collection
//
- (void) addAisle:(Aisle*)newAisle
{
	if (newAisle != nil)
	{
		// add the item to the array
		[aislesArray addObject:newAisle];
	
		// add the item to the index
		[aislesIndex setObject:newAisle forKey:newAisle.uid];
	
		[self markDirty];
	}	
}

//
//	Gets the aisle at the specified index within
//	the collection.
//
- (Aisle*) aisleAtIndex:(NSInteger)index
{
	Aisle* aisle = nil;
	if ((index >= 0) && (index < [aislesArray count]))
	{
		aisle = (Aisle*)[aislesArray objectAtIndex:index];
	}
	return aisle;
}

//
//	Remove the aisle at the specified index from this
//	collection.
//	Returns the items removed from the collection.
//
- (Aisle*) removeAisleAtIndex:(NSInteger)index
{
	Aisle* aisle = nil;
	if ((index >= 0) && (index < [aislesArray count]))
	{
		aisle = (Aisle*)[aislesArray objectAtIndex:index];
		
		// remove from array
		[aislesArray removeObjectAtIndex:index];

		if (aisle != nil)
		{
			// remove from index hash
			[aislesIndex removeObjectForKey:aisle.uid];
			[self markDirty];
		}
	}
	return aisle;
}

- (void) moveAisleAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	NSLog(@"Before: %@", aislesArray);
	Aisle* a = [aislesArray objectAtIndex:fromIndex];
	if (toIndex < fromIndex)
	{
		[aislesArray removeObjectAtIndex:fromIndex];
		[aislesArray insertObject:a atIndex:toIndex];
	}
	else 
	{
		[aislesArray removeObjectAtIndex:fromIndex];
		[aislesArray insertObject:a atIndex:toIndex];
	}

	[self markDirty];
	NSLog(@"After: %@", aislesArray);
}

- (NSUInteger) indexOfAisle:(Aisle*)aisle;
{
	NSUInteger value = [aislesArray indexOfObject:aisle];
	return value;
}

//
//	Look up aisle by its unique Id
//
- (Aisle*) aisleForUid: (NSString*)uid
{
	return [aislesIndex objectForKey:uid];
} 

//
//	NSCoding method - called to save the collection to file.
//
- (void) encodeWithCoder: (NSCoder*)coder
{
	[coder encodeObject:aislesArray];
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
			[aislesArray release];
			aislesArray = rehydratedArray;
			
			// rebuild the uid index
			[aislesIndex removeAllObjects];			
			for (Aisle* eachAisle in aislesArray)
			{
				if (eachAisle != nil)
				{
					[eachAisle setOwnerContainer:self];				
					[aislesIndex setObject:eachAisle forKey:[eachAisle uid]];
				}
			}		
			
		}
	}
	return self;
}

@end
