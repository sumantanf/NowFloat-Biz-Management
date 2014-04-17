//
//  BusinessAddressViewController.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 31/01/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "BusinessAddressViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexaString.h"
#import "MyAnnotation.h"
#import "UpdateStoreData.h"
#import "Mixpanel.h"
#import "GetFpAddressDetails.h"
#import "BusinessAddress.h"


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@interface BusinessAddressViewController ()<updateStoreDelegate,FpAddressDelegate,GMSMapViewDelegate>
{
    NSString *version;
    UIImageView *pinImageView;
    GMSMapView *storeMapView;
    CGFloat animatedDistance;
    NSString *addressUpdate;
    
}
@end

@implementation BusinessAddressViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showAddress];
   
    
    if([appDelegate.storeDetailDictionary objectForKey:@"changedAddress" ] != nil){
        [self UpdateMapView];
    }
    else{
    
        [self showMapView];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    addressTextView.delegate = self;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            
            addressScrollView.contentSize=CGSizeMake(self.view.frame.size.width,result.height+160);

        }
        if(result.height == 568)
        {
            // iPhone 5
            //[addressScrollView setContentSize:CGSizeMake(320, 568)];
            
        }
    }

    
    version = [[UIDevice currentDevice] systemVersion];
    
    if ([version floatValue]==7.0)
    {
        
        [addressTextView  setTextContainerInset:UIEdgeInsetsMake(-5,0 , 0, 0)];

        self.automaticallyAdjustsScrollViewInsets=NO;

    }
    
    
    
    else
    {
        [addressTextView setContentInset:UIEdgeInsetsMake(-10,0 , 0, 0)];
        
    }

    [mapView setFrame:CGRectMake(0, 44, mapView.frame.size.width, mapView.frame.size.height)];

    [self.view setBackgroundColor:[UIColor colorWithHexString:@"f0f0f0"]];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];

    version = [[UIDevice currentDevice] systemVersion];

    [addressTextView.layer setCornerRadius:6.0f];
    
    [addressTextView.layer setBorderWidth:1.0];
    
    [addressTextView.layer setBorderColor:[UIColor colorWithHexString:@"dcdcda"].CGColor];
    
    addressTextView.textColor=[UIColor colorWithHexString:@"9c9b9b"];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    revealController.delegate=self;

    /*Design the NavigationBar here*/
    
    if (version.floatValue<7.0)
    {
        self.navigationController.navigationBarHidden=YES;
        
        CGFloat width = self.view.frame.size.width;
        
        navBar = [[UINavigationBar alloc] initWithFrame:
                                   CGRectMake(0,0,width,44)];
        
        [self.view addSubview:navBar];
        
        UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
        
        [leftCustomButton setImage:[UIImage imageNamed:@"detail-btn.png"] forState:UIControlStateNormal];
        
        [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [navBar addSubview:leftCustomButton];
        
        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 13,160, 20)];
        
        headerLabel.text=@"Business Address";
        
        headerLabel.backgroundColor=[UIColor clearColor];
        
        headerLabel.textAlignment=NSTextAlignmentCenter;
        
        headerLabel.font=[UIFont fontWithName:@"Helvetica" size:18.0];
        
        headerLabel.textColor=[UIColor colorWithHexString:@"464646"];
        
        [navBar addSubview:headerLabel];
        
        
        doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [doneButton setFrame:CGRectMake(270,0,50,44)];
        
        [doneButton setTitle:@"Edit" forState:UIControlStateNormal];
        
        [doneButton addTarget:self action:@selector(makeAddressEditable:) forControlEvents:UIControlEventTouchUpInside];
        
        [navBar addSubview:doneButton];


        customButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [customButton setFrame:CGRectMake(280,5, 30, 30)];
        
        [customButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
        
        [customButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"]  forState:UIControlStateNormal];
        
        [navBar addSubview:customButton];
        
        [customButton setHidden:YES];
    
    }
    
    else
    {
        self.navigationController.navigationBarHidden=NO;
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0f green:185/255.0f blue:0/255.0f alpha:1.0f];
        
        self.navigationController.navigationBar.translucent = NO;
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.navigationItem.title=@"Business Address";
        
        [contentSubView setFrame:CGRectMake(0,-44, contentSubView.frame.size.width, contentSubView.frame.size.height)];
        
        UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
        
        [leftCustomButton setImage:[UIImage imageNamed:@"detail-btn.png"] forState:UIControlStateNormal];
        
        [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc]initWithCustomView:leftCustomButton];
        
        doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [doneButton setFrame:CGRectMake(270,0,50,44)];
        
        [doneButton setTitle:@"Edit" forState:UIControlStateNormal];
        
        [doneButton addTarget:self action:@selector(showMapView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        
        self.navigationItem.leftBarButtonItem = leftBtnItem;
        
        self.navigationItem.rightBarButtonItem = rightBtnItem;

        
        customButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [customButton setFrame:CGRectMake(280,5, 30, 30)];
        
        [customButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
        
        [customButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"]  forState:UIControlStateNormal];
        
        [customButton setHidden:YES];
        
    }
    
    

    
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    //Set the RightRevealWidth 0
    revealController.rightViewRevealWidth=0;
    revealController.rightViewRevealOverdraw=0;
    

}


-(void)showAddress
{
    if ([appDelegate.storeDetailDictionary objectForKey:@"Address"]!=[NSNull null])
    {
        
        addressTextView.text=[appDelegate.storeDetailDictionary objectForKey:@"Address"];
        
        NSString *spList=addressTextView.text;
        NSArray *list = [spList componentsSeparatedByString:@","];
        
        addressTextView.text=[NSString stringWithFormat:@"%@",list];
        
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@")" withString:@""];
        
        addressTextView.text=[addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
    }
    else
    {
        addressTextView.text=@"No Description";
    }
    
}



-(void)showMapView
{
    
    CLLocationCoordinate2D center;
    
    center.latitude=[[appDelegate.storeDetailDictionary objectForKey:@"lat"] doubleValue];
    
    center.longitude=[[appDelegate.storeDetailDictionary objectForKey:@"lng"] doubleValue];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:center.latitude
                                                            longitude:center.longitude
                                                                 zoom:18];
    storeMapView = [GMSMapView mapWithFrame:CGRectMake(0,0, mapView.frame.size.width, mapView.frame.size.height) camera:camera];
    
    storeMapView.delegate = self;
    
    pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mappin12.png"]];
    
    pinImageView.center = storeMapView.center;
    
    [storeMapView addSubview:pinImageView];
    
    [mapView insertSubview:storeMapView atIndex:0];
    
    [self.view addSubview:mapView];
    
    
}

-(void)UpdateMapView
{
    CLLocationCoordinate2D center;
    
    center.latitude=[[appDelegate.storeDetailDictionary objectForKey:@"lat"] doubleValue];
    
    center.longitude=[[appDelegate.storeDetailDictionary objectForKey:@"lng"] doubleValue];
    
    GMSCameraUpdate *cams = [GMSCameraUpdate setTarget:center zoom:18];
    
    storeMapView.delegate = self;
    
    [storeMapView animateWithCameraUpdate:cams];
    
   
}


#pragma mark - Textview Delegate methods.


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    doneButton.hidden = NO;
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [doneButton setHidden:YES];
        [textView resignFirstResponder];
        [customButton setHidden:NO];
        return NO;
    }
    return YES;
}




