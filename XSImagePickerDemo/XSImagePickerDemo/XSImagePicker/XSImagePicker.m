//
//  XSImagePicker.m
//  XSImagePickerDemo
//
//  Created by XingSo on 13-8-20.
//  Copyright (c) 2013年 XingSo. All rights reserved.
//

#import "XSImagePicker.h"
#define CAN_NOT_READ_ALERT 1

@interface XSImagePicker ()
{
    UIScrollView    * _scrollPhotoWall;
    NSMutableArray  * _pictureArray;
    NSMutableArray  * _imageViewArray;
    NSMutableArray  * _imageArray;
    UIImageView     * _selectedImageView;
    
    UIBarButtonItem * _shareBarButton;
    
    
}

@end

@implementation XSImagePicker

@synthesize zoomSize;
@synthesize animation;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"library photos", nil);
        
        
        _shareBarButton = [[UIBarButtonItem alloc]initWithTitle:@"choose" style:UIBarButtonItemStyleBordered target:self action:@selector(touchEventWithUse)];
        [_shareBarButton setEnabled:NO];
        
        self.navigationItem.rightBarButtonItem = _shareBarButton;
        
                
        _pictureArray   = [[NSMutableArray alloc] init];
        _imageViewArray = [[NSMutableArray alloc] init];
        _imageArray     = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getImgs];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - get all picture
-(void)getImgs{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", nil)
                                                             message:NSLocalizedString(@"can't read photo in library, please give me permission to access your photo", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                   otherButtonTitles:nil];
            [alert setTag:CAN_NOT_READ_ALERT];
            [alert show];
            
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    
                    [_imageArray addObject:result.defaultRepresentation.url];
                    [_pictureArray addObject:[UIImage imageWithCGImage:result.thumbnail]];
                }
            }
            
            
        };
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group!=nil) {
                NSLog(@"group:%@",[NSString stringWithFormat:@"%@",group]);//group
                NSString * groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                
                if ([groupName isEqual: @"Camera Roll"] || [groupName isEqual:@"Saved Photos"]){
                    //_imageArray = [[NSMutableArray alloc] init];
                    //_pictureArray = [[NSMutableArray alloc] init];
                    
                    [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    NSLog(@"pic count:%d",_pictureArray.count);
                    
                }
                
                //[group enumerateAssetsUsingBlock:groupEnumerAtion];
                
            }
            else{
                NSLog(@"=========\n");
                
                [self addPicToPhotoWall];
            }
            
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
        NSLog(@"ssss");
        
    });
    
}



-(void) addPicToPhotoWall{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (_pictureArray.count < 1){
        //no picture
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake((screenSize.width - 200) / 2, (screenSize.height - 20) / 2, 200, 20)];
        label.text = NSLocalizedString(@"no photos", nil);
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
        [label adjustsFontSizeToFitWidth];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:label];
        
        return;
    }
    
    //add  to library
    
    CGSize picSize;
    picSize.width     = (screenSize.width - 8) / 3;
    picSize.height    = picSize.width;
    
    
    int numberColumn = 0;
    int numberRow    = 0;
    
    
    _scrollPhotoWall  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 2, screenSize.width, screenSize.height)];
    
    
    
    for (int i = 0; i < _pictureArray.count; i++) {
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(2 + numberColumn * (2 +  picSize.width), 2 + (2 + picSize.height) * numberRow, picSize.width, picSize.height)];
        img.contentMode            = UIViewContentModeScaleAspectFill;
        img.clipsToBounds          = YES;
        img.userInteractionEnabled = YES;
        img.tag                    = i;
        img.image                  = [_pictureArray objectAtIndex:i];
        
        [img addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClick:)]];
        
        [_imageViewArray insertObject:img atIndex:i];
        [_scrollPhotoWall addSubview:img];
        
        
        numberColumn++;
        if (numberColumn > 2) {
            numberRow++;
            numberColumn =0;
        }
    }
    
    if (_pictureArray.count % 3 != 0){
        numberRow++;
    }
    [_scrollPhotoWall setContentSize:CGSizeMake(screenSize.width, numberRow * (picSize.height + 2)+86)];
    [_scrollPhotoWall setShowsVerticalScrollIndicator:YES];
    
    [self.view addSubview:_scrollPhotoWall];
    
    
}


-(void) onImageClick:(UITapGestureRecognizer *)sender{
    
    
    UIImageView * clickedImageView = [_imageViewArray objectAtIndex:sender.view.tag];
    
    
    
    if (self.animation){
        [UIView beginAnimations:@"zoom" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    
    if (_selectedImageView != nil){
        //undo zoom for old image & remove border
        [self zoomOutImage:_selectedImageView];
    }
    else{
        [_shareBarButton setEnabled:YES];
    }
    
    //zoom for image & add border
    if (_selectedImageView != clickedImageView){
        _selectedImageView = clickedImageView;
        [self zoomInImage:_selectedImageView];
    }
    else{
        _selectedImageView = nil;
        _shareBarButton.enabled = NO;
    }
    
    if (self.animation){
        [UIView commitAnimations];
    }
    
}

- (void) zoomOutImage:(UIImageView *)image{
    if (zoomSize > 0){
        [self changeImageView:image frameWith:(-self.zoomSize)];
    }
    
    image.layer.borderWidth = 0;
}

- (void) zoomInImage:(UIImageView *)image{
    [_scrollPhotoWall bringSubviewToFront:image];
    if (self.zoomSize > 0){
        [self changeImageView:image frameWith:self.zoomSize];
    }
    _selectedImageView.layer.borderColor = [[UIColor greenColor] CGColor];
    _selectedImageView.layer.borderWidth = 5.0;
}


- (void)changeImageView:(UIImageView *)image frameWith:(int) size{
    CGRect tempFrame = image.frame;
    if (image.tag % 3 != 0){
        //not left
        tempFrame.origin.x -= size;
    }
    
    if (image.tag % 3 != 2){
        //not right
        tempFrame.size.width += 2 * size;
    }
    else{
        tempFrame.size.width += 1 * size;
    }
    
    if (image.tag / 3 != 0){
        //not top
        tempFrame.origin.y -= size;
    }
    
    tempFrame.size.height += 2 * size;
    
    
    image.frame = tempFrame;
}

- (void) touchEventWithUse{
    if (_selectedImageView == nil){
        return ;
    }

    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[_imageArray objectAtIndex:_selectedImageView.tag]
         resultBlock:^(ALAsset *asset)
     {
         UIImage *image = [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]];
         
         NSDictionary * imageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    image , @"image",
                                                    _selectedImageView.image,@"imageThumb", nil];
         
         [self callDelegateWithInfo:imageInfo];
         
         NSLog(@"image:%@",image);
         
     }
        failureBlock:^(NSError *error)
     {
         NSLog(@"fail");
     }
     ];
    
}


- (void) callDelegateWithInfo: (NSDictionary *) info{
    [self.delegate performSelector:@selector(XSImagePicker:didFinishPickingImageWithInfo:) withObject:self withObject:info];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
