//
//  SecondViewController.m
//  BestBean
//
//  Created by Robert Miller on 3/31/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import "SecondViewController.h"
#import "NewAnnotation.h"

@interface SecondViewController ()
{
    BOOL detailViewShowing;
}

@end

@implementation SecondViewController
@synthesize locationManager, mapView;

#define MAXANNOTATIONS  25

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor brownColor];
    _userSwitch = [[UISwitch alloc] init];
    [_userSwitch setFrame:CGRectMake(135, 50, 10, 10)];
    _userSwitch.tintColor = [[AppDelegate sharedInstance] subViewTintColor];
    _userSwitch.onTintColor = [[AppDelegate sharedInstance] subViewTintColor];
    _userSwitch.transform = CGAffineTransformMakeScale(2, 2);
    [_userSwitch addTarget:self action:@selector(userSwitchOnOff) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_userSwitch];
    
    UILabel * userLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 35, 50, 60)];
    userLabel.text = @"Users";
    [self.view addSubview:userLabel];
    
    UILabel * selfLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 35, 110, 60)];
    selfLabel.text = @"My Coffees";
    [self.view addSubview:selfLabel];
    
    mapView = [[MKMapView alloc]
                initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 160)];
    self.mapView.delegate = self;
    _mapTapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(moveMapBack)];
    [_mapTapGesture setDelegate:self];
    [_mapTapGesture setEnabled:NO];
    [mapView addGestureRecognizer:_mapTapGesture];
    [self.view addSubview:mapView];
    
    _annotationArray = [[NSMutableArray alloc] init];
    
    detailViewShowing = false;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [[self locationManager] startUpdatingLocation];
    //[NSThread sleepForTimeInterval:3.0];
    PFGeoPoint * location = [PFGeoPoint geoPointWithLocation:[locationManager location]];
    [locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [self.mapView setCenterCoordinate:coordinate];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    double mileRadius = 5;
    double scalingFactor = ABS((cos(2 * M_PI * location.latitude / 360.0)));
    span.latitudeDelta = mileRadius / 69;
    span.longitudeDelta = mileRadius / (scalingFactor * 69);
    region.span = span;
    region.center = coordinate;
    [self.mapView setRegion:region animated:YES];
    
    NSLog(@"geopoint longitude: %f", location.longitude);
    
    if (detailViewShowing) {
        [self moveMapBack];
    }
    
    [mapView removeAnnotations:mapView.annotations];
    [_annotationArray removeAllObjects];
    
    if ([_userSwitch isOn]) {
        NSLog(@"user switch on");
        PFQuery * query = [PFQuery queryWithClassName:@"CoffeeCup"];
        [query whereKey:@"userName" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"location" nearGeoPoint:location withinMiles:5];
        query.limit = MAXANNOTATIONS;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"query resulted in error: %@", [error description]);
            }
            else    {
                NSLog(@"no error in map query, array with %lu objects", (unsigned long)[results count]);
                _parseObjects = [[NSArray alloc] initWithArray:results];
                for (int i = 0; i < [results count]; i++) {
                    NSLog(@"up");
                    PFObject * tempObject = [results objectAtIndex:i];
                    NSLog(@"object name: %@", tempObject[@"coffeeName"]);
                    //PFGeoPoint *geoPoint = tempObject[@"location"];
                    //CLLocationCoordinate2D returnCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    NewAnnotation * annotation = [[NewAnnotation alloc] init];
                    annotation.object = tempObject;
                    [_annotationArray insertObject:annotation atIndex:i];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"add annotations");
                    NSArray * sendArray = [[NSArray alloc] initWithArray:_annotationArray];
                    [self.mapView addAnnotations:sendArray];
                    
                });
            }
        }];
    }
    else    {
        NSLog(@"user switch off");
        PFQuery * query = [PFQuery queryWithClassName:@"CoffeeCup"];
        [query whereKey:@"userName" notEqualTo:[[PFUser currentUser] username]];
        [query whereKey:@"location" nearGeoPoint:location withinMiles:10];
        query.limit = MAXANNOTATIONS;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"query resulted in error: %@", [error description]);
            }
            else    {
                NSLog(@"no error in map query, array with %lu objects", (unsigned long)[results count]);
                _parseObjects = [[NSArray alloc] initWithArray:results];
                for (int i = 0; i < [results count]; i++) {
                    NSLog(@"up");
                    PFObject * tempObject = [results objectAtIndex:i];
                    NSLog(@"object name: %@", tempObject[@"coffeeName"]);
                    //PFGeoPoint *geoPoint = tempObject[@"location"];
                    //CLLocationCoordinate2D returnCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    NewAnnotation * annotation = [[NewAnnotation alloc] init];
                    annotation.object = tempObject;
                    [_annotationArray insertObject:annotation atIndex:i];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"add annotations");
                    NSArray * sendArray = [[NSArray alloc] initWithArray:_annotationArray];
                    [self.mapView addAnnotations:sendArray];
                    
                });
            }
        }];
    }
}

