//
//  BCMultiTabBar.m
//  SinaNews
//
//  Created by shieh exbice on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BCMultiTabBar.h"
#import "BCTabBar.h"

@interface BCMultiTabBar ()

-(void)setRow:(NSInteger)row enabled:(BOOL)bEabled;

@end

@implementation BCMultiTabBar

@synthesize multiCount = _multiCount;
@synthesize tabBarArray = _tabBarArray;
@synthesize arrowImage,showedMaxItem,selectedAlignment,barBackgroundImage,selectedImage,leftArrowImage,rightArrowImage,barBackgroundColor,delegate,selectedMovement;
@synthesize arrowCoverScroll;

- (id)initWithFrame:(CGRect)frame heights:(NSArray*)heightArray
{
    self = [super initWithFrame:frame];
    if (self) {
        _tabBarArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        int startY = 0;
        _multiCount = [heightArray count];
        for (NSNumber* oneHeight in heightArray) {
            if (oneHeight) {
                float height = [oneHeight intValue];
                CGRect aRect = CGRectMake(0, startY, frame.size.width, height);
                BCTabBar* aTabBar = [[BCTabBar alloc] initWithFrame:aRect];
                aTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                aTabBar.delegate = self;
                [_tabBarArray addObject:aTabBar];
                [self addSubview:aTabBar];
                [self sendSubviewToBack:aTabBar];
                [aTabBar release];
                startY += height;
            }
        }
    }
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.00001];
    return self;
}

-(void)setShowedMaxItem:(NSInteger)aShowedMaxItem
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.showedMaxItem = aShowedMaxItem;
    }
}

-(void)setSelectedImage:(UIImage *)aSelectedImage
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.selectedImage = aSelectedImage;
    }
}

-(void)setSelectedAlignment:(NSInteger)aSelectedAlignment
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.selectedAlignment = aSelectedAlignment;
    }
}

-(void)setArrowImage:(UIImage *)aArrowImage
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.arrowImage = aArrowImage;
    }
}

-(void)setBarBackgroundColor:(UIColor *)aBarBackgroundColor
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.backgroundColor = aBarBackgroundColor;
    }
}

-(void)setBarBackgroundImage:(UIImage *)aBarBackgroundImage
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.backgroundImage = aBarBackgroundImage;
    }
}

-(void)setLeftArrowImage:(UIImage *)aLeftArrowImage
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.leftArrowImage = aLeftArrowImage;
    }
}

-(void)setRightArrowImage:(UIImage *)aRightArrowImage
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.rightArrowImage = aRightArrowImage;
    }
}

-(void)setSelectedMovement:(NSInteger)aSelectedMovement
{
    selectedMovement = aSelectedMovement;
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.selectedMovement = aSelectedMovement;
    }
}

-(void)setArrowCoverScroll:(BOOL)aArrowCoverScroll
{
    for (BCTabBar* oneTabBar in _tabBarArray) {
        oneTabBar.arrowCoverScroll = aArrowCoverScroll;
    }
}

-(void)dealloc
{
    [_tabBarArray release];
    
    [super dealloc];
}

-(void)reloadData
{
    [self reloadDataForRow:0];
}

-(void)reloadDataForRow:(NSInteger)row
{
    if (row<=_multiCount) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadDataForSingleRow:) object:[NSNumber numberWithInt:row]];
        if (row<_multiCount) {
            //[self performSelector:@selector(reloadDataForSingleRow:) withObject:[NSNumber numberWithInt:row] afterDelay:0.01];
            [self performSelector:@selector(reloadDataForSingleRow:) withObject:[NSNumber numberWithInt:row]];
        }
        else
        {
            [self performSelector:@selector(reloadDataForSingleRow:)  withObject:[NSNumber numberWithInt:row]];
        }
    }
    
}

-(void)reloadNilDataForSingleRow:(NSNumber*)rowNumber
{
    int row = [rowNumber intValue];
    if (row <_multiCount) {
        BCTabBar* oneTabBar = [_tabBarArray objectAtIndex:row];
        [oneTabBar setTabs:nil];
        [self setRow:row enabled:YES];
        [self reloadNilDataForSingleRow:[NSNumber numberWithInt:row+1]];
    }
    else
    {
        if (_multiCount>0) {
            if([self.delegate respondsToSelector:@selector(multiTabBar:didSelectTabAtIndex:)])
            {
                NSIndexPath* index = [NSIndexPath indexPathForRow:row-1 inSection:-1];
                [self.delegate multiTabBar:self didSelectTabAtIndex:index];
            }
        }
    }
}

-(void)reloadDataForSingleRow:(NSNumber*)rowNumber
{
    int row = [rowNumber intValue];
    if (row <_multiCount) {
        NSInteger section = 0;
        if (row>0) {
            section = [(BCTabBar*)[_tabBarArray objectAtIndex:row-1] selectedColumn];
        }
        NSIndexPath* index = [NSIndexPath indexPathForRow:row inSection:section];
        NSArray* tabs = [self.delegate multiTabBar:self tabsForIndex:index];
        BCTabBar* oneTabBar = [_tabBarArray objectAtIndex:row];
        [oneTabBar setTabs:nil];
        [oneTabBar setTabs:tabs];
        [self setRow:row enabled:YES];
        if (!tabs||[tabs count]==0) {
            [self reloadNilDataForSingleRow:[NSNumber numberWithInt:row+1]];
        }
    }
    else
    {
        if (_multiCount>0) {
            if([self.delegate respondsToSelector:@selector(multiTabBar:didSelectTabAtIndex:)])
            {
                int section = [(BCTabBar*)[_tabBarArray lastObject] selectedColumn];
                NSIndexPath* index = [NSIndexPath indexPathForRow:row-1 inSection:section];
                [self.delegate multiTabBar:self didSelectTabAtIndex:index];
            }
        }
    }
}

-(void)setRow:(NSInteger)row enabled:(BOOL)bEabled
{
    if (row<[self.tabBarArray count]) {
        BCTabBar* oneBar = [self.tabBarArray objectAtIndex:row];
        if (bEabled) {
            oneBar.userInteractionEnabled = YES;
        }
        else
            oneBar.userInteractionEnabled = NO;
    }
}

-(NSInteger)curRowForTabBar:(BCTabBar*)aTabBar
{
    return [self.tabBarArray indexOfObject:aTabBar];
}

- (void)tabBar:(BCTabBar *)aTabBar didSelectTabAtIndex:(NSInteger)index
{
    if(aTabBar.selectedMovement==MovementStyle_Free)
    {
        NSInteger row = [self curRowForTabBar:aTabBar];
        [self reloadDataForRow:row+1];
    }
}

-(void)tabBar:(BCTabBar *)aTabBar didCoverArrowHideChanged:(BOOL)bHided
{
    NSInteger row = [self curRowForTabBar:aTabBar];
    if (!bHided) {
        if ((aTabBar.oldSelectedTab!=aTabBar.selectedTab||aTabBar.oldSelectedTab==nil)) {
            aTabBar.oldSelectedTab = aTabBar.selectedTab;
            [self reloadDataForRow:row+1];
        }
        else
        {
            [self setRow:row+1 enabled:YES];
        }
    }
    else
    {
        for (int i=row; i<_multiCount; i++) {
            [self setRow:row+1 enabled:NO];
        }
    }
}
-(void)tabBar:(BCTabBar *)aTabBar didcoverimageAppear:(float)offset
{
    [self.delegate multiTabBar:self coverimageAppear:offset];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
