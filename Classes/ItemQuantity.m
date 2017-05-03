//
//  ItemQuantity.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "ItemQuantity.h"

@implementation ItemQuantity

- init
{
	if (self = [super init])
	{
		type = QuantityTypeNone;
		amount = 0;
	}
	return self;
}

- (QuantityType) type;
{
	return type;
}
- (void) setType:(QuantityType)newValue;
{
	if (type != newValue)
	{
		QuantityType oldType = type;
		type = newValue;
		if (delegate) 
		{
			[delegate didChangeItemQuantityType:self oldValue:oldType];
		}
	}
}

- (double) amount;
{
	return amount;
}
- (void) setAmount:(double)newValue;
{
	if (amount != newValue)
	{
		double oldAmount = amount;
		amount = newValue;
		if (delegate) 
		{
			[delegate didChangeItemQuantityAmount:self oldValue:oldAmount];
		}
	}
}

- (void) convertToType:(QuantityType)newType;
{
	// not really changing the type
	if (type == newType) {
		return;
	}
	
	CGFloat newAmt = amount;

	// grams and milliliters are not continuous, so convert them.
	// leave zeroes alone
	if (amount > 0)
	{
		if (newType == QuantityTypeGram)
		{
			newAmt = 100.0;
		}
		else if (newType == QuantityTypeMilliliter)
		{
			newAmt = 100.0;
		}
		else if (type == QuantityTypeGram)
		{
			newAmt = 1.0;
		}
		else if (type == QuantityTypeMilliliter)
		{
			newAmt = 1.0;
		}
	}

	self.amount = newAmt;
	self.type = newType;
}

