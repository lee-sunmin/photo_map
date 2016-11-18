//
//  ViewController.m
//  photo_map
//
//  Created by 이선민 on 2016. 10. 30..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import "ViewController.h"
#import "FSInteractiveMapView.h"

@interface ViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) CAShapeLayer* oldClickedLayer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) FSInteractiveMapView* map;
@end

@implementation ViewController{
    CAShapeLayer* saveLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self initExample3];
    //[self initExample1];
}

#pragma mark - Examples

- (void)initExample1
{
    NSDictionary* data = @{@"asia" : @12,
                           @"australia" : @2,
                           @"north_america" : @5,
                           @"south_america" : @14,
                           @"africa" : @5,
                           @"europe" : @20
                           };
    
    FSInteractiveMapView* map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, self.view.frame.size.height)];
    
    [map loadMap:@"world-continents-low" withData:data colorAxis:@[[UIColor lightGrayColor], [UIColor darkGrayColor]]];
    
    [map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"Continent clicked: %@", identifier];
    }];
    
    [self.scrollView addSubview:map];
}
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

- (void)initExample2
{
    NSDictionary* data = @{@"fr" : @12,
                           @"it" : @2,
                           @"de" : @9,
                           @"pl" : @24,
                           @"uk" : @17
                           };
    
    FSInteractiveMapView* map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(-1, 64, self.view.frame.size.width + 2, 500)];
    [map loadMap:@"europe" withData:data colorAxis:@[[UIColor blueColor], [UIColor greenColor], [UIColor yellowColor], [UIColor redColor]]];
    
    [self.view addSubview:map];
}


- (void)initExample3
{
    self.map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [self.map loadMap:@"map" withColors:nil];
    
    [self.map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
        if(_oldClickedLayer) {
            _oldClickedLayer.zPosition = 0;
            _oldClickedLayer.shadowOpacity = 0;
            NSLog(@"%@",identifier);
        }
        
        _oldClickedLayer = layer;
        
        // We set a simple effect on the layer clicked to highlight it
        layer.zPosition = 10;
        layer.shadowOpacity = 0.5;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowRadius = 5;
        layer.shadowOffset = CGSizeMake(0, 0);
        
        //NSLog(@"clicked layer : %@",layer);
        saveLayer = layer;
        [self addImage];
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

- (void)inputImage:(CAShapeLayer *)layer :(UIImage *)image{
    NSLog(@"image : %@",image);
    NSLog(@"layer : %@",saveLayer);
    [self.map loadMap:@"map" withPhoto:image withLayer:layer];
    
}

#pragma mark - UIActionSheetDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self inputImage:saveLayer:image];
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
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.delegate = self;

    //self.scrollView.contentSize = self.view ? sizeOfScreen : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.map;
}


@end
