//
//  EnoSecondViewController.m
//  BluetoothEx
//
//  Created by hiroto kitamur on 2014/02/13.
//  Copyright (c) 2014年 Hiroto Kitamur. All rights reserved.
//

#import "EnoSecondViewController.h"

#define SERVICE_UUID        @"C7A4A46D-4B89-4BB7-A7BE-863C52326BBF"
#define CHARACTERISTIC_UUID @"6E0F524D-46B3-4A68-9168-D19D277CD845"

@interface EnoSecondViewController ()

@end

@implementation EnoSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ペリフェラルマネージャを起動
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * デバイスのセットアップ
 */
- (void)setupService
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    // characteristic UUIDを生成
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    NSLog( @"[characteristicUUID.description] %@", characteristicUUID.description );
    
    // characteristicの生成
    /*
    uint    battery_level = 39;
    NSData *dataBatteryLevel = [NSData dataWithBytes:&battery_level length:sizeof(battery_level)];
    self.characteristic      = [[CBMutableCharacteristic alloc]
                                initWithType:characteristicUUID
                                properties:CBCharacteristicPropertyRead
                                value:dataBatteryLevel
                                permissions:CBAttributePermissionsReadable];
    */
    NSString *data = @"data";
    self.characteristic = [[CBMutableCharacteristic alloc]
                           initWithType:characteristicUUID
                           properties:CBCharacteristicPropertyRead
                           value:[data dataUsingEncoding:NSUTF8StringEncoding]
                           permissions:CBAttributePermissionsReadable];
    
    // service UUIDの生成
    CBUUID *serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    
    // serviceの生成（主サービス）
    self.service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    NSLog( @"service uuid : %@", self.service.UUID );
    
    // サービスにcharacteristicsをセット
    [self.service setCharacteristics:@[self.characteristic]];
    
    // サービスの登録
    [self.peripheralManager addService:self.service];
}

/**
 * CBPeripheralManagerが初期化されたり状態が変化した際に呼ばれる
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    switch ( peripheral.state ) {
        case CBPeripheralManagerStatePoweredOn:
            // PowerOnならデバイスのセットアップをする
            NSLog( @"%@", @"CBPeripheralManagerStatePoweredOn" );
            [self setupService];
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            NSLog( @"%@", @"CBPeripheralManagerStatePoweredOff" );
            break;
            
        case CBPeripheralManagerStateResetting:
            NSLog( @"%@", @"CBPeripheralManagerStateResetting" );
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            NSLog( @"%@", @"CBPeripheralManagerStateUnauthorized" );
            break;
            
        case CBPeripheralManagerStateUnsupported:
            NSLog( @"%@", @"CBPeripheralManagerStateUnsupported" );
            break;
            
        case CBPeripheralManagerStateUnknown:
            NSLog( @"%@", @"CBPeripheralManagerStateUnknown" );
            break;
            
        default:
            break;
    }
}

/**
 * peripheralManagerがシステムによってリストアされようとする直前に呼ばれる
 */
/* warning が出るのでいったん消す
 http://stackoverflow.com/questions/20956880/corebluetoothwarning-has-no-restore-identifier-but-the-delegate-implements
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}
*/

/**
 * serveceが追加されたとき
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
        didAddService:(CBService *)service
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    NSDictionary *dict = @{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:SERVICE_UUID]]};
    
    // サービスをアドバタイズする
    [self.peripheralManager startAdvertising:dict];
    
    NSLog( @"START ADVERTISING!!!" );
}

/**
 * advertising がスタートしたとき
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    NSLog( @"no error" );
}

/**
 * when a remote central device subscribes to a characteristic’s value.
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
        central:(CBCentral *)central
        didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * when a remote central device unsubscribes from a characteristic’s value.
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral
        central:(CBCentral *)central
        didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * when a local peripheral device is again ready to send characteristic value updates.
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * when a local peripheral device receives an Attribute Protocol (ATT) read request for a characteristic that has a dynamic value.
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * when a local peripheral device receives an Attribute Protocol (ATT) write request for a characteristic that has a dynamic value.
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

@end
