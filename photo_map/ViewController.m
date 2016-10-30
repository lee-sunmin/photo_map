//
//  ViewController.m
//  photo_map
//
//  Created by 이선민 on 2016. 10. 30..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import "ViewController.h"
#import "FSInteractiveMapView.h"

@interface ViewController ()
@property (nonatomic, weak) CAShapeLayer* oldClickedLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self initExample3];
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
    
    [self.view addSubview:map];
}

- (void)initExample3
{
    FSInteractiveMapView* map = [[FSInteractiveMapView alloc] initWithFrame:CGRectMake(16, 96, self.view.frame.size.width - 32, 500)];
    [map loadMap:@"map" withColors:nil];
    
    [map setClickHandler:^(NSString* identifier, CAShapeLayer* layer) {
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
    
    [self.view addSubview:map];
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


@end
