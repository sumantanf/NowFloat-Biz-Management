//
//  CreateStoreDeal.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 12/02/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface CreateStoreDeal : NSObject
{

    AppDelegate *appDelegate;
    
}

-(void)createDeal:(NSMutableDictionary *)dictionary;

@end
