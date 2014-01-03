#import "BCTab.h"

@interface BCTab ()

@end

@implementation BCTab
@synthesize forceImageView,mainImageView,nameLabel,selected,backgroundImageView, bubbleImageView, bubbleContentLable, bubbleView;

-(id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled = NO;
	}
	return self;
}

-(void)dealloc
{
    [forceImageView release];
    [backgroundImageView release];
    [mainImageView release];
    [nameLabel release];
    [bubbleImageView release];
    [bubbleContentLable release];
    [bubbleView release];
    [super dealloc];
}

-(UIImageView*)forceImageView
{
    if (!forceImageView) {
        forceImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        forceImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:forceImageView];
    }
    return forceImageView;
}
-(UIView*)bubbleView
{
    if (!bubbleView)
    {
        bubbleView = [[UIView alloc]initWithFrame:CGRectMake(45, 5, 25, 15)];
        bubbleView.backgroundColor = [UIColor clearColor];
        [self addSubview:bubbleView];
        if (bubbleView) {
            [self sendSubviewToBack:bubbleView];
        }
        if (mainImageView) {
            [self sendSubviewToBack:mainImageView];
        }
        if (nameLabel) {
            [self sendSubviewToBack:nameLabel];
        }
        if (backgroundImageView) {
            [self sendSubviewToBack:backgroundImageView];
        }
    }
    return bubbleView;
}
-(UILabel*)bubbleContentLable
{
    if (!bubbleContentLable) 
    {
        bubbleContentLable = [[UILabel alloc]initWithFrame:CGRectMake(2, 2, 20, 10)];
        bubbleContentLable.backgroundColor = [UIColor clearColor];
        bubbleContentLable.textAlignment = UITextAlignmentCenter;
        bubbleContentLable.textColor = [UIColor redColor];
//        [bubbleContentLable sizeToFit];
        if (bubbleView) 
        {
            [bubbleView addSubview:bubbleContentLable];
            if (bubbleContentLable) 
            {
                [bubbleView sendSubviewToBack:bubbleContentLable];
            }
            if (bubbleImageView) 
            {
                [bubbleView sendSubviewToBack:bubbleImageView];
            }
        }
    }
    return bubbleContentLable;
}
-(UIImageView*)bubbleImageView
{
    if (!bubbleImageView)
    {
        bubbleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 0, 20, 15)];
        bubbleImageView.backgroundColor = [UIColor clearColor];
        if (bubbleView) {
            [bubbleView addSubview:bubbleImageView];
        }
    }
    return bubbleImageView;
}
-(UIImageView*)mainImageView
{
    if (!mainImageView) {
        mainImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        mainImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:mainImageView];
        if (mainImageView) {
            [self sendSubviewToBack:mainImageView];
        }
        if (nameLabel) {
            [self sendSubviewToBack:nameLabel];
        }
        if (backgroundImageView) {
            [self sendSubviewToBack:backgroundImageView];
        }
    }
    return mainImageView;
}

-(UIImageView*)backgroundImageView
{
    if (!backgroundImageView) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backgroundImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:backgroundImageView];
        if (mainImageView) {
            [self sendSubviewToBack:mainImageView];
        }
        if (nameLabel) {
            [self sendSubviewToBack:nameLabel];
        }
        if (backgroundImageView) {
            [self sendSubviewToBack:backgroundImageView];
        }
    }
    return backgroundImageView;
}

-(UILabel*)nameLabel
{
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:13.0];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:nameLabel];
        if (mainImageView) {
            [self sendSubviewToBack:mainImageView];
        }
        if (nameLabel) {
            [self sendSubviewToBack:nameLabel];
        }
        if (backgroundImageView) {
            [self sendSubviewToBack:backgroundImageView];
        }
    }
    return nameLabel;
}

