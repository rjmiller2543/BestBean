//
//  FirstViewController.m
//  BestBean
//
//  Created by Robert Miller on 3/31/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import "FirstViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface FirstViewController ()
{
    UIToolbar * _toolbar;
    BOOL _navHidden;
    UIScrollView * _scrollView;
    UILabel * _dateLabel;
    UITextView * _notesView;
    MKMapView * _mapView;
    BOOL _editMode;
}
@end

#define TOOLBAR_HEIGHT      44
#define DELETEACTIONSHEET   0x11
#define IMAGEACTIONSHEET    0xff

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _editMode = false;
    self.tabBarController.tabBar.hidden = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    
    self.view.backgroundColor = [UIColor brownColor];
    self.title = _parseObject[@"coffeeName"];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, self.view.frame.size.height - TOOLBAR_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(320, 1020);
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBackgroundState)];
    [tapGest setDelegate:self];
    [_scrollView addGestureRecognizer:tapGest];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 45, 306, 306)];
    _imageView.backgroundColor = [UIColor grayColor];
    _imageView.layer.cornerRadius = 5.0;
    _imageView.layer.masksToBounds = YES;
    [_scrollView addSubview:_imageView];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 370, 100, 20)];
    [_scrollView addSubview:_dateLabel];
    
    _notesView = [[UITextView alloc] initWithFrame:CGRectMake(15, 410, 290, 290)];
    [_notesView setEditable:NO];
    _notesView.layer.cornerRadius = 5.0;
    _notesView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:210.0/255.0 alpha:1];
    [_scrollView addSubview:_notesView];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(7, 720, 306, 180)];
    _mapView.layer.cornerRadius = 5.0;
    [_scrollView addSubview:_mapView];
    /*
     NSArray *shareContent = [NSArray arrayWithObjects: @"Share Item", nil];
     UISegmentedControl * shareButton = [[UISegmentedControl alloc] initWithItems:shareContent];
     CGRect shareFrame = CGRectMake(0,960,320,40);
     shareButton.frame = shareFrame;
     [shareButton setTitleTextAttributes:attributes
     forState:UIControlStateNormal];
     shareButton.selectedSegmentIndex = -1;
     [shareButton addTarget:self action:@selector(shareMode) forControlEvents:UIControlEventValueChanged];
     shareButton.backgroundColor = [UIColor grayColor];
     shareButton.tintColor = [UIColor whiteColor];
     shareButton.momentary = YES;
     [scrollView addSubview:shareButton];
     */
    [self.view addSubview:_scrollView];
    
    _toolbar = [[UIToolbar alloc] init];
    [_toolbar setFrame:CGRectMake(0, [self toolbarYOrigin], self.view.frame.size.width, TOOLBAR_HEIGHT)];
    
    [_toolbar setItems:@[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonPressed)]]];
    
    [self.view addSubview:_toolbar];
    
    [self configureView];
}

-(void)configureView
{
    [self performSelectorInBackground:@selector(loadImage:) withObject:_imageView];
    
    NSDateFormatter * dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateStyle:NSDateFormatterMediumStyle];
    _dateLabel.text = [dateFormater stringFromDate:_parseObject[@"creationDate"]];
    
    _notesView.text = _parseObject[@"coffeeNotes"];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view will disappear");
    self.tabBarController.tabBar.hidden = NO;
    //If the nav bar has been toggled, it disappears when you tap the back button, hard code to make sure nav bar is not hidden
    //Apple Bug???
    [[self navigationController] setNavigationBarHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    self.tabBarController.tabBar.hidden = YES;
    if (_editMode) {
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
    }
}

-(void)loadImage:(UIImageView *)imageView
{
    
    PFFile *userImageFile = _parseObject[@"coffeePhoto"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            [UIView transitionWithView:self.view
                              duration:2.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                UIImage *image = [UIImage imageWithData:imageData];
                                imageView.image = image;
                            } completion:^(BOOL finished){
                                NSLog(@"icon loaded");
                            }];
        }
    }];
    
}

#pragma mark - Delete Methods

