//
//  ExpertViewController.h
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "ExpertsTableView.h"

@interface ExpertViewController : RootViewController
{
//    BOOL                        _bCommentExpertsBtnSelected;
    
    NSInteger                   _recommendExpertsCount;
    NSMutableArray*             _recommendExpertsArray;
    
    NSMutableDictionary*        _categoryNameAndIDDics;
    NSInteger                   _groupedExpertsCount;
    NSMutableArray*             _groupedExpertsArray;
    
    NSInteger                   _expertsCounts;
    NSMutableArray*             _expertsArray;
        
    BOOL                        _bRecommenExpertDataReady;
    BOOL                        _bGroupedExpertDataReady;
    BOOL                        _bGroupedExpertCategoryDataReady;
    
    BOOL                        _bForceRefreshRecommendExpertData;
}

@property (retain, nonatomic) IBOutlet UIButton *btnCommentExperts;
@property (retain, nonatomic) IBOutlet UIButton *btnExpertsGroup;

@property (retain, nonatomic) ExpertsTableView *expertsList;

@property (retain, nonatomic) NSMutableArray* expertID;
@property (retain, nonatomic) NSMutableArray* categoryID;

@property (nonatomic)NSInteger              curPage;

- (IBAction)btnCommentExpertsClicked:(id)sender;
- (IBAction)btnExpertsGroupClicked:(id)sender;
@end
