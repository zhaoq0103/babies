#import "BCTabBar.h"
#import "BCTab.h"


#define kTabMargin 2.0
#define kLeftRightArrowWidth 15

@implementation TabBarPreLoadData

@synthesize selectedIndex,contentOffset;

@end

@interface BCTabBar ()

- (void)positionArrowAnimated:(BOOL)animated;
-(void)layOutScrollView;
-(void)updateLeftRightArrowEnable;
-(BCTab*)findTabWithPos:(CGPoint)offsetPos;
-(BCTab*)findNextTab:(BCTab*)aTab;
-(BCTab*)findPrefTab:(BCTab*)aTab;
- (void)tabSelected:(BCTab *)sender;
-(void)myLayout;
-(void)changeCoverArrowHidenStatus:(BOOL)bHiden;
-(void)updateCoverArrowImage;
@end

@implementation BCTabBar
@synthesize tabMargin=mTabMargin,leftRightArrowWidth,tabs, selectedTab,oldSelectedTab, backgroundImage, arrowView,coverArrowView,arrowImage,coverArrowImageArray,delegate,selectedImage,scrollView;
@synthesize leftArrow,rightArrow,leftArrowImage,rightArrowImage,selectedAlignment,selectedMovement,coverArrowUseText,showedMaxItem,maxTabWidth,arrowCoverScroll,ArrowBackScrollAnimate;
@synthesize forceView,forceImage;
@dynamic scrollPos;
@synthesize preData;

- (id)initWithFrame:(CGRect)aFrame {

	if (self = [super initWithFrame:aFrame]) {
        self.backgroundColor = [UIColor clearColor];
        selectedAlignment = AlignmentStyle_Center;
        selectedMovement = MovementStyle_Free;
        arrowCoverScroll = YES;
        ArrowBackScrollAnimate = YES;
        maxTabWidth = 999999.0;
        animateScrollCount = 0;
       bScrolling = NO;
       bDecelerating = NO;
       coverArrowUseText = NO;
       mTabMargin = kTabMargin;
        CGRect boundsRect = CGRectMake(0, 0, aFrame.size.width, aFrame.size.height);
       limitView = [[UIView alloc] initWithFrame:boundsRect];
       limitView.backgroundColor = [UIColor clearColor];
       limitView.userInteractionEnabled = YES;
       limitView.clipsToBounds = YES;
       [self addSubview:limitView];
       [limitView release];
        UIView* scrollBackView = [[UIView alloc] initWithFrame:boundsRect];
        scrollBackView.backgroundColor = [UIColor clearColor];
        scrollBackView.clipsToBounds = NO;
        [limitView addSubview:scrollBackView];
        scrollView = [[UIScrollView alloc] initWithFrame:boundsRect];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delegate = (id<UIScrollViewDelegate>)self;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        [scrollBackView addSubview:scrollView];
        CGRect leftRect = CGRectMake(0, 0, 20, boundsRect.size.height);
        leftArrow = [[UIButton alloc] initWithFrame:leftRect];
        [leftArrow setImage:leftArrowImage forState:UIControlStateNormal];
        [self addSubview:leftArrow];
        [leftArrow addTarget:self action:@selector(leftArrowClicked:) forControlEvents:UIControlEventTouchUpInside];
        leftArrow.hidden = YES;
        [leftArrow release];
        CGRect rightRect = CGRectMake(boundsRect.size.width - 20, 0, 20, boundsRect.size.height);
        rightArrow = [[UIButton alloc] initWithFrame:rightRect];
        [rightArrow setImage:rightArrowImage forState:UIControlStateNormal];
        [self addSubview:rightArrow];
        [rightArrow addTarget:self action:@selector(rightArrowClicked:) forControlEvents:UIControlEventTouchUpInside];
        rightArrow.hidden = YES;
        [rightArrow release];
		arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrowView.clipsToBounds = NO;
        scrollView.clipsToBounds = NO;
        self.clipsToBounds = NO;
		[scrollView addSubview:arrowView];
        [arrowView release];
        [scrollView release];
       forceView = [[UIImageView alloc] initWithFrame:CGRectZero];
       [scrollBackView addSubview:forceView];
       [forceView release];
        coverArrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
       coverArrowView.image = nil;
        arrowView.clipsToBounds = NO;
        [scrollBackView addSubview:coverArrowView];
        [coverArrowView release];
        [scrollBackView release];
		self.userInteractionEnabled = YES;
        showedMaxItem = 5;
       leftRightArrowWidth = 0;
        
	}
	
	return self;
}

-(void)setLeftArrowImage:(UIImage *)aLeftArrowImage
{
    if (leftArrowImage!=aLeftArrowImage) {
        [leftArrowImage release];
        leftArrowImage = aLeftArrowImage;
        [leftArrowImage retain];
        [leftArrow setImage:leftArrowImage forState:UIControlStateNormal];
        if (!aLeftArrowImage) {
            leftRightArrowWidth = 0;
        }
        else
        {
            leftRightArrowWidth = kLeftRightArrowWidth;
        }
    }
}

-(void)setRightArrowImage:(UIImage *)aRightArrowImage
{
    if (rightArrowImage!=aRightArrowImage) {
        [rightArrowImage release];
        rightArrowImage = aRightArrowImage;
        [rightArrowImage retain];
        [rightArrow setImage:rightArrowImage forState:UIControlStateNormal];
        if (!aRightArrowImage) {
            leftRightArrowWidth = 0;
        }
        else
        {
            leftRightArrowWidth = kLeftRightArrowWidth;
        }
    }
}