-(void)userSwitchOnOff
{
    if (detailViewShowing) {
        [self moveMapBack];
    }
    
    [mapView removeAnnotations:mapView.annotations];
    [_annotationArray removeAllObjects];
    
    [[self locationManager] startUpdatingLocation];
    //[NSThread sleepForTimeInterval:3.0];
    PFGeoPoint * location = [PFGeoPoint geoPointWithLocation:[locationManager location]];
    [locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [self.mapView setCenterCoordinate:coordinate];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    double mileRadius = 5;
    double scalingFactor = ABS((cos(2 * M_PI * location.latitude / 360.0)));
    span.latitudeDelta = mileRadius / 69;
    span.longitudeDelta = mileRadius / (scalingFactor * 69);
    region.span = span;
    region.center = coordinate;
    [self.mapView setRegion:region animated:YES];
    
    NSLog(@"geopoint longitude: %f", location.longitude);
    
    if ([_userSwitch isOn]) {
        NSLog(@"user switch on");
        PFQuery * query = [PFQuery queryWithClassName:@"CoffeeCup"];
        [query whereKey:@"userName" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"location" nearGeoPoint:location withinMiles:10];
        query.limit = MAXANNOTATIONS;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"query resulted in error: %@", [error description]);
            }
            else    {
                NSLog(@"no error in map query, array with %lu objects", (unsigned long)[results count]);
                _parseObjects = [[NSArray alloc] initWithArray:results];
                for (int i = 0; i < [results count]; i++) {
                    NSLog(@"up");
                    PFObject * tempObject = [results objectAtIndex:i];
                    NSLog(@"object name: %@", tempObject[@"coffeeName"]);
                    //PFGeoPoint *geoPoint = tempObject[@"location"];
                    //CLLocationCoordinate2D returnCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    NewAnnotation * annotation = [[NewAnnotation alloc] init];
                    annotation.object = tempObject;
                    [_annotationArray insertObject:annotation atIndex:i];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"add annotations");
                    NSArray * sendArray = [[NSArray alloc] initWithArray:_annotationArray];
                    [self.mapView addAnnotations:sendArray];
                    
                });
            }
        }];
    }
    else    {
        NSLog(@"user switch off");
        PFQuery * query = [PFQuery queryWithClassName:@"CoffeeCup"];
        [query whereKey:@"userName" notEqualTo:[[PFUser currentUser] username]];
        [query whereKey:@"location" nearGeoPoint:location withinMiles:10];
        query.limit = MAXANNOTATIONS;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"query resulted in error: %@", [error description]);
            }
            else    {
                NSLog(@"no error in map query, array with %lu objects", (unsigned long)[results count]);
                _parseObjects = [[NSArray alloc] initWithArray:results];
                for (int i = 0; i < [results count]; i++) {
                    NSLog(@"up");
                    PFObject * tempObject = [results objectAtIndex:i];
                    NSLog(@"object name: %@", tempObject[@"coffeeName"]);
                    //PFGeoPoint *geoPoint = tempObject[@"location"];
                    //CLLocationCoordinate2D returnCoordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    NewAnnotation * annotation = [[NewAnnotation alloc] init];
                    annotation.object = tempObject;
                    [_annotationArray insertObject:annotation atIndex:i];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"add annotations");
                    NSArray * sendArray = [[NSArray alloc] initWithArray:_annotationArray];
                    [self.mapView addAnnotations:sendArray];
                    
                });
            }
        }];
    }
}

#pragma mark - Mapping Methods

-(CLLocationManager *)locationManager
{
    if(locationManager != nil)   {
        return locationManager;
    }
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDelegate:self];
    
    return locationManager;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation    {
    NSLog(@"RootView locationManager: didUpdateToLocation");
    
}

- (MKAnnotationView *)mapView:(MKMapView *)methodMapView viewForAnnotation:(NewAnnotation *)annotation      {
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
    
    if([annotation isKindOfClass:[NewAnnotation class]]){
        //Try to get an unused annotation, similar to uitableviewcells
        MKAnnotationView *annotationView = [methodMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        //If one isn't available, create a new one
        if(!annotationView){
            annotationView = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: annotationIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"coffee@2x.png"];
            
            NSInteger annotationValue = [_annotationArray indexOfObject:annotation];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            rightButton.tag = annotationValue;
            
            [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
            
            annotationView.rightCalloutAccessoryView = rightButton;
        }
        return annotationView;
    }
    return nil;
}

-(void)showDetails:(UIView *)sender
{
    if (mapView.frame.size.height < self.view.frame.size.height - 180) {
        return;
    }
    PFObject * tempObject = [_parseObjects objectAtIndex:sender.tag];
    [self setupDetailView:tempObject];
    [_mapTapGesture setEnabled:YES];
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         PFGeoPoint * location = tempObject[@"location"];
                         
                         CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                         [self.mapView setCenterCoordinate:coordinate];
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         span.latitudeDelta = 0.05;
                         span.longitudeDelta = 0.05;
                         region.span = span;
                         region.center = coordinate;
                         [self.mapView setRegion:region animated:YES];
                         
                         CGRect newMapFrame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, mapView.frame.size.width, mapView.frame.size.height - 270);
                         
                         mapView.frame = newMapFrame;
                         
                         CGRect movedFrame = CGRectMake(0, newMapFrame.origin.y + newMapFrame.size.height, self.view.frame.size.width, 320);
                         
                         _detailView.frame = movedFrame;
                         
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                         
                     }];
}

