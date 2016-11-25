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
//
@property (nonatomic, strong) UIImage* image;
@end

@implementation ViewController{
    BOOL hasImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self initExample3];
    //[self initExample1];
}

#pragma mark - Examples

/*
- (void)initExample3
{
    self.map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [self.map loadMap:@"map" withColors:nil];
    
    [self.map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
        if(_oldClickedLayer) {
            _oldClickedLayer.zPosition = 0;
            _oldClickedLayer.shadowOpacity = 0;
        }
        
        _oldClickedLayer = layer;
        
        // We set a simple effect on the layer clicked to highlight it
        layer.zPosition = 10;
        layer.shadowOpacity = 0.5;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowRadius = 5;
        layer.shadowOffset = CGSizeMake(0, 0);
    }];
    
    [self.map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
        //self.detailDescriptionLabel.text = [NSString stringWithFormat:@"Continent clicked: %@", identifier];
        NSLog(@"clicked : %@",identifier);
    }];
    
    [self.scrollView addSubview:self.map];
}
*/

/*
 
 //layer.sublayers = nil;
 
 //a.frame = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height);
 //[layer insertSublayer:a atIndex:0];
 
 //[layer setContents:(id)self.image.CGImage];
 // 이게 정답
 //layer.fillColor = [UIColor colorWithPatternImage:self.image].CGColor;
 
 //layer.contents = (id) [UIImage imageNamed:@"disclosure,png"].CGImage;
 
 //layer = [[CALayer alloc] init];
 //layer.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
 //[layer setContents:(id)self.image.CGImage];
 
 
 // layer 추가하는 방법
 UIImage *backgroundImageSource = self.image;
 CALayer *backgroundImage = [CALayer layer];
 backgroundImage.zPosition = 0;
 [backgroundImage setFrame:CGRectMake(0, 0, 20, 20)];
 backgroundImage.contents = (id) backgroundImageSource.CGImage;
 [layer addSublayer:backgroundImage];
 

 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
 
 [imageView removeFromSuperview];
 [imageView setImage:self.image];
 //imageView.layer.mask = maskLayer;
 [imageView.layer insertSublayer:layer atIndex:0];
 

CALayer *imageLayer = [CALayer layer];
imageLayer.frame = layer.bounds;
imageLayer.cornerRadius = 10.0;
imageLayer.contents = (id) self.image.CGImage;
imageLayer.masksToBounds = YES;
[layer addSublayer:imageLayer];
//[layer setNeedsDisplay];

//layer.fillColor=[UIColor clearColor].CGColor ;

//CALayer *a = [CAShapeLayer layer];

//a.bounds = CGRectMake(layer.position.x, layer.position.y, 20, 20);
//a.frame = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height);
//a.fillColor = [UIColor blueColor].CGColor;
//[layer addSublayer:a];


 */

- (void)initExample3
{
    hasImage = NO;
    self.map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [self.map loadMap:@"map" withColors:nil];
    
    [self.map setClickHandler:^(NSString* identifier, CALayer* layer) {

        [self addImage];
        
        //UIImage *backgroundImageSource = [UIImage imageNamed:@"disclosure"];
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
        
        //[self.map setNeedsDisplay];
        hasImage = YES;
    }];
    
    [self.scrollView addSubview:self.map];
}

/*
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIImage *img = self.image;
    [img drawInRect:rect];
}
*/

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
                             
                             
                             UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                             picker.delegate = self;
                             picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                             
                             [self presentViewController:picker animated:NO completion:nil];
                             
                             [view dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"CANCLE"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:camera];
    [view addAction:album];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}
/*
- (void)inputImage:(CAShapeLayer *)layer :(UIImage *)image{
    //NSLog(@"image : %@",image);
    //NSLog(@"layer : %@",saveLayer);
    //[self.map loadMap:@"map" withPhoto:image withLayer:layer];
    NSLog(@"in the input image");
    
    [_scrollView setNeedsDisplay];
}
*/

#pragma mark - UIActionSheetDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // setting image size
    self.image = [self imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
    
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
