//
//  NameAndPictureView.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 5/18/08.
//  Copyright 2008 GBCB Software. All rights reserved.
//

#import "NameAndPictureView.h"

@interface NameAndPictureView(PrivateMethods)
- (void) selectNewPicture;
- (void) createImageVCIfNeeded;
- (void) choosePhoto;
- (void) takePhoto;
@end


@implementation NameAndPictureView

@synthesize didImageChange;
@synthesize editing;

- (id)initWithFrame:(CGRect)frame 
{
	if (self = [super initWithFrame:frame]) 
	{
		didImageChange = NO;
		editing = YES;
		
		pictureButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[pictureButton addTarget:self action:@selector(pictureAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:pictureButton];	

		pictureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		pictureLabel.backgroundColor = [UIColor clearColor];
		pictureLabel.font = [UIFont boldSystemFontOfSize:13];
		pictureLabel.lineBreakMode = NSLineBreakByWordWrapping;
		pictureLabel.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
		pictureLabel.textAlignment = NSTextAlignmentCenter;
		pictureLabel.numberOfLines = 3;
		[self addSubview:pictureLabel];		
		
		backgroundButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		backgroundButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[backgroundButton addTarget:self action:@selector(nameAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:backgroundButton];

		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:14];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		[self addSubview:nameLabel];		
	
		// NEW ONE
		linkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		linkButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[self addSubview:linkButton];
		
		arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_arrow.png"]];
		[arrowImageView retain];
		[self addSubview:arrowImageView];

		infoButton = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
		[infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:infoButton];	
		
		// load up the two image overlays - one for view mode one for edit mode
		overlayEditMode = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit_overlay.png"]];
		[overlayEditMode retain];
		overlayEditMode.hidden = YES;
		[self addSubview:overlayEditMode];

		overlayViewMode = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_overlay.png"]];
		[overlayViewMode retain];
		overlayViewMode.hidden = YES;
		[self addSubview:overlayViewMode];
		
		editImageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		editImageLabel.textColor = [UIColor whiteColor];
		editImageLabel.shadowColor = [UIColor darkGrayColor];
		editImageLabel.shadowOffset = CGSizeMake(0,1);
		editImageLabel.textAlignment = NSTextAlignmentCenter;
		editImageLabel.hidden = YES;
		editImageLabel.backgroundColor = [UIColor clearColor];
		editImageLabel.font = [UIFont boldSystemFontOfSize:11]; 
		editImageLabel.text = NSLocalizedString(@"Edit", @"Edit picture label");
		[self addSubview:editImageLabel];		
	}
	return self;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[nameLabel release];
	[pictureButton release];
	[backgroundButton release];
	[arrowImageView release];
	[overlayEditMode release];
	[overlayViewMode release];
	[editImageLabel release];
	[pictureLabel release];
	[linkButton release];
	
	[placeholder release];
	[name release];
	[notes release];
	[link release];

	// the parentVC is not retained, to prevent circular reference count
	[nameVC release];
	[imageVC release];
	
	[super dealloc];
}

- (void)layoutSubviews
{
	const int IMAGE_WIDTH = 64;
	const int IMAGE_HEIGHT = 64;
	const int TOP_BORDER = 10;
	const int LEFT_BORDER = 10;
	const int MID_BORDER = 16;
	const int EDIT_OVERLAY_HEIGHT = 14;
	
	[super layoutSubviews];	
	
	CGRect frame = [self bounds];
	CGRect controlFrame;
	
	// Place the subviews appropriately.
	controlFrame = CGRectMake(frame.origin.x + LEFT_BORDER, 
							  frame.origin.y + TOP_BORDER, 
							  IMAGE_WIDTH, 
							  IMAGE_HEIGHT);	
	pictureButton.frame = controlFrame;
	overlayEditMode.frame = controlFrame;
	overlayViewMode.frame = controlFrame;
	
	// this holds the text "Add Photo" - it's inset so that it won't
	// bleed out into the rectangular graphic for the button. Esp. important for other
	// languages like Dutch
	controlFrame = CGRectInset(controlFrame, 6.0, 6.0);
	pictureLabel.frame = controlFrame;
	
	controlFrame = CGRectMake(frame.origin.x + LEFT_BORDER, 
							  frame.origin.y + TOP_BORDER + IMAGE_HEIGHT - EDIT_OVERLAY_HEIGHT - 2, 
							  IMAGE_WIDTH, 
							  EDIT_OVERLAY_HEIGHT);	
	editImageLabel.frame = controlFrame;
	
	int backgroundLeft = frame.origin.x + LEFT_BORDER + IMAGE_WIDTH + MID_BORDER;
	controlFrame = CGRectMake(backgroundLeft, 
							  frame.origin.y + TOP_BORDER, 
							  frame.size.width - (LEFT_BORDER*2) - MID_BORDER - IMAGE_WIDTH, 
							  IMAGE_HEIGHT);	
	backgroundButton.frame = controlFrame;
	backgroundButton.hidden = !editing;

	int arrowLeft = frame.origin.x + frame.size.width - 31;
	controlFrame = CGRectMake(arrowLeft, 
							  TOP_BORDER + (IMAGE_HEIGHT / 2) - 9, 
							  14, 
							  18);	
	arrowImageView.frame = controlFrame;
	arrowImageView.hidden = !editing;

	BOOL hasLink = ((link != nil) && (![link isEqualToString:@""]));

	if (editing)
	{
		infoButton.hidden = YES;
	}
	else
	{
		infoButton.hidden = NO;
		controlFrame = CGRectMake(frame.origin.x + frame.size.width - 40, 
								  TOP_BORDER + 16, 
								  40, 
								  34);	
		infoButton.frame = controlFrame;
	}
	
	int leftBorderText = (editing ? LEFT_BORDER : 0);
	int infoButtonBorder = (infoButton.hidden ? 0 : 6);
	
	controlFrame = CGRectMake(backgroundLeft + leftBorderText, 
							  frame.origin.y + TOP_BORDER + 4, 
							  arrowLeft - backgroundLeft - leftBorderText - infoButtonBorder, 
							  (hasLink ? 41.0 : 58.0));	
	nameLabel.frame = controlFrame;
	nameLabel.numberOfLines = (hasLink ? 2 : 3);
	nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

	// either show a gray placeholder or the name, depending on the value
	if ((name == nil) || ([name isEqual:@""]))
	{
		nameLabel.text = placeholder;
		nameLabel.textColor = [UIColor grayColor];
	}
	else
	{
		nameLabel.text = name;
		nameLabel.textColor = [UIColor darkTextColor];
	}
	
	// NEW ONE
	controlFrame = CGRectMake(backgroundLeft + leftBorderText, 
							  54.0,  
							  arrowLeft - backgroundLeft - leftBorderText - infoButtonBorder, 
							  14.0);	
	linkButton.frame = controlFrame;
	linkButton.hidden = !hasLink;
	
	if (hasLink)
	{
		NSString* shortLink = link;
		NSURL* linkUrl = [NSURL URLWithString:link];
		if (linkUrl != nil)
		{
			shortLink = [NSString stringWithFormat:@"%@://%@", linkUrl.scheme, linkUrl.host];
		}
		[linkButton setTitle:shortLink forState:UIControlStateNormal];
		[linkButton sizeToFit];
		
		// in edit mode, don't want the hyperlink to launch, just to show the edit dialog
		// as if you'd tapped on the name
		if (editing)
		{
			[linkButton addTarget:self action:@selector(nameAction:) forControlEvents:UIControlEventTouchUpInside];
			[linkButton setTitleColor:[UIColor grayColor]  
							 forState:UIControlStateNormal];
			[linkButton setBackgroundImage:nil forState:UIControlStateHighlighted];
		}
		else
		{
			[linkButton addTarget:self action:@selector(linkAction:) forControlEvents:UIControlEventTouchUpInside];
			[linkButton setTitleColor:[UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0]  
							 forState:UIControlStateNormal];
			UIImage* imgGray = [UIImage imageNamed:@"gray_selection.png"];
			[linkButton setBackgroundImage:imgGray forState:UIControlStateHighlighted];
		}
	}
		
	if (image != nil)
	{
		[pictureButton setBackgroundImage:image forState:UIControlStateNormal];
		pictureLabel.text = @"";
		overlayEditMode.hidden = !editing;
		editImageLabel.hidden = !editing;
		overlayViewMode.hidden = editing;
	}
	else // no image
	{
		if (editing)
		{
			[pictureButton setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
			pictureLabel.text = NSLocalizedString(@"Add Photo",@"");
			overlayViewMode.hidden = YES;
		}
		else
		{
			[pictureButton setBackgroundImage:[UIImage imageNamed:@"recipe" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
			pictureLabel.text = @"";
			overlayViewMode.hidden = NO;
		}
		overlayEditMode.hidden = YES;
		editImageLabel.hidden = YES;
	}
	
	// For debugging...
//	textField.backgroundColor = [UIColor redColor];
}

- (void)nameAction:(NSNotification*)notification
{
	if (editing)
	{
		if (nameVC == nil) {
			nameVC = [[NewNameAndLinkViewController alloc] initWithStyle:UITableViewStyleGrouped];
			nameVC.delegate = self;
			nameVC.title = NSLocalizedString(@"Recipe Info", @"Title for recipe name");
		}
		nameVC.name = name;
		nameVC.link = link;
		[[parentVC navigationController] pushViewController:nameVC animated:YES];
	}
}

- (void)didChange:(NewNameAndLinkViewController*)controller;
{
	// user edited the name, update it on this control
	self.name = controller.name;
	self.link = controller.link;
}

- (void)pictureAction:(NSNotification*)notification
{
	if (editing) 
	{
		[self selectNewPicture];
	}
}

- (void)linkAction:(NSNotification*)notification
{
	if ((link != nil) && (![link isEqualToString:@""]))
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
	}
}

- (void)infoAction:(NSNotification*)notification
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:name message:notes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Close",@"button")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {}];
    
    UIAlertAction *email = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Email", @"THIS NEEDS TO BE SHORT! Button to email a specific recipe")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   if (delegate && [delegate respondsToSelector:@selector(didWantToEmail)])
                                   {
                                       [delegate didWantToEmail];
                                   }
                               }];
    
    [alert addAction:email];
    [alert addAction:cancel];
    [parentVC presentViewController:alert animated:YES completion:nil];
}

