//
//  NewAnnotation.h
//  BestBean
//
//  Created by Robert Miller on 4/21/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface NewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) PFObject * object;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
