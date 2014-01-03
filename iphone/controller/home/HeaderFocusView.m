//
//  HeaderFocusView.m
//  babyfaq
//
//  Created by YANGJINGXI on 13-6-13.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "HeaderFocusView.h"
#import "CustomViewGallery.h"
#import "CommentDataList.h"
#import "DataCenter.h"
#import "MessageManager.h"
#import "defines.h"
#import "ExpertDetailsViewController.h"

@implementation HeaderFocusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _expertViewArray = nil;
        _viewGallery = nil;
        _expertsArray = nil;
    }
    return self;
}

- (void)dealloc
{
    if(_viewGallery)
    {
        [_viewGallery stopTimer];
        [_viewGallery release];
    }
    if(_expertsArray)
        [_expertsArray release];
    [_pageControl release];
    
    if (_expertViewArray != nil) {
        [_expertViewArray removeAllObjects];
        [_expertViewArray release];
    }
    _expertViewArray = nil;
    [super dealloc];
}

- (void)showVideos:(NSArray *)videoItems
{
    if (_expertsArray) {
        [_expertsArray release];
        _expertsArray = nil;
    }
    _expertsArray = [videoItems retain];
    
    if(_expertsArray.count > 0)
    {
        if (_expertViewArray != nil) {
            [_expertViewArray removeAllObjects];
            [_expertViewArray release];
        }
        
        _expertViewArray = [[NSMutableArray alloc] initWithCapacity:_expertsArray.count];
        int i;
        for (i = 0; i < _expertsArray.count; i++) {
            ExpertCellView* view = [[ExpertCellView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            view.expertModel = _expertsArray[i];
            [_expertViewArray addObject:view];
        }
//        i = 0;
        
        [_viewGallery initWithViews:_expertViewArray target:self action:@selector(viewChanged) width:_viewGallery.frame.size.width height:_viewGallery.frame.size.height];
        [_pageControl setNumberOfPages:_expertsArray.count];
        [_pageControl setCurrentPage:0];
        [_viewGallery showView:0 offsetX:0 animation:NO];
//        [self showVideo];
        if(_viewGallery.gestureRecognizers.count == 0)
        {
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            [_viewGallery addGestureRecognizer:gesture];
            [gesture release];
        }
    }
    else
    {
        [_pageControl setNumberOfPages:0];
    }
}

- (void)refreshImage:(NSArray *)args
{
//    NSString *str = [args objectAtIndex:0];
//    UIImage *image = [args objectAtIndex:1];
//    UIImageView *view = [_imageViews objectAtIndex:str.intValue];
//    [view setImage:image];
}

- (void)viewChanged
{
    [_pageControl setCurrentPage:[_viewGallery getCurrentIndex]];
//    [self showVideo];
}

- (void)showVideo
{
//     _curExpertCellView.expertModel;
//    NSString* expertnameStr = [oneExpert valueForKey:EXPERT_NAME];
//    NSString* fieldStr = [NSString stringWithFormat:@"%@", [oneExpert valueForKey:EXPERT_POSITION]];
//    NSString* timeStr = [oneExpert valueForKey:EXPERT_WEEKDAY];
//    NSString* introStr = [NSString stringWithFormat:@"　　%@", [oneExpert valueForKey:EXPERT_INTRO]];
}

#pragma mark - custom action

- (IBAction)pageChanged:(id)sender
{
    if(_expertsArray && _expertsArray.count > 0)
    {
        [_viewGallery showView:_pageControl.currentPage offsetX:0 animation:YES];
//        [self showVideo];
    }
}

#pragma mark - 焦点图点击事件
- (void)handleImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state != UIGestureRecognizerStateRecognized)
    {
        return;
    }
    
    int iCurrentExpertIndex = [_viewGallery getCurrentIndex];
    DataModel* oneExpert = _expertsArray[iCurrentExpertIndex];
    
    NSDictionary* dict = [oneExpert dataDict];
    NSNumber* uid =[dict objectForKey:EXPERT_UID];
    if (uid)
    {
        ExpertDetailsViewController* details = [[ExpertDetailsViewController alloc]initWithNibName:@"ExpertDetailsViewController" bundle:nil];
        details.expertModel = oneExpert;
        //        details.currExpert = [uid intValue];
        //    resultVC.searchType = ExpertAllAns;
        //    resultVC.keyWords = expertuid;
        //    resultVC.title = expertnameStr;
        
        //push to viewcontroller        
        [self.parentViewController.navigationController pushViewController:details animated:YES];
        [details release];
    }
}

@end
