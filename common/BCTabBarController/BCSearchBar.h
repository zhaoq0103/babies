//
//  BCSearchBar.h
//  SinaNews
//
//  Created by shieh exbice on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCSearchBar;

@protocol BCSearchBarDelegate <NSObject>

-(void)searchBar:(BCSearchBar*)searchBar cancelClicked:(UIButton*)sender;
-(void)searchBar:(BCSearchBar*)searchBar returnContent:(NSString*)content;
@end

@interface BCSearchBar : UIImageView
{
    id<BCSearchBarDelegate> delegate;
    UIButton* cancelBtn;
    UIImageView* inputZoneView;
    UIButton* modeBtn;
    UIImageView* inputBackgroundView;
    NSString* placeHoder;
    UIImageView* pullmenuView;
    UIImageView* separateView;
}

@property(nonatomic,assign)id<BCSearchBarDelegate> delegate;

@property(nonatomic,retain)UIButton* cancelBtn;
@property(nonatomic,retain)UIButton* modeBtn;
@property(nonatomic,retain)UIImageView* inputZoneView;
@property(nonatomic,retain)UIImageView* inputBackgroundView;
@property(nonatomic,retain)NSString* placeHoder;
@property(nonatomic,retain)UIImageView* backgroundField;
@property(nonatomic,retain)UITextField* inputField;
@property(nonatomic,retain)UIImageView* pullmenuView;
@property(nonatomic,retain)UIImageView* separateView;

@end
