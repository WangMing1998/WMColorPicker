//
//  WMColorPicker.h
//  ColorPicker
//
//  Created by Heaton on 2018/2/2.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMColorPicker;
typedef void (^WMColorPickerValuneChange)(WMColorPicker *picker,UIColor *color);
typedef void (^WMColorPickerTouchBegan)(WMColorPicker *picker,UIColor *color);
typedef void (^WMColorPickerTouchEnd)(WMColorPicker *picker,UIColor *color);
@interface WMColorPicker : UIControl
// 滑帽图片
@property(nonatomic,strong) UIImage *selectorImage;
// 色环图片
@property(nonatomic,strong) UIImage *colorsImage;

// 当前选中颜色
@property(nonatomic,strong) UIColor *currentColor;

// 滑帽初始化位置
@property(nonatomic,assign) int angle;

// value change block
@property(nonatomic,copy) WMColorPickerValuneChange valueChangeBlock;

// touch began block
@property(nonatomic,copy) WMColorPickerTouchBegan   touchBeganBlock;

// touch end block
@property(nonatomic,copy) WMColorPickerTouchEnd     touchEndBlock;

@end