-(void)setBackgroundImage:(UIImage *)aBackgroundImage
{
    if (backgroundImage) {
        UIImage* oldImage = backgroundImage;
        backgroundImage = aBackgroundImage;
        [backgroundImage retain];
        [oldImage release];
    }
    else
    {
        backgroundImage = aBackgroundImage;
        [backgroundImage retain];
    }
}

-(void)setArrowImage:(UIImage *)newArrowImage
{
    if (arrowImage) {
        UIImage* oldImage = arrowImage;
        arrowImage = newArrowImage;
        [arrowImage retain];
        [oldImage release];
    }
    else
    {
        arrowImage = newArrowImage;
        [arrowImage retain];
    }
    self.arrowView.image = arrowImage;
}

-(void)setCoverArrowImageArray:(NSArray *)aCoverArrowImageArray
{
    if (coverArrowImageArray) {
        NSArray* oldArray = aCoverArrowImageArray;
        coverArrowImageArray = aCoverArrowImageArray;
        [coverArrowImageArray retain];
        [oldArray release];
    }
    else
    {
        coverArrowImageArray = aCoverArrowImageArray;
        [coverArrowImageArray retain];
    }
    self.coverArrowView.image = nil;
}

-(void)setForceImage:(UIImage *)aForceImage
{
    if (forceImage) {
        UIImage* oldImage = forceImage;
        forceImage = aForceImage;
        [forceImage retain];
        [oldImage release];
    }
    else
    {
        forceImage = aForceImage;
        [forceImage retain];
    }
    self.forceView.image = forceImage;
    //[self layOutScrollView];
}

-(void)setSelectedImage:(UIImage *)aSelectedImage
{
    if (selectedImage) {
        UIImage* oldImage = selectedImage;
        selectedImage = aSelectedImage;
        [selectedImage retain];
        [oldImage release];
    }
    else
    {
        selectedImage = aSelectedImage;
        [selectedImage retain];
    }
    
    if (tabs) {
        for (BCTab *tab in tabs) {
            tab.forceImageView.highlightedImage = selectedImage;
        }
        [self layOutScrollView];
    }
}

-(void)dealloc
{
    [tabs release];
    [selectedTab release];
    [arrowView release];
    [arrowImage release];
    [backgroundImage release];
    [selectedImage release];
    [scrollView release];
    [leftArrow release];
    [rightArrow release];
    [leftArrowImage release];
    [rightArrowImage release];
    [preData release];
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self.backgroundImage drawInRect:rect];
}

-(void)setShowedMaxItem:(NSInteger)aShowedMaxItem
{
    showedMaxItem = aShowedMaxItem;
    if (tabs) {
        [self layOutScrollView];
    }
}

-(void)setSelectedMovement:(NSInteger)aSelectedMovement
{
    selectedMovement = aSelectedMovement;
    if (tabs) {
        [self layOutScrollView];
    }
}

-(void)setMaxTabWidth:(float)aMaxTabWidth
{
    maxTabWidth = aMaxTabWidth;
    if (tabs) {
        [self layOutScrollView];
    }
}

-(void)setArrowCoverScroll:(BOOL)bArrowCoverScroll
{
    arrowCoverScroll = bArrowCoverScroll;
    if (tabs) {
        [self layOutScrollView];
    }
}

-(void)setSelectedAlignment:(NSInteger)aSelectedAlignment
{
    selectedAlignment = aSelectedAlignment;
    if (tabs) {
        [self layOutScrollView];
    }
}

-(void)setTabs:(NSArray *)tabArray maxItem:(NSInteger)maxItemInt
{
    showedMaxItem = maxItemInt;
    if (tabArray) {
        [self setTabs:tabArray];
    }
}

- (void)setTabs:(NSArray *)array {
    if (tabs != array) {
        for (BCTab *tab in tabs) {
            [tab removeFromSuperview];
        }
        if ([array count]>0) {
            NSArray* oldTabs = tabs;
            tabs = [array retain];    
            [oldTabs release];
            
            for (BCTab *tab in tabs) {
                tab.forceImageView.highlightedImage = selectedImage;
                tab.userInteractionEnabled = YES;
                [tab addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchDown];
            }
            oldSelectedTab = nil;
            if (self.preData) {
                CGPoint newContentPos = self.preData.contentOffset;
                NSInteger newSelectedIndex = self.preData.selectedIndex;
                self.preData = nil;
                [self setSelectedColumn:newSelectedIndex];
                [self layOutScrollView];
                self.scrollPos = newContentPos;
            }
            else
            {
                [self setSelectedTab:[tabs objectAtIndex:0] animated:NO];
                
                [self layOutScrollView];
            }
            
        }
        else
        {
            oldSelectedTab = nil;
            [self setSelectedTab:nil animated:NO];
            [tabs release];
            tabs = nil;
            [self layOutScrollView];
        }
        
    }
}