- (void)layoutSubviews {
	CGRect mainFrame = self.bounds;
    int insize = 0;
    int textMargin = 4;
    if (forceImageView) {
         forceImageView.frame = CGRectMake(insize, insize, mainFrame.size.width-insize*2, mainFrame.size.height-insize*2);
    }
    if (backgroundImageView) {
        backgroundImageView.frame = CGRectMake(insize, insize, mainFrame.size.width-insize*2, mainFrame.size.height-insize*2);
    }
    if (nameLabel) {
        CGSize labelHeightSize = CGSizeZero;
        labelHeightSize = [@" " sizeWithFont:nameLabel.font];
        int labelHeight = labelHeightSize.height;
        CGRect nameLabelFrame = CGRectMake(insize+textMargin, mainFrame.size.height - labelHeight - 2 - insize, mainFrame.size.width - insize*2 - textMargin*2, labelHeight);
        if (mainImageView.image==nil&&mainImageView.highlightedImage==nil) {
            nameLabelFrame = CGRectMake(insize+textMargin, 0, mainFrame.size.width - insize*2-textMargin*2, mainFrame.size.height);
        }
        nameLabel.frame = nameLabelFrame;
    }
    CGRect mainImageFrame = CGRectZero;
    if (!nameLabel||(nameLabel.text&&![nameLabel.text isEqualToString:@""])) {
        mainImageFrame = CGRectMake(insize, insize, mainFrame.size.width-insize*2, nameLabel.frame.origin.y - insize);
    }
    else
    {
        mainImageFrame = CGRectMake(insize, insize, mainFrame.size.width-insize*2, mainFrame.size.height-insize*2);
    }
    if (!mainImageView||(mainImageView.image==nil&&mainImageView.highlightedImage==nil)) {
        mainImageView.frame = CGRectZero;
    }
    else
    {
        CGSize imageSize = CGSizeZero;
        if (mainImageView.highlightedImage) {
            imageSize = mainImageView.highlightedImage.size;
        }
        else
        {
            imageSize = mainImageView.image.size;
        }
        if (imageSize.height>mainImageFrame.size.height) {
          mainImageFrame = CGRectMake(mainImageFrame.origin.x + (mainImageFrame.size.width - imageSize.width)/2, mainImageFrame.origin.y + (mainImageFrame.size.height - imageSize.height), imageSize.width, imageSize.height);
        }
        else
        {
            mainImageFrame = CGRectMake(mainImageFrame.origin.x + (mainImageFrame.size.width - imageSize.width)/2, mainImageFrame.origin.y + (mainImageFrame.size.height - imageSize.height)/2, imageSize.width, imageSize.height);
        }
        mainImageView.frame = mainImageFrame;
    }
}

-(void)setSelected:(BOOL)bSelected
{
    [self setSelected:bSelected animated:NO];
}

-(BOOL)selected
{
    return mSelected;
}

- (void)setSelected:(BOOL)bSelected animated:(BOOL)animated {
    mSelected = bSelected;
    mainImageView.highlighted = bSelected;
    forceImageView.highlighted = bSelected;
    nameLabel.highlighted = bSelected;
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize rtval = CGSizeZero;
    
    int insize = 0;
    int textMargin = 4;
    rtval.width += insize*2;
    rtval.height += insize*2;
    if (nameLabel) {
        CGSize labelHeightSize = [@" " sizeWithFont:nameLabel.font];
        labelHeightSize.width = [nameLabel.text sizeWithFont:nameLabel.font].width;
        int labelHeight = labelHeightSize.height;
        if (nameLabel.text&&![nameLabel.text isEqualToString:@""])
        {
            rtval.width += textMargin*2 + labelHeightSize.width;
            rtval.height += labelHeight;
        }
    }
    
    if (!mainImageView||(mainImageView.image!=nil||mainImageView.highlightedImage!=nil)) 
    {
        rtval.height += 2;
        CGSize imageSize = CGSizeZero;
        CGSize highlyImageSize = CGSizeZero;
        if (mainImageView.highlightedImage) {
            highlyImageSize = mainImageView.highlightedImage.size;
        }
        if (mainImageView.image)
        {
            imageSize = mainImageView.image.size;
        }
        if (imageSize.width<highlyImageSize.width) {
            imageSize.width = highlyImageSize.width;
        }
        if (imageSize.height<highlyImageSize.height) {
            imageSize.height = highlyImageSize.height;
        }
        
        rtval.height += imageSize.height;
        int imageTotalWidth = imageSize.width + insize*2;
        rtval.width = rtval.width > imageTotalWidth ? rtval.width : imageTotalWidth;
    }
    
    return rtval;
}

@end
