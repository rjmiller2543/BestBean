//
//  LocalListViewController.m
//  BestBean
//
//  Created by Robert Miller on 4/1/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import "LocalListViewController.h"
#import "ObjectTableViewCell.h"
#import "FirstViewController.h"
#import "MBProgressHUD.h"

@interface LocalListViewController ()

@end

@implementation LocalListViewController
@synthesize locationManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor brownColor];
    
    self.title = @"BestBean";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userName = [prefs stringForKey:@"storedUserName"];
    NSString *password = [prefs stringForKey:@"storedPassword"];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPress)];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    PFUser * user = [PFUser currentUser];
    NSLog(@"current user: %@", [user description]);
    
    if (user) {
        [PFFacebookUtils logInWithPermissions:@[@"publish_stream"] block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                //[self reloadParseObjects];
            } else {
                NSLog(@"User logged in through Facebook!");
                //[self reloadParseObjects];
            }
        }];
    }
    else if (userName) {
        [PFUser logInWithUsernameInBackground:userName password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                                [[AppDelegate sharedInstance] setParseUser:user];
                                                //[self reloadParseObjects];
                                            } else {
                                                // The login failed. Check error to see why.
                                                NSLog(@"log in error: %@", [error description]);
                                            }
                                        }];
    }
    else    {
        
        [self setupLogin];
        
    }
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"add_list.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(addObjectToParse)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self reloadParseObjects];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self reloadParseObjects];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_objects count];
}

#pragma mark - Login Methods

#define USERFIELDTAG    0x100
#define PASSWORDTAG     0x101
#define EMAILTAG        0x110
-(void)setupLogin   {
    
    _loginView = [[UIView alloc]
                  initWithFrame:CGRectMake(0, 700, self.view.frame.size.width, self.view.frame.size.height)];
    _loginView.backgroundColor = [UIColor brownColor];
    UITextField *userField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 180, 40)];
    UITextField *passField = [[UITextField alloc] initWithFrame:CGRectMake(30, 120, 180, 40)];
    UITextField *mailField = [[UITextField alloc] initWithFrame:CGRectMake(30, 180, 180, 40)];
    UIButton *signupButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 240, 180, 40)];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 300, 180, 40)];
    UIButton *fbSignupButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 360, 180, 40)];
    [signupButton addTarget:self action:@selector(signUpNewUser) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(cancelSignUp) forControlEvents:UIControlEventTouchUpInside];
    [fbSignupButton addTarget:self action:@selector(linkWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    userField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    passField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    mailField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    signupButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    cancelButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    fbSignupButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    userField.layer.cornerRadius = 5.0;
    passField.layer.cornerRadius = 5.0;
    mailField.layer.cornerRadius = 5.0;
    signupButton.layer.cornerRadius = 5.0;
    cancelButton.layer.cornerRadius = 5.0;
    fbSignupButton.layer.cornerRadius = 5.0;
    
    userField.placeholder = @"Username";
    passField.placeholder = @"Password";
    mailField.placeholder = @"Email";
    
    [signupButton setTitle:@"Sign Up!" forState:UIControlStateNormal];
    [cancelButton setTitle:@"Not Now" forState:UIControlStateNormal];
    [fbSignupButton setTitle:@"Sign In with Facebook" forState:UIControlStateNormal];
    signupButton.titleLabel.textColor = [UIColor brownColor];
    cancelButton.titleLabel.textColor = [UIColor brownColor];
    fbSignupButton.titleLabel.textColor = [UIColor brownColor];
    
    userField.tag = USERFIELDTAG;
    passField.tag = PASSWORDTAG;
    mailField.tag = EMAILTAG;
    
    [_loginView addSubview:userField];
    [_loginView addSubview:passField];
    [_loginView addSubview:mailField];
    [_loginView addSubview:signupButton];
    [_loginView addSubview:cancelButton];
    [_loginView addSubview:fbSignupButton];
    
    [self.tabBarController.view addSubview:_loginView];
    
    CGRect movedFrame = self.view.frame;
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // do whatever animation you want, e.g.,
                         NSLog(@"moving");
                         _loginView.frame = movedFrame;
                     }
                     completion:NULL];
    
}

-(void)removeLoginView:(NSSet *)objects {
    
    CGRect movedFrame = CGRectMake(40, 700, 10, 10);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // do whatever animation you want, e.g.,
                         NSLog(@"moving");
                         _loginView.frame = movedFrame;
                     }
                     completion:^(BOOL finished){
                         [_loginView removeFromSuperview];
                     }];
    
}

