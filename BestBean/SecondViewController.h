//
//  SecondViewController.h
//  BestBean
//
//  Created by Robert Miller on 3/31/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"


@interface SecondViewController : UIViewController  <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>
{
    MKMapView * mapView;
}

@property (nonatomic, retain) MKMapView * mapView;
@property (nonatomic, retain) UISwitch * userSwitch;
@property (nonatomic, retain) NSMutableArray * annotationArray;
@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) NSArray * parseObjects;
@property (nonatomic, retain) UIView * detailView;
@property (nonatomic, retain) UITapGestureRecognizer * mapTapGesture;

@end