- (void)setSelectedTab:(BCTab *)aTab animated:(BOOL)animated {
	if (aTab != selectedTab) {
        BCTab *oldTab = selectedTab;
		selectedTab = [aTab retain];
        [oldTab release];
		selectedTab.selected = YES;
		
		for (BCTab *tab in tabs) {
			if (tab == aTab) continue;
			
			tab.selected = NO;
		}
       [self updateCoverArrowImage];
	}
	
	[self positionArrowAnimated:animated];	
}

- (void)setSelectedTab:(BCTab *)aTab {
	[self setSelectedTab:aTab animated:YES];
}

- (void)tabSelected:(BCTab *)sender {
    
    if ([self.tabs count]>0) {
//        BOOL bSelectedSameTab = self.selectedTab==sender?YES:NO;
        [self setSelectedTab:sender animated:YES];
        
//        if(!bSelectedSameTab&&[self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)])
        if([self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)])
        {
            [self.delegate tabBar:self didSelectTabAtIndex:[self.tabs indexOfObject:sender]];
        }
    }
}

-(void)setScrollPos:(CGPoint)pos
{
    if (scrollView) {
        if (scrollView.contentSize.width>pos.x&&scrollView.contentSize.height>pos.y) {
            [scrollView setContentOffset:pos animated:NO];
        }
    }
}

-(CGPoint)scrollPos
{
    CGPoint rtval = CGPointZero;
    if (scrollView) {
        rtval = scrollView.contentOffset;
    }
    return rtval;
}

-(void)setPreData:(TabBarPreLoadData *)aPreData
{
    if (preData!=aPreData) {
        TabBarPreLoadData* oldData = preData;
        preData = aPreData;
        [preData retain];
        [oldData release];
    }
}

-(void)reloadPreData
{
    if (self.preData&&self.tabs&&[self.tabs count]>0) {
        CGPoint newContentPos = self.preData.contentOffset;
        NSInteger newSelectedIndex = self.preData.selectedIndex;
        CGPoint oldCOntentPos = self.scrollPos;
        NSInteger oldSelectedIndex = self.selectedColumn;
        self.preData = nil;
        if (!CGPointEqualToPoint(oldCOntentPos, newContentPos)) {
            self.scrollPos = newContentPos;
        }
        if (oldSelectedIndex!=newSelectedIndex) {
            [self setSelectedColumnWithReload:newSelectedIndex];
        }
    }
    
}

+(CGPoint)convertPoint:(CGPoint)aPoint fromSubView:(UIView *)subview parentView:(UIView *)view
{
    CGPoint rtval = aPoint;
    rtval.x = subview.frame.origin.x + aPoint.x;
    rtval.y = subview.frame.origin.y + aPoint.y;
    return rtval;
}

+(CGPoint)convertPoint:(CGPoint)aPoint toSubView:(UIView *)subview parentView:(UIView *)view
{
    CGPoint rtval = aPoint;
    rtval.x = aPoint.x - subview.frame.origin.x;
    rtval.y = aPoint.y - subview.frame.origin.y;
    return rtval;
}

-(NSInteger)selectedColumn
{
    NSInteger rtval = -1;
    for (int i=0; i<[tabs count]; i++) {
        BCTab* oneTab = [tabs objectAtIndex:i];
        if (self.selectedTab==oneTab) {
            rtval = i;
            break;
        }
    }
    return rtval;
}

-(void)setSelectedColumn:(NSInteger)index
{
    if ([self.tabs count]>index) {
        BCTab* tab = [self.tabs objectAtIndex:index];
        self.selectedTab = tab;
    }
}

-(void)setSelectedColumnWithReload:(NSInteger)index
{
    if ([self.tabs count]>index) {
        BCTab* tab = [self.tabs objectAtIndex:index];
        BOOL bSelectedSameTab = self.selectedTab==tab?YES:NO;
        [self setSelectedTab:tab animated:YES];
        
        if(!bSelectedSameTab&&[self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)])
        //if([self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)])
        {
            [self.delegate tabBar:self didSelectTabAtIndex:[self.tabs indexOfObject:tab]];
        }
    }
}

