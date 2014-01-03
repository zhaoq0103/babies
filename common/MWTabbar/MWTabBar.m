//
//  MWTabBar.m
//  babyfaq
//
//  Created by mayanwei on 13-5-24.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "MWTabBar.h"
#import "defines.h"
#import "MyTool.h"

@implementation MWTabBar
@synthesize delegate = _delegate;
@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_bar.png"]];
        
//        UIImageView* bg = [[UIImageView alloc] initWithFrame:frame];
//        bg.image =[UIImage imageNamed:@"bg_bar.png"];
//        self.bkImage = bg;
//        [self addSubview:_bkImage];
//        [bg release];
        
		self.buttons = [NSMutableArray arrayWithCapacity:[imageArray count]];
		
		CGFloat width = self.bounds.size.width / [imageArray count];
        
		for (int i = 0; i < [imageArray count]; i++)
		{
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.tag = i;
			btn.frame = CGRectMake(width * i, 0, width, kTabBarHeight);
            
            //add text
            NSArray*   titles = @[@"首页", @"问专家", @"搜索", @"全程指导",@"个人中心"];
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, width, 20)];
            text.backgroundColor = [UIColor clearColor];
            text.textColor = [MyTool colorWithHexString:@"#5BA8B2"];
            text.textAlignment = NSTextAlignmentCenter;
            text.text = titles[i];
            
            text.tag = 2013;
            text.font = [UIFont boldSystemFontOfSize:12.0f];
            [btn addSubview:text];
            [text release];
            
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Default"] forState:UIControlStateNormal];
            [btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Default"] forState:UIControlStateHighlighted];
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Seleted"] forState:UIControlStateSelected];
			[btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self.buttons addObject:btn];
			[self addSubview:btn];
		}
    }
    return self;
}


- (void)tabBarButtonClicked:(id)sender
{
	UIButton *btn = sender;
	[self selectTabAtIndex:btn.tag];
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [_delegate tabBar:self didSelectIndex:btn.tag];
    }
}

- (void)selectTabAtIndex:(NSInteger)index
{
	for (int i = 0; i < [self.buttons count]; i++)
	{
		UIButton *b = [self.buttons objectAtIndex:i];
		b.selected = NO;
        b.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_bar.png"]];
		b.userInteractionEnabled = YES;
        
        UILabel* text = (UILabel*)[b viewWithTag:2013];
        text.hidden = NO;
        
	}
	UIButton *btn = [self.buttons objectAtIndex:index];
	btn.selected = YES;
    btn.backgroundColor = [UIColor colorWithRed:202.0/255.0 green:238.0/255.0 blue:246.0/255.0 alpha:1.0];
	btn.userInteractionEnabled = NO;
    
    UILabel* text = (UILabel*)[btn viewWithTag:2013];
    text.hidden = YES;
}

- (void)dealloc
{
    [_buttons release];
    [super dealloc];
}

@end
