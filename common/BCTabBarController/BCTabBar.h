#import "BCTab.h"

@class BCTab;

@protocol BCTabBarDelegate;

@interface TabBarPreLoadData : NSObject
{
    NSInteger selectedIndex; 
    CGPoint contentOffset;
};
@property(assign) NSInteger selectedIndex; 
@property(assign) CGPoint contentOffset;
@end

enum AlignmentStyle
{
    AlignmentStyle_Top,
    AlignmentStyle_Center,
    AlignmentStyle_Bottom
};

enum MovementStyle
{
    MovementStyle_Free,
    MovementStyle_FixLeft,
    MovementStyle_FixCenter,
    MovementStyle_FixRight
};

@interface BCTabBar : UIView
{
    UIImage* forceImage;
    NSArray* coverArrowImageArray;
    UIImage* arrowImage;
    UIImage *backgroundImage;
    UIImage *selectedImage;
    UIImage *leftArrowImage;
    UIImage *rightArrowImage;
    NSInteger showedMaxItem;
@private
    BCTab *selectedTab;
    BCTab *oldSelectedTab;
    UIImageView *forceView;
    UIImageView *arrowView;
    UIImageView *coverArrowView;
    UILabel* coverArrowLabel;
    UIScrollView* scrollView;
    UIView* limitView;
    UIButton *leftArrow;
    UIButton *rightArrow;
    NSInteger selectedAlignment;
    NSInteger selectedMovement;
    BOOL coverArrowUseText;
    float eachTabWidth;
    float maxTabWidth;
    BOOL arrowCoverScroll;
    BOOL ArrowBackScrollAnimate;
    int animateScrollCount;
    BOOL bScrolling;
    BOOL bDecelerating;
    NSInteger mTabMargin;
}

- (id)initWithFrame:(CGRect)aFrame;
- (void)setSelectedTab:(BCTab *)aTab animated:(BOOL)animated;
-(void)setTabs:(NSArray *)tabs maxItem:(NSInteger)maxItemInt;

@property (nonatomic, assign) NSInteger tabMargin;
@property (nonatomic, assign) NSInteger leftRightArrowWidth;
@property (nonatomic, retain) NSArray *tabs;
@property (nonatomic, retain) BCTab *selectedTab;
@property (nonatomic, assign) BCTab *oldSelectedTab;
@property (nonatomic, assign) id <BCTabBarDelegate> delegate;
@property (nonatomic, retain) UIImageView *forceView;
@property (nonatomic, retain) UIImageView *arrowView;
@property (nonatomic, retain) UIImageView *coverArrowView;
@property (nonatomic, retain) UIImage *forceImage;
@property (nonatomic, retain) UIImage *arrowImage;
@property (nonatomic, retain) NSArray *coverArrowImageArray;
@property (nonatomic, assign) NSInteger showedMaxItem;
@property (nonatomic, assign) NSInteger selectedAlignment;
@property (nonatomic, assign) NSInteger selectedMovement;
@property (nonatomic, assign) BOOL coverArrowUseText;
@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *leftArrowImage;
@property (nonatomic, retain) UIImage *rightArrowImage;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIButton *leftArrow;
@property (nonatomic, retain) UIButton *rightArrow;
@property (nonatomic, assign) float maxTabWidth;
@property (nonatomic, assign) BOOL arrowCoverScroll;
@property (nonatomic, assign) BOOL ArrowBackScrollAnimate;
@property (nonatomic, assign) CGPoint scrollPos;
@property (nonatomic, retain) TabBarPreLoadData* preData;

+(CGPoint)convertPoint:(CGPoint)aPoint fromSubView:(UIView *)view parentView:(UIView *)view;
+(CGPoint)convertPoint:(CGPoint)aPoint toSubView:(UIView *)subview parentView:(UIView *)view;
-(void)rightArrowClicked:(UIButton*)sender;
-(void)leftArrowClicked:(UIButton*)sender;
-(NSInteger)selectedColumn;
-(void)setSelectedColumn:(NSInteger)index;
-(void)setSelectedColumnWithReload:(NSInteger)index;
-(void)reloadPreData;

@end

@protocol BCTabBarDelegate <NSObject>
- (void)tabBar:(BCTabBar *)aTabBar didSelectTabAtIndex:(NSInteger)index;
-(void)tabBar:(BCTabBar *)aTabBar didCoverArrowHideChanged:(BOOL)bHided;
-(void)tabBar:(BCTabBar *)aTabBar didcoverimageAppear:(float)offset;
@end