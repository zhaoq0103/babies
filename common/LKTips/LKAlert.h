//
//  LKAlert.h
//  SK
//
//  Created by luke on 10-11-15.
//  Copyright 2010 pica.com. All rights reserved.
//

#import <Foundation/Foundation.h>



void alertWithError(NSError *error);
void alertWithMessage(NSString *message);
void alertWithMessageAndTitle(NSString *title, NSString *message);
void alertWithOkAndDelegate(NSString *message, id delegate);
void alertWithMessageAndDelegate(NSString *message, id delegate);

