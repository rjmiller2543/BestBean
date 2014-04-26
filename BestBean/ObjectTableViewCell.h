//
//  ObjectTableViewCell.h
//  BestBean
//
//  Created by Robert Miller on 4/6/14.
//  Copyright (c) 2014 Robert Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeObject.h"
#import <Parse/Parse.h>

@interface ObjectTableViewCell : UITableViewCell

@property (nonatomic, retain) PFObject * parseObject;
@property (nonatomic, retain) UILabel * titleLabel;
@property (nonatomic, retain) UILabel * subtitleLabel;
@property (nonatomic, retain) UIImageView * _imageView;

-(void)configureCell;

@end
