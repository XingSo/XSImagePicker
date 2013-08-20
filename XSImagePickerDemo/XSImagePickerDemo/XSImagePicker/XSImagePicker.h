//
//  XSImagePicker.h
//  XSImagePickerDemo
//
//  Created by XingSo on 13-8-20.
//  Copyright (c) 2013年 XingSo. All rights reserved.
//

@protocol XSImagePickerDelegate <NSObject>

@required
- (void) XSImagePicker:(id) picker didFinishPickingImageWithInfo:(NSDictionary *)info;

@end


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface XSImagePicker : UIViewController

@property (nonatomic, assign) id delegate;


@property (nonatomic) bool animation;
@property (nonatomic) int zoomSize ;

@end
