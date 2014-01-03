//
//  CustomSearchBar.m
//  babyfaq
//
//  Created by PRO on 13-5-29.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "CustomSearchBar.h"
#import "SeachResultViewController.h"
#import "HomeViewController.h"
#import "ExpertSearchViewController.h"

@implementation CustomSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_textView release];
    [_keywordText release];
    [_cancelButton release];
    [super dealloc];
}
//搜索事件
- (IBAction)cancelClicked:(id)sender
{
    //[_keywordText resignFirstResponder];
    if (_keywordText.text == @"" || _keywordText.text == Nil || _keywordText.text.length == 0) {
        return;
    }
    
    [_keywordText resignFirstResponder];
    
    if(_target && _searchAction)
    {
        [_target performSelector:_searchAction];
    }    
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length == 0)
    {
        return NO;
    }
//    [_keywordText resignFirstResponder];
    [self cancelClicked:nil];
    
    return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if(_cancelButton.hidden)
//    {
//        CGRect frame = _textView.frame;
//        frame.size.width -= _cancelButton.frame.size.width + 5;
//        [UIView animateWithDuration:0.3 animations:^{
//            _textView.frame = frame;
//            _cancelButton.hidden = NO;
//        }];
//    }
//    if(_target && _editBeginAction)
//    {
//        [_target performSelector:_editBeginAction];
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if(!_cancelButton.hidden)
//    {
//        CGRect frame = _textView.frame;
//        frame.size.width += _cancelButton.frame.size.width + 5;
//        [UIView animateWithDuration:0.3 animations:^{
//            _textView.frame = frame;
//            _cancelButton.hidden = YES;
//        }];
//    }
//    if(_target && _editEndAction)
//    {
//        [_target performSelector:_editEndAction];
//    }
}



@end
