//
//  QuantityViewController.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 9/13/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "QuantityViewController.h"
#import "ItemQuantity.h"
#import "QuantityTableViewCell.h"

@interface QuantityViewController(PrivateMethods)
- (void) updatePickerPlurals;
- (void) updatePickerForAmount;
- (void) updatePickerCompletely;
@end

@implementation QuantityViewController

@synthesize showUsual;
@synthesize neededText;

- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) 
	{
		neededText = [NSLocalizedString(@"Needed now", @"Quantity needed") retain];
		self.title = NSLocalizedString(@"Quantity", @"Title of quantity screen");
		showUsual = YES;
	}
	return self;
}

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 44.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}

// creates arrays and the picker. Does not yet configure it to match the current
// quantity value
- (void)createPicker
{
	BOOL isPlural = NO;
	pickerUnitTypeNamesSingular = [[NSMutableArray arrayWithObjects:
				[ItemQuantity nameForType:QuantityTypeNone isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypePound isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeOunce isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypePint isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeQuart isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeGallon isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeTeaspoon isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeTablespoon isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeCup isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeGram isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeKilogram isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeLiter isPlural:isPlural],
				[ItemQuantity nameForType:QuantityTypeMilliliter isPlural:isPlural],
							nil] retain];
	
	isPlural = YES;
	pickerUnitTypeNamesPlural = [[NSMutableArray arrayWithObjects:
				  [ItemQuantity nameForType:QuantityTypeNone isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypePound isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeOunce isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypePint isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeQuart isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeGallon isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeTeaspoon isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeTablespoon isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeCup isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeGram isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeKilogram isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeLiter isPlural:isPlural],
				  [ItemQuantity nameForType:QuantityTypeMilliliter isPlural:isPlural],
								  nil] retain];
	pickerUnitTypeNamesCurrent = pickerUnitTypeNamesSingular;

	NSLocale* loc = [NSLocale currentLocale];
	NSNumber* metricNumber = [loc objectForKey:NSLocaleUsesMetricSystem];
	BOOL metric = [metricNumber boolValue];

	if (!metric) // start with pounds in imperial countries
	{
		pickerUnitOrder = [[NSArray arrayWithObjects:
							[NSNumber numberWithInt:QuantityTypeNone],
							[NSNumber numberWithInt:QuantityTypePound],
							[NSNumber numberWithInt:QuantityTypeOunce],
							[NSNumber numberWithInt:QuantityTypePint],
							[NSNumber numberWithInt:QuantityTypeQuart],
							[NSNumber numberWithInt:QuantityTypeGallon],
							[NSNumber numberWithInt:QuantityTypeTeaspoon],
							[NSNumber numberWithInt:QuantityTypeTablespoon],
							[NSNumber numberWithInt:QuantityTypeCup],
							[NSNumber numberWithInt:QuantityTypeGram],
							[NSNumber numberWithInt:QuantityTypeKilogram],
							[NSNumber numberWithInt:QuantityTypeLiter],
							[NSNumber numberWithInt:QuantityTypeMilliliter],
							nil] retain];
	}
	else // and grams in metric countries
	{
		pickerUnitOrder = [[NSArray arrayWithObjects:
							[NSNumber numberWithInt:QuantityTypeNone],
							[NSNumber numberWithInt:QuantityTypeGram],
							[NSNumber numberWithInt:QuantityTypeKilogram],
							[NSNumber numberWithInt:QuantityTypeLiter],
							[NSNumber numberWithInt:QuantityTypeMilliliter],
							[NSNumber numberWithInt:QuantityTypePound],
							[NSNumber numberWithInt:QuantityTypeOunce],
							[NSNumber numberWithInt:QuantityTypePint],
							[NSNumber numberWithInt:QuantityTypeQuart],
							[NSNumber numberWithInt:QuantityTypeGallon],
							[NSNumber numberWithInt:QuantityTypeTeaspoon],
							[NSNumber numberWithInt:QuantityTypeTablespoon],
							[NSNumber numberWithInt:QuantityTypeCup],
							nil] retain];
	}

	pickerUnitsFraction = [[NSArray arrayWithObjects:
							@"-", @"¼", @"⅓", @"½", @"⅔", @"¾", nil] retain];
	pickerUnitsDecimal =  [[NSArray arrayWithObjects:
							[NSNumber numberWithDouble:0.0],
							[NSNumber numberWithDouble:0.25],
						    [NSNumber numberWithDouble:0.3333333],
						    [NSNumber numberWithDouble:0.50],
						    [NSNumber numberWithDouble:0.6666667],
						    [NSNumber numberWithDouble:0.75], nil] retain];
	
	gramArray = [[NSArray arrayWithObjects:
				  [NSNumber numberWithDouble:0.0],
				  [NSNumber numberWithDouble:5.0],
				  [NSNumber numberWithDouble:10.0],
				  [NSNumber numberWithDouble:15.0],
				  [NSNumber numberWithDouble:20.0],
				  [NSNumber numberWithDouble:25.0],
				  [NSNumber numberWithDouble:30.0],
				  [NSNumber numberWithDouble:35.0],
				  [NSNumber numberWithDouble:40.0],
				  [NSNumber numberWithDouble:45.0],
				  [NSNumber numberWithDouble:50.0],
				  [NSNumber numberWithDouble:60.0],
				  [NSNumber numberWithDouble:70.0],
				  [NSNumber numberWithDouble:75.0],
				  [NSNumber numberWithDouble:80.0],
				  [NSNumber numberWithDouble:90.0],
				  [NSNumber numberWithDouble:100.0],
				  [NSNumber numberWithDouble:125.0],
				  [NSNumber numberWithDouble:150.0],
				  [NSNumber numberWithDouble:175.0],
				  [NSNumber numberWithDouble:200.0],
				  [NSNumber numberWithDouble:225.0],
				  [NSNumber numberWithDouble:250.0],
				  [NSNumber numberWithDouble:275.0],
				  [NSNumber numberWithDouble:300.0],
				  [NSNumber numberWithDouble:325.0],
				  [NSNumber numberWithDouble:350.0],
				  [NSNumber numberWithDouble:375.0],
				  [NSNumber numberWithDouble:400.0],
				  [NSNumber numberWithDouble:425.0],
				  [NSNumber numberWithDouble:450.0],
				  [NSNumber numberWithDouble:475.0],
				  [NSNumber numberWithDouble:500.0],
				  [NSNumber numberWithDouble:525.0],
				  [NSNumber numberWithDouble:550.0],
				  [NSNumber numberWithDouble:575.0],
				  [NSNumber numberWithDouble:600.0],
				  [NSNumber numberWithDouble:625.0],
				  [NSNumber numberWithDouble:650.0],
				  [NSNumber numberWithDouble:675.0],
				  [NSNumber numberWithDouble:700.0],
				  [NSNumber numberWithDouble:725.0],
				  [NSNumber numberWithDouble:750.0],
				  [NSNumber numberWithDouble:775.0],
				  [NSNumber numberWithDouble:800.0],
				  [NSNumber numberWithDouble:825.0],
				  [NSNumber numberWithDouble:850.0],
				  [NSNumber numberWithDouble:875.0],
				  [NSNumber numberWithDouble:900.0],
				  [NSNumber numberWithDouble:925.0],
				  [NSNumber numberWithDouble:950.0],
				  [NSNumber numberWithDouble:975.0],
				  [NSNumber numberWithDouble:1000.0], nil] retain];
	
	milliliterArray = [[NSArray arrayWithObjects:
						[NSNumber numberWithDouble:0.0],
						[NSNumber numberWithDouble:5.0],
						[NSNumber numberWithDouble:10.0],
						[NSNumber numberWithDouble:20.0],
						[NSNumber numberWithDouble:25.0],
						[NSNumber numberWithDouble:30.0],
						[NSNumber numberWithDouble:40.0],
						[NSNumber numberWithDouble:50.0],
						[NSNumber numberWithDouble:60.0],
						[NSNumber numberWithDouble:70.0],
						[NSNumber numberWithDouble:75.0],
						[NSNumber numberWithDouble:80.0],
						[NSNumber numberWithDouble:90.0],
						[NSNumber numberWithDouble:100.0],
						[NSNumber numberWithDouble:150.0],
						[NSNumber numberWithDouble:200.0],
						[NSNumber numberWithDouble:250.0],
						[NSNumber numberWithDouble:300.0],
						[NSNumber numberWithDouble:350.0],
						[NSNumber numberWithDouble:400.0],
						[NSNumber numberWithDouble:450.0],
						[NSNumber numberWithDouble:500.0],
						[NSNumber numberWithDouble:550.0],
						[NSNumber numberWithDouble:600.0],
						[NSNumber numberWithDouble:650.0],
						[NSNumber numberWithDouble:700.0],
						[NSNumber numberWithDouble:750.0],
						[NSNumber numberWithDouble:800.0],
						[NSNumber numberWithDouble:850.0],
						[NSNumber numberWithDouble:900.0],
						[NSNumber numberWithDouble:950.0],
						[NSNumber numberWithDouble:1000.0], nil] retain];
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	unitPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	CGSize pickerSize = [unitPicker sizeThatFits:CGSizeZero];
	unitPicker.frame = [self pickerFrameWithSize:pickerSize];
	
	unitPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	unitPicker.delegate = self;
	unitPicker.showsSelectionIndicator = YES;	// note this is default to NO
	
	[self.view addSubview:unitPicker];
}

