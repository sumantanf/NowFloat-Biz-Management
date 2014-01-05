//
//  FileManagerHelper.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 20/10/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface FileManagerHelper : NSObject

@property (nonatomic,strong) NSString *userFpTag;

-(void)createUserSettings;

-(NSMutableDictionary *)openUserSettings;

-(void)updateUserSettingWithValue:(id)value forKey:(id)key;

-(void)removeUserSettingforKey:(id)key;

@end