#pragma mark - GMSMapView Delegate methods.



-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
  
}




-(void)makeAddressEditable:(id)sender
{
    [addressTextView becomeFirstResponder];
}


-(void)editAddress
{
    
    addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
    addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSError *error = nil;
    
    NSRegularExpression *regexComma = [NSRegularExpression regularExpressionWithPattern:@", +" options:NSRegularExpressionCaseInsensitive error:&error];
    
    addressTextView.text = [regexComma stringByReplacingMatchesInString:addressTextView.text options:0 range:NSMakeRange(0, [addressTextView.text length]) withTemplate:@" ,"];
    
     NSRegularExpression *regexSpace = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    
    addressTextView.text = [regexSpace stringByReplacingMatchesInString:addressTextView.text options:0 range:NSMakeRange(0, [addressTextView.text length]) withTemplate:@" "];
    
   
        doneButton.hidden = YES;
    
        customButton.hidden = YES;
    
        GetFpAddressDetails *_verifyAddress=[[GetFpAddressDetails alloc]init];
        
        _verifyAddress.delegate=self;
        
        [_verifyAddress downloadFpAddressDetails:addressTextView.text];
   
}


#pragma FpAddressDelegate

-(void)fpAddressDidFetchLocationWithLocationArray:(NSArray *)locationArray
{
    
    storeLatitude=[[locationArray valueForKey:@"lat"] doubleValue];
    storeLongitude=[[locationArray valueForKey:@"lng"] doubleValue];
    
    @try {
        
        [appDelegate.storeDetailDictionary setValue:addressTextView.text forKey:@"Address"];
        [appDelegate.storeDetailDictionary setValue:[NSNumber numberWithDouble:storeLatitude] forKey:@"lat"];
        [appDelegate.storeDetailDictionary setValue:[NSNumber numberWithDouble:storeLongitude] forKey:@"lng"];
        addressUpdate = addressTextView.text;
        
        NSLog(@"Address is %@",addressUpdate);
        [self UpdateMapView];
        [self showAddress];
        [self updateAddress];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
}


-(void)fpAddressDidFail
{
    UIAlertView *noLocationAlertView=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"We could not point on the map with the given address. Please enter a valid address." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [noLocationAlertView show];
    noLocationAlertView=nil;
}



-(void)updateAddress
{
    
    NSMutableArray *uploadArray=[[NSMutableArray alloc]init];
    
    UpdateStoreData *strData=[[UpdateStoreData  alloc]init];
    
    strData.delegate=self;

    NSString *uploadString=[NSString stringWithFormat:@"%f,%f",storeLatitude ,storeLongitude];
    
    NSDictionary *upLoadDictionary=@{@"value":uploadString,@"key":@"GEOLOCATION"};
    
    NSString *uploadAddressString = addressUpdate;
    
    NSDictionary *uploadAddressDictionary = @{@"value":uploadAddressString,@"key":@"ADDRESS"};
    
    [uploadArray addObject:uploadAddressDictionary];
    
    [uploadArray addObject:upLoadDictionary];
    
    [strData updateStore:uploadArray];
}


-(void)storeUpdateComplete
{
    
    Mixpanel *mixPanel=[Mixpanel sharedInstance];
    
    [mixPanel track:@"update_Business Address"];
    

    [customButton setHidden:YES];
    
    UIAlertView *successAlert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Business location changed successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    
    [successAlert show];
    
    successAlert=nil;

}


-(void)storeUpdateFailed
{
    UIAlertView *failedAlert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Business Address could not be updated." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [failedAlert show];
    
    failedAlert=nil;
    
}


#pragma SWRevealViewControllerDelegate


- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    else if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    else if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    else if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    
    else if ( position == FrontViewPositionLeftSide ) str = @"FrontViewPositionLeftSide";
    
    else if ( position == FrontViewPositionLeftSideMostRemoved ) str = @"FrontViewPositionLeftSideMostRemoved";
    
    return str;
}




