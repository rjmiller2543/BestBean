//
//  CoffeeObject.h
//  BestBean
//
//  Created by Robert Miller on 4/6/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoffeeObject : NSObject

@property (nonatomic, retain) NSString      * objectID;
@property (nonatomic, retain) NSString      * name;
@property (nonatomic, retain) NSString      * locationName;
@property (nonatomic, retain) NSString      * notes;
@property (nonatomic, retain) CLLocation    * geoLocation;
@property (nonatomic, retain) NSDate        * creationDate;
@property (nonatomic, retain) NSNumber      * rating;
@property (nonatomic, retain) UIImage       * iconImage;
@property (nonatomic, retain) UIImage       * photo;

@end