-(void)signUpNewUser    {
    
    PFUser *user = [PFUser user];
    
    NSArray * loginSubviews = [_loginView subviews];
    for (int i = 0; i < [loginSubviews count]; i++) {
        if ([[loginSubviews objectAtIndex:i] tag] == USERFIELDTAG) {
            UITextField * tempTextField = (UITextField *)[loginSubviews objectAtIndex:i];
            user.username = tempTextField.text;
        }
        else if ([[loginSubviews objectAtIndex:i] tag] == PASSWORDTAG)  {
            UITextField * tempTextField = (UITextField *)[loginSubviews objectAtIndex:i];
            user.password = tempTextField.text;
        }
        else if ([[loginSubviews objectAtIndex:i] tag] == EMAILTAG) {
            UITextField * tempTextField = (UITextField *)[loginSubviews objectAtIndex:i];
            user.email = tempTextField.text;
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:user.username forKey:@"storedUserName"];
    [prefs setObject:user.password forKey:@"storedPassword"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            [self removeLoginView:nil];
            
        } else {
            // Show the errorString somewhere and let the user try again.
            NSLog(@"finished with error: %@", [error description]);
            //UIAlertView *signInError = [[UIAlertView alloc] initWithTitle:@"Sign Up Error!" message:@"There was an error in the sing up process... Please Try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            //[signInError show];
            if ([error code] == 202) {
                UIAlertView * userNameError = [[UIAlertView alloc] initWithTitle:@"Username Already in Use!" message:@"Sorry to be bearer of bad news... but somebody has already taken your username.  Try using another" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [userNameError show];
            }
            if ([error code] == 203) {
                UIAlertView * emailError = [[UIAlertView alloc] initWithTitle:@"Email Already Been Used!" message:@"Oy! Looks as though somebody has already singed up with this email address... Try Using another or contact the admin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [emailError show];
            }
        }
    }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex   {
    
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [self removeLoginView:nil];
            break;
            
        default:
            break;
    }
    
}

-(void)cancelSignUp {
    
    UIAlertView *areYouSure = [[UIAlertView alloc] initWithTitle:@"Are You Sure?!" message:@"To get the full effect of the app we encourage you to sign up for a free account.  The app is limited without a user account." delegate:self cancelButtonTitle:@"Sign Me Up!" otherButtonTitles:@"Continue", nil];
    
    [areYouSure show];
    
}

#pragma mark - Settings View Methods

-(void)settingsButtonPress  {
    
    [self setupSettingsView];
    
}

-(void)setupSettingsView    {
    
    _settingsView = [[UIView alloc]
                     initWithFrame:CGRectMake(30, 40, 0, 0)];
    _settingsView.backgroundColor = [UIColor brownColor];
    
    UIButton * signUpOrOutButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 60, 180, 40)];
    UIButton * linkWithFbButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 120, 180, 40)];
    UIButton * linkWithTwButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 180, 180, 40)];
    UIButton * sortButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 240, 180, 40)];
    UIButton * closeButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 300, 180, 40)];
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"fb linked: %hhd",[prefs boolForKey:@"fbLinked"]);
    PFUser * user = [PFUser currentUser];
    if (user) {
        [signUpOrOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        if ([PFFacebookUtils isLinkedWithUser:user]) {
            [linkWithFbButton setTitle:@"Unlink with Facebook" forState:UIControlStateNormal];
        }
        else
            [linkWithFbButton setTitle:@"Link With Facebook" forState:UIControlStateNormal];
        [linkWithTwButton setTitle:@"Link With Twitter" forState:UIControlStateNormal];
    }
    else    {
        [signUpOrOutButton setTitle:@"Sign Up With Email" forState:UIControlStateNormal];
        [linkWithFbButton setTitle:@"Sign Up With Facebook" forState:UIControlStateNormal];
        [linkWithTwButton setTitle:@"Sign Up With Twitter" forState:UIControlStateNormal];
    }
    [sortButton setTitle:@"Sort Your Coffees" forState:UIControlStateNormal];
    [closeButton setTitle:@"Close This Window" forState:UIControlStateNormal];
    
    signUpOrOutButton.layer.cornerRadius = 5.0;
    signUpOrOutButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    signUpOrOutButton.titleLabel.textColor = [UIColor brownColor];
    signUpOrOutButton.tintColor = [UIColor brownColor];
    linkWithFbButton.layer.cornerRadius = 5.0;
    linkWithFbButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    linkWithFbButton.titleLabel.textColor = [UIColor brownColor];
    linkWithFbButton.tintColor = [UIColor brownColor];
    sortButton.layer.cornerRadius = 5.0;
    sortButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    sortButton.titleLabel.textColor = [UIColor brownColor];
    sortButton.tintColor = [UIColor brownColor];
    closeButton.layer.cornerRadius = 5.0;
    closeButton.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    closeButton.titleLabel.textColor = [UIColor brownColor];
    closeButton.tintColor = [UIColor brownColor];
    
    [signUpOrOutButton addTarget:self action:@selector(signUpOrOutUser) forControlEvents:UIControlEventTouchUpInside];
    [linkWithFbButton addTarget:self action:@selector(linkWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    [linkWithTwButton addTarget:self action:@selector(linkWithTwitter) forControlEvents:UIControlEventTouchUpInside];
    [sortButton addTarget:self action:@selector(sortButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(closeSettingsWindow) forControlEvents:UIControlEventTouchUpInside];
    
    [_settingsView addSubview:signUpOrOutButton];
    [_settingsView addSubview:linkWithFbButton];
    //[_settingsView addSubview:linkWithTwButton];  /* Excluding the twitter button until app is set up with twitter api */
    [_settingsView addSubview:sortButton];
    [_settingsView addSubview:closeButton];
    
    [self.tabBarController.view addSubview:_settingsView];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect movedFrame = self.view.frame;
                         
                         _settingsView.frame = movedFrame;
        
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                     }];
    
    
}

-(void)signUpOrOutUser  {
    
    [PFUser logOut];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"storedUserName"];
    [prefs setObject:nil forKey:@"storePassword"];
    
    [self setupLogin];
    
}

