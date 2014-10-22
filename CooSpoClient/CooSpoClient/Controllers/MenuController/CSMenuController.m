//
//  CSMenuController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-10.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSMenuController.h"
#import "CSAboutViewController.h"
#import "UIViewController+CSSide.h"
#import "CSNavigationController.h"
#import "CSTabBarController.h"
#import "CSAlertView.h"
#import "YZProgressHUD.h"

@interface CSMenuController() <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CSMenuController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // 默认选中第一行
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_home_image"];
        cell.textLabel.text = NSLocalizedString(@"首页",nil);
    }
    else if (indexPath.row == 1)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_goal_image"];
        cell.textLabel.text = NSLocalizedString(@"今日目标",nil);
    }
    else if (indexPath.row ==2)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_record_image"];
        cell.textLabel.text = NSLocalizedString(@"历史记录",nil);
    }
    else if (indexPath.row == 3)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_perData_image"];
        cell.textLabel.text = NSLocalizedString(@"个人资料",nil);
    }
    else if (indexPath.row == 4)
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_update_image"];
        cell.textLabel.text = NSLocalizedString(@"版本更新",nil);
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"menu_cell_about_image"];
        cell.textLabel.text = NSLocalizedString(@"关于我们",nil);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        UINavigationController *cooSpoNavVC = [CSNavigationController shared];
        [self.sideController setRootViewController:cooSpoNavVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        UINavigationController *tGoalNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CSTGoalController"];
        [self.sideController setRootViewController:tGoalNavVC animated:YES];
    }
    else if (indexPath.row ==2)
    {
        UINavigationController *recordsNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CSTabBarController"];
        [self.sideController setRootViewController:recordsNavVC animated:YES];
    }
    else if (indexPath.row == 3)
    {
        UINavigationController *profileNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CSProfileController"];
        [self.sideController setRootViewController:profileNavVC animated:YES];
    }
    else if (indexPath.row == 4)
    {
        [[YZProgressHUD HUD]showOnWindow:self.view.window labelText:@"正在检查新版本" detailText:nil];
        [self performSelector:@selector(checkNewVersion) withObject:nil afterDelay:2];
    }
    else
    {
        
        UINavigationController *aboutNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CSAboutController"];
        [self.sideController setRootViewController:aboutNavVC animated:YES];
    }

}

- (void)checkNewVersion
{
    [[YZProgressHUD HUD]hide];
    CSAlertView *alertView = [[CSAlertView alloc]initWithTitle:@"版本更新"
                                                       message:@"已是最新版本"
                                                      complete:nil
                                             cancelButtonTitle:@"确定"
                                            confirmButtonTitle:nil];
    [alertView show];
    alertView = nil;
}
@end