- (void)selectNewPicture
{
	BOOL haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	BOOL haveLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
	
	if (haveCamera && haveLibrary) 
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] 
									  initWithTitle:@""
									  delegate:self 
									  cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel button") 
									  destructiveButtonTitle:nil
									  otherButtonTitles:
									    NSLocalizedString(@"Take Photo", @"Button"), 
										NSLocalizedString(@"Choose Existing Photo", @"Button"), 
									    nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[actionSheet showInView:self.superview];
		[actionSheet release];
	}
	else if (haveCamera) // have a camera, but no pictures in the library
	{
		[self takePhoto];
	}
	else if (haveLibrary) // no camera, for example, iPod Touch
	{
		[self choosePhoto];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[self takePhoto];
			break;
			
		case 1:
			[self choosePhoto];
			break;
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[parentVC dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)newImage 
				  editingInfo:(NSDictionary *)editingInfo
{
	didImageChange = YES;
		
	[self setImage:newImage];

	// TODO: save bounds and original image, too
	
	// TODO: animate this into the Edit button like the New Contact screen 
	// does
	NSLog(@"%@", editingInfo);
	[parentVC dismissViewControllerAnimated:YES completion: nil];
}

- (void) createImageVCIfNeeded
{
	if (imageVC == nil)
	{
		// create the image picker lazily
		imageVC = [[UIImagePickerController alloc] init];
		imageVC.delegate = self;
		imageVC.allowsEditing = YES;
	}	
}

- (void) choosePhoto
{
	[self createImageVCIfNeeded];
	imageVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[parentVC presentViewController:imageVC animated:YES completion: nil];
}

- (void) takePhoto
{
	[self createImageVCIfNeeded];
	imageVC.sourceType = UIImagePickerControllerSourceTypeCamera;
	[parentVC presentViewController:imageVC animated:YES completion: nil];
}

// ============================================================================
#pragma mark Property methods

- (void) setImage:(UIImage*)newValue
{
	[newValue retain];
	[image release];
	image = newValue;
	
	[self setNeedsLayout];
}

- (UIImage*) image
{
	return image;
}

- (void) setParentVC:(UIViewController*)newValue
{
	// the parentVC is not retained, to prevent circular reference count
	parentVC = newValue;
}
- (UIViewController*)parentVC
{
	return parentVC;
}

- (NSString*)name
{
	return name;
}
- (void)setName:(NSString*)value
{
	value = [value copy];
	[name release];
	name = value;
	
	[self setNeedsLayout];
}

- (NSString*)placeholder
{
	return placeholder;
}
- (void)setPlaceholder:(NSString*)value
{
	value = [value copy];
	[placeholder release];
	placeholder = value;

	[self setNeedsLayout];
}

- (NSString*)notes
{
	return notes;
}
- (void)setNotes:(NSString*)value
{
	value = [value copy];
	[notes release];
	notes = value;

	[self setNeedsLayout];
}

- (NSString*)link
{
	return link;
}
- (void)setLink:(NSString*)value
{
	value = [value copy];
	[link release];
	link = value;

	[self setNeedsLayout];
}

// ============================================================================
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

@end
