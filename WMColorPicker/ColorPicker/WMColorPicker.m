//
//  WMColorPicker.m
//  ColorPicker
//
//  Created by Heaton on 2018/2/2.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import "WMColorPicker.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )
#define SELECTOR_WIDTH 50
@interface WMColorPicker()

@property(nonatomic,assign) CGPoint handleCenter;
@property(nonatomic,assign) NSInteger radius;
@property(nonatomic,assign) CGContextRef context;
// 滑帽图片
@property(nonatomic,strong) UIImageView *selectorImageView;
// 色环图片
@property(nonatomic,strong) UIImageView *colorsImageView;
@end

@implementation WMColorPicker

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.opaque = NO;
        self.selectorImage = [UIImage imageNamed:@"color_picker_selector"];
        self.colorsImage = [UIImage imageNamed:@"colorView"];
        self.radius = frame.size.width/2 - SELECTOR_WIDTH/2;// 半径大小
        self.angle = 360;// 默认起始位置
        
        self.colorsImageView.frame = CGRectMake(0,0,frame.size.width,frame.size.height);
        [self addSubview:self.colorsImageView];
        
        // 添加滑帽
        CGFloat x = CGRectGetWidth(frame) - SELECTOR_WIDTH;
        CGFloat y = CGRectGetHeight(frame)/2 - SELECTOR_WIDTH/2;
        self.selectorImageView.frame = CGRectMake(x,y,SELECTOR_WIDTH,SELECTOR_WIDTH);
        [self addSubview:self.selectorImageView];
        [self updatePositionForSelectorImage];
        CGPoint centerPoint = CGPointMake(self.selectorImageView.center.x, self.selectorImageView.center.y);
        self.currentColor = [self getColorWithImage:self.colorsImage point:centerPoint];
    }
    return self;
}


#pragma mark 触摸事件处理
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    [self updataValueWithTouch:touch];
    if(self.touchBeganBlock){
        self.touchBeganBlock(self,self.currentColor);
    }
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    [self updataValueWithTouch:touch];
    return YES;
}


-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self updataValueWithTouch:touch];
    if(self.touchEndBlock){
        self.touchEndBlock(self,self.currentColor);
    }
}


-(void)updataValueWithTouch:(UITouch *)touch{
    CGPoint lastPoint = [touch locationInView:self.colorsImageView];
    [self moveHandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


-(void)moveHandle:(CGPoint)point{
//    double distance = sqrt(((self.colorsImageView.center.x-point.x)*(self.colorsImageView.center.x -point.x)) + ((self.colorsImageView.frame.origin.y - point.y)*(self.colorsImageView.center.y - point.y)));
//    if (distance > self.radius) {
//        return;
//    }
//    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height), point)) {
//        return ;
//    }
    
    // 计算图片旋转角度
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    float floatAngle = AngleFromNorth(centerPoint,point,NO);
    int intAngle = floor(floatAngle);
    self.angle = 360 - intAngle;
    CGPoint selectorCenterPoint = CGPointMake(self.selectorImageView.center.x, self.selectorImageView.center.y);
    self.currentColor = [self getColorWithImage:self.colorsImage point:selectorCenterPoint];
    [self updatePositionForSelectorImage];
    if(self.valueChangeBlock){
        NSLog(@"currentColor:%@",self.currentColor);
        self.valueChangeBlock(self,self.currentColor);
    }
}

-(UIColor *)getColorWithImage:(UIImage *)image point:(CGPoint)point{
    // 计算滑帽的中心点位置，取色
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = self.frame.size.width;
    NSUInteger height = self.frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    //
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    UIColor *color = [UIColor colorWithRed:(CGFloat)pixelData[0] / 255.0f green:(CGFloat)pixelData[1] / 255.0f blue:(CGFloat)pixelData[2] / 255.0f alpha:1];
    
    return color;
}


-(void)updatePositionForSelectorImage{
    CGPoint handleCenter = [self pointFromAngle:self.angle];
    self.selectorImageView.frame = CGRectMake(handleCenter.x,handleCenter.y,SELECTOR_WIDTH,SELECTOR_WIDTH);
    CGPoint centerPoint = CGPointMake(self.selectorImageView.center.x, self.selectorImageView.center.y);
//    self.currentColor = [self getPixelColorAtLocation:centerPoint context:self.context];
    NSLog(@"--centerX%.2f  centerY:%.2f--",centerPoint.x,centerPoint.y);
}

// 给定的角度得到圆环上对应的经纬度
- (CGPoint)pointFromAngle:(int)angleInt{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - SELECTOR_WIDTH/2, self.frame.size.height/2 - SELECTOR_WIDTH/2);
    
    CGPoint result;
    result.y = round(centerPoint.y + self.radius * sin(ToRad(-angleInt)));
    result.x = round(centerPoint.x + self.radius * cos(ToRad(-angleInt)));
    self.handleCenter = CGPointMake(result.x + 20, result.y + 20);
    return result;
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}



-(UIImageView *)selectorImageView{
    if(_selectorImageView == nil){
        _selectorImageView = [[UIImageView alloc] initWithImage:self.selectorImage];
        _selectorImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectorImageView;
}

-(UIImageView *)colorsImageView{
    if(_colorsImageView == nil){
        _colorsImageView = [[UIImageView alloc] initWithImage:self.colorsImage];
        _colorsImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _colorsImageView;
}


-(void)dealloc{
    CGContextRelease(self.context);
}

@end
