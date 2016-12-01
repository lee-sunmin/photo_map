//
//  ViewController.m
//  photo_map
//
//  Created by 이선민 on 2016. 10. 30..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import "ViewController.h"
#import "FSInteractiveMapView.h"
#import <QuartzCore/QuartzCore.h>


@interface ViewController () <UIScrollViewDelegate>
//@property (nonatomic, weak) CALayer* oldClickedLayer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) FSInteractiveMapView* map;
@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle; //The cropping style
@property (nonatomic, strong) UIImage* image;

@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
#pragma clang diagnostic pop
@end


@implementation ViewController{
    BOOL hasImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self initExample3];
}

#pragma mark - Examples

- (void)initExample3
{
    hasImage = NO;
    self.map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [self.map loadMap:@"map" withColors:nil];
    
    [self.map setClickHandler:^(NSString* identifier, CALayer* layer) {

        [self addImage];
        
        if (hasImage) {
            
            NSLog(@"%f",layer.frame.size.width);

            UIImage *backgroundImageSource = self.image;
            CALayer *backgroundImage = [CALayer layer];
            backgroundImage.zPosition = 10;
            
            float imx = (self.image.size.width/2);
            float imy = (self.image.size.height/2);
            
            NSLog(@"%f",imx);
            NSLog(@"%f",imy);
            
            [backgroundImage setFrame:CGRectMake(self.map.x-10, self.map.y-10, 20, 20)];
            
            NSLog(@"frame: %@", [NSValue valueWithCGRect:layer.frame]);
            
            backgroundImage.contents = (id) backgroundImageSource.CGImage;
            [layer addSublayer:backgroundImage];
            
        }
        hasImage = YES;
    }];
    
    [self.scrollView addSubview:self.map];
}


- (void)addImage
{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"한가지를 선택해주세요."
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* camera = [UIAlertAction
                         actionWithTitle:@"camera"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             [view dismissViewControllerAnimated:YES completion:nil];
                             
                             UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                             picker.delegate = self;
                             picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                             
                             [self presentViewController:picker animated:NO completion:nil];
                             
                             [view dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    UIAlertAction* album = [UIAlertAction
                         actionWithTitle:@"album"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             self.croppingStyle = TOCropViewCroppingStyleDefault;
                             
                             UIImagePickerController *standardPicker = [[UIImagePickerController alloc] init];
                             standardPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                             standardPicker.allowsEditing = NO;
                             standardPicker.delegate = self;
                             [self presentViewController:standardPicker animated:YES completion:nil];
                              }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"CANCLE"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    [view addAction:camera];
    [view addAction:album];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
    cropController.delegate = self;
    self.image = image;

    [picker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:cropController animated:YES completion:nil];
    }];
}


#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    self.image = image;
    //[self imageViewControll];
    [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"success");
    
    NSLog(@"new image : %@",newImage);
    return newImage;
}

/*
- (void)imageViewControll
{
    CGFloat padding = 20.0f;
    
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.imageView.image.size;
    
    if (self.imageView.image.size.width > viewFrame.size.width ||
        self.imageView.image.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
        self.imageView.frame = imageFrame;
    }
    else {
        self.imageView.frame = imageFrame;
        self.imageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
    }
}
*/



- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = self.detailItem;
        self.detailDescriptionLabel.text = @"";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma-mark scroll view

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 6.5;
    _scrollView.delegate = self;

    //self.scrollView.contentSize = self.view ? sizeOfScreen : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.map;
}


@end
