//
//  NumberTableViewCell.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 4/29/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NumberTableViewCell.h"


@implementation NumberTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	// Drawing code
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	// Configure the view for the selected state
}


- (void)prepareForReuse {
	// If the cell is reusable (has a reuse identifier), this method is called just before the cell is returned from the table view method dequeueReusableCellWithIdentifier:
}


- (void)dealloc {
	[super dealloc];
}


@end