// when a user adds 8 oz to 1 lb we can be smart. Returns NO if the types weren't compatible
// and we had to remove the type, so we can show a message to the user.
//
// Note: this is not supposed to be mathematically precise - this is just a rough estimate.
// For example 500g = 1 lb, not 483g. That way it doesn't seem to nerdy to the user
// General philosophy is that when we can add the quantity, we keep the larger unit, for
// example: 500g + 1 kg = 1 1/2 kg, not 1500g
//
- (BOOL) increaseQuantityBy:(ItemQuantity*)qtyToAdd;
{
	double amt = self.amount;
	BOOL converted = YES;
	
	// simple case, both are of the same type, or we are zero
	if ((qtyToAdd.type == self.type) || (self.amount == 0.0))
	{
		self.amount = amt + qtyToAdd.amount;
		self.type = qtyToAdd.type;
	}
	else // not so simple
	{
		if (self.type == QuantityTypePound)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeOunce:    
					self.amount = amt + (qtyToAdd.amount / 16);
					break;
				case QuantityTypeKilogram: 
					self.type = qtyToAdd.type;
					self.amount = (amt / 2) + qtyToAdd.amount; 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}
		else if (self.type == QuantityTypeOunce)
		{
			switch (qtyToAdd.type) {
				case QuantityTypePound:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 16) + qtyToAdd.amount; 
					break;
				case QuantityTypeKilogram: 
					self.type = qtyToAdd.type;
					self.amount = (amt / 32) + qtyToAdd.amount; 
					break;
				case QuantityTypeCup:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 8) + qtyToAdd.amount; 
					break;
				case QuantityTypePint:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 16) + qtyToAdd.amount; 
					break;
				case QuantityTypeQuart:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 32) + qtyToAdd.amount; 
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 128) + qtyToAdd.amount; 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}
		else if (self.type == QuantityTypeGram)
		{
			switch (qtyToAdd.type) {
				case QuantityTypePound:    
					self.type = qtyToAdd.type;
					self.amount = (amt * 0.002) + qtyToAdd.amount; // 1/500
					break;
				case QuantityTypeKilogram: 
					self.type = qtyToAdd.type;
					self.amount = (amt * 0.001) + qtyToAdd.amount; // 1/1000
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}
		else if (self.type == QuantityTypeKilogram)
		{
			switch (qtyToAdd.type) {
				case QuantityTypePound:    
					self.amount = amt + (qtyToAdd.amount * 0.5); 
					break;
				case QuantityTypeGram:     
					self.amount = amt + (qtyToAdd.amount * 0.001); 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}
		else if (self.type == QuantityTypeTeaspoon)
		{
			switch (qtyToAdd.type) {
			  //case QuantityTypeTeaspoon:    
				case QuantityTypeTablespoon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 3) + qtyToAdd.amount; // 1/3
					break;
				case QuantityTypeCup:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 48) + qtyToAdd.amount; // 1/48
					break;
				case QuantityTypePint:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 96) + qtyToAdd.amount; // 1/96
					break;
				case QuantityTypeQuart:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 192) + qtyToAdd.amount; // 1/192
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt * 0.00130) + qtyToAdd.amount; // 1/768
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeTablespoon)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeTeaspoon:    
					self.amount = amt + (qtyToAdd.amount / 3); // 1/3
					break;
				//case QuantityTypeTablespoon:    
				case QuantityTypeCup:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 16) + qtyToAdd.amount; // 1/16
					break;
				case QuantityTypePint:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 32) + qtyToAdd.amount; // 1/32
					break;
				case QuantityTypeQuart:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 64) + qtyToAdd.amount; // 1/64
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 256) + qtyToAdd.amount; // 1/256
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeCup)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeTeaspoon:    
					self.amount = amt + (qtyToAdd.amount / 48); // 1/48
					break;
				case QuantityTypeTablespoon:    
					self.amount = amt + (qtyToAdd.amount / 16); // 1/16
					break;
				//case QuantityTypeCup:    
				case QuantityTypePint:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 2) + qtyToAdd.amount; // 1/2
					break;
				case QuantityTypeQuart:    
				case QuantityTypeLiter:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 4) + qtyToAdd.amount; // 1/4
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 16) + qtyToAdd.amount; // 1/16
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypePint)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeTeaspoon:    
					self.amount = amt + (qtyToAdd.amount / 48); // 1/48
					break;
				case QuantityTypeTablespoon:    
					self.amount = amt + (qtyToAdd.amount / 16); // 1/16
					break;
				case QuantityTypeCup:    
					self.amount = amt + (qtyToAdd.amount / 2); // 1/2
					break;
				//case QuantityTypePint:    
				case QuantityTypeQuart:
				case QuantityTypeLiter:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 2) + qtyToAdd.amount; // 1/2
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 8) + qtyToAdd.amount; // 1/8
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeQuart)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeTeaspoon:    
					self.amount = amt + (qtyToAdd.amount / 96);
					break;
				case QuantityTypeTablespoon:    
					self.amount = amt + (qtyToAdd.amount / 32); 
					break;
				case QuantityTypeCup:    
					self.amount = amt + (qtyToAdd.amount / 4); 
					break;
				case QuantityTypePint:    
					self.amount = amt + (qtyToAdd.amount / 2); 
					break;
				//case QuantityTypeQuart:    
				case QuantityTypeLiter:    
					self.amount = amt + (qtyToAdd.amount); 
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 4) + qtyToAdd.amount; 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeGallon)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeTeaspoon:    
					self.amount = amt + (qtyToAdd.amount / 768);
					break;
				case QuantityTypeTablespoon:    
					self.amount = amt + (qtyToAdd.amount / 192); 
					break;
				case QuantityTypeCup:    
					self.amount = amt + (qtyToAdd.amount / 16); 
					break;
				case QuantityTypePint:    
					self.amount = amt + (qtyToAdd.amount / 8); 
					break;
				case QuantityTypeQuart:    
				case QuantityTypeLiter:    
					self.amount = amt + (qtyToAdd.amount / 4); 
					break;
				//case QuantityTypeGallon:    
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeLiter)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeMilliliter:    
					self.amount = amt + (qtyToAdd.amount / 1000);
					break;
				case QuantityTypeQuart:    
					self.amount = amt + (qtyToAdd.amount); // treat as equal 
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 4) + qtyToAdd.amount; 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else if (self.type == QuantityTypeMilliliter)
		{
			switch (qtyToAdd.type) {
				case QuantityTypeLiter:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 1000) + qtyToAdd.amount; 
					break;
				case QuantityTypeQuart:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 1000) + qtyToAdd.amount; 
					break;
				case QuantityTypeGallon:    
					self.type = qtyToAdd.type;
					self.amount = (amt / 4000) + qtyToAdd.amount; 
					break;
				default:				   
					converted = NO; 
					break;				   
			} 
		}	
		else
		{
			converted = NO;
		}
	}
	
	return converted;
}

- (NSString*)description;
{
	NSNumber* num = [NSNumber numberWithDouble:amount];
	NSString* unitsText = [ItemQuantity nameForType:type isPlural:(amount > 1.0)];

	return [NSString stringWithFormat:@"%@ %@", num.description, unitsText];
}

- (void) encodeWithCoder: (NSCoder *)coder
{
	[coder encodeInt:type forKey:@"type"];	
	[coder encodeDouble:amount forKey:@"amount"];
}

