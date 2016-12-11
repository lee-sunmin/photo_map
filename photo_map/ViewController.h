//
//  ViewController.h
//  photo_map
//
//  Created by 이선민 on 2016. 10. 30..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOCropViewController.h"
#import "FSInteractiveMapView.h"
#import "FSSVG.h"
#import "FSSVGPathElement.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIImageView *ivPickedImage;
@property (nonatomic, strong) FSInteractiveMapView* map;
@property (nonatomic, strong) FSSVG* svg;

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

