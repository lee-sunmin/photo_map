//
//  AppDelegate.h
//  photo_map
//
//  Created by 이선민 on 2016. 10. 30..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FSInteractiveMapView.h"
#import "LocalImage.h"
#import "FSSVG.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) FSInteractiveMapView* map;
@property (nonatomic, strong) FSSVG* fssvg;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (int)getI;

@property float scaleHorizontal;
@property float scaleVertical;

@end

