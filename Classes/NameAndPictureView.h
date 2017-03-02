//
//  NameAndPictureView.h
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/18/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewNameAndLinkViewController.h"

@class NewTextFieldViewController;

@protocol NameAndPictureViewDelegate <NSObject>
- (void) didWantToEmail;
@end

@interface NameAndPictureView : UIView 
	<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
	NewNameAndLinkViewControllerDelegate, UIAlertViewDelegate>
{
	id <NameAndPictureViewDelegate> delegate;

	// UI Controls
	UILabel* nameLabel;
	UIButton* pictureButton;
	UIButton* backgroundButton;
	UIButton* infoButton;
	UILabel* editImageLabel;
	UILabel* pictureLabel;
	UIButton* linkButton;
	
	UIImage* image;
	UIImage* currentRecipeImage;
	UIImageView* arrowImageView;
	UIImageView* overlayEditMode;
	UIImageView* overlayViewMode;
	
	BOOL editing; 
	
	BOOL didImageChange;
	NSString* placeholder;
	NSString* name;
	NSString* notes;
	NSString* link;
	
	// additional view controllers
	UIImagePickerController* imageVC;
	NewNameAndLinkViewController* nameVC;

	// parentVC is needed to launch the photo dialog from, since we are
	// a table view cell, not a full fledged view controller.
	// the parentVC is not retained, to prevent circular reference count
	UIViewController* parentVC;
}
- (id <NameAndPictureViewDelegate>)delegate;
- (void)setDelegate:(id <NameAndPictureViewDelegate>)newDelegate;

@property (nonatomic, assign) BOOL didImageChange;
@property (nonatomic, assign) BOOL editing; // View draws itself differently if in edit mode

- (void) setImage:(UIImage*)newValue;
- (UIImage*) image;

- (void) setParentVC:(UIViewController*)newValue;
- (UIViewController*)parentVC;

- (void) setName: (NSString*)value;
- (NSString*) name;

- (void) setPlaceholder: (NSString*)value;
- (NSString*) placeholder;

- (void) setNotes: (NSString*)value;
- (NSString*) notes;

- (void) setLink: (NSString*)value;
- (NSString*) link;

@end
