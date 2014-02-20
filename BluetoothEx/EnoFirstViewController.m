//
//  EnoFirstViewController.m
//  BluetoothEx
//
//  Created by hiroto kitamur on 2014/02/13.
//  Copyright (c) 2014年 Hiroto Kitamur. All rights reserved.
//

#import "EnoFirstViewController.h"

#define SERVICE_UUID        @"C7A4A46D-4B89-4BB7-A7BE-863C52326BBF"
#define CHARACTERISTIC_UUID @"6E0F524D-46B3-4A68-9168-D19D277CD845"

@interface EnoFirstViewController ()

@end

@implementation EnoFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * ペリフェラル（情報を発信する側）が無事に接続された時
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // メソッド名表示
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    NSLog( @"%@", peripheral.description );
    
    // データの初期化
    [self.data setLength:0];
    
    [self.peripheral setDelegate:self];
    
    // サービスの探索を開始
    [self.peripheral discoverServices:@[ [CBUUID UUIDWithString:SERVICE_UUID] ]];
}

/**
 * ペリフェラルの接続が切れたとき
 */
- (void)centralManager:(CBCentralManager *)central
        didDisconnectPeripheral:(CBPeripheral *)peripheral
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        NSLog( @"[error] %@", [error localizedFailureReason] );
        NSLog( @"[error] %@", [error localizedRecoverySuggestion] );
    }
    
    NSLog( @"disconnect" );
}

/**
 * デバイス発見時
 */
- (void)centralManager:(CBCentralManager *)central
        didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary *)advertisementData
        RSSI:(NSNumber *)RSSI
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    [self.centralManager stopScan];
    
    NSLog( @"[RSSI] %@", RSSI );
    
    if ( self.peripheral != peripheral ) {
        
        // 発見されたデバイスに接続
        self.peripheral = peripheral;
        NSLog( @"Connecting to pripheral %@", peripheral );
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 * 接続失敗時
 */
- (void)centralManager:(CBCentralManager *)central
        didFailToConnectPeripheral:(CBPeripheral *)peripheral
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * 接続済みのペリフェラルを見つけたとき
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * centralManagerが知っているペリフェラルを見つけたとき
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * centralManagerが初期化されたり、状態が変化した時
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    switch ( central.state ) {
        case CBCentralManagerStatePoweredOn:
            NSLog( @"%d, CBCentralManagerStatePoweredOn", central.state );
            
            // 単一デバイスの発見イベントを重複して発行させない
            [self.centralManager
             scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:SERVICE_UUID] ]
             options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog( @"%d, CBCentralManagerStatePoweredOff", central.state );
            break;
            
        case CBCentralManagerStateResetting:
            NSLog( @"%d, CBCentralManagerStateResetting", central.state );
            break;
            
        case CBCentralManagerStateUnauthorized:
            NSLog( @"%d, CBCentralManagerStateUnauthorized", central.state );
            break;
            
        case CBCentralManagerStateUnsupported:
            NSLog( @"%d, CBCentralManagerStateUnsupported", central.state );
            break;
            
        case CBCentralManagerStateUnknown:
            NSLog( @"%d, CBCentralManagerStateUnknown", central.state );
            break;
            
        default:
            break;
    }
}

/**
 * centralManagerがリストアされる直前
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * ペリフェラルの利用可能なサービスが見つかった
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    for ( CBService *service in peripheral.services ) {
        
        NSLog( @"Service found with UUID: %@", service.UUID );
        
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID] ] ) {
            
            NSLog( @"discover characteristic!" );
            [self.peripheral
             discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]]
             forService:service];
        }
    }
}

/**
 * 指定したサービスを見つけた
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverIncludedServicesForService:(CBService *)service
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * 指定したサービスのCharacteristicsを見つけた
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverCharacteristicsForService:(CBService *)service
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] ) {
        
        for ( CBCharacteristic *characteristic in service.characteristics ) {
            
            NSLog( @"characteristices is found!" );
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

/**
 * characteristicのdescriptionが見つかった
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * characteristicの値が変更された
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    NSLog( @"no error" );
    
    NSData *data = characteristic.value;
    int     mog  = *(int *)([data bytes]);
    
    NSLog( @"[data] %d", mog );
    
    ushort         value;
    NSMutableData *data2 = [NSMutableData dataWithData:characteristic.value];
    [data2 increaseLengthBy:8];
    [data2 getBytes:&value length:sizeof(value)];
    
    NSLog( @"[data] %d", value );
    
    [self.centralManager cancelPeripheralConnection:peripheral];
}

/**
 * descriptorの値が更新された！
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateValueForDescriptor:(CBDescriptor *)descriptor
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * characteristicを上書きしたとき
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * descriptorがうわがかれた
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didWriteValueForDescriptor:(CBDescriptor *)descriptor
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * 周辺機器が起動したり、characteristicの値の通知の提供を停止する要求を受け取ったとき
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    if ( error ) {
        
        NSLog( @"[error] %@", [error localizedDescription] );
        return;
    }
    
    if ( ![characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] ) {
        
        return ;
    }
    
    if ( characteristic.isNotifying ) {
        
        NSLog( @"Notification began on %@", characteristic );
        [peripheral readValueForCharacteristic:characteristic];
    }
    else {
        
        NSLog( @"Notification stopped on %@. Disconnecting", characteristic );
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

/**
 * RSSIが更新された
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * ペリフェラルの名前が変更された
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

/**
 * ペリフェラルサービスがかわった
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

@end