-(void)layOutScrollView
{
    if (self.tabs) {
        CGRect f = self.bounds;
        float scrollViewWidth = 0;
        int tempMaxCount = self.tabs.count>showedMaxItem ? showedMaxItem : self.tabs.count;
        if (arrowCoverScroll) {
            scrollViewWidth = f.size.width;
            f.size.width = (f.size.width)/ tempMaxCount;
        }
        else
        {
            if(self.tabs.count>showedMaxItem||(selectedMovement!=MovementStyle_Free&&[self.tabs count]>1))
            {
                scrollViewWidth = f.size.width - 2*leftRightArrowWidth;
                f.size.width = (f.size.width - 2*leftRightArrowWidth)/ tempMaxCount;
            }
            else
            {
                scrollViewWidth = f.size.width;
                f.size.width = (f.size.width)/ tempMaxCount;
            }
        }
        f.size.width -= (mTabMargin * (tempMaxCount + 1)) / tempMaxCount;
        f.size.width = floorf((f.size.width > maxTabWidth) ? maxTabWidth : f.size.width);
        eachTabWidth = f.size.width;
        
//        int normalWidthCount = self.tabs.count;
        float maxTabHeight = f.size.height;
        float extraWidthTotal = 0;
        for (int i=0;i<[self.tabs count];i++) {
            BCTab *tab = [self.tabs objectAtIndex:i];
            f.origin.x += mTabMargin;
            CGSize oneTabSize = [tab sizeThatFits:f.size];
            maxTabHeight = maxTabHeight<oneTabSize.height ? oneTabSize.height : maxTabHeight;
            float useWidth = oneTabSize.width < f.size.width ? f.size.width : oneTabSize.width;
            int extraHeaderWidth = 0;
            if (i==0) {
                if (selectedMovement==MovementStyle_FixCenter) {
                    extraHeaderWidth = scrollViewWidth/2 - (useWidth/2+mTabMargin);
                }
                else if (selectedMovement==MovementStyle_FixLeft) {
                    ;
                }
                else if (selectedMovement==MovementStyle_FixRight) {
                    extraHeaderWidth = scrollViewWidth - (useWidth+mTabMargin*2);
                }
                f.origin.x += extraHeaderWidth;
            }
            if (i==[self.tabs count]-1) {
                if (selectedMovement==MovementStyle_FixCenter) {
                    extraHeaderWidth = scrollViewWidth/2 - (useWidth/2+mTabMargin);
                }
                else if (selectedMovement==MovementStyle_FixLeft) {
                    extraHeaderWidth = scrollViewWidth - (useWidth+mTabMargin*2);
                }
                else if (selectedMovement==MovementStyle_FixRight) {
                    ;
                }
            }
            CGRect tabRect = CGRectMake(floorf(f.origin.x), f.origin.y, floorf(useWidth), f.size.height);
            tab.frame = tabRect;
            
            f.origin.x += useWidth;
            [scrollView addSubview:tab];
            extraWidthTotal += extraHeaderWidth + useWidth + mTabMargin;
        }
        int totalLength = extraWidthTotal +mTabMargin;
        scrollView.contentSize = CGSizeMake(totalLength, f.size.height);
        UIImage* aRrrowImage = arrowView.image;
        CGRect arrowFrame = CGRectZero;
        arrowView.hidden = NO;
        if (YES) {
            if (aRrrowImage) {
                arrowFrame = arrowView.frame;
            }
            else
            {
                arrowFrame.size = CGSizeMake(1, 1);
            }
            CGRect selectedFrame = CGRectZero;
            if (self.selectedTab) {
                selectedFrame = self.selectedTab.frame;
            }
            else
            {
                selectedFrame = [(BCTab*)[self.tabs objectAtIndex:0] frame];
            }
            
            arrowFrame.size = aRrrowImage.size;
            if (selectedAlignment==AlignmentStyle_Center) {
                arrowFrame.origin.y = ((f.size.height / 2) - (arrowFrame.size.height / 2));
            }
            else if(selectedAlignment==AlignmentStyle_Top)
            {
                arrowFrame.origin.y = 0;
            }
            else
            {
                arrowFrame.origin.y = f.size.height - arrowFrame.size.height;
            }
            arrowFrame.origin.x = selectedFrame.origin.x + ((f.size.width / 2) - (arrowFrame.size.width / 2));
            arrowView.frame = arrowFrame;
            [scrollView sendSubviewToBack:arrowView];
        }
        
        [self changeCoverArrowHidenStatus:NO];
        [self updateCoverArrowImage];
        UIImage* aCoverRrrowImage = coverArrowView.image;
        CGRect coverArrowFrame = CGRectZero;
        
        if (YES) 
        {
            if (aCoverRrrowImage) {
                coverArrowFrame = coverArrowView.frame;
            }
            else
            {
                coverArrowFrame.size = CGSizeMake(1, 1);
            }
            
            CGRect selectedFrame = CGRectZero;
            if (self.selectedTab) {
                selectedFrame = self.selectedTab.frame;
            }
            else
            {
                selectedFrame = [(BCTab*)[self.tabs objectAtIndex:0] frame];
            }
            if (aCoverRrrowImage) {
                coverArrowFrame.size = aCoverRrrowImage.size;
            }
            else
            {
                coverArrowFrame.size = CGSizeZero;
            }
            
            if (selectedAlignment==AlignmentStyle_Center) {
                coverArrowFrame.origin.y = ((f.size.height / 2) - (coverArrowFrame.size.height / 2));
            }
            else if(selectedAlignment==AlignmentStyle_Top)
            {
                coverArrowFrame.origin.y = 0;
            }
            else
            {
                coverArrowFrame.origin.y = f.size.height - coverArrowFrame.size.height;
            }
            
            if(selectedMovement==MovementStyle_FixLeft)
            {
                coverArrowFrame.origin.x = mTabMargin + selectedFrame.size.width/2 - coverArrowFrame.size.width/2;
            }
            else if(selectedMovement==MovementStyle_FixRight)
            {
                coverArrowFrame.origin.x = scrollViewWidth - (mTabMargin + selectedFrame.size.width/2) - coverArrowFrame.size.width/2;
            }
            else if(selectedMovement==MovementStyle_FixCenter)
            {
                coverArrowFrame.origin.x = scrollView.frame.size.width/2 - coverArrowFrame.size.width/2;
            }
        }
        CGRect useMaxRect = (arrowFrame.size.height>coverArrowView.frame.size.height) ? arrowFrame:coverArrowFrame;
        float arrowHeight = useMaxRect.size.height;
        CGRect limitFrame = limitView.frame;
        if (maxTabHeight>arrowHeight) {
            CGRect maxTabRect = CGRectMake(0, self.bounds.size.height - maxTabHeight, eachTabWidth, maxTabHeight);
            limitFrame.origin.y = maxTabRect.origin.y<useMaxRect.origin.y ? maxTabRect.origin.y : arrowFrame.origin.y;
            int bottomY = (maxTabRect.origin.y+maxTabRect.size.height) < (useMaxRect.origin.y+arrowHeight) ? (useMaxRect.origin.y+arrowHeight) : (maxTabRect.origin.y+maxTabRect.size.height);
            limitFrame.size.height = bottomY - limitFrame.origin.y;
        }
        else
        {
            limitFrame.size.height = useMaxRect.size.height;
            limitFrame.origin.y = useMaxRect.origin.y;
        }
        limitView.frame = limitFrame;
        CGRect scrollBackFrame = scrollView.superview.frame;
        scrollBackFrame.size.height = limitFrame.size.height;
        scrollBackFrame.origin.y = 0;
        scrollView.superview.frame = scrollBackFrame;
        
        coverArrowFrame.origin = [BCTabBar convertPoint:coverArrowFrame.origin fromSubView:scrollView parentView:nil];
        if(CGRectIsEmpty(coverArrowFrame)||CGRectIsInfinite(coverArrowFrame))
        {
            coverArrowFrame = CGRectZero;
        }
        coverArrowView.frame = coverArrowFrame;
        
        if(self.tabs.count>showedMaxItem||(selectedMovement!=MovementStyle_Free&&[self.tabs count]>1))
        {
            leftArrow.hidden = NO;
            rightArrow.hidden = NO;
            [self updateLeftRightArrowEnable];
        }
        else
        {
            leftArrow.hidden = YES;
            rightArrow.hidden = YES;
        }
        scrollView.hidden = NO;
        [self positionArrowAnimated:NO];
    }
    else
    {
        scrollView.hidden = YES;
        arrowView.hidden = YES;
        leftArrow.hidden = YES;
        rightArrow.hidden = YES;
        [self changeCoverArrowHidenStatus:YES];
    }
    //[self setNeedsLayout];
    [self myLayout];
}

