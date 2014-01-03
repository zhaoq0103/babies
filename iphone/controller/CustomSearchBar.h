//
//  CustomSearchBar.h
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Event_Delegate <NSObject>
@optional
-(void)itemInnerCellClickedAction_PushViewController : (UIViewController*)controller animate:(BOOL) animate;
@end

@interface CustomSearchBar : UIView <UITextFieldDelegate, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UITextField *keywordText;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL searchAction;
@property (nonatomic, assign) SEL editBeginAction;
@property (nonatomic, assign) SEL editEndAction;

@property(nonatomic, assign) id<Event_Delegate>    eventDelegate;

- (IBAction)cancelClicked:(id)sender;

@end
