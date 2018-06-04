//
//  JKSideSlipView.h
//  JKSideSlipView
//
//  Created by Jakey on 15/1/10.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKSideSlipView : UIView
{
    BOOL isOpen;
    UITapGestureRecognizer *_tap;
    UISwipeGestureRecognizer *_leftSwipe, *_rightSwipe;
    UIImageView *_blurImageView;
    UIViewController *_sender;
    UIView *_contentView;
}
@property (nonatomic, assign) BOOL showFromLeft; ///<Defualt left YES
@property (nonatomic, assign) CGFloat spaceToEdge; ///<边缘的距离 default 30
@property (nonatomic, assign) BOOL showBur;        ///<边缘半透明是否显示 default YES


- (instancetype)initWithSender:(UIViewController*)sender;
-(void)show;
-(void)hide;
-(void)switchMenu;
-(void)setContentView:(UIView*)contentView;

@end
