//
//  EnoSecondViewController.h
//  BluetoothEx
//
//  Created by hiroto kitamur on 2014/02/13.
//  Copyright (c) 2014年 Hiroto Kitamur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface EnoSecondViewController : UIViewController<
    CBPeripheralManagerDelegate
>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBCharacteristic    *characteristic;
@property (nonatomic, strong) CBMutableService    *service;

@end
