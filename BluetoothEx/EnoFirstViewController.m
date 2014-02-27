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

/**
 * FirstViewでセントラルマネージャーとなる
 */
@implementation EnoFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // セントラルマネージャーの起動
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * centralManagerが初期化されたり、状態が変化した時
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
    
    switch ( central.state ) {
        case CBCentralManagerStatePoweredOn:
            NSLog( @"%@", @"CBCentralManagerStatePoweredOn" );
            // ペリフェラルの走査開始（単一デバイスの発見イベントを重複して発行させない）
            [self.centralManager
             // scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]
             scanForPeripheralsWithServices:nil
             options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            break;
            
        case CBCentralManagerStatePoweredOff:
            NSLog( @"%@", @"CBCentralManagerStatePoweredOff" );
            break;
            
        case CBCentralManagerStateResetting:
            NSLog( @"%@", @"CBCentralManagerStateResetting" );
            break;
            
        case CBCentralManagerStateUnauthorized:
            NSLog( @"%@", @"CBCentralManagerStateUnauthorized" );
            break;
            
        case CBCentralManagerStateUnsupported:
            NSLog( @"%@", @"CBCentralManagerStateUnsupported" );
            break;
            
        case CBCentralManagerStateUnknown:
            NSLog( @"%@", @"CBCentralManagerStateUnknown" );
            break;
            
        default:
            break;
    }
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
    
    NSLog( @"Discovered %@", peripheral.name );
    
    // 省電力のため、他のペリフェラルの走査は停止する
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    NSLog( @"[RSSI] %@", RSSI );
    
    if ( self.peripheral != peripheral ) {
        
        // 発見されたデバイスに接続
        self.peripheral = peripheral;
        NSLog( @"Connecting to pripheral %@", peripheral );
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
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
    
    // デリゲート設定
    self.peripheral.delegate = self;
    
    // サービスの探索を開始
    [self.peripheral discoverServices:@[ [CBUUID UUIDWithString:SERVICE_UUID] ]];
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
            
            // サービスの特性を検出する
            [self.peripheral
             discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]]
             forService:service];
        }
    }
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
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID]] ) {
        
        for ( CBCharacteristic *characteristic in service.characteristics ) {
            
            NSLog( @"characteristices is found!" );
            
            // 特性の値を読み取る
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
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
    NSLog( @"[data] %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] );
    /*
    int     mog  = *(int *)([data bytes]);
    
    NSLog( @"[data] %d", mog );
    
    ushort         value;
    NSMutableData *data2 = [NSMutableData dataWithData:characteristic.value];
    [data2 increaseLengthBy:8];
    [data2 getBytes:&value length:sizeof(value)];
    
    NSLog( @"[value] %d", value );
    */
    
    [self.centralManager cancelPeripheralConnection:peripheral];
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
 * centralManagerがリストアされる直前
 */
/* warning が出るのでいったん消す 
 http://stackoverflow.com/questions/20956880/corebluetoothwarning-has-no-restore-identifier-but-the-delegate-implements
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}
*/

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
 * characteristicのdescriptionが見つかった
 */
- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
        error:(NSError *)error
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
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
