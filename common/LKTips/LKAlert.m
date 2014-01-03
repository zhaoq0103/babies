//
//  LKAlert.m
//  SK
//
//  Created by luke on 10-11-15.
//  Copyright 2010 pica.com. All rights reserved.
//

#import "LKAlert.h"

void alertWithError(NSError *error) {
	
    NSString *message = [NSString stringWithFormat:@"Error! %@ %@", [error localizedDescription], [error localizedFailureReason]];
	alertWithMessage (message);
}


void alertWithMessage(NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LKAlertTitle", nil) 
													message:message delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"LKAlertYes", nil) 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

void alertWithMessageAndTitle(NSString *title, NSString *message) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil) 
													message:NSLocalizedString(message, nil) delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"LKAlertYes", nil) 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

void alertWithOkAndDelegate(NSString *message, id delegate) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LKAlertTitle", nil) 
													message:message delegate:delegate 
										  cancelButtonTitle:NSLocalizedString(@"LKAlertYes", nil) 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

void alertWithMessageAndDelegate(NSString *message, id delegate) {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LKAlertTitle", nil) 
													message:message delegate:delegate 
										  cancelButtonTitle:nil 
										  otherButtonTitles:NSLocalizedString(@"LKAlertYes", nil), NSLocalizedString(@"WinksAlertNo", nil), nil];
	[alert show];
	[alert release];
}
