//
//  Aisles.h
//  Interface definition for a collection of aisles.
//
//  Created by Craig on 3/26/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Aisle;

@interface AislesTable : NSObject
{
	NSMutableArray* aislesArray;
	NSMutableDictionary* aislesIndex;
	bool isDirty;
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (bool) isDirty;
- (void) markDirty;
- (NSUInteger) count;
- (Aisle*) aisleAtIndex:(int)index;
- (Aisle*) aisleForUid: (NSString*)uid;
- (NSUInteger) indexOfAisle:(Aisle*)aisle;

- (void) addAisle:(Aisle*)newAisle;
- (Aisle*) removeAisleAtIndex:(int)index;
- (void) moveAisleAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
