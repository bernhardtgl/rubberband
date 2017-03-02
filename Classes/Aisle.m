//
//  Aisle.m
//  Implementation of an object that represents an aisle within 
//	a store.
//
//  Created by Craig on 3/23/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "Aisle.h"
#import "Database.h"
#import "AislesTable.h"


@implementation Aisle


//
// Initializes a brand new aisle object with a 
// new unique id.
//
- init
{
	return [self initWithUid:[Database generateUid]];
}

//
// Initializes a new aisle object with a known or 
// existing unique id.
//
- (id) initWithUid: (NSString*)newUid
{
	if (self = [super init])
	{
		uid = [newUid copy];
		self.name = @"";
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"***** dealloc Aisle %@", name);
	[name release];
	[super dealloc];
}

//
//	Set the Aisles collection that this item is contained by.
//	This is called when the aisle is added to the Aisles collection.
//
- (void) setOwnerContainer:(NSObject*)container
{
	ownerContainer = container;
}

//
//	Set the isDirty flag to YES to indicate that the aisle
//	has changed since it was loaded from disk.
//
- (void) markDirty
{
	if (ownerContainer != nil)
	{
		AislesTable* as = (AislesTable*)ownerContainer;
		[as markDirty];
	}
}

//
// get the unique id of this aisle object 
//
- (NSString*) uid
{
	return uid;
}

//
// set aisle name
//
- (void) setName: (NSString *)newName
{
	NSString *n = [newName copy];
	[name release];
	name = n;
	[self markDirty];
}

//
// get aisle name
//
- (NSString*) name
{
	return name;
}



// description is what is returned when the object is printed to the log
- (NSString*) description
{
	// description is what is returned when the object is printed to the log
	return [NSString stringWithFormat:@"%@ %@", uid, name ];
}

//
//	NSCoding method - called to save the save the object to file.
//
- (void) encodeWithCoder: (NSCoder*)coder
{
	[coder encodeInt:1 forKey:@"version"];

	[coder encodeObject:uid forKey:@"uid"];
	[coder encodeObject:name forKey:@"name"];
}

//
// NSCoding method - called to rehydrate the object from file.
//
- (id) initWithCoder: (NSCoder*)coder
{
	if (self = [super init])
	{
		// don't need to decode it though, because we don't need it yet
		// commented out so no compiler warning
//		int version = [coder decodeIntForKey:@"version"];

		uid = [[coder decodeObjectForKey:@"uid"] copy];
		[self setName:[coder decodeObjectForKey:@"name"]];
	}
	return self;
}

@end