-(void)updateLeftRightArrowEnable
{
    if (self.tabs) {
        int RectX = scrollView.contentOffset.x;
        RectX = RectX >0 ? RectX : 0;
        if (RectX==0) {
            leftArrow.enabled = NO; 
        }
        else
        {
            leftArrow.enabled = YES; 
        }
        RectX = scrollView.contentOffset.x;
        int scrollWidth = scrollView.frame.size.width;
        BOOL hasToEnd = RectX+scrollWidth >=scrollView.contentSize.width;
        if (!hasToEnd) {
            rightArrow.enabled = YES;
        }
        else
        {
            rightArrow.enabled = NO;
        }
    }
    else
    {
        rightArrow.enabled = NO;
        leftArrow.enabled = NO; 
    }
}

-(BOOL)adjustScrollViewContentOffset
{
    BOOL rtval = NO;
    if (self.tabs) {
        if (selectedMovement!=MovementStyle_Free) {
            CGRect scrollRect = scrollView.frame;
            int arrowX = 0;
            if (selectedMovement==MovementStyle_FixLeft)
            {
                arrowX = mTabMargin;;
            }
            else if (selectedMovement==MovementStyle_FixRight)
            {
                arrowX = scrollRect.size.width - mTabMargin;
            }
            else 
            {
                arrowX = scrollRect.size.width/2;
            }
            CGPoint arrowCenter = CGPointMake(arrowX, scrollRect.origin.y + scrollRect.size.height/2);
            arrowCenter.x = arrowCenter.x + scrollView.contentOffset.x;
            BCTab* findTab = [self findTabWithPos:arrowCenter];
            
            CGRect selectedFrame = findTab.frame;
            CGPoint movePoint = CGPointZero;
            if (selectedMovement==MovementStyle_FixLeft) {
                movePoint = scrollView.contentOffset;
                movePoint.x = floorf(selectedFrame.origin.x - mTabMargin);
            }
            else if(selectedMovement==MovementStyle_FixRight)
            {
                movePoint = scrollView.contentOffset;
                movePoint.x = floorf(selectedFrame.origin.x + mTabMargin + selectedFrame.size.width) - floorf(scrollRect.size.width);
            }
            else if(selectedMovement==MovementStyle_FixCenter)
            {
                movePoint = scrollView.contentOffset;
                movePoint.x += floorf(selectedFrame.origin.x + selectedFrame.size.width/2) - floorf(scrollView.contentOffset.x + scrollRect.size.width/2);
            }
            if (movePoint.x!=scrollView.contentOffset.x) 
            {
                if(self.selectedTab==findTab)
                {
                    [self positionArrowAnimated:YES];
                }
                rtval = YES;
            }
            if(self.selectedTab!=findTab)
            {
                [self tabSelected:findTab];
            }
        }
    }
    return rtval;
}