-(void)linkWithFacebook {
    
    PFUser *user = [PFUser currentUser];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:false forKey:@"fbLinked"];
    if ([PFFacebookUtils isLinkedWithUser:user]) {
        NSLog(@"fb linked");
        [prefs setBool:false forKey:@"fbLinked"];
        // Unlink Facebook
        if ([PFFacebookUtils isLinkedWithUser:user]) {
            [PFFacebookUtils unlinkUser:user];
        }
    }
    else    {
        NSLog(@"fb not linked");
        if (![prefs stringForKey:@"storedUserName"]) {
            NSLog(@"no user signing up with fb");
            [PFFacebookUtils logInWithPermissions:@[@"publish_stream"] block:^(PFUser *user, NSError *error) {
                if (!user) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else if (user.isNew) {
                    NSLog(@"User signed up and logged in through Facebook!");
                    FBRequest *request = [FBRequest requestForMe];
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            NSDictionary *userData = (NSDictionary *)result;
                            NSString *name = userData[@"name"];
                            user[@"fbUserName"] = name;
                            [user saveInBackground];
                        }}];
                } else {
                    NSLog(@"User logged in through Facebook!");
                    [self reloadParseObjects];
                }
            }];
        }
        else    {
            NSLog(@"linking with fb");
            if (![PFFacebookUtils isLinkedWithUser:user]) {
                [PFFacebookUtils linkUser:user permissions:@[@"publish_stream"] block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Woohoo, user logged in with Facebook!");
                        [prefs setBool:true forKey:@"fbLinked"];
                    }
                }];
        }
        [prefs setBool:true forKey:@"fbLinked"];
        }
    }
    
    if (_loginView.frame.origin.x < self.view.frame.size.height) {
        [self removeLoginView:nil];
    }
    
}

-(void)linkWithTwitter  {
    
    // For now Twitter will do nothing... May have to add link with Twitter in a later update.  Parse requires a valid Callback URL in the Twitter Application Setup in order for to validate the username and link.
    
}

-(void)sortButtonPressed    {
    
    
    
}

-(void)closeSettingsWindow  {
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect movedFrame = CGRectMake(30, 40, 0, 0);
                         
                         _settingsView.frame = movedFrame;
                         
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                         [_settingsView removeFromSuperview];
                     }];
    
}

#pragma mark - New Object Methods

-(void)addObjectToParse
{
    
    [self setupNewObjectView];
    
}

