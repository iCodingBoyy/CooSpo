//
//  CSTGoalViewController.m
//  CooSpoClient
//
//  Created by 马远征 on 14-10-11.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CSTGoalViewController.h"
#import "UIViewController+CSSide.h"
#import "CooSpoDefine.h"
#import "CSCoreData.h"
#import "YZProgressHUD.h"

@interface CSTGoalViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation CSTGoalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textfield.text = nil;
    self.textfield.textColor = UIColorFromRGB(0x2e2e2e);
    self.textfield.font = [UIFont fontWithName:@"Arial" size:45];
    
    // 查询目标与完成情况
    WEAKSELF;STRONGSELF;
    [[CSCoreData shared]fetchTGoal:NO result:^(NSArray *ret, NSError *error) {
        
        NSUInteger steps = 100000;
        if (ret && ret.count > 0)
        {
            NSDictionary *dict = [ret lastObject];
            if (dict)
            {
                steps = [dict[@"dailyGoals"] integerValue];
            }
        }
        [strongSelf.textfield setText:[NSString stringWithFormat:@"%ld",(unsigned long)steps]];
    }];
}

#pragma mark -
#pragma mark UIControl

- (IBAction)clickToSaveTargetSetting:(id)sender
{
    [self.view endEditing:YES];
    if (_textfield.text.length <= 0)
    {
        // 提示保存失败
        [[YZProgressHUD HUD]showWithError:self.view.window labelText:@"提示" detailText:@"请设置运动目标"];
        return;
    }

    [[YZProgressHUD HUD]showOnWindow:self.view.window labelText:@"正在保存,请稍后..." detailText:nil];
    
    [[CSCoreData shared]insertOrUpdateUserInfo:@{@"goal":@(_textfield.text.integerValue)}];
    [[CSCoreData shared]insertOrUpdateTGoal:@{@"goal":@(_textfield.text.integerValue)}];
    // 显示保存成功
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Event_Goal_Setting_notify" object:nil];
    
    [[YZProgressHUD HUD]hideWithSuccess:@"保存成功" detailText:nil];
}

- (IBAction)TapToEndEditing:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (IBAction)clickToShowLeftMenu:(id)sender
{
    if (self.navigationController.sideController)
    {
        [self.navigationController.sideController showLeftViewController:YES];
    }
}

#pragma mark -
#pragma mark UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textfield)
    {
        if ([string isEqualToString:@"\n"]||[string isEqualToString:@""])
        {
            return YES;
        }
        NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (toBeString.length >= 6)
        {
            self.textfield.text = [toBeString substringToIndex:6];
            if ([textField.text integerValue] > 100000)
            {
                self.textfield.text = @"100000";
            }
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
