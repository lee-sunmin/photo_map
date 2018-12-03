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


#define ALTER_CANCLE NSLocalizedStringFromTable(@"ALTER_CANCLE",@"ViewController",@"CANCLE")
#define ALTER_ALBUM NSLocalizedStringFromTable(@"ALTER_ALBUM",@"ViewController",@"ALBUM")
#define ALTER_MENU NSLocalizedStringFromTable(@"ALTER_MENU",@"ViewController",@"MENU")

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
    __weak typeof(self) weakSelf = self;
    
    hasImage = NO;
    self.image = nil;
    self.map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [self.map loadMap:@"map" withColors:nil];
    [self.map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
        
        // Image not changed, not Selected
        //if([weakSelf selectImageFromAlbum]){
        
        //}else{ // changed
        //self->hasImage = YES;
        if(self.image == nil){
            NSLog(@"Please Select Image!");
            
            //Step 1: Create a UIAlertController
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"warning"
                                                                                       message: @"Please Select Image"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            //Step 2: Create a UIAlertAction that can be added to the alert
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     //Do some thing here, eg dismiss the alertwindow
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            //Step 3: Add the UIAlertAction ok that we just created to our AlertController
            [myAlertController addAction: ok];
            
            //Step 4: Present the alert to the user
            [weakSelf presentViewController:myAlertController animated:YES completion:nil];
            return;
        }
        
        if([layer.sublayers count] > 0)
            [[layer.sublayers objectAtIndex:0] removeFromSuperlayer];
        
        weakSelf.image = [weakSelf imageWithImage:weakSelf.image scaledToSize:CGSizeMake(50,50)];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.map = weakSelf.map;
        weakSelf.svg = appDelegate.fssvg;
        
        float scale = MIN(appDelegate.scaleHorizontal, appDelegate.scaleVertical);
        
        CGAffineTransform scaleTransform = CGAffineTransformIdentity;
        scaleTransform = CGAffineTransformMakeScale(scale, scale);
        scaleTransform = CGAffineTransformTranslate(scaleTransform,-self->_svg.bounds.origin.x, -self->_svg.bounds.origin.y);
        
        FSSVGPathElement* temp;
        for(int i = 0; i < 242; i++){
            FSSVGPathElement* element = self->_svg.paths[i];
            if ([element.identifier isEqualToString:identifier]) {
                temp = element;
                break;
            }
        }
        
        UIBezierPath* scaled = [temp.path copy];
        
        [scaled applyTransform:scaleTransform];
        
        float scaled_height =scaled.bounds.size.height;
        float scaled_width =scaled.bounds.size.width;
        
        UIImageView *maskedImageView = [[UIImageView alloc] initWithImage:self.image];
        
        UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.map.x-(scaled_width/2), self.map.y-(scaled_height/2), scaled_width+0.5, scaled_height+0.5)];
        tempImageView.image = self.image;
        
        [maskedImageView.layer addSublayer:tempImageView.layer];
        
        CAShapeLayer *theLayer = [[CAShapeLayer alloc] init];
        theLayer.path = scaled.CGPath;
        
        layer.fillColor = [UIColor clearColor].CGColor;
        
        maskedImageView.layer.mask = theLayer;
        
        maskedImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [layer addSublayer:maskedImageView.layer];
        
        NSData *imageData = UIImagePNGRepresentation(self.image);
        [self add:identifier :imageData];
        //}
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
    
    //NSError *error = nil;
    //NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
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

// true : same image, false : changed
- (BOOL)selectImageFromAlbum
{
    UIImage* image = self.image;
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:ALTER_MENU
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* album = [UIAlertAction
                            actionWithTitle:ALTER_ALBUM
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                // image pick and crop
                                self.croppingStyle = TOCropViewCroppingStyleLayer;
                                UIImagePickerController *standardPicker = [[UIImagePickerController alloc] init];
                                standardPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                standardPicker.allowsEditing = NO;
                                standardPicker.delegate = self;
                                [self presentViewController:standardPicker animated:YES completion:nil];
                            }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:ALTER_CANCLE
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:album];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
    NSLog(@"End SelectImageFromAlbum");
    
    if(image == self.image){
        return true;
    }else {
        return false;
    }
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
    
    // MODIFY!
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


- (IBAction)btnAddImg:(id)sender {
    [self selectImageFromAlbum];
}
@end
