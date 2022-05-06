//
//  ViewController.m
//  iOSInterView
//
//  Created by hushaohui on 2022/4/4.
//  Copyright © 2022 hushaohui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong)NSMutableDictionary *controllers;//控制器配置文件

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iOS八股文";

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
    
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
    
    self.controllers = [[NSMutableDictionary alloc] initWithDictionary:configDic];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.controllers.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *title = [self.controllers.allKeys objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cls = [self.controllers objectForKey:[self.controllers.allKeys objectAtIndex:indexPath.row]];
    UIViewController *controller = [[NSClassFromString(cls) alloc] init];
    controller.title = [self.controllers.allKeys objectAtIndex:indexPath.row];
    controller.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