- (void)dealloc 
{
	[qtyNeeded release];
	[qtyUsual release];
	[neededText release];
	
	[neededCell release];
	[usualCell release];
	[unitPicker release];
	
	[pickerUnitTypeNamesSingular release];
	[pickerUnitTypeNamesPlural release];
	[pickerUnitsFraction release];
	[pickerUnitsDecimal release];
	[pickerUnitOrder release];
	[gramArray release];
	[milliliterArray release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];

	neededCell = [[QuantityTableViewCell alloc] initWithFrame:CGRectZero];
	neededCell.label = NSLocalizedString(@"Needed now", @"Item count currently needed");
	
	usualCell = [[QuantityTableViewCell alloc] initWithFrame:CGRectZero];
	usualCell.label = NSLocalizedString(@"I usually buy", @"Item count usually needed");
		
	// Add the "Done" button to the navigation bar
	UIBarButtonItem* button = [[UIBarButtonItem alloc] 
							   initWithTitle:NSLocalizedString(@"Done", @"Done button")
									   style:UIBarButtonItemStyleDone
									  target:self 
									  action:@selector(doneAction:)];	
	self.navigationItem.rightBarButtonItem = button;
	[button release];

	// Change back button to Cancel on left
	button = [[UIBarButtonItem alloc] 
							   initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")
							   style:UIBarButtonItemStylePlain
							   target:self 
							   action:@selector(cancelAction:)];	
	self.navigationItem.leftBarButtonItem = button;
	[button release];
	
	self.tableView.scrollEnabled = NO;
	[self createPicker];
}