-(BCTab*)findTabWithPos:(CGPoint)offsetPos
{
    BCTab* rtval = nil;
    BCTab* firstTab = nil;
    BCTab* secondTab = nil;
    int tabCount = [tabs count];
    for (int i=0;i<=tabCount;i++) {
        firstTab = secondTab;
        if (i>=tabCount) {
            secondTab = nil;
        }
        else
        {
            secondTab = [tabs objectAtIndex:i];
        }
        if (firstTab!=nil&&secondTab!=nil) {
            CGRect firstRect = firstTab.frame;
            CGRect secondRect = secondTab.frame;
            if (secondRect.origin.x+secondRect.size.width<offsetPos.x) {
                continue;
            }
            else
            {
                NSInteger center = (secondRect.origin.x - (firstRect.origin.x+firstRect.size.width))/2 + firstRect.origin.x;
                if (center<offsetPos.x) {
                    rtval = secondTab;
                    break;
                }
                else
                {
                    rtval = firstTab;
                    break;
                }
            }
        }
        else if(secondTab!=nil)
        {
            CGRect secondRect = secondTab.frame;
            if (secondRect.origin.x+secondRect.size.width<offsetPos.x) {
                continue;
            }
            else
            {
                rtval = secondTab;
                break;
            }
        }
        else
        {
            rtval = firstTab;
            break;
        }
    }
    return rtval;
}

-(BCTab*)findPrefTab:(BCTab*)aTab
{
    BCTab* rtval = nil;
    BCTab* preTab = nil;
    for (int i=0;i<[self.tabs count];i++) {
        BCTab* oneTab = [self.tabs objectAtIndex:i];
        if (aTab==oneTab) {
            rtval = preTab;
            break;
        }
        preTab = oneTab;
    }
    return rtval;
}

-(BCTab*)findNextTab:(BCTab*)aTab
{
    BCTab* rtval = nil;
    BCTab* nextTab = nil;
    for (int i=[self.tabs count]-1;i>=0;i--) {
        BCTab* oneTab = [self.tabs objectAtIndex:i];
        if (aTab==oneTab) {
            rtval = nextTab;
            break;
        }
        nextTab = oneTab;
    }
    return rtval;
}

- (void)positionArrowAnimated:(BOOL)animated {
    if (arrowView.hidden==NO) {
        BOOL needAnimate = ArrowBackScrollAnimate ? animated : NO;
        if (needAnimate) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
        }
        CGRect f = self.arrowView.frame;
        if (self.selectedTab) {
            f.size.width = self.selectedTab.frame.size.width;
            f.origin.x = self.selectedTab.frame.origin.x + ((self.selectedTab.frame.size.width / 2) - (f.size.width / 2));
        }
        
        
        self.arrowView.frame = f;
        
        if (needAnimate) {
            [UIView commitAnimations];
        }
    }
    
	if (selectedMovement!=MovementStyle_Free)
    {
        CGPoint offsetPos = scrollView.contentOffset;
        CGRect scrollRect = scrollView.frame;
        CGRect selectedFrame = self.selectedTab.frame;
        CGPoint movePoint = CGPointZero;
        if (selectedMovement==MovementStyle_FixLeft) {
            movePoint = offsetPos;
            movePoint.x = floorf(selectedFrame.origin.x - mTabMargin);
            
        }
        else if(selectedMovement==MovementStyle_FixRight)
        {
            movePoint = offsetPos;
            movePoint.x = floorf(selectedFrame.origin.x + mTabMargin + selectedFrame.size.width) - floorf(scrollView.frame.size.width);
        }
        else
        {
            movePoint = offsetPos;
            movePoint.x += floorf(selectedFrame.origin.x + selectedFrame.size.width/2) - floorf(offsetPos.x + scrollRect.size.width/2);
        }
        if (!CGPointEqualToPoint(movePoint, offsetPos)) {
            if (animated) {
                [self changeCoverArrowHidenStatus:YES];
                animateScrollCount++;
            }
            [scrollView setContentOffset:movePoint animated:animated];
        }
    }
     
}

- (void)layoutSubviews {
    //[self myLayout];
    [self layOutScrollView];
}

-(void)myLayout
{
//    CGRect selectedRect = self.selectedTab.frame;
    CGRect scrollFrame = scrollView.superview.frame;
    if(self.tabs.count>showedMaxItem||(selectedMovement!=MovementStyle_Free&&[self.tabs count]>1))
    {
        scrollFrame.origin.x = leftRightArrowWidth;
        scrollFrame.size.width = self.bounds.size.width - leftRightArrowWidth*2;
    }
    else
    {
        scrollFrame.origin.x = 0;
        scrollFrame.size.width = self.bounds.size.width;
    }
    if (scrollFrame.size.height<self.bounds.size.height) {
        scrollFrame.size.height = self.bounds.size.height;
    }
    
    CGRect limitFrame = limitView.frame;
    limitFrame.origin.x = 0;
    limitFrame.size.width = self.bounds.size.width;
    if (limitFrame.size.height<self.bounds.size.height) {
        limitFrame.size.height = self.bounds.size.height;
        limitFrame.origin.y = 0; 
    }
    limitView.frame = limitFrame;
    
    if (coverArrowView.hidden==NO&&(arrowCoverScroll||selectedMovement==MovementStyle_FixCenter)) {
        CGRect coverRect = coverArrowView.frame;
        CGPoint coverArrowP = coverRect.origin;
        coverArrowP = [BCTabBar convertPoint:coverArrowP fromSubView:scrollView.superview parentView:nil];
        scrollView.superview.frame = scrollFrame;
        coverArrowP = [BCTabBar convertPoint:coverArrowP toSubView:scrollView.superview parentView:nil];
        coverRect.origin = coverArrowP;
        coverArrowView.frame = coverRect;
    }
    else
    {
        scrollView.superview.frame = scrollFrame;
    }
    
    if (arrowCoverScroll) {
        scrollView.superview.clipsToBounds = NO;
        scrollView.frame = CGRectMake(0-scrollFrame.origin.x, 0-limitFrame.origin.y, self.bounds.size.width, self.bounds.size.height);
    }
    else
    {
        scrollView.superview.clipsToBounds = YES;
        scrollView.frame = CGRectMake(0, 0-limitFrame.origin.y, scrollFrame.size.width, self.bounds.size.height);
    }
    forceView.frame = scrollView.frame;
    
    if (leftArrowImage) {
        CGRect leftRect = CGRectMake(0, 0, leftRightArrowWidth, self.bounds.size.height);
        leftArrow.frame = leftRect;
    }
    else
    {
        leftArrow.frame = CGRectZero;
    }
    if (rightArrowImage) {
        CGRect rightRect = CGRectMake(self.bounds.size.width - leftRightArrowWidth, 0, leftRightArrowWidth, self.bounds.size.height);
        rightArrow.frame = rightRect;
    }
    else
    {
        rightArrow.frame = CGRectZero;
    }
    
}

- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
    
}

-(void)leftArrowClicked:(UIButton*)sender
{
    CGPoint curPoint = scrollView.contentOffset;
    int RectX = 0;
    if (selectedMovement==MovementStyle_FixCenter) {
        curPoint.x += scrollView.frame.size.width/2;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findPrefTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = scrollView.contentOffset.x + floorf(prefTab.frame.origin.x + prefTab.frame.size.width/2) - floorf(scrollView.contentOffset.x + scrollView.frame.size.width/2);
    }
    else if (selectedMovement==MovementStyle_FixLeft) {
        curPoint.x += mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findPrefTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = floorf(prefTab.frame.origin.x - mTabMargin);
    }
    else if (selectedMovement==MovementStyle_FixRight) {
        curPoint.x =scrollView.contentOffset.x+scrollView.frame.size.width - mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findPrefTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = floorf(prefTab.frame.origin.x + mTabMargin + prefTab.frame.size.width) - floorf(scrollView.frame.size.width);
    }
    else
    {
        curPoint.x += mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findPrefTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = scrollView.contentOffset.x - (curPoint.x - prefTab.frame.origin.x + mTabMargin);
    }
    RectX = RectX >0 ? RectX : 0;
    if (RectX<scrollView.contentOffset.x) {
        CGPoint offsetPoint = CGPointMake(RectX, scrollView.contentOffset.y);
        [self changeCoverArrowHidenStatus:YES];
        animateScrollCount++;
        [scrollView setContentOffset:offsetPoint animated:YES];
    }
}

