//
//  Protocols.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/31/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableViewDataSourceDelegate <NSObject>
- (UITableViewCell*) willCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void) didCommitInsert:(NSIndexPath*)indexPath;
@end

@protocol DialogDelegate <NSObject>
- (void) didSave:(UITableViewController*)dialogController;
@end

////////////////////////////////////////////////////////////////////////
// Everything you need to implement a delegate, cut and paste from below
/*
////////////////////////////////////////////////////////////////////////
 // HEADER FILE
@protocol NameAndPictureViewDelegate <NSObject>
- (void) didWantToEmail:(UITableViewController*)dialogController;
@end

id <NameAndPictureViewDelegate> delegate;

- (id <NameAndPictureViewDelegate>)delegate;
- (void)setDelegate:(id <NameAndPictureViewDelegate>)newDelegate;


////////////////////////////////////////////////////////////////////////
// IMPL FILE

if (delegate && [delegate respondsToSelector:@selector(didWantToEmail:)]) 
{
	[delegate didWantToEmail:self];
}

#pragma mark Delegate properties
- (id <NameAndPictureViewDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id <NameAndPictureViewDelegate>)newDelegate
{   
	// by convention, objects do not retain their delegates
    delegate = newDelegate;
}
 
 //////////////////////////////////////////////////////////////////////////
 // MASTER HEADER FILE

 <NameAndPictureViewDelegate>
 
//////////////////////////////////////////////////////////////////////////
// MASTER IMPL FILE
 
 CHILDOBJECT.delegate = self;

 // **************************************************************************************
#pragma mark NameAndPictureViewDelegate
- (void)didWantToEmail:(UITableViewController*)dialogController;
{
} 
*/
