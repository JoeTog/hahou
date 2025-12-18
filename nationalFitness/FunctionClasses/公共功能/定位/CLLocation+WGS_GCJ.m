//
//  CLLocation+WGS_GCJ.m
//  nationalFitness
//
//  Created by nevercry on 7/7/15.
//  Copyright (c) 2015 chenglong. All rights reserved.
//

#import "CLLocation+WGS_GCJ.h"
#import "convert.h"

@implementation CLLocation (WGS_GCJ)  

- (CLLocationCoordinate2D)gcjCoord {
    return transform(self.coordinate);
}

@end
