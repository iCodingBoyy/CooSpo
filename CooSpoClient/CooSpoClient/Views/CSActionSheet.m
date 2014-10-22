//
//  CSActionSheet.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSActionSheet.h"
#import "AppDelegate.h"

@interface CSActionSheet() <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic,   copy) completeBlock cblock;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CSActionSheet
- (id)initWithTitle:(NSString*)title Unit:(NSString*)unit Parmas:(NSArray*)parmas
{
    CGRect bounds = [[UIScreen mainScreen]bounds];
    self = [super initWithFrame:bounds];
    if (self)
    {
        _params = parmas;
        _title = title;
        _unit = unit;
        
        self.backgroundColor = [UIColor clearColor];
        [self setUp];
    }
    return self;
}

- (void)show:(completeBlock)block
{
    _cblock = block;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    [self MoveIn];
}

- (void)setUp
{
    
    
    // 背景图
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    bgImageView.image = [UIImage imageNamed:@"cs_actionsheet_bg_image"];
    [self addSubview:bgImageView];
    
    // contentView
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height*3/4)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    UIImageView *headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width, 40)];
    headerImageView.image = [UIImage imageNamed:@"nav_bg_image"];
    [_contentView addSubview:headerImageView];
    
    // titleLabel
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 24)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    _titleLabel.text = _title;
    [_contentView addSubview:_titleLabel];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, self.bounds.size.width, _contentView.bounds.size.height-40)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_contentView addSubview:_tableView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    if ([myTouch.view isEqual:self])
    {
        [self MoveOut];
    }
}

- (void)MoveOut
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         _contentView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}
- (void)MoveIn
{
    [UIView animateWithDuration:0.35f
                     animations:^{
                         CGFloat height = _contentView.bounds.size.height;
                         _contentView.transform = CGAffineTransformMakeTranslation(0, -height);
                     }
                     completion:^(BOOL finished){}];
}


#pragma mark -
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _params.count;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *string = [_params objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",string,_unit];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *string = [_params objectAtIndex:indexPath.row];
    if (_cblock)
    {
        _cblock([string intValue]);
    }
    [self MoveOut];
}


@end
