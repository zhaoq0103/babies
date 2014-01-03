//
//  HomeViewController.h
//  babyfaq
//
//  Created by mayanwei on 13-5-23.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "RootViewController.h"
#import "DataModel.h"
#import "QandATableView.h"

@interface HomeViewController : RootViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate, UIAlertViewDelegate>
{
    NSInteger                   _recommendExpertsCount;
    NSMutableArray*             _recommendExpertsArray;
    DataModel*                  _currExpert;
    //快捷菜单

    //BOOL bInited;
    BOOL                        _bFastMenuDataReady;
    BOOL                        _bRecommendExpertDataReady;
    BOOL                        _bLatestQADataReady;
    BOOL                        _bAllQADataReady;
    BOOL                        _bNewQua;
    
    BOOL                        _bAnExpertLogined;
    BOOL                        _bQuestionsNeedReplyReady;
    NSInteger                   _needReplyQsCount;
    NSMutableArray*             _needReplyQsArray;
    
    BOOL                        _bForceRefreshRecommendExpertData;
}





@property (retain, nonatomic) NSMutableArray* expertID;

@property(nonatomic,retain)NSArray* searchArgs;
@property (nonatomic)NSInteger              curPage;
@property (nonatomic)NSInteger              curPageOfOfflineData;
@property(nonatomic, retain)NSMutableArray*        searchNewResultArray;
@property(nonatomic, retain)NSMutableArray*        searchResultArray;
@property(nonatomic)NSInteger               searchResultCount;
@property(nonatomic,retain)NSString* keyWords;
@property(nonatomic,assign)NSInteger searchType;
@property (retain, nonatomic) QandATableView *searchResultTable;
//
@property(nonatomic,retain)NSMutableArray* searchArray;
@property(nonatomic,retain)NSArray* searchID;
@property(nonatomic,retain)NSMutableArray* classIDArray;

@property (retain, nonatomic) IBOutlet UIButton *btnNewAskAnswer;
@property (retain, nonatomic) IBOutlet UIButton *btnAllAskAnswer;
@property (retain, nonatomic) IBOutlet UITableView *fastShowView;
@property (retain, nonatomic) IBOutlet UIScrollView *FocusView;
@property (retain, nonatomic) IBOutlet UIView *fastShowBgView;

- (IBAction)btnNewAskAnswerClicked:(id)sender;
- (IBAction)btnAllAskAnswerClicked:(id)sender;
//快捷菜单
-(void)initUI;
-(void)initNotification;
-(void)reloadTableData;
-(void)reloadDataSource:(BOOL)needDown;
- (void)hideFastMenu;
- (void)hideFastMemuAndKeyBoard;
- (void)fastShowBgViewClicked:(UITapGestureRecognizer*)recognizer;
@end
