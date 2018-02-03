//
//  ViewController.m
//  ColorPicker
//
//  Created by Heaton on 2018/2/2.
//  Copyright © 2018年 WangMingDeveloper. All rights reserved.
//

#import "ViewController.h"
#import "WMColorPicker.h"
@interface ViewController ()
@property(nonatomic,strong) UIView *colorView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WMColorPicker *pickerColorView = [[WMColorPicker alloc] initWithFrame:CGRectMake(0,0,200,200)];
    
    [self.view addSubview:pickerColorView];
    pickerColorView.center = self.view.center;
    
    
    self.colorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,50,50)];
    self.colorView.backgroundColor =  pickerColorView.currentColor;
    [self.view addSubview:self.colorView];
    
    // 监听颜色值变化---方式1
    pickerColorView.valueChangeBlock = ^(WMColorPicker *picker, UIColor *color) {
        self.colorView.backgroundColor = color;
    };
    
    // 监听颜色值变化---方式2
    //    [pickerColorView addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    
    
    pickerColorView.touchBeganBlock = ^(WMColorPicker *picker, UIColor *color) {
        NSLog(@"触摸开始，当前颜色是:%@",color);
    };
    
    pickerColorView.touchEndBlock = ^(WMColorPicker *picker, UIColor *color) {
        NSLog(@"触摸结束，当前颜色是:%@",color);
    };
}

-(void)valueChange:(WMColorPicker *)sender{
    self.colorView.backgroundColor = sender.currentColor;
}

@end

