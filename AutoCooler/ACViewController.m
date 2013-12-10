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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.110766
                                                            longitude:-88.227755
                                                                 zoom:18];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.mapType = kGMSTypeSatellite;

    self.view = mapView_;
    
    // Creates a marker in the center of the map.

    
    NSMutableArray *lats = [[NSMutableArray alloc] init];
    NSMutableArray *longs = [[NSMutableArray alloc] init];

    
    NSString * origin = @"40.110766,-88.227755";
    NSString * destination = @"40.112339,-88.226931";
    
    
    
    NSString *subUrl = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=true&mode=walking", kMDDirectionsURL, origin, destination];
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
        int i = 0;
        while(i < [steps[@"steps"] count])
        {
            NSLog(@"Loop");

            currSteps = steps[@"steps"][i];
            [lats addObject:currSteps[@"end_location"][@"lat"]];
            [lats addObject:currSteps[@"start_location"][@"lat"]];
            [longs addObject:currSteps[@"end_location"][@"lng"]];
            [longs addObject:currSteps[@"start_location"][@"lng"]];
            i++;
        }
        NSLog(@"%@", lats);
        
            GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[lats objectAtIndex:0] doubleValue], [[longs objectAtIndex:0] doubleValue]);
            marker.title = @"Start";
            marker.snippet = @"Australia";
            marker.map = mapView_;
        int num = [lats count];
        for(i = 0; i<num;i++)
        {
        
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[lats objectAtIndex:i] doubleValue], [[longs objectAtIndex:i] doubleValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.title = [NSString stringWithFormat:@"%@,%@",[lats objectAtIndex:i],[longs objectAtIndex:i]];
            marker.map = mapView_;
        }
        //NSLog(@"single reponse, %@", [[[_response objectForKey:@"data"]objectForKey:@"children"]objectAtIndex:0]);
        //NSLog(@"again single reponse, %@", tempDict[@"data"][@"children"][0][@"data"]);
        
        //[self loadPicture:numPage];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