-(void)rightArrowClicked:(UIButton*)sender
{
    CGPoint curPoint = CGPointMake(scrollView.contentOffset.x+scrollView.frame.size.width, scrollView.contentOffset.y);
    int RectX = 0;
    if (selectedMovement==MovementStyle_FixCenter) {
        curPoint.x -= scrollView.frame.size.width/2;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findNextTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = scrollView.contentOffset.x + floorf(prefTab.frame.origin.x + prefTab.frame.size.width/2) - floorf(scrollView.contentOffset.x + scrollView.frame.size.width/2);
    }
    else if (selectedMovement==MovementStyle_FixLeft) {
        curPoint.x = scrollView.contentOffset.x + mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findNextTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = floorf(prefTab.frame.origin.x - mTabMargin);
    }
    else if (selectedMovement==MovementStyle_FixRight) {
        curPoint.x -= mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* prefTab = [self findNextTab:curTab];
        prefTab = prefTab==nil?curTab:prefTab;
        RectX = floorf(prefTab.frame.origin.x + mTabMargin + prefTab.frame.size.width) - floorf(scrollView.frame.size.width);
    }
    else
    {
        curPoint.x -= mTabMargin;
        BCTab* curTab = [self findTabWithPos:curPoint];
        BCTab* nextfTab = [self findNextTab:curTab];
        nextfTab = nextfTab==nil?curTab:nextfTab;
        RectX = scrollView.contentOffset.x + (nextfTab.frame.origin.x - curPoint.x + nextfTab.frame.size.width + mTabMargin);
    }
    
    RectX = RectX >scrollView.contentSize.width ? scrollView.contentSize.width : RectX;
    if (RectX>scrollView.contentOffset.x) {
        CGPoint offsetPoint = CGPointMake(RectX, scrollView.contentOffset.y);
        [self changeCoverArrowHidenStatus:YES];
        animateScrollCount++;
        [scrollView setContentOffset:offsetPoint animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    bDecelerating = NO;
    BOOL needAdjust = [self adjustScrollViewContentOffset];
    if (!needAdjust) {
        [self changeCoverArrowHidenStatus:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    bScrolling = NO;
    if (!decelerate) {
        BOOL needAdjust = [self adjustScrollViewContentOffset];
        if (!needAdjust) {
            [self changeCoverArrowHidenStatus:NO];
        }
    }
    else
    {
        bDecelerating = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sview
{
    [self updateLeftRightArrowEnable];
   // NSLog(@"qiao >> qiao >> qiao scroll offset = [%f]", self.selectedTab.frame.origin.x - scrollView.contentOffset.x);
    float offset =  self.selectedTab.frame.origin.x - sview.contentOffset.x;
    if([self.delegate respondsToSelector:@selector(tabBar:didcoverimageAppear:)])
    {
        [self.delegate tabBar:self didcoverimageAppear:offset];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    bDecelerating = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    bScrolling = YES;
    [self changeCoverArrowHidenStatus:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    animateScrollCount--;
    if (!bScrolling&&!bDecelerating) {
        BOOL needAdjust = [self adjustScrollViewContentOffset];
        if (!needAdjust) {
            if (animateScrollCount==0) {
                [self changeCoverArrowHidenStatus:NO];
            }
            /*
             BOOL movedToRightPos = NO;
             CGPoint offsetPos = scrollView.contentOffset;
             if (selectedMovement==MovementStyle_FixCenter) {
             offsetPos.x += scrollView.frame.size.width/2;
             }
             else if(selectedMovement==MovementStyle_FixLeft)
             {
             offsetPos.x += mTabMargin;
             }
             else if(selectedMovement==MovementStyle_FixRight)
             {
             offsetPos.x += scrollView.frame.size.width - mTabMargin;
             }
             BCTab* curTab = [self findTabWithPos:offsetPos];
             if (curTab==selectedTab) {
             movedToRightPos = YES;
             }
             if (movedToRightPos) {
             [self changeCoverArrowHidenStatus:NO];
             }
             */
        }
    }
    
}

-(void)updateCoverArrowImage
{
    if (coverArrowImageArray&&[coverArrowImageArray count]>0) {
        CGRect oldRect = coverArrowView.frame;
        CGSize oldSize = oldRect.size;
        UIImage* newImage = nil;
        if ([coverArrowImageArray count]>1) {
            int selectNum = 0;
            if (self.selectedTab) {
                selectNum = [self selectedColumn];
            }
            selectNum = selectNum<[coverArrowImageArray count]?selectNum:0;
            newImage = [coverArrowImageArray objectAtIndex:selectNum];
        }
        else if([coverArrowImageArray count]==1)
        {
            newImage = [coverArrowImageArray objectAtIndex:0];
        }
        if (newImage!=coverArrowView.image) {
            coverArrowView.image = newImage;
            CGSize newSize = coverArrowView.image.size;
            CGRect newRect = oldRect;
            newRect.size = newSize;

             if (selectedMovement==MovementStyle_FixCenter) {
             newRect.origin.x = oldRect.origin.x - (newSize.width - oldSize.width)/2;
             newRect.origin.y = oldRect.origin.y - (newSize.height - oldSize.height)/2;
             }
             else if(selectedMovement==MovementStyle_FixLeft)
             {
             newRect.origin.y = oldRect.origin.y - (newSize.height - oldSize.height)/2;
             }
             else if(selectedMovement==MovementStyle_FixRight)
             {
             newRect.origin.y = oldRect.origin.y - (newSize.height - oldSize.height)/2;
             newRect.origin.x = oldRect.origin.x - (newSize.width - oldSize.width)/2;
             }
             
             coverArrowView.frame = newRect;

        }
    }
    
    if (coverArrowUseText) {
        if (!coverArrowLabel) {
            coverArrowLabel = [[UILabel alloc] init];
            coverArrowLabel.backgroundColor = [UIColor clearColor];
            [coverArrowView addSubview:coverArrowLabel];
            [coverArrowLabel release];
        }
        if (self.selectedTab)
        {
            NSString* coverString = self.selectedTab.nameLabel.text;
            coverArrowLabel.text = coverString;
            coverArrowLabel.textColor = [UIColor blackColor];
            coverArrowLabel.font = self.selectedTab.nameLabel.font;
            [coverArrowLabel sizeToFit];
            CGRect converLabelRect = self.selectedTab.nameLabel.frame;
            
            CGRect coverArrowRect = coverArrowView.bounds;
            converLabelRect.origin.x = coverArrowRect.size.width/2 - coverArrowLabel.frame.size.width/2;
            converLabelRect.size = coverArrowLabel.frame.size;
            converLabelRect.origin.y = self.bounds.size.height/2 - coverArrowLabel.frame.size.height/2;
            coverArrowLabel.frame = converLabelRect;
            
            
            /*
            [coverArrowLabel sizeToFit];
            
            CGRect converLabelRect = coverArrowLabel.frame;
            converLabelRect.origin.x = coverArrowRect.size.width/2 - converLabelRect.size.width/2;
            converLabelRect.origin.y = coverArrowRect.size.height/2 - converLabelRect.size.height/2;
            coverArrowLabel.frame = converLabelRect;
             */
        }
        else
        {
            coverArrowLabel.text = nil;
        }
    }
}

-(void)changeCoverArrowHidenStatus:(BOOL)bHiden
{
    if (coverArrowView.hidden!=bHiden)
    {
        [self updateCoverArrowImage];
        coverArrowView.hidden = bHiden;
        if (!bHiden) {
            if (self.tabs) {
                if ([self.delegate respondsToSelector:@selector(tabBar:didCoverArrowHideChanged:)]) {
                    [self.delegate tabBar:self didCoverArrowHideChanged:bHiden];
                }
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(tabBar:didCoverArrowHideChanged:)]) {
                [self.delegate tabBar:self didCoverArrowHideChanged:bHiden];
            }
        }
        
    }
    
}

@end
