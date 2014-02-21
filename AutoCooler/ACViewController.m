//
//  ACViewController.m
//  AutoCooler
//
//  Created by Caleb Freed on 12/10/13.
//  Copyright (c) 2013 Caleb Freed. All rights reserved.
//

#import "ACViewController.h"

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

@interface ACViewController ()

@end


@implementation ACViewController
{
    GMSMapView *mapView_;
}
@synthesize lats, longs, origin, destination, markers;
-(void) viewWillAppear:(BOOL)animated{
}

- (void)extracted_method:(NSString *)dest origin:(NSString *)orig
{
    NSString *subUrl = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=true&mode=walking", kMDDirectionsURL, orig, dest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:subUrl  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary * tempDict = (NSDictionary *)responseObject;
        //_response = tempDict[@"data"];
        NSDictionary *steps;
        NSDictionary *currSteps;
        
        steps = (NSDictionary*)tempDict[@"routes"][0][@"legs"][0];
        NSLog(@"routes:%@", tempDict[@"routes"][0][@"legs"][0][@"steps"][0][@"end_location"][@"lat"]);
        NSLog(@"steps: %@", steps[@"steps"][0]);
        int i = 1;
        returnedStates = (int)[steps[@"steps"] count];
        while(i < [steps[@"steps"] count])
        {
            NSLog(@"Loop");
            
            currSteps = steps[@"steps"][i];
            [lats addObject:currSteps[@"end_location"][@"lat"]];
            //[lats addObject:currSteps[@"start_location"][@"lat"]];
            [longs addObject:currSteps[@"end_location"][@"lng"]];
            //[longs addObject:currSteps[@"start_location"][@"lng"]];
            i++;
        }
        NSLog(@"%@, %@", lats, longs);
        
//        GMSMarker *marker = [[GMSMarker alloc] init];
        //marker.position = CLLocationCoordinate2DMake([[lats objectAtIndex:0] doubleValue], [[longs objectAtIndex:0] doubleValue]);
//        marker.title = @"Start";
//        marker.snippet = @"Australia";
//        marker.map = mapView_;
        int num = (int)[lats count];
        [mapView_ clear];
        for(i = 0; i<num;i++)
        {
            
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[lats objectAtIndex:i] doubleValue], [[longs objectAtIndex:i] doubleValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.title = [NSString stringWithFormat:@"S:%i %@,%@",i,[lats objectAtIndex:i],[longs objectAtIndex:i]];
            marker.map = mapView_;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // add gesture recodgnizer to the grid view to start the edit mode
//    UILongPressGestureRecognizer *pahGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerStateChanged:)];
//    pahGestureRecognizer.minimumPressDuration = 0.5;
//    [self.view addGestureRecognizer:pahGestureRecognizer];
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
//Current instruction state
    state = 0;
    retrieveState = 0;
//    Setting up the map and camera
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.110766
                                                            longitude:-88.227755
                                                                 zoom:18];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.mapType = kGMSTypeSatellite;

    self.view = mapView_;
    
//    Set up the gesture regconizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    longPress.delegate = self;
    
//    Add the reconizer to the view
    [mapView_ addGestureRecognizer:longPress];
// Adds the instruction label
    self.navigationItem.title = @"Waiting for BT connection...";
//    Adds the clear data points button
//    UIButton * clear = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [clear addTarget:self action:@selector(clearDataPoints) forControlEvents:UIControlEventTouchDown];
//    [clear setTitle:@"Clear Points" forState:UIControlStateNormal];
//    clear.backgroundColor = [UIColor whiteColor];
//    clear.frame = CGRectMake(190, 525, 100 , 30);
//    [self.view addSubview:clear];
//    Adds the steps view button
//    UIButton * stepsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [stepsButton addTarget:self action:@selector(stepsButtonPressed) forControlEvents:UIControlEventTouchDown];
//    [stepsButton setTitle:@"Steps" forState:UIControlStateNormal];
//    stepsButton.backgroundColor = [UIColor whiteColor];
//    stepsButton.frame = CGRectMake(80, 525, 100 , 30);
//    [self.view addSubview:stepsButton];
    
    //Get Car Location button
    UIBarButtonItem *carLocButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(getCarLocation)];
    
    //Start Navigation button
    UIBarButtonItem *startNav = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(sendWaypoints)];
    
    //Space
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //Adds magnifying glass for searching for bluetooth
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(connectBT)];

    //Clear Points
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clearDataPoints)];
    //Show steps
    UIBarButtonItem *steps= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(stepsButtonPressed)];

    NSArray *items = [NSArray arrayWithObjects:connectButton,flexibleItem,carLocButton,flexibleItem, steps, flexibleItem, startNav, flexibleItem, cancelButton, nil];
    self.toolbarItems = items;
    
    lats = [[NSMutableArray alloc] init];
    longs = [[NSMutableArray alloc] init];
    markers = [[NSMutableArray alloc] init];

    
}