#define IMAGEVIEWTAG        0x1000
#define NAMEFIELDTAG        0x1001
#define LOCATIONNAMETAG     0x1010
#define RATINGTAG           0x1011
#define SCROLLVIEWTAG       0x1100
#define LOCATIONTAG         0x1101
#define NOTESVIEWTAG        0x1110
#define RATINGFIELDTAG      0x1111
#define TOOLBARHEIGHT       55
int currRating = 0;
int tempRating = 0;
-(void)setupNewObjectView
{
    [[self locationManager] startUpdatingLocation];
    // Setup the frame and toolbar
    _addNewObjectView = [[UIView alloc] initWithFrame:CGRectMake(0, 700, self.view.frame.size.width, self.view.frame.size.height)];
    _addNewObjectView.backgroundColor = [UIColor brownColor];
    _addNewObjectView.alpha = 0.5;
    
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, TOOLBARHEIGHT)];
    toolbar.backgroundColor = [UIColor blackColor];
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewObjectView)];
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNewObject)];
    UIBarButtonItem * separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    toolbar.items = @[cancelButton, separator, saveButton];
    [_addNewObjectView addSubview:toolbar];
    
    // Setup the scroll view
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - TOOLBARHEIGHT)];
    scrollView.contentSize = CGSizeMake(320, 800);
    scrollView.tag = SCROLLVIEWTAG;
    
    // Setup the Image view, tag it, and add to scroll view
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 20, 306, 306)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.image = [UIImage imageNamed:@"add_image.png"];
    imageView.userInteractionEnabled = YES;
    imageView.tag = IMAGEVIEWTAG;
    [scrollView addSubview:imageView];
    UIButton * takePictureButton = [[UIButton alloc] initWithFrame:imageView.frame];
    [takePictureButton addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:takePictureButton];
    
    // Setup the Name field, tag it, and add to scroll view
    UITextField * nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 330, 220, 30)];
    nameField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    nameField.placeholder = @"Name";
    nameField.layer.cornerRadius = 5.0;
    nameField.tag = NAMEFIELDTAG;
    nameField.delegate = self;
    [scrollView addSubview:nameField];
    
    // Setup the Location Name field, tag it, and add to scroll view
    UITextField * locationNameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 380, 220, 30)];
    locationNameField.backgroundColor =[[AppDelegate sharedInstance] subViewTintColor];
    locationNameField.layer.cornerRadius = 5.0;
    locationNameField.placeholder = @"Location Name";
    locationNameField.tag = LOCATIONNAMETAG;
    locationNameField.delegate = self;
    [scrollView addSubview:locationNameField];
    
    // Setup the rating view with a picker for input view, tag it, and add it to scroll view
    UIPickerView * ratingPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 216, 320, 216)];
    ratingPicker.delegate = self;
    ratingPicker.dataSource = self;
    ratingPicker.showsSelectionIndicator = YES;
    
    UITextField * ratingField = [[UITextField alloc] initWithFrame:CGRectMake(10, 430, 220, 30)];
    ratingField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    ratingField.layer.cornerRadius = 5.0;
    ratingField.placeholder = @"Rating";
    ratingField.tag = RATINGFIELDTAG;
    ratingField.inputView = ratingPicker;
    
    [scrollView addSubview:ratingField];
    
    //_ratingChoices = @[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zero_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zero_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"one_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"three_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"four_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"full_rating.png"]]];
    
    // Setup the Notes Text View, tag it, and add it to scroll view
    UITextView * notesView = [[UITextView alloc] initWithFrame:CGRectMake(10, 480, 300, 240)];
    notesView.layer.cornerRadius = 5.0;
    notesView.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    notesView.text = @"Notes...";
    notesView.scrollEnabled = YES;
    notesView.tag = NOTESVIEWTAG;
    notesView.delegate = self;
    [scrollView addSubview:notesView];
    
    //
    [_addNewObjectView addSubview:scrollView];
    [self.tabBarController.view addSubview:_addNewObjectView];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect movedFrame = self.view.frame;
                         
                         _addNewObjectView.frame = movedFrame;
                         _addNewObjectView.alpha = 1.0;
                         
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                     }];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSLog(@"CoffeeRatingView numberOfComponentsInPickerView");
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"CoffeeRatingView pickerView: numberOfRowsInComponent");
    //return _ratingChoices.count;
    return 6;
}
/*
-(UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view   {
    NSLog(@"view for row: %ld", (long)row);
    //return [_ratingChoices objectAtIndex:row];
}
*/
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[NSNumber numberWithInt:row] stringValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"CoffeeRatingView pickerView: didSelectRow");
    currRating = row;
    NSArray * newObjectSubviews = [_addNewObjectView subviews];
    for (int i = 0; i < [newObjectSubviews count]; i++) {
        if ([[newObjectSubviews objectAtIndex:i] tag] == SCROLLVIEWTAG) {
            NSLog(@"Found Scroll View");
            UIScrollView * tempScrollView = (UIScrollView *)[newObjectSubviews objectAtIndex:i];
            NSArray * scrollViewSubviews = [tempScrollView subviews];
            for (int j = 0; j < [scrollViewSubviews count]; j++) {
                if ([[scrollViewSubviews objectAtIndex:j] tag] == RATINGFIELDTAG) {
                    UITextField * tempField = (UITextField *)[scrollViewSubviews objectAtIndex:j];
                    tempField.text = [[NSNumber numberWithInt:row] stringValue];
                    [tempField resignFirstResponder];
                }
            }
        }
    }
    //[pickerView resignFirstResponder];
    [pickerView removeFromSuperview];
}

