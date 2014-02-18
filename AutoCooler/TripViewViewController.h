//
//  TripViewViewController.h
//  AutoCooler
//
//  Created by Caleb Freed on 1/29/14.
//  Copyright (c) 2014 Caleb Freed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripViewViewController : UITableViewController


@property (nonatomic, strong) NSMutableArray * longs;
@property (nonatomic, strong) NSMutableArray * lats;
@property int numberSteps;

@end
