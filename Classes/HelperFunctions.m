//
//  HelperFunctions.m
//  Rubberband
//
//  Created by Greg (208) 861-9988 on 1/31/09.
//  Copyright 2009 GBCB Software. All rights reserved.
//

#import "HelperFunctions.h"

void showAlert(NSString* message)
{
	UIAlertView *alert = [[UIAlertView alloc]  
						  initWithTitle:@""
						  message:message
						  delegate:nil 
						  cancelButtonTitle:NSLocalizedString(@"Close",@"button")
						  otherButtonTitles:nil];	
	[alert show];
	[alert release];
}

NSString* encodeUrlString(NSString* string)
{
	// The stringByAddingPercentEscapesUsingEncoding method doesn't properly encode ampersands
	// so we need handle this separately.
	NSString* retString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	retString = [retString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	return retString;
}

NSString* unencodeUrlString(NSString* string)
{
	// The stringByAddingPercentEscapesUsingEncoding method doesn't properly encode ampersands
	// so we need handle this separately.
	NSString* retString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	retString = [retString stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
	return retString;
}
