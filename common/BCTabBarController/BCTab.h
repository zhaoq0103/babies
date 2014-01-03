
@interface BCTab : UIButton {
@private
	UIImageView* forceImageView;
    UIImageView* backgroundImageView;
    UIImageView* mainImageView;
    UILabel* nameLabel;
    BOOL mSelected;
    
    UIView* bubbleView;
    UIImageView* bubbleImageView;
    UILabel* bubbleContentLable;
}

@property(nonatomic,retain)UIImageView* forceImageView;
@property(nonatomic,retain)UIImageView* backgroundImageView;
@property(nonatomic,retain)UIImageView* mainImageView;
@property(nonatomic,retain)UILabel* nameLabel;
@property(nonatomic,assign)BOOL selected;
@property(nonatomic,retain)UIImageView* bubbleImageView;
@property(nonatomic,retain)UILabel* bubbleContentLable;
@property(nonatomic,retain)UIView* bubbleView;
- (void)setSelected:(BOOL)bSelected animated:(BOOL)animated;
- (CGSize)sizeThatFits:(CGSize)size;

@end