- (id) initWithCoder: (NSCoder *)coder
{
	if (self = [super init])
	{
		type = [coder decodeIntForKey:@"type"];
		amount = [coder decodeDoubleForKey:@"amount"];
	}
	return self;
}

- (NSString*) abbreviation;
{
	NSNumber* numAmount = [NSNumber numberWithDouble:amount];
	NSInteger amountWhole = [numAmount integerValue];
	CGFloat amountFrac = ([numAmount doubleValue] - amountWhole);
	
	// create the fraction string by roughly matching it to the value
	NSString* fracPart = @"";
	if (amountFrac <= 0.10)  // none
		{ }
	else if ((amountFrac > 0.10) && (amountFrac <= 0.30))  // 1/4
		{ fracPart = @"¼"; }
	else if ((amountFrac > 0.30) && (amountFrac <= 0.40)) // 1/3
		{ fracPart = @"⅓"; }
	else if ((amountFrac > 0.40) && (amountFrac <= 0.60)) // 1/2
		{ fracPart = @"½"; }
	else if ((amountFrac > 0.60) && (amountFrac <= 0.70)) // 2/3
		{ fracPart = @"⅔"; }
	else if (amountFrac > 0.70) // 3/4
		{ fracPart = @"¾"; }

	// don't show 0 1/2 lb, show 1/2 lb
	if (amountWhole == 0 && ![fracPart isEqual:@""])
	{
		return [NSString stringWithFormat:@"%@%@", fracPart,
				[ItemQuantity abbreviationForType:type]];
	}
	else
	{
		return [NSString stringWithFormat:@"%ld%@%@", (long)amountWhole, fracPart,
					[ItemQuantity abbreviationForType:type]];
	}
}

- (id <ItemQuantityDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <ItemQuantityDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}

