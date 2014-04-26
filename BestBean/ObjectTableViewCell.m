//
//  ObjectTableViewCell.m
//  BestBean
//
//  Created by Robert Miller on 4/6/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import "ObjectTableViewCell.h"

@implementation ObjectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // Set the frame
        NSLog(@"init with style");
        [self configureCell];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"init with frame");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.frame = CGRectMake(0, 0, 320, 53);
    }
    return self;
}

-(void)configureCell
{
    NSLog(@"configure cell");
    
    //self.frame = CGRectMake(0, 0, 320, 63);
    self.contentView.frame = CGRectMake(0, 0, 320, 63);
    self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:210.0/255.0 alpha:1];
    
    // Create the Image view with placeholder and load the image in the background
    __imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 53, 53)];
    __imageView.layer.cornerRadius = 5;
    __imageView.layer.masksToBounds = YES;
    __imageView.image = [UIImage imageNamed:@"cellplaceholder.png"];
    [self performSelectorInBackground:@selector(loadImage:) withObject:__imageView];
    
    // Create the Title Text
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 220, 20)];
    _titleLabel.text = _parseObject[@"coffeeName"];
    
    // Create the Subtitle Test
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 35, 70, 15)];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    NSString * dateString = [dateFormat stringFromDate:_parseObject[@"creationDate"]];
    _subtitleLabel.text = dateString;
    
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
    [self addSubview:__imageView];
    
}

-(void)loadImage:(UIImageView *)imageView
{
    PFFile *userImageFile = _parseObject[@"iconImage"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            [UIView transitionWithView:self.contentView
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
    
}

-(void)prepareForReuse
{
    
    [super prepareForReuse];
    _titleLabel.text = @"";
    _subtitleLabel.text = @"";
    __imageView.image = nil;
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
