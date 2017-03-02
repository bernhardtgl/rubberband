//
//  Aisle.h
//  Interface definition for an aisle within a store.
//
//  Created by Craig on 3/23/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Aisle : NSObject <NSCoding>
{
	NSObject* ownerContainer;
	NSString* uid;
	NSString* name;
}
- (id) initWithUid: (NSString*)uid;

- (void) setOwnerContainer:(NSObject*)container;

- (NSString*) uid;
- (void) setName: (NSString*)newName;
- (NSString*) name;

@end