- (void)viewWillAppear:(BOOL)animated
{
	neededCell.quantity = qtyNeeded;
	usualCell.quantity = qtyUsual;
	
	// owner of this dialog can override the text shown for "needed"
	if (neededText != nil)
	{
		neededCell.label = neededText;
	}

	// if 0 or 1 needed and 1 usual, then link the 2 selections together, 
	// to save the user "clicks"
	if ((([qtyNeeded amount] == 0) || ([qtyNeeded amount] == 1)) && 
		([qtyUsual amount] == 1) && 
		([qtyNeeded type] == QuantityTypeNone) && 
		([qtyUsual type] == QuantityTypeNone))
	{
		isUpdatingBothQuantities = YES;
	}
	
	[self.tableView reloadData];	
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
		animated:NO 
		scrollPosition:UITableViewScrollPositionNone];	
	
	// shortcut to update the correct quantity with the picker
	qtySelected = qtyNeeded;
	
	[self updatePickerCompletely];
}

#pragma mark UITableView delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return (showUsual ? 2 : 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row == 0)
	{
		return neededCell;
	}
	else 
	{
		return usualCell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row == 0)
	{
		qtySelected = qtyNeeded;
	}
	else
	{
		qtySelected = qtyUsual;
	}
	[self updatePickerCompletely];
}

#pragma mark PickerView delegate methods

- (void)pickerView:(UIPickerView *)pickerView 
	  didSelectRow:(NSInteger)row 
	   inComponent:(NSInteger)component
{
	// if the user edits the "usual" quantity, unlink them
	if (qtySelected == qtyUsual)
	{
		isUpdatingBothQuantities = NO;
	}
	
	// changing the whole number or the fraction
	if ((component == 0) || ((component == 1) && isFractionShown))
	{
		NSInteger wholeNumRow = [pickerView selectedRowInComponent:0];
		CGFloat newAmount;
		if (isPickerUnitContinuous)
		{
			newAmount = (wholeNumRow + pickerMin);
		}
		else
		{
			NSNumber* num = (NSNumber*)[pickerNumberArray objectAtIndex:wholeNumRow];
			newAmount = [num doubleValue];
		}
		
		if (isFractionShown)
		{
			NSInteger decimalNumRow = [pickerView selectedRowInComponent:1]; 
			NSNumber* decNum = (NSNumber*)[pickerUnitsDecimal objectAtIndex:decimalNumRow];
			newAmount = newAmount + [decNum doubleValue];
		}
		
		qtySelected.amount = newAmount;
		if (isUpdatingBothQuantities)
		{
			qtyUsual.amount = newAmount;
		}
		
		[self updatePickerPlurals];
	}
	else //unit type
	{
		// figure out which quantity type the user selected, because the order will
		// vary by locale
		NSNumber* newTypeObj = [pickerUnitOrder objectAtIndex:row];
		QuantityType newType = [newTypeObj intValue];
		
		[qtySelected convertToType:newType];		
		if (isUpdatingBothQuantities)
		{
			[qtyUsual convertToType:newType];
		}
		
		[self updatePickerCompletely];
	}
	[self.tableView reloadData];
}

