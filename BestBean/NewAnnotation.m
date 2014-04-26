//
//  NewAnnotation.m
//  BestBean
//
//  Created by Robert Miller on 4/21/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import "NewAnnotation.h"

@implementation NewAnnotation

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    self.coordinate = coord;
    return self;
}

- (CLLocationCoordinate2D) coordinate;
{
    //NSLog(@"Annotation coordinate");
    CLLocationCoordinate2D returnCoordinate;
    PFGeoPoint *geoPoint = _object[@"location"];
    returnCoordinate.longitude = geoPoint.longitude;
    returnCoordinate.latitude = geoPoint.latitude;
    
    return returnCoordinate;
}

- (NSString *) title  {
    //NSLog(@"Annotation title");
    return _object[@"coffeeName"];
}

@end
