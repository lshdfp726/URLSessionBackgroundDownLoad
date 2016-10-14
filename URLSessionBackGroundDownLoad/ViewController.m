//
//  ViewController.m
//  URLSessionBackGroundDownLoad
//
//  Created by 刘松洪 on 16/10/14.
//  Copyright © 2016年 刘松洪. All rights reserved.
//

#import "ViewController.h"
#define ImageUrl @"http://img05.tooopen.com/images/20141208/sy_76623349543.jpg"
@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage:) name:@"updataImage" object:nil];
}


- (void)updateImage:(NSNotification *)noti {
    NSData *data = nil;
    if ([noti.object isKindOfClass:[NSData class]]) {
        data = noti.object;
    }else {
        data = [[NSData alloc]initWithContentsOfFile:noti.object];
    }
    UIImage *image = [[UIImage alloc]initWithData:data];
    //*   利用gcd的主线程方法更新图片
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [[self class] image:image scaleSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height)];
    });
    
}

///压缩图片
+ (UIImage *)image:(UIImage *)image scaleSize:(CGSize)size {
    
    //图片上下文入栈
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //处理图片的上下文出栈
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
