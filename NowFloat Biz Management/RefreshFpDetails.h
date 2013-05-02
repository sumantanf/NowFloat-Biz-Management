//
//  RefreshFpDetails.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 15/04/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface RefreshFpDetails : NSObject
{
    NSMutableData *receivedData;
    AppDelegate *appDelegate;
    NSData *msgData;
    NSUserDefaults *userdetails;
}


-(void)fetchFpDetail;


@end
