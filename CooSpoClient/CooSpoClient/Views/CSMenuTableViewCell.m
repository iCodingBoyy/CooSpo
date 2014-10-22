//
//  CSMenuTableViewCell.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSMenuTableViewCell.h"
#import "CooSpoDefine.h"

@implementation CSMenuTableViewCell
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIImage *selectedImage = [UIImage imageNamed:@"menu_cell_selected_bg_image"];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:selectedImage];
        self.selectedBackgroundView = imageView;
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.textColor = UIColorFromRGB(0xFFFFFF);
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    }
    return self;
}

@end
