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
#import "AppDelegate.h"

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) CALayer* oldClickedLayer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    
    [self.map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {

        [self addImage];
        
        if (hasImage) {
            //self.image = [self imageWithImage:self.image scaledToSize:CGSizeMake(30,30)];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.map = self.map;
            self.svg = appDelegate.fssvg;
            
            float scaleHorizontal = 343.000000 / _svg.bounds.size.width;
            float scaleVertical = 500.000000 / _svg.bounds.size.height;
            
            float scale = MIN(scaleHorizontal, scaleVertical);
            
            CGAffineTransform scaleTransform = CGAffineTransformIdentity;
            scaleTransform = CGAffineTransformMakeScale(scale, scale);
            //scaleTransform = CGAffineTransformTranslate(scaleTransform,-_svg.bounds.origin.x, -_svg.bounds.origin.y);
            
            FSSVGPathElement* temp;
            for(int i = 0; i < 242; i++){
                FSSVGPathElement* element = _svg.paths[i];
                if ([element.identifier isEqualToString:identifier] && element.fill) {
                    temp = element;
                    break;
                }
            }
            
            UIBezierPath* scaled = [temp.path copy];
            [scaled applyTransform:scaleTransform];
            
            UIImageView *maskedImageView = [[UIImageView alloc] initWithImage:self.image];
            
            CAShapeLayer *theLayer = [[CAShapeLayer alloc] init];
            theLayer.path = scaled.CGPath;
        
            layer.fillColor = [UIColor clearColor].CGColor;
            
            maskedImageView.layer.mask = theLayer;
            [maskedImageView.layer addSublayer:layer];
            [self.map addSubview:maskedImageView];
            
            
            // save//
//            float scaleHorizontal = 0.675197;
//            float scaleVertical = 0.699302;
//            
//            float scale = MIN(scaleHorizontal, scaleVertical);
//            
//            CGAffineTransform scaleTransform = CGAffineTransformIdentity;
//            scaleTransform = CGAffineTransformMakeScale(scale, scale);
//            scaleTransform = CGAffineTransformTranslate(scaleTransform,-0.500000, -0.606000);
//            
//            UIBezierPath *scaled = [UIBezierPath bezierPathWithCGPath:layer.path];
//            [scaled applyTransform:scaleTransform];
//            
//            CAShapeLayer *theLayer = [[CAShapeLayer alloc] init];
//            theLayer.path = layer.path;
//            
//            UIImageView *maskedImageView = [[UIImageView alloc] initWithImage:self.image];
//            maskedImageView.layer.mask = theLayer;
//            [maskedImageView.layer addSublayer:layer];
//            [self.view addSubview:maskedImageView];
            
            
            NSData *imageData = UIImagePNGRepresentation(self.image);
            [self add:identifier :imageData];
        }
        hasImage = YES;
    }];
    
    [self.scrollView addSubview:self.map];
}

- (void)add:(NSString*)local :(NSData *)image
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    //LocalImage *newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"LocalImage" inManagedObjectContext:context];
    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"LocalImage" inManagedObjectContext:context];
    
    NSManagedObject * isSame = [self searchDB:local];
    if (isSame!=nil) {
        [context deleteObject:isSame];
    }
    
    [newDevice setValue:local forKey:@"local"];
    [newDevice setValue:image forKey:@"image"];
    
    NSError *error = nil;
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)showAllDB
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest* request = [[NSFetchRequest alloc]initWithEntityName:@"LocalImage"];
    [request setReturnsObjectsAsFaults:NO];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"LocalImage" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
}

- (NSManagedObject *)searchDB: (NSString *)local
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest* request = [[NSFetchRequest alloc]initWithEntityName:@"LocalImage"];
    [request setReturnsObjectsAsFaults:NO];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"LocalImage" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    for(int i = 0; i < fetchedObjects.count; i++){
        if ([[fetchedObjects[i] local]isEqualToString:local]) {
            return fetchedObjects[i];
        }
    }
    return nil;
}

- (void)addImage
{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"한가지를 선택해주세요."
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* album = [UIAlertAction
                         actionWithTitle:@"album"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             self.croppingStyle = TOCropViewCroppingStyleLayer;
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

    [view addAction:album];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
    cropController.delegate = self;
    //cropController.imageCropFrame = self.oldClickedLayer.frame;
    
    self.image = image;

    [picker pushViewController:cropController animated:YES];
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