-(void)setupDetailView:(PFObject *)detailObject
{
    detailViewShowing = true;
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, mapView.frame.origin.y + mapView.frame.size.height, self.view.frame.size.width, 320)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 140, 140)];
    imageView.backgroundColor = [UIColor grayColor];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    [_detailView addSubview:imageView];
    
    UILabel * usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 120, 80)];
    usernameLabel.numberOfLines = 0;
    usernameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if ([_userSwitch isOn]) {
        PFUser * detailUser = [PFUser currentUser];
        if([PFFacebookUtils isLinkedWithUser:detailUser]){ //<-
            usernameLabel.text = detailUser[@"fbUserName"];
        } else {
            usernameLabel.text = detailUser[@"userName"];
        }
    }
    else    {
        PFQuery * query = [PFUser query];
        [query whereKey:@"username" equalTo:detailObject[@"userName"]];
        NSArray * users = [query findObjects];
        NSLog(@"# users: %lu",(unsigned long)[users count]);
        PFUser * detailUser = (PFUser *)[users objectAtIndex:0];
        if([PFFacebookUtils isLinkedWithUser:detailUser]){ //<-
            usernameLabel.text = detailUser[@"fbUserName"];
        } else {
            usernameLabel.text = detailUser[@"userName"];
        }
    }
    //usernameLabel.text = detailObject[@"userName"];
    [_detailView addSubview:usernameLabel];
    
    PFFile *userImageFile = detailObject[@"coffeePhoto"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            [UIView transitionWithView:_detailView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                UIImage *image = [UIImage imageWithData:imageData];
                                imageView.image = image;
                                
                            } completion:^(BOOL finished){
                                NSLog(@"icon loaded");
                            }];
        }
    }];
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 150, 240, 65)];
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.text = detailObject[@"coffeeName"];
    [_detailView addSubview:nameLabel];
    
    UILabel * ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 210, 170, 45)];
    NSString * ratingString = @"Rating: ";
    ratingLabel.text = [ratingString stringByAppendingString:[[NSNumber numberWithInt:[detailObject[@"rating"] intValue]] stringValue]];
    [_detailView addSubview:ratingLabel];
    
    UILabel * locationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 210, 150, 60)];
    locationNameLabel.numberOfLines = 0;
    locationNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    locationNameLabel.text = detailObject[@"locationName"];
    
    UITextView * notesView = [[UITextView alloc] initWithFrame:CGRectMake(160, 160, 150, 100)];
    notesView.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    notesView.layer.cornerRadius = 5.0;
    notesView.scrollEnabled = YES;
    notesView.editable = NO;
    notesView.text = detailObject[@"coffeeNotes"];
    [_detailView addSubview:notesView];
    
    [self.view addSubview:_detailView];
    
}

-(void)moveMapBack
{
    detailViewShowing = false;
    [_mapTapGesture setEnabled:NO];
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CLLocation *location = [locationManager location];
                         CLLocationCoordinate2D coordinate = location.coordinate;
                         [self.mapView setCenterCoordinate:coordinate];
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         double mileRadius = 5;
                         double scalingFactor = ABS((cos(2 * M_PI * location.coordinate.latitude / 360.0)));
                         span.latitudeDelta = mileRadius / 69;
                         span.longitudeDelta = mileRadius / (scalingFactor * 69);
                         region.span = span;
                         region.center = coordinate;
                         [self.mapView setRegion:region animated:YES];
                         
                         CGRect newMapFrame = CGRectMake(mapView.frame.origin.x,
                                                         mapView.frame.origin.y,
                                                         mapView.frame.size.width,
                                                         self.view.frame.size.height - 160);
                         
                         mapView.frame = newMapFrame;
                         
                         CGRect movedFrame = CGRectMake(0, newMapFrame.origin.y + newMapFrame.size.height, self.view.frame.size.width, 320);
                         
                         _detailView.frame = movedFrame;
                         
                         
                         
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                         [_detailView removeFromSuperview];
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
