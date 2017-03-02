//
//  NotesTableViewCell.h
//  Rubberband
//
//  Created by Craig on 5/18/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

//  This cell shows placeholder text if the notes are empty, and dynamically sizes
//  height to fit the full text of the notes. 
//  Acts like the Notes cell in the iPhone Contacts application

#import <UIKit/UIKit.h>

@interface NotesTableViewCell : UITableViewCell 
{
	NSString* notes;
	
	// UI Controls
	UILabel* textLabel;
	UILabel* snippetLabel;		
}

// call this to find out what the cell height should be, when in the function
// tableView:heightForRowAtIndexPath:
- (CGFloat) cellHeight;

- (void) setNotes:(NSString*)newNotes;
- (NSString*) notes;

@end