- (NSString *)pickerView:(UIPickerView *)pickerView 
			 titleForRow:(NSInteger)row 
			forComponent:(NSInteger)component
{
	if (component == 0)
	{
		if (isPickerUnitContinuous)
		{
			return [[NSNumber numberWithInteger:row] stringValue];
		}
		else
		{
			return [[pickerNumberArray objectAtIndex:row] stringValue];
		}
	}
	else if ((component == 1) && isFractionShown)
	{	
		return [pickerUnitsFraction objectAtIndex:row];
	}
	else
	{
		NSNumber* typeObj = [pickerUnitOrder objectAtIndex:row];
		QuantityType typeForRow = [typeObj intValue];
		
		return [pickerUnitTypeNamesCurrent objectAtIndex:typeForRow];
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	const CGFloat NUM_WIDTH = 60.0;
	const CGFloat FRAC_WIDTH = 60.0;
	const CGFloat NAME_WIDTH = 180.0;
	const CGFloat BORDER_WIDTH = 2.0;
	
	if ((component == 0) && isFractionShown)
	{
		return NUM_WIDTH;
	}
	else if ((component == 0) && !isFractionShown)
	{
		return NUM_WIDTH + FRAC_WIDTH + BORDER_WIDTH;
	}
	else if ((component == 1) && isFractionShown)
	{
		return FRAC_WIDTH;
	}
	else // name 
	{
		return NAME_WIDTH;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0)
	{
		if (isPickerUnitContinuous) 
		{
			return pickerMax - pickerMin + 1;
		}
		else
		{
			return [pickerNumberArray count]; 
		}
	}
	else if ((component == 1) && isFractionShown)
	{
		return [pickerUnitsFraction count];
	}
	else // names
	{
		return [pickerUnitTypeNamesCurrent count];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return (isFractionShown) ? 3 : 2;
}

// checks the amount and if that's different plural-ness than the current picker
// shows, updates the text of the picker
- (void) updatePickerPlurals;
{
	BOOL newisPluralShown = ((qtySelected.amount == 0) || (qtySelected.amount > 1)); 
	if (isPluralShown != newisPluralShown)
	{
		isPluralShown = newisPluralShown;
		pickerUnitTypeNamesCurrent = (isPluralShown ? pickerUnitTypeNamesPlural : 
									  pickerUnitTypeNamesSingular);
		
		[unitPicker reloadComponent:(isFractionShown ? 2 : 1)];
	}
	
}

// assumes type is already correct, and amount pickers are already there - selects the 
// correct rows
- (void) updatePickerForAmount;
{
	NSNumber* amount = [NSNumber numberWithDouble:qtySelected.amount];
	
	NSInteger amountWhole = [amount integerValue];
	CGFloat amountFrac = ([amount doubleValue] - amountWhole);
	
	NSUInteger row = 0;
	
	if (isPickerUnitContinuous)
	{
		if (amountWhole > pickerMax) amountWhole = pickerMax;
		if (amountWhole < pickerMin) amountWhole = pickerMin;
		
		row = (amountWhole - pickerMin);
	}
	else
	{
		BOOL found = NO;
		int i;
		for (i = 0; i < [pickerNumberArray count]; i++)
		{
			NSNumber* eachNum = [pickerNumberArray objectAtIndex:i];
			if ([eachNum integerValue] < amountWhole)
			{
				continue;
			}
			else
			{
				row = i;
				found = YES;
				break;
			}
		}
		if (!found)
		{
			row = [pickerNumberArray count] - 1;
		}
		
		// the number for the selected row might not exactly match the non-continuous 
		// range (for example, change 1/4 lb to grams = 125g - the picker will select 200g
		// because 125g is not an option. Want to make sure the picker and the value match
		NSNumber* newAmount = [pickerNumberArray objectAtIndex:row];
		qtySelected.amount = [newAmount doubleValue];
	}
	
	[unitPicker selectRow:row inComponent:0 animated:NO];
	[self updatePickerPlurals];
	
	// update the fraction picker if it's displayed. We only support 5 fractional
	// positions, so we use whichever is closest
	if (isFractionShown)
	{
		int fracIndex = 0;
		if (amountFrac <= 0.10)  // none
		{ }
		else if ((amountFrac > 0.10) && (amountFrac <= 0.30))  // 1/4
		{ fracIndex = 1; }
		else if ((amountFrac > 0.30) && (amountFrac <= 0.40)) // 1/3
		{ fracIndex = 2; }
		else if ((amountFrac > 0.40) && (amountFrac <= 0.60)) // 1/2
		{ fracIndex = 3; }
		else if ((amountFrac > 0.60) && (amountFrac <= 0.70)) // 2/3
		{ fracIndex = 4; }
		else if (amountFrac > 0.70) // 3/4
		{ fracIndex = 5; }
		[unitPicker selectRow:fracIndex inComponent:1 animated:NO];
	}
}

// configures the entire picker based on the current type and in qtySelected
- (void) updatePickerCompletely;
{
	NSUInteger selectedTypeRow = 0;
	QuantityType selectedType = qtySelected.type;
	
	// array only has 13 items in it, so this is a brute force way of figuring out
	// which row should be selected based on the type
	int n;
	for (n = 0; n < pickerUnitOrder.count; n++)
	{
		NSNumber* typeForRow = [pickerUnitOrder objectAtIndex:n];
		if ([typeForRow intValue] == selectedType)
		{
			selectedTypeRow = n;
			break;
		}
	}
	
	switch (selectedType) {
		case QuantityTypeNone:
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;	
			break;
		case QuantityTypePound:
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeOunce:		// weight: liq volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = NO;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypePint:		// liq volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeQuart:		// liq volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeGallon:		// liq volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeTeaspoon:	// liq volume: sol volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeTablespoon:	// liq volume: sol volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeCup:		// liq volume: sol volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case QuantityTypeGram:
			isFractionShown = NO;
			isPickerUnitContinuous = NO;
			pickerNumberArray = gramArray;
			break;
		case 	QuantityTypeKilogram:	// weight
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case 	QuantityTypeLiter:	    // volume
			pickerMin = 0;
			pickerMax = 99;
			isFractionShown = YES;
			isPickerUnitContinuous = YES;		
			break;
		case 	QuantityTypeMilliliter:	// volume
			isFractionShown = NO;
			isPickerUnitContinuous = NO;
			pickerNumberArray = milliliterArray;
			break;
		default:
			break;
	}
	
	// reload all, because the number of components might change
	[unitPicker reloadAllComponents];
	
	// reselect the right row in the unit picker, because the above line resets it
	[unitPicker selectRow:selectedTypeRow 
			  inComponent:(isFractionShown ? 2 : 1) 
				 animated:NO];
	
	[self updatePickerForAmount];	
}

#pragma mark Actions
- (void)doneAction:(id)sender
{
	if (delegate && [delegate respondsToSelector:@selector(didSave:)]) 
	{
		[delegate didSave:self];
	}
	
	[[self navigationController] popViewControllerAnimated:YES];		
}

- (void)cancelAction:(NSNotification*)notification
{
	[[self navigationController] popViewControllerAnimated:YES];		
}

#pragma mark Properties
- (ItemQuantity*) qtyNeeded;
{
	return qtyNeeded;
}
- (void) setQtyNeeded:(ItemQuantity*)value;
{
	[qtyNeeded release];
	qtyNeeded = nil;
	
	// copy because we want user to be able to cancel
	qtyNeeded = [[ItemQuantity alloc] init];
	qtyNeeded.amount = value.amount;
	qtyNeeded.type = value.type;
}
- (ItemQuantity*) qtyUsual;
{
	return qtyUsual;
}
- (void) setQtyUsual:(ItemQuantity*)value;
{
	[qtyUsual release];
	qtyUsual = nil;
	
	// copy because we want user to be able to cancel
	qtyUsual = [[ItemQuantity alloc] init];
	qtyUsual.amount = value.amount;
	qtyUsual.type = value.type;
}

- (id <DialogDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <DialogDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}


@end

