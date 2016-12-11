//
//  LocalImage+CoreDataProperties.h
//  photo_map
//
//  Created by 이선민 on 2016. 12. 11..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import "LocalImage.h"


NS_ASSUME_NONNULL_BEGIN

@interface LocalImage (CoreDataProperties)

+ (NSFetchRequest<LocalImage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *local;
@property (nullable, nonatomic, retain) NSData *image;

@end

NS_ASSUME_NONNULL_END
