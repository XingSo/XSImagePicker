//
//  ViewController.m
//  XSImagePickerDemo
//
//  Created by XingSo on 13-8-20.
//  Copyright (c) 2013年 XingSo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"XingSo Demo";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickImage:(UIButton *)sender {
    XSImagePicker * imagePick = [[XSImagePicker alloc] init];
    imagePick.delegate = self;  //set image picker delegate to receive image
    imagePick.animation = YES;  //set whether need animation
    imagePick.zoomSize = 20;    //set image zoom size
    [self.navigationController pushViewController:imagePick animated:YES];    
}


#pragma mark - XSImagePickerDelegate
-(void)XSImagePicker:(id)picker didFinishPickingImageWithInfo:(NSDictionary *)info{
    NSLog(@"sdfsdf:%@",info);
    imageView.image = [info objectForKey:@"image"];
}
@end
