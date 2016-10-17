//
//  ViewController.m
//  XLsn0wNetwork
//
//  Created by XLsn0w on 2016/10/17.
//  Copyright © 2016年 XLsn0w. All rights reserved.
//

#import "ViewController.h"

#import "JMHttpRequestMethod.h"

static NSString *url = @"http://open3.bantangapp.com/recommend/index?app_installtime=1453382654.838161&app_versions=5.3.1&channel_name=appStore&client_id=bt_app_ios&client_secret=9c1e6634ce1c5098e056628cd66a17a5&os_versions=9.2&page=0&pagesize=20&screensize=750&track_device_info=iPhone7%2C2&track_deviceid=8C446621-00E5-4909-8131-131C3C2EF7C7&v=10";

static NSString *url1 = @"http://open3.bantangapp.com/topic/list?app_installtime=1453382654.838161&app_versions=5.3.1&channel_name=appStore&client_id=bt_app_ios&client_secret=9c1e6634ce1c5098e056628cd66a17a5&os_versions=9.2&page=0&pagesize=20&scene=8&screensize=750&track_device_info=iPhone7%2C2&track_deviceid=8C446621-00E5-4909-8131-131C3C2EF7C7&v=10";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)parse:(id)sender {
    [JMHttpRequestMethod getWithUrl:url refreshCache:YES success:^(id responseObject) {
        
 
        NSLog(@"responseObject===%@", responseObject);
        
        // [JMHttpRequestMethod cleanNetWorkRefreshCache];
        NSLog(@"缓存大小为%@",  [JMHttpRequestMethod fileSizeWithDBPath]);
    } fail:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