#pragma mark - Location Methods

-(CLLocationManager *)locationManager   {
    NSLog(@"RootView locationManager");
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)saveNewObject
{
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"CoffeeCups"];
    
    PFObject *coffeeCup = [PFObject objectWithClassName:@"CoffeeCup"];
    
    NSArray * newObjectSubviews = [_addNewObjectView subviews];
    for (int i = 0; i < [newObjectSubviews count]; i++) {
        if ([[newObjectSubviews objectAtIndex:i] tag] == SCROLLVIEWTAG) {
            NSLog(@"Found Scroll View");
            UIScrollView * tempScrollView = (UIScrollView *)[newObjectSubviews objectAtIndex:i];
            NSArray * scrollViewSubviews = [tempScrollView subviews];
            for (int j = 0; j < [scrollViewSubviews count]; j++) {
                if ([[scrollViewSubviews objectAtIndex:j] tag] == NAMEFIELDTAG) {
                    UITextField * tempField = (UITextField *)[scrollViewSubviews objectAtIndex:j];
                    NSLog(@"tempfield text: %@", tempField.text);
                    coffeeCup[@"coffeeName"] = tempField.text;
                }
                else if ([[scrollViewSubviews objectAtIndex:j] tag] == IMAGEVIEWTAG) {
                    UIImageView * tempImageView = (UIImageView *)[scrollViewSubviews objectAtIndex:j];
                    NSLog(@"returned the image view");
                    //UIImage
                    UIImage * iconImage = [self imageWithImage:tempImageView.image scaledToSize:CGSizeMake(53, 53)];
                    PFFile *uploadFile = [PFFile fileWithData:UIImageJPEGRepresentation(tempImageView.image, 1.0)];
                    PFFile *iconFile  = [PFFile fileWithData:UIImageJPEGRepresentation(iconImage, 0.25)];
                    coffeeCup[@"coffeePhoto"] = uploadFile;
                    coffeeCup[@"iconImage"] = iconFile;
                }
                else if ([[scrollViewSubviews objectAtIndex:j] tag] == NOTESVIEWTAG)    {
                    UITextView * tempView = (UITextView *)[scrollViewSubviews objectAtIndex:j];
                    coffeeCup[@"coffeeNotes"] = tempView.text;
                }
            }
            break;
        }
    }
    
    coffeeCup[@"creationDate"] = [NSDate date];
    coffeeCup[@"rating"] = [NSNumber numberWithInt:currRating];
    NSLog(@"location: %@", [[locationManager location] description]);
    PFGeoPoint * location = [PFGeoPoint geoPointWithLocation:[locationManager location]];
    coffeeCup[@"location"] = location;
    coffeeCup[@"userName"] = [[PFUser currentUser] username];
    
    [MBProgressHUD showHUDAddedTo:_addNewObjectView animated:YES];
    
    [coffeeCup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [relation addObject:coffeeCup];
            [user saveInBackground];
            [self removeNewObjectView:nil];
            [self reloadParseObjects];
            [MBProgressHUD hideHUDForView:_addNewObjectView animated:YES];
        }
        else    {
            NSLog(@"save failed with error: %@", [error description]);
            [MBProgressHUD hideHUDForView:_addNewObjectView animated:YES];
            UIAlertView * saveFailAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Save Failed!"
                                           message:@"There was an error saving your coffee.  Try to save again.  If you continue to have issues, please contact the admin"
                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [saveFailAlert show];
        }
        
    }];
    
}

-(void)cancelNewObjectView
{
    
    [self removeNewObjectView:nil];
    
}