-(void)deleteCoffee   {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            NSLog(@"item deleted");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self removeEditObjectView:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
            NSLog(@"item failed to delete with error: %@", [error description]);
    }];
    
    
}

-(IBAction)deleteMode  {
    //[self performSelector:@selector(createActionSheet) withObject:nil afterDelay:0.1];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Are You Sure?" otherButtonTitles:nil];
    actionSheet.tag = DELETEACTIONSHEET;
    [actionSheet showInView:_editView];
}

#pragma mark - Share Methods

-(void)shareMode
{
    
    UIImage * shareImage = _imageView.image;
    
    NSArray *itemArray = @[shareImage];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:NULL];
    
}

#pragma mark - Nav Bar Methods

-(void)toggleBackgroundState
{
    _navHidden = !_navHidden;
    
    [[self navigationController] setNavigationBarHidden:_navHidden animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = _toolbar.frame;
        frame.origin.y = [self toolbarYOrigin];
        
        if(_navHidden) {
            [self.navigationController setToolbarHidden:YES];
        }
        else    {
            
        }
        
        [_toolbar setFrame:frame];
        [self setNeedsStatusBarAppearanceUpdate];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(float)toolbarYOrigin
{
    float y = self.view.frame.size.height;
    if(!_navHidden)
        y -= TOOLBAR_HEIGHT;
    return y;
}

-(void)shareButtonPressed
{
    UIImage * shareData = [_imageView image];
    NSURL * shareURL = [NSURL URLWithString:@"http://www.futureapplink.com"];
    NSString * shareString = @"#BestBean";
    NSArray *itemArray = @[shareString, shareURL, shareData];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:NULL];
}

-(void)editButtonPressed
{
    [self setupEditView];
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
int editCurrRating = 0;
int editTempRating = 0;
-(void)setupEditView
{
    _editMode = true;
    
    _editView = [[UIView alloc] initWithFrame:self.view.frame];
    _editView.backgroundColor = [UIColor brownColor];
    //_editView.alpha = 1.0;
    
    UIToolbar * editToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, TOOLBAR_HEIGHT)];
    editToolbar.backgroundColor = [UIColor blackColor];
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelNewObjectView)];
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNewObject)];
    UIBarButtonItem * separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    editToolbar.items = @[cancelButton, separator, saveButton];
    [_editView addSubview:editToolbar];
    
    // Setup the scroll view
    UIScrollView * editScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT)];
    editScrollView.contentSize = CGSizeMake(320, 800);
    editScrollView.tag = SCROLLVIEWTAG;
    
    // Setup the Image view, tag it, and add to scroll view
    UIImageView * editImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 20, 306, 306)];
    editImageView.layer.cornerRadius = 5.0;
    editImageView.layer.masksToBounds = YES;
    if (_imageView.image) {
        editImageView.image = _imageView.image;
    }
    else
        editImageView.image = [UIImage imageNamed:@"add_image.png"];
    editImageView.userInteractionEnabled = YES;
    editImageView.tag = IMAGEVIEWTAG;
    [editScrollView addSubview:editImageView];
    UIButton * takePictureButton = [[UIButton alloc] initWithFrame:editImageView.frame];
    [takePictureButton addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
    [editImageView addSubview:takePictureButton];
    
    // Setup the Name field, tag it, and add to scroll view
    UITextField * nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 330, 220, 30)];
    nameField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    nameField.text = _parseObject[@"coffeeName"];
    nameField.placeholder = @"Name";
    nameField.layer.cornerRadius = 5.0;
    nameField.tag = NAMEFIELDTAG;
    nameField.delegate = self;
    [editScrollView addSubview:nameField];
    
    // Setup the Location Name field, tag it, and add to scroll view
    UITextField * locationNameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 380, 220, 30)];
    locationNameField.backgroundColor =[[AppDelegate sharedInstance] subViewTintColor];
    locationNameField.layer.cornerRadius = 5.0;
    locationNameField.text = _parseObject[@"locationName"];
    locationNameField.placeholder = @"Location Name";
    locationNameField.tag = LOCATIONNAMETAG;
    locationNameField.delegate = self;
    [editScrollView addSubview:locationNameField];
    
    // Setup the rating view with a picker for input view, tag it, and add it to scroll view
    UIPickerView * ratingPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 216, 320, 216)];
    ratingPicker.delegate = self;
    ratingPicker.dataSource = self;
    ratingPicker.showsSelectionIndicator = YES;
    
    UITextField * ratingField = [[UITextField alloc] initWithFrame:CGRectMake(10, 430, 220, 30)];
    ratingField.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    ratingField.layer.cornerRadius = 5.0;
    ratingField.text = [[NSNumber numberWithInt:[_parseObject[@"rating"] intValue]] stringValue];
    ratingField.placeholder = @"Rating";
    ratingField.tag = RATINGFIELDTAG;
    ratingField.inputView = ratingPicker;
    
    [editScrollView addSubview:ratingField];
    
    //_ratingChoices = @[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zero_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zero_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"one_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"two_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"three_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"four_rating.png"]], [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"full_rating.png"]]];
    
    // Setup the Notes Text View, tag it, and add it to scroll view
    UITextView * notesView = [[UITextView alloc] initWithFrame:CGRectMake(10, 480, 300, 240)];
    notesView.layer.cornerRadius = 5.0;
    notesView.backgroundColor = [[AppDelegate sharedInstance] subViewTintColor];
    notesView.text = _parseObject[@"coffeeNotes"];
    notesView.scrollEnabled = YES;
    notesView.tag = NOTESVIEWTAG;
    notesView.delegate = self;
    [editScrollView addSubview:notesView];
    
    NSArray *deleteContent = [NSArray arrayWithObjects: @"Delete Item", nil];
    UISegmentedControl * deletButton = [[UISegmentedControl alloc] initWithItems:deleteContent];
    CGRect frame = CGRectMake(0,740,320,40);
    deletButton.frame = frame;
    UIFont *Boldfont = [UIFont boldSystemFontOfSize:18.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:Boldfont
                                                           forKey:NSFontAttributeName];
    [deletButton setTitleTextAttributes:attributes
                               forState:UIControlStateNormal];
    deletButton.selectedSegmentIndex = -1;
    [deletButton addTarget:self action:@selector(deleteMode) forControlEvents:UIControlEventValueChanged];
    deletButton.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:74.0f/255.0f blue:54.0f/255.0f alpha:0.8f];
    deletButton.tintColor = [UIColor whiteColor];
    deletButton.momentary = YES;
    [editScrollView addSubview:deletButton];
    //
    [_editView addSubview:editScrollView];
    
    if (!_navHidden) {
        [self toggleBackgroundState];
    }
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         [self.view addSubview:_editView];
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
    return 5;
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
    editCurrRating = row;
    NSArray * newObjectSubviews = [_editView subviews];
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
    [pickerView removeFromSuperview];
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
    
    NSArray * newObjectSubviews = [_editView subviews];
    for (int i = 0; i < [newObjectSubviews count]; i++) {
        if ([[newObjectSubviews objectAtIndex:i] tag] == SCROLLVIEWTAG) {
            NSLog(@"Found Scroll View");
            UIScrollView * tempScrollView = (UIScrollView *)[newObjectSubviews objectAtIndex:i];
            NSArray * scrollViewSubviews = [tempScrollView subviews];
            for (int j = 0; j < [scrollViewSubviews count]; j++) {
                if ([[scrollViewSubviews objectAtIndex:j] tag] == NAMEFIELDTAG) {
                    UITextField * tempField = (UITextField *)[scrollViewSubviews objectAtIndex:j];
                    NSLog(@"tempfield text: %@", tempField.text);
                    _parseObject[@"coffeeName"] = tempField.text;
                }
                else if ([[scrollViewSubviews objectAtIndex:j] tag] == IMAGEVIEWTAG) {
                    UIImageView * tempImageView = (UIImageView *)[scrollViewSubviews objectAtIndex:j];
                    NSLog(@"returned the image view");
                    //UIImage
                    UIImage * iconImage = [self imageWithImage:tempImageView.image scaledToSize:CGSizeMake(53, 53)];
                    PFFile *uploadFile = [PFFile fileWithData:UIImageJPEGRepresentation(tempImageView.image, 1.0)];
                    PFFile *iconFile  = [PFFile fileWithData:UIImageJPEGRepresentation(iconImage, 0.25)];
                    _parseObject[@"coffeePhoto"] = uploadFile;
                    _parseObject[@"iconImage"] = iconFile;
                }
                else if ([[scrollViewSubviews objectAtIndex:j] tag] == NOTESVIEWTAG)    {
                    UITextView * tempView = (UITextView *)[scrollViewSubviews objectAtIndex:j];
                    _parseObject[@"coffeeNotes"] = tempView.text;
                }
                else if ([[scrollViewSubviews objectAtIndex:j] tag] == LOCATIONNAMETAG) {
                    UITextView * tempView = (UITextView *)[scrollViewSubviews objectAtIndex:j];
                    _parseObject[@"locationName"] = tempView.text;
                }
            }
            break;
        }
    }
    
    //coffeeCup[@"creationDate"] = [NSDate date];
    _parseObject[@"rating"] = [NSNumber numberWithInt:editCurrRating];
    
    [MBProgressHUD showHUDAddedTo:_editView animated:YES];
    
    [_parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            //[relation addObject:coffeeCup];
            //[user saveInBackground];
            [self removeEditObjectView:nil];
            [MBProgressHUD hideHUDForView:_editView animated:YES];
        }
        else    {
            NSLog(@"save failed with error: %@", [error description]);
            UIAlertView * saveFailAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Save Failed!"
                                           message:@"There was an error saving your coffee.  Try to save again.  If you continue to have issues, please contact the admin in Settings"
                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [saveFailAlert show];
        }
        
    }];
    
}

