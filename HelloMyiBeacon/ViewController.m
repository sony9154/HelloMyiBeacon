//
//  ViewController.m
//  HelloMyiBeacon
//
//  Created by Peter Yo on 4月/22/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLBeaconRegion *beaconRegion1;
    CLBeaconRegion *beaconRegion2;
}
@property (weak, nonatomic) IBOutlet UILabel *info1Label;
@property (weak, nonatomic) IBOutlet UILabel *info2Label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Prepare LocationManager
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    [locationManager requestAlwaysAuthorization];
    
    // Prepare beaconRegion
    NSUUID *beacon1UUID = [[NSUUID alloc] initWithUUIDString:@"94278BDA-B644-4520-8F0C-720EAF059935"];
    NSUUID *beacon2UUID = [[NSUUID alloc] initWithUUIDString:@"84278BDA-B644-4520-8F0C-720EAF059935"];
    
    beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:beacon1UUID identifier:@"beacon1"];
    beaconRegion1.notifyOnExit = true;//當user離開圈圈時通知
    beaconRegion1.notifyOnEntry = true;//當user進入圈圈時通知
    beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:beacon2UUID identifier:@"beacon2"];
    beaconRegion2.notifyOnExit = true;
    beaconRegion2.notifyOnEntry = true;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enableValueChanged:(id)sender {
    
    if([sender isOn]) {
        [locationManager startMonitoringForRegion:beaconRegion1];
        [locationManager startMonitoringForRegion:beaconRegion2];
        
    } else {
        
        [locationManager stopMonitoringForRegion:beaconRegion1];
        [locationManager stopRangingBeaconsInRegion:beaconRegion1];//
        
        [locationManager stopMonitoringForRegion:beaconRegion2];
        [locationManager stopRangingBeaconsInRegion:beaconRegion2];
        
    }
    
}

- (void) showLocalNotificationWithMessage:(NSString*)message {
    
    NSLog(@"showLocalNotificationWithMessage: %@",message);
    
    UILocalNotification *notify = [UILocalNotification new];
    notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];//比現在的時間稍晚1秒
    notify.alertBody = message;//要跳出來的訊息
    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
    
}

#pragma mark - CLLocationManagerDelegate Methods
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
    [locationManager requestStateForRegion:region];
    
}


-(void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    NSString *message = nil;
    if(state == CLRegionStateInside) {
        
        message = [NSString stringWithFormat:@"User is insode of the region: %@",region.identifier];
        // Start ranging...
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
        
    } else if (state == CLRegionStateOutside) {
        
        message = [NSString stringWithFormat:@"User is outside of the region: %@",region.identifier];
        // Stop ranging...
        [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    }
    
    [self showLocalNotificationWithMessage:message];
    
    
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    //5/5 AM11:00
    //for(CLBeaconRegion *tmp in beacons) {
    for(CLBeacon *tmp in beacons) {
        NSString *proximityString;
        switch(tmp.proximity) {
            
            case CLProximityImmediate:
                proximityString = @"Immediate";
                break;
            case CLProximityNear:
                proximityString =@"Near";
            case CLProximityFar:
                proximityString = @"Far";
                break;
            case CLProximityUnknown:
                proximityString = @"Unknown";
            break;
        }
        
        //Prepare info string
        NSString *info = [NSString stringWithFormat:@"%@,RSSI:%ld,%@,Accuracy:%.2f",region.identifier,(long)tmp.rssi,proximityString,tmp.accuracy];
        
        if([region.identifier isEqualToString:beaconRegion1.identifier]) {
            _info1Label.text = info;
        } else if ([region.identifier isEqualToString:beaconRegion2.identifier]) {
            _info2Label.text = info;
        }
    }
    
}


@end























