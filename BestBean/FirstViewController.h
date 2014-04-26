//
//  FirstViewController.h
//  BestBean
//
//  Created by Robert Miller on 3/31/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface FirstViewController : UIViewController   <MKMapViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, retain) PFObject * parseObject;
@property (nonatomic, retain) UIImageView * imageView;
@property (nonatomic, retain) UIView * editView;

@end
