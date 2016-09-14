//
//  ViewController.m
//  SqliteTools
//
//  Created by apple on 9/12/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "ViewController.h"
#import "SQFriendsDAO.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) SQFriendsDAO *friendsDAO;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsDAO = [[SQFriendsDAO alloc]init];
    NSDictionary *dict = @{@"USER_CODE":@"1",@"USER_NAME":@"南风不竞",@"FRIEND_CODE":@"1"};
    [self.friendsDAO save:dict];
    NSDictionary *dict1 = @{@"USER_CODE":@"2",@"USER_NAME":@"秋风不下惋红曲",@"FRIEND_CODE":@"2"};
    [self.friendsDAO save:dict1];
    UIButton *qureyButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    [qureyButton setTitle:@"查询数据" forState:UIControlStateNormal];
    [qureyButton setBackgroundColor:[UIColor blackColor]];
    [qureyButton addTarget:self action:@selector(onClick1) forControlEvents:UIControlEventTouchUpInside];
    UIButton *delButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100,50)];
    [delButton setTitle:@"删除一条数据" forState:UIControlStateNormal];
    [delButton setBackgroundColor:[UIColor blackColor]];
    [delButton addTarget:self action:@selector(onClick2) forControlEvents:UIControlEventTouchUpInside];
    
    self.dataLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, self.view.bounds.size.width, 50)];
    self.dataLabel.layer.borderWidth = 0.1;
    self.dataLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:qureyButton];
    [self.view addSubview:delButton];
    [self.view addSubview:self.dataLabel];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)onClick1{
    SQConditionBean *condition = [[SQConditionBean alloc]init];
    [condition andNE:@"1" forKey:@"FRIEND_CODE"];
    NSArray *array = [self.friendsDAO fetchList:condition];
    NSLog(@"%@",array);
}
- (void)onClick2{
    [self.friendsDAO deleteWithPK:@"1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
