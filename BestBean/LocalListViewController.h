//
//  LocalListViewController.h
//  BestBean
//
//  Created by Robert Miller on 4/1/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <Mapkit/MapKit.h>

@interface LocalListViewController : UITableViewController  <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, retain) UIView *loginView;
@property (nonatomic, retain) UIView *settingsView;
@property (nonatomic, retain) UIView *addNewObjectView;
@property (nonatomic, retain) NSArray *objects;
@property (nonatomic, retain) NSArray *ratingChoices;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
