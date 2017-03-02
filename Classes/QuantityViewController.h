//
//  QuantityViewController.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class ItemQuantity;
@class QuantityTableViewCell;

@interface QuantityViewController : UITableViewController 
	<UIPickerViewDelegate>
{
	id <DialogDelegate> delegate;

	ItemQuantity* qtyNeeded;
	ItemQuantity* qtyUsual;
	
	ItemQuantity* qtySelected;

	BOOL showUsual;
	NSString* neededText;
	
	// UI elements
	QuantityTableViewCell* neededCell;
	QuantityTableViewCell* usualCell;
	UIPickerView* unitPicker;
	
	// Holds "items", "pounds", etc... as NSStrings. Order matches order of enum
	NSMutableArray* pickerUnitTypeNamesPlural;
	// Same, except "item", "pound", etc...
	NSMutableArray* pickerUnitTypeNamesSingular;
	// Points to one or the other of the above arrays
	NSMutableArray* pickerUnitTypeNamesCurrent;
	
	// strings for, -, 1/4, 1/3, etc...
	NSMutableArray* pickerUnitsFraction;
	// equivalenf values in decimal of the above array: 0, 0.25, 0.33, etc.
	NSMutableArray* pickerUnitsDecimal;

	// arrays of NSNumbers for the selections of "grams" and "milliliters"
	NSArray* gramArray;
	NSArray* milliliterArray;
	
	// array of NSNumbers that correlate row number in the picker to the enum
	// type for ItemQuantity
	NSArray* pickerUnitOrder;
	
	int pickerMin;				// some measures, like pounds, use a continuous range
	int pickerMax;				
	NSArray* pickerNumberArray; // some measures, like grams, use an array
	BOOL isPickerUnitContinuous;
	BOOL isFractionShown;
	BOOL isPluralShown;
	
	BOOL isUpdatingBothQuantities;
}
- (id <DialogDelegate>)delegate;
- (void)setDelegate:(id <DialogDelegate>)newDelegate;

@property (nonatomic, assign) BOOL showUsual;
@property (nonatomic, copy) NSString* neededText;

// these are not properties because I need to make copies of the objects when they are set
// looked into doing it with the NSCopying protocol, but I don't feel completely confident
// that I understand it yet
- (ItemQuantity*) qtyNeeded;
- (void) setQtyNeeded:(ItemQuantity*)value;
- (ItemQuantity*) qtyUsual;
- (void) setQtyUsual:(ItemQuantity*)value;

@end
