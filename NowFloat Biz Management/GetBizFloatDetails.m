//
//  GetBizFloatDetails.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 29/05/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "GetBizFloatDetails.h"

@implementation GetBizFloatDetails
@synthesize delegate;

-(void)getBizfloatDetails:(NSString *)floatID
{

    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    floatData=[[NSMutableData alloc]init];
    
    NSString *urlString=[NSString stringWithFormat:
                         @"%@/Discover/v1/bizFloatForWeb/%@?clientId=%@",appDelegate.apiUri,floatID,appDelegate.clientId];
    
    
    NSMutableURLRequest *getFloatDetailsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    
    NSURLConnection *theConnection;
    
    theConnection =[[NSURLConnection alloc] initWithRequest:getFloatDetailsRequest delegate:self];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data1
{
    
    [floatData appendData:data1];
    
}




- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{


    NSError* error;
    NSMutableDictionary* json = [NSJSONSerialization
                                 JSONObjectWithData:floatData
                                 options:kNilOptions
                                 error:&error];

    
    [delegate performSelector:@selector(getKeyWords:) withObject:json];
    
    
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//    int code = [httpResponse statusCode];


}

-(void)connection:(NSURLConnection *)connection   didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert= [[UIAlertView alloc] initWithTitle: [error localizedDescription] message: [error localizedFailureReason] delegate:nil                  cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [errorAlert show];
    
    NSLog (@"Connection Failed in getting GETBIZFLOAT :%@",[error localizedFailureReason]);
    
}


@end