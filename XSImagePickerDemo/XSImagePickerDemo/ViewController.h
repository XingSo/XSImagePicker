//
//  ViewController.h
//  XSImagePickerDemo
//
//  Created by XingSo on 13-8-20.
//  Copyright (c) 2013年 XingSo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XSImagePicker.h"


@interface ViewController : UIViewController <XSImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