-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    BusinessAddress *businessMapView = [[BusinessAddress alloc] initWithNibName:@"BusinessAddress" bundle:nil];
    
    [self presentViewController:businessMapView animated:YES completion:nil];
}


- (IBAction)revealFrontController:(id)sender
{
    
    SWRevealViewController *revealController = [self revealViewController];
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeftSide"]) {
        
        [revealController performSelector:@selector(rightRevealToggle:)];
        
    }
    
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"]) {
        
        [revealController performSelector:@selector(revealToggle:)];
        
    }
    
}


- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position;
{
    
    frontViewPosition=[self stringFromFrontViewPosition:position];
    
    //FrontViewPositionLeft
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeftSide"])
    {
        
        [revealFrontControllerButton setHidden:NO];
        
    }
    
    //FrontViewPositionCenter
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeft"]) {
        
        [revealFrontControllerButton setHidden:YES];
        
    }
    
    //FrontViewPositionRight
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"])
    {
        [revealFrontControllerButton setHidden:NO];        
    }
    
}


-(void)callCustomerSupport
{
    
    UIAlertView *callAlertView=[[UIAlertView alloc]initWithTitle:nil message:@"Are you sure you want to call the customer care?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    callAlertView.tag=1;
    [callAlertView show];
    callAlertView=nil;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{

    if (alertView.tag==1)
    {
        
        if (buttonIndex==1) {
            
            
            NSString* phoneNumber=@"919160004303";
            
            NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",phoneNumber]];
            
            if([[UIApplication sharedApplication] canOpenURL:callUrl])
            {
                [[UIApplication sharedApplication] openURL:callUrl];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            

        }
        
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    addressTextView = nil;
    [super viewDidUnload];
}




@end
