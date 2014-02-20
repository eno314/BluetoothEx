//
//  EnoFirstViewController.h
//  BluetoothEx
//
//  Created by hiroto kitamur on 2014/02/13.
//  Copyright (c) 2014年 Hiroto Kitamur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface EnoFirstViewController : UIViewController <
    CBCentralManagerDelegate,
    CBPeripheralDelegate
>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *peripheral;
@property (nonatomic, strong) NSMutableData    *data;

@end
