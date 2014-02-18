//
//  ACViewController.h
//  AutoCooler
//
//  Created by Caleb Freed on 12/10/13.
//  Copyright (c) 2013 Caleb Freed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TripViewViewController.h"
@import CoreBluetooth;
#import "BLEDefines.h"
#import "BLE.h"



@interface ACViewController : UIViewController <BLEDelegate, UIGestureRecognizerDelegate>
{
    int state;
    int retrieveState;
    int returnedStates;
    BLE *ble;

}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral * arduinoBLE;
@property (nonatomic, strong) NSMutableArray * longs;
@property (nonatomic, strong) NSMutableArray * lats;
@property (nonatomic, strong) NSString * origin;
@property (nonatomic, strong) NSString * destination;
@property (nonatomic, strong) NSMutableArray * markers;
@property (strong, nonatomic) NSString *connected;


//Functions
-(void) receiveStateCheck:(NSString *) received;
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length;
- (void)BLESend:(NSString *)STOS;
- (void) clearDataPoints;
- (void) connectBT;
-(void)getCarLocation;
-(void)sendWaypoints;





@end