-(void)removeNewObjectView:(NSSet *)objects
{
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect movedFrame = CGRectMake(0, 700, self.view.frame.size.width, self.view.frame.size.height);
                         
                         _addNewObjectView.frame = movedFrame;
                         
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                         [_addNewObjectView removeFromSuperview];
                         [[self locationManager] stopUpdatingLocation];
                         [self reloadParseObjects];
                     }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"did finish picking media with info");
    UIImage *outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    NSArray * newObjectSubviews = [_addNewObjectView subviews];
    for (int i = 0; i < [newObjectSubviews count]; i++) {
        if ([[newObjectSubviews objectAtIndex:i] tag] == SCROLLVIEWTAG) {
            NSLog(@"Found Scroll View");
            UIScrollView * tempScrollView = (UIScrollView *)[newObjectSubviews objectAtIndex:i];
            NSArray * scrollViewSubviews = [tempScrollView subviews];
            for (int j = 0; j < [scrollViewSubviews count]; j++) {
                if ([[scrollViewSubviews objectAtIndex:j] tag] == IMAGEVIEWTAG) {
                    UIImageView * tempImageView = (UIImageView *)[scrollViewSubviews objectAtIndex:j];
                    NSLog(@"returned the image view");
                    //UIImage
                    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
                    tempImageView.clipsToBounds = YES;
                    tempImageView.image = outputImage;
                }
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex    {
    NSLog(@"CoffeeCupEditor actionSheet: clickedButtonAtIndex");
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.allowsEditing = YES;
    ipc.delegate = self;
    
    if (buttonIndex == 0) {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    if (buttonIndex == 1) {
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    if (buttonIndex == 2)   {
        
    }
}

-(void)createActionSheet    {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
        actionSheet.alpha = 1.0;//0.8;
        [actionSheet showInView:self.view];
    }
    
    else {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    
}

-(IBAction)choosePhoto  {
    NSLog(@"CoffeeCupEditor choosePhoto");
    [self performSelector:@selector(createActionSheet) withObject:nil afterDelay:0.1];
}

#pragma mark - Table View Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"objectCell" forIndexPath:indexPath];
    ObjectTableViewCell *cell = (ObjectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"objectCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject * cellObject = [_objects objectAtIndex:indexPath.row];
    
    cell.parseObject = cellObject;
    [cell configureCell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}

-(void)reloadParseObjects
{
    NSLog(@"reload parse objects");
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"CoffeeCups"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"creationDate"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // There was an error
            NSLog(@"error: %@", [error description]);
        } else {
            // objects has all the Posts the current user liked.
            NSLog(@"no error fill array with objects: %lu", (unsigned long)[objects count]);
            _objects = objects;
            [self.tableView reloadData];
        }
    }];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Text Field Delegates

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [_addNewObjectView setFrame:CGRectMake(_addNewObjectView.frame.origin.x,
                                               0, _addNewObjectView.frame.size.width,
                                               _addNewObjectView.frame.size.height)];
    }completion:^(BOOL finished){
        NSLog(@"text field moved frame up");
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat newY = 0;
    switch (textField.tag) {
        case NAMEFIELDTAG:
            newY = -160;
            break;
            
        case LOCATIONNAMETAG:
            newY = -280;
            break;
        
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
            [_addNewObjectView setFrame:CGRectMake(_addNewObjectView.frame.origin.x,
                                                   newY, _addNewObjectView.frame.size.width,
                                                   _addNewObjectView.frame.size.height)];
        }completion:^(BOOL finished){
            NSLog(@"text field moved frame up");
        }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGFloat newY = -200;
    [UIView animateWithDuration:0.3 animations:^{
        [_addNewObjectView setFrame:CGRectMake(_addNewObjectView.frame.origin.x,
                                               newY, _addNewObjectView.frame.size.width,
                                               _addNewObjectView.frame.size.height)];
    }completion:^(BOOL finished){
        NSLog(@"text field moved frame up");
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGFloat newY = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [_addNewObjectView setFrame:CGRectMake(_addNewObjectView.frame.origin.x,
                                               newY, _addNewObjectView.frame.size.width,
                                               _addNewObjectView.frame.size.height)];
    }completion:^(BOOL finished){
        NSLog(@"text field moved frame up");
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare for segue");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FirstViewController * detailViewController = (FirstViewController *)[segue destinationViewController];
    NSLog(@"sender class: %@", [sender class]);
    ObjectTableViewCell * cell = (ObjectTableViewCell *)sender;
    detailViewController.parseObject = cell.parseObject;
}


@end
