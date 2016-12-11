//
//  LocalImage+CoreDataProperties.m
//  photo_map
//
//  Created by 이선민 on 2016. 12. 11..
//  Copyright © 2016년 이선민. All rights reserved.
//

#import "LocalImage.h"

@implementation LocalImage (CoreDataProperties)

+ (NSFetchRequest<LocalImage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"LocalImage"];
}

@dynamic local;
@dynamic image;

@end