/*
 *  Sends an "o" to tell the arduino to send the current location
 
 
 
 */
-(void)getCarLocation
{
    NSLog(@"Get Car Location");
    //Get car location;
    [self BLESend:@"o"];
    self.navigationItem.title = @"Long press for destination";
}

/*      Sends the waypoints in this order:
 *          First: how many steps there are.
 *          Second: Origin lat followed immediately by origin long
 *          Third:  Remaining coordinates in the same order.
 *  May need to change this to incoporate an ack signal
*/
-(void)sendWaypoints
{
    [self BLESend:[NSString stringWithFormat:@"%i",returnedStates]];
    
    for(int i = 0; i < returnedStates; i++)
    {
        NSLog(@"In loop for sending: %@", [lats objectAtIndex:i]);
        [self BLESend:[NSString stringWithFormat:@"%@",[lats objectAtIndex:i]]];
        [self BLESend:[NSString stringWithFormat:@"%@",[longs objectAtIndex:i]]];
    }
}

-(void) connectionTimer:(NSTimer *)timer
{
    if(ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }

}

- (void) bleDidDisconnect{
    NSLog(@"Wanting to disconnect");
}

- (void) connectBT
{
    NSLog(@"Connect Button Pressed");
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [ble findBLEPeripherals:3];
    
    

    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    self.navigationItem.title = @"Waiting on car location...";

}

- (void) stepsButtonPressed
{
    [self performSegueWithIdentifier:@"toSteps" sender:self];
}

- (void) clearDataPoints
{
    [mapView_ clear];
    state = 0;
    retrieveState = 0;
    [longs removeAllObjects];
    [lats removeAllObjects];
    self.navigationItem.title = @"Waiting on car location...";
    origin = @"";
    destination = @"";
}

//  To allow long press gesture and map gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