-(void)cancelNewObjectView
{
    
    [self removeEditObjectView:nil];
    
}

-(void)removeEditObjectView:(NSSet *)objects
{
    _editMode = false;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         [_editView removeFromSuperview];
                         [self configureView];
                         [self toggleBackgroundState];
                     }completion:^(BOOL finished){
                         NSLog(@"animation completed");
                     }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"did finish picking media with info");
    UIImage *outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    NSArray * newObjectSubviews = [_editView subviews];
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
                    _imageView.image = outputImage;
                }
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)createActionSheet    {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
        actionSheet.alpha = 1.0;//0.8;
        actionSheet.tag = IMAGEACTIONSHEET;
        [actionSheet showInView:_editView];
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

#pragma mark - Action Sheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex    {
    
    if (actionSheet.tag == DELETEACTIONSHEET) {
        if (buttonIndex == 0) {
            [self deleteCoffee];
        }
        if (buttonIndex == 1)   {
            
        }
    }
    else if (actionSheet.tag == IMAGEACTIONSHEET)   {
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
    
    
}

#pragma mark - Text Field Delegates

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [_editView setFrame:CGRectMake(_editView.frame.origin.x,
                                       0, _editView.frame.size.width,
                                       _editView.frame.size.height)];
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
            newY = -200;
            break;
            
        case LOCATIONNAMETAG:
            newY = -220;
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [_editView setFrame:CGRectMake(_editView.frame.origin.x,
                                               newY, _editView.frame.size.width,
                                               _editView.frame.size.height)];
    }completion:^(BOOL finished){
        NSLog(@"text field moved frame up");
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGFloat newY = -200;
    [UIView animateWithDuration:0.3 animations:^{
        [_editView setFrame:CGRectMake(_editView.frame.origin.x,
                                               newY, _editView.frame.size.width,
                                               _editView.frame.size.height)];
    }completion:^(BOOL finished){
        NSLog(@"text field moved frame up");
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGFloat newY = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [_editView setFrame:CGRectMake(_editView.frame.origin.x,
                                               newY, _editView.frame.size.width,
                                               _editView.frame.size.height)];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