#pragma mark Class Methods
+ (NSString*) nameForType:(QuantityType)type isPlural:(BOOL)isPlural;
{
	if (!isPlural)
	{
		switch (type) 
		{
			case QuantityTypeNone:	{ return NSLocalizedString(@"item", @"unit of measure"); }
			case QuantityTypePound: { return NSLocalizedString(@"pound", @"unit of measure"); }
			case QuantityTypeOunce:  { return NSLocalizedString(@"ounce", @"unit of measure"); }
			case QuantityTypePint:  { return NSLocalizedString(@"pint", @"unit of measure"); }
			case QuantityTypeQuart:  { return NSLocalizedString(@"quart", @"unit of measure"); }
			case QuantityTypeGallon:  { return NSLocalizedString(@"gallon", @"unit of measure"); }
			case QuantityTypeTeaspoon:  { return NSLocalizedString(@"teaspoon", @"unit of measure"); }
			case QuantityTypeTablespoon:  { return NSLocalizedString(@"tablespoon", @"unit of measure"); }
			case QuantityTypeCup:  { return NSLocalizedString(@"cup", @"unit of measure"); }
			case QuantityTypeGram:  { return NSLocalizedString(@"gram", @"unit of measure"); }
			case QuantityTypeKilogram:  { return NSLocalizedString(@"kilogram", @"unit of measure"); }
			case QuantityTypeLiter:  { return NSLocalizedString(@"liter", @"unit of measure"); }
			case QuantityTypeMilliliter:  { return NSLocalizedString(@"milliliter", @"unit of measure"); }
		}
	}
	else
	{
		switch (type) 
		{
			case QuantityTypeNone:	{ return NSLocalizedString(@"items", @"unit of measure"); }
			case QuantityTypePound: { return NSLocalizedString(@"pounds", @"unit of measure"); }
			case QuantityTypeOunce:  { return NSLocalizedString(@"ounces", @"unit of measure"); }
			case QuantityTypePint:  { return NSLocalizedString(@"pints", @"unit of measure"); }
			case QuantityTypeQuart:  { return NSLocalizedString(@"quarts", @"unit of measure"); }
			case QuantityTypeGallon:  { return NSLocalizedString(@"gallons", @"unit of measure"); }
			case QuantityTypeTeaspoon:  { return NSLocalizedString(@"teaspoons", @"unit of measure"); }
			case QuantityTypeTablespoon:  { return NSLocalizedString(@"tablespoons", @"unit of measure"); }
			case QuantityTypeCup:  { return NSLocalizedString(@"cups", @"unit of measure"); }
			case QuantityTypeGram:  { return NSLocalizedString(@"grams", @"unit of measure"); }
			case QuantityTypeKilogram:  { return NSLocalizedString(@"kilograms", @"unit of measure"); }
			case QuantityTypeLiter:  { return NSLocalizedString(@"liters", @"unit of measure"); }
			case QuantityTypeMilliliter:  { return NSLocalizedString(@"milliliters", @"unit of measure"); }
		}
	}
	return @"";	
}
+ (QuantityType) typeForName:(NSString*)name;
{
	if ([name isEqual:NSLocalizedString(@"item", @"")] || 
		[name isEqual:NSLocalizedString(@"items", @"")]) {
		return QuantityTypeNone; 
	}
	else if ([name isEqual:NSLocalizedString(@"pound", @"")] || 
			 [name isEqual:NSLocalizedString(@"pounds", @"")]) {
		return QuantityTypePound; 	
	}
	else if ([name isEqual:NSLocalizedString(@"ounce", @"")] || 
			 [name isEqual:NSLocalizedString(@"ounces", @"")]) {
		return QuantityTypeOunce; 	
	}
	else if ([name isEqual:NSLocalizedString(@"pint", @"")] || 
			 [name isEqual:NSLocalizedString(@"pints", @"")]) {
		return QuantityTypePint; 	
	}
	else if ([name isEqual:NSLocalizedString(@"quart", @"")] || 
			 [name isEqual:NSLocalizedString(@"quarts", @"")]) {
		return QuantityTypeQuart; 	
	}
	else if ([name isEqual:NSLocalizedString(@"gallon", @"")] || 
			 [name isEqual:NSLocalizedString(@"gallons", @"")]) {
		return QuantityTypeGallon; 	
	}
	else if ([name isEqual:NSLocalizedString(@"teaspoon", @"")] || 
			 [name isEqual:NSLocalizedString(@"teaspoons", @"")]) {
		return QuantityTypeTeaspoon; 	
	}
	else if ([name isEqual:NSLocalizedString(@"tablespoon", @"")] || 
			 [name isEqual:NSLocalizedString(@"tablespoons", @"")]) {
		return QuantityTypeTablespoon; 	
	}	
	else if ([name isEqual:NSLocalizedString(@"cup", @"")] || 
			 [name isEqual:NSLocalizedString(@"cups", @"")]) {
		return QuantityTypeCup; 	
	}
	else if ([name isEqual:NSLocalizedString(@"gram", @"")] || 
			 [name isEqual:NSLocalizedString(@"grams", @"")]) {
		return QuantityTypeGram; 	
	}
	else if ([name isEqual:NSLocalizedString(@"kilogram", @"")] || 
			 [name isEqual:NSLocalizedString(@"kilograms", @"")]) {
		return QuantityTypeKilogram;
	}
	else if ([name isEqual:NSLocalizedString(@"liter", @"")] || 
			 [name isEqual:NSLocalizedString(@"liters", @"")]) {
		return QuantityTypeLiter; 	
	}
	else if ([name isEqual:NSLocalizedString(@"milliliter", @"")] || 
			 [name isEqual:NSLocalizedString(@"milliliters", @"")]) {
		return QuantityTypeMilliliter; 	
	}
	else
	{
		return QuantityTypeNone; 
	}		
}

+ (NSString*) abbreviationForType:(QuantityType)type /*isPlural:(BOOL)isPlural;*/
{
	switch (type) 
	{
		case QuantityTypeNone:	{ return @""; }
		case QuantityTypePound: { return NSLocalizedString(@" lb", @"pound abbreviation"); }
		case QuantityTypeOunce:  { return NSLocalizedString(@" oz", @"ounce abbreviation"); }
		case QuantityTypePint:  { return NSLocalizedString(@" pt", @"pint abbreviation"); }
		case QuantityTypeQuart:  { return NSLocalizedString(@" qt", @"quart abbreviation"); }
		case QuantityTypeGallon:  { return NSLocalizedString(@" gal", @"gallon abbreviation"); }
		case QuantityTypeTeaspoon:  { return NSLocalizedString(@" tsp", @"teaspoon abbreviation"); }
		case QuantityTypeTablespoon:  { return NSLocalizedString(@" Tbsp", @"tablespoon abbreviation"); }
		case QuantityTypeCup:  { return NSLocalizedString(@" c", @"cup abbreviation"); }
		case QuantityTypeGram:  { return NSLocalizedString(@" g", @"gram abbreviation"); }
		case QuantityTypeKilogram:  { return NSLocalizedString(@" kg", @"kilogram abbreviation"); }
		case QuantityTypeLiter:  { return NSLocalizedString(@" l", @"liter abbreviation"); }
		case QuantityTypeMilliliter:  { return NSLocalizedString(@" ml", @"milliliter abbreviation"); }
	}
	return @"";	
}

@end
