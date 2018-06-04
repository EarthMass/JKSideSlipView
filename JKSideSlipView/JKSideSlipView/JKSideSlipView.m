//
//  JKSideSlipView.m
//  JKSideSlipView
//
//  Created by Jakey on 15/1/10.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "JKSideSlipView.h"
#import <Accelerate/Accelerate.h>

static CGFloat SLIP_WIDTH = 250;

@implementation JKSideSlipView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(nil, @"please init with -initWithSender:sender");
    }
    return self;
    
}

- (instancetype)initWithSender:(UIViewController*)sender{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(-SLIP_WIDTH, 0, SLIP_WIDTH, bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews:sender];
    }
    return self;
}
-(void)buildViews:(UIViewController*)sender{
    _sender = sender;
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    _tap.numberOfTapsRequired = 1;
    
    _leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    _rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(show)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
     [_sender.view addGestureRecognizer:_tap];
    [_sender.view addGestureRecognizer:_leftSwipe];
    [_sender.view addGestureRecognizer:_rightSwipe];
    
    
    _blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _blurImageView.userInteractionEnabled = NO;
    _blurImageView.alpha = 0;
//    _blurImageView.backgroundColor = [UIColor grayColor];
    //_blurImageView.layer.borderWidth = 5;
    //_blurImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubview:_blurImageView];
    
    self.showFromLeft = YES;
    self.showBur = YES;
    
}

#pragma mark- Setting
- (void)setShowFromLeft:(BOOL)showFromLeft {
    _showFromLeft = showFromLeft;
    
    CGRect frame = self.frame;
    frame.origin.x = isOpen?[self showOriginX]:[self hiddenOriginX];
    self.frame = frame;
    
    _blurImageView.frame = CGRectMake([self burImgVoriginX], 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [_leftSwipe removeTarget:self action:@selector(hide)];
     [_leftSwipe removeTarget:self action:@selector(show)];
    [_leftSwipe addTarget:self action:_showFromLeft?@selector(hide):@selector(show)];
    
    [_rightSwipe removeTarget:self action:@selector(hide)];
    [_rightSwipe removeTarget:self action:@selector(show)];
    [_rightSwipe removeTarget:self action:nil];
    [_rightSwipe addTarget:self action:_showFromLeft?@selector(show):@selector(hide)];
 
}

-(void)setContentView:(UIView*)contentView{
    if (contentView) {
        _contentView = contentView;
    }
    
    _contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_contentView];

}

- (void)setSpaceToEdge:(CGFloat)spaceToEdge {
     CGRect bounds = [UIScreen mainScreen].bounds;
    _spaceToEdge = spaceToEdge;
    SLIP_WIDTH = bounds.size.width - _spaceToEdge;
  
    CGRect frame = CGRectMake(-SLIP_WIDTH, 0, SLIP_WIDTH, bounds.size.height);
    self.frame = frame;
    self.showFromLeft = _showFromLeft;
    
}
- (void)setShowBur:(BOOL)showBur {
    _showBur = showBur;
}
#pragma mark

-(void)show:(BOOL)show{
    UIImage *image =  [self imageFromView:_sender.view];
   
    if (!isOpen) {
        _blurImageView.alpha = 1;

    }
    if (!show) {
        _blurImageView.alpha = 0;
        _blurImageView.image = nil;
    }
    
   
    CGFloat x = show?[self showOriginX]:[self hiddenOriginX];
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(x, 0, self.frame.size.width, self.frame.size.height);
        if(!isOpen){
            if (_showBur) {
                _blurImageView.image = image;
                _blurImageView.image= [self blurryImage:_blurImageView.image withBlurLevel:0.2];
            } else {
                _blurImageView.image = nil;
                 _blurImageView.alpha = 0;
            }
           
        }
    } completion:^(BOOL finished) {
        isOpen = show;
        if(!isOpen){
            _blurImageView.alpha = 0;
            _blurImageView.image = nil;
            NSLog(@"hidden");
        }

    }];
    
}


-(void)switchMenu{
    [self show:!isOpen];
}
-(void)show{
    [self show:YES];

}

-(void)hide {
    if (!isOpen) {
        return;
    }
    [self show:NO];
}

- (CGFloat)showOriginX {
    return  _showFromLeft?0:_sender.view.frame.size.width - SLIP_WIDTH;
}
- (CGFloat)hiddenOriginX {
    return _showFromLeft?-SLIP_WIDTH:_sender.view.frame.size.width + SLIP_WIDTH;
}
- (CGFloat)burImgVoriginX {
    return _showFromLeft?SLIP_WIDTH: - [UIScreen mainScreen].bounds.size.width;
}

#pragma mark - shot
- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark - Blur


- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