//Set up the response to the long press gesture handler
-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        CGPoint touchPoint = [sender locationInView:self.view];
        NSLog(@"Touched at %f, %f", touchPoint.x, touchPoint.y);
        CLLocationCoordinate2D touchMapCoordinate = [mapView_.projection coordinateForPoint:touchPoint];
        NSLog(@"%f, %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);

//        if (state == 0)
//        {
//            GMSMarker *org = [GMSMarker markerWithPosition:touchMapCoordinate];
//            org.title = [NSString stringWithFormat:@"Start: %f,%f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
//            org.map = mapView_;
//            [markers addObject:org];
//            origin = [NSString stringWithFormat:@"%f,%f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
//            [lats addObject:[NSString stringWithFormat:@"%f", touchMapCoordinate.latitude]];
//            [longs addObject:[NSString stringWithFormat:@"%f", touchMapCoordinate.longitude]];
//
//            state = 1;
//            instructions.text = @"Long press for Destination";
//            
//        }
//        State 1 is to add the destination
        if(state == 1)
        {
            GMSMarker *dest = [GMSMarker markerWithPosition:touchMapCoordinate];
            dest.title = [NSString stringWithFormat:@"End: %f,%f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
            dest.map = mapView_;
            destination = [NSString stringWithFormat:@"%f,%f", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
            state = 2;
            self.navigationItem.title = @"Route Shown";
            [self extracted_method:destination origin:origin];
            
            GMSMarker * temp = markers[0];
            temp.map = nil;
            dest.map = nil;
            
        }
//        State 2 is to add additional trip points
        else if(state == 2)
        {
            GMSMarker *marker = [GMSMarker markerWithPosition:touchMapCoordinate];
            marker.title = [NSString stringWithFormat:@"ADD STEP: %f,%f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
            [longs addObject:[NSString stringWithFormat:@"%f", touchMapCoordinate.longitude]];
            [lats addObject:[NSString stringWithFormat:@"%f", touchMapCoordinate.latitude]];

            marker.map = mapView_;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [[segue destinationViewController] setNumberSteps:returnedStates];
    [[segue destinationViewController] setLats:lats];
    [[segue destinationViewController] setLongs:longs];

}

- (void)BLESend:(NSString *)STOS
{
    
    NSString *s;
    NSData *d;
    NSLog(@"beginning blesend");
    if (STOS.length > 16)
        s = [STOS substringToIndex:16];
    else
        s = STOS;
    NSLog(@"Middle BLESend");
    s = [NSString stringWithFormat:@"%@\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Sent: %@ Data: %@",s,d);
    
    
    [ble write:d];
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSLog(@"d: %@", d);
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    double thing = [s doubleValue];
    NSLog(@"Reveived int value: %f, string is: %@", thing, s);
    NSLog(@"Retrieve State = %i", retrieveState);
    [self receiveStateCheck:s];
}

-(void) receiveStateCheck:(NSString *) received
{
//    NSLog(@"Received: %@",received);
//    NSUInteger length = [received length];
//    received = [received stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, length)];

    //    Get the first part of the gps coordinate from the car
    if(retrieveState == 0)
    {
        NSLog(@"Received: %@",received);
        NSUInteger length = [received length];
        received = [received stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, length)];
        NSLog(@"Received after: %@",received);

        //      put it in the origin nsstring
        origin = [NSString stringWithFormat:@"%@",received];
        NSLog(@"Origin: %@", origin);
        NSArray* split = [received componentsSeparatedByString: @","];

        //      also the lats array
        [lats addObject:[split firstObject]];
        //        put in the long array
        [longs addObject:[split lastObject]];
        //        next state
        //        Turn it into a coordinate and make the marker
        CLLocationCoordinate2D orginLocation = CLLocationCoordinate2DMake([[lats objectAtIndex:0] doubleValue], [[longs objectAtIndex:0] doubleValue]);
        GMSMarker * org = [GMSMarker markerWithPosition:orginLocation];
        org.title = [NSString stringWithFormat:@"End: %f,%f",orginLocation.latitude,orginLocation.longitude];
        org.map = mapView_;
        [markers addObject:org];

        //        Next state for next received
        state = 1;
        retrieveState = 1;
    }
    //    Get the second part of the gps coordinate, the longitude
    else if(retrieveState == 1)
    {
        NSLog(@"Shit");
    }
    //    Then something else sent or recieved
    else if(retrieveState == 2)
    {
        NSLog(@"something else recieved: %@", received);
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
//===============================================================================================================================
//
//CORE BLUETOOTH REQUIREMENTS
//
//
//
//
//
//
//
//
//===============================================================================================================================
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
//{
//    [peripheral setDelegate:self];
//    [peripheral discoverServices:nil];
//    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
//    NSLog(@"%@", self.connected);
//}
//
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
//{
//    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
//    if ([localName length] > 0) {
//        NSLog(@"Target Aquired: %@", localName);
//        [self.centralManager stopScan];
//        self.arduinoBLE = peripheral;
//        peripheral.delegate = self;
//        [self.centralManager connectPeripheral:peripheral options:nil];
//    }
//}
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    // Determine the state of the peripheral
//    if ([central state] == CBCentralManagerStatePoweredOff) {
//        NSLog(@"CoreBluetooth BLE hardware is powered off");
//    }
//    else if ([central state] == CBCentralManagerStatePoweredOn) {
//        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
//    }
//    else if ([central state] == CBCentralManagerStateUnauthorized) {
//        NSLog(@"CoreBluetooth BLE state is unauthorized");
//    }
//    else if ([central state] == CBCentralManagerStateUnknown) {
//        NSLog(@"CoreBluetooth BLE state is unknown");
//    }
//    else if ([central state] == CBCentralManagerStateUnsupported) {
//        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
//    }
//}
//
//#pragma mark - CBPeripheralDelegate
//
//// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
//{
//    for (CBService *service in peripheral.services) {
//        NSLog(@"Discovered service: %@", service.UUID);
//        [peripheral discoverCharacteristics:nil forService:service];
//    }
//}
//
//// Invoked when you discover the characteristics of a specified service.
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
//{
//    if (!error)
//    {
//        //        printf("Characteristics of service with UUID : %s found\n",[self CBUUIDToString:service.UUID]);
//        
//        for (int i=0; i < service.characteristics.count; i++)
//        {
//            //            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
//            //            printf("Found characteristic %s\n",[ self CBUUIDToString:c.UUID]);
//            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
//            
//            if ([service.UUID isEqual:s.UUID])
//            {
//                
//                NSLog(@"Something is happening in didDiscoverCharacteristscs for Service funct");
//                break;
//            }
//        }
//    }
//    else
//    {
//        NSLog(@"Characteristic discorvery unsuccessful!");
//    }
//}
//
//// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//{
//    unsigned char data[20];
//    
//    static unsigned char buf[512];
//    static int len = 0;
//    NSInteger data_len;
//    NSLog(@"Char Changed");
//    if (!error)
//    {
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@RBL_CHAR_TX_UUID]])
//        {
//            data_len = characteristic.value.length;
//            [characteristic.value getBytes:data length:data_len];
//            NSLog(@"Data:0x%02x",(unsigned char) data);
//            NSLog(@"%s", data);
//            if (data_len == 20)
//            {
//                memcpy(&buf[len], data, 20);
//                len += data_len;
//                NSLog(@"Buffer when = 20: %s", buf);
//            }
//            else if (data_len < 20)
//            {
//                memcpy(&buf[len], data, data_len);
//                len += data_len;
//                len = 0;
//                NSLog(@"Buffer Length < 20: %s", buf);
//            }
//        }
//    }
//    else
//    {
//        NSLog(@"updateValueForCharacteristic failed!");
//    }
//}



@end
