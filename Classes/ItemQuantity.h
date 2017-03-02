//
//  ItemQuantity.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    QuantityTypeNone,
    QuantityTypePound,		// weight
    QuantityTypeOunce,		// weight, liq volume
    QuantityTypePint,		// liq volume
    QuantityTypeQuart,		// liq volume
    QuantityTypeGallon,		// liq volume
	QuantityTypeTeaspoon,	// liq volume, sol volume
	QuantityTypeTablespoon,	// liq volume, sol volume
	QuantityTypeCup,		// liq volume, sol volume

	QuantityTypeGram,		// weight
	QuantityTypeKilogram,	// weight
	QuantityTypeLiter,	    // volume
	QuantityTypeMilliliter,	// volume

} QuantityType;

@class ItemQuantity;

@protocol ItemQuantityDelegate <NSObject>
- (void) didChangeItemQuantityType:(ItemQuantity*)itemQuantity oldValue:(QuantityType)oldValue;
- (void) didChangeItemQuantityAmount:(ItemQuantity*)itemQuantity oldValue:(double)oldValue;
@end

@interface ItemQuantity : NSObject <NSCoding>
{
	id <ItemQuantityDelegate> delegate;

	QuantityType type;
	double amount;
}
- (id <ItemQuantityDelegate>)delegate;
- (void)setDelegate:(id <ItemQuantityDelegate>)newDelegate;

- (QuantityType) type;
- (void) setType:(QuantityType)newValue;
- (double) amount;
- (void) setAmount:(double)newValue;

- (NSString*) abbreviation;

// when a user changes from pounds to kilos, we may want to be smart and change 1 lb to 1/2kg
- (void) convertToType:(QuantityType)newType;

// when a user adds 8 oz to 1 lb we can be smart. Returns NO if the types weren't compatible
// and we had to remove the type, so we can show a message to the user
- (BOOL) increaseQuantityBy:(ItemQuantity*)qtyToAdd;

// conversion from enum to string and vice versa
+ (NSString*) nameForType:(QuantityType)type isPlural:(BOOL)isPlural;
+ (NSString*) abbreviationForType:(QuantityType)type /*isPlural:(BOOL)isPlural*/;
+ (QuantityType) typeForName:(NSString*)name;

@end

