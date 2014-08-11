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
#import "BusinessAddressCell.h"
#import "businessAddressCell1.h"
#import "AlertViewController.h"

BOOL isMapClicked;
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
    float viewHeight;
    UIBarButtonItem *rightBtnItem;
    NSString *addressLine;
    
}
@end

@implementation BusinessAddressViewController
@synthesize isFromOtherViews;

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
  
    if([appDelegate.storeDetailDictionary objectForKey:@"changedAddress"] != nil){
        
        [AlertViewController CurrentView:self.view errorString:@"Business Location Updated" size:0 success:YES];
        [self UpdateMapView];
    }
    else{
    
        [self showMapView];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
       appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
  
    isMapClicked = YES;
    
    NSLog(@"Store dicy %@",appDelegate.storeDetailDictionary);
    
    
    
    
        addressLine = [appDelegate.storeDetailDictionary objectForKey:@"Address"];
    
        if([appDelegate.storeDetailDictionary objectForKey:@"City"] == [NSNull null])
        {
        
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",[appDelegate.storeDetailDictionary objectForKey:@"City"]] withString:@""];
        }
        
        if([appDelegate.storeDetailDictionary objectForKey:@"PinCode"] == [NSNull null])
        {
        
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",[appDelegate.storeDetailDictionary objectForKey:@"PinCode"]] withString:@""];
        }
        
    
        if([appDelegate.storeDetailDictionary objectForKey:@"Country"] == [NSNull null])
        {
            
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@",[appDelegate.storeDetailDictionary objectForKey:@"Country"]] withString:@""];
        }
    
    
    
    
    addressTextView.delegate = self;
    addressTextView.frame = CGRectMake(0, 2000, 320, 200);
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    mixPanel.showNotificationOnActive = NO;
    
    version = [[UIDevice currentDevice] systemVersion];
    
    self.businessAddTable1.bounces =NO;
    self.businessAddTable2.bounces =NO;
    
    self.businessAddTable1.scrollEnabled = NO;
    self.businessAddTable1.scrollEnabled = NO;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            viewHeight = 480;
            if(version.floatValue < 7.0)
            {
            [mapView setFrame:CGRectMake(0, 220, mapView.frame.size.width, mapView.frame.size.height+140)];
            self.businessAddTable1.frame = CGRectMake(self.businessAddTable1.frame.origin.x, self.businessAddTable1.frame.origin.y-20, self.businessAddTable1.frame.size.width, 180);
                
            self.businessAddTable2.frame = CGRectMake(self.businessAddTable2.frame.origin.x, self.businessAddTable2.frame.origin.y-20, self.businessAddTable2.frame.size.width, 178);
                
            self.locateLabel.frame = CGRectMake(self.locateLabel.frame.origin.x, self.locateLabel.frame.origin.y-24, self.locateLabel.frame.size.width, self.locateLabel.frame.size.height);
            }
            else
            {
            [mapView setFrame:CGRectMake(0,215, mapView.frame.size.width, mapView.frame.size.height+140)];
                
                self.businessAddTable1.frame = CGRectMake(self.businessAddTable1.frame.origin.x, self.businessAddTable1.frame.origin.y-10, self.businessAddTable1.frame.size.width, 180);
                
                self.businessAddTable2.frame = CGRectMake(self.businessAddTable2.frame.origin.x, self.businessAddTable2.frame.origin.y-10, self.businessAddTable2.frame.size.width, 178);
                
                self.locateLabel.frame = CGRectMake(self.locateLabel.frame.origin.x, self.locateLabel.frame.origin.y-24, self.locateLabel.frame.size.width, self.locateLabel.frame.size.height);
            }
            
            addressScrollView.contentSize=CGSizeMake(self.view.frame.size.width,result.height+160);

        }
        if(result.height == 568)
        {
            // iPhone 5
            //[addressScrollView setContentSize:CGSizeMake(320, 568)];
            viewHeight = 568;
            [mapView setFrame:CGRectMake(0,260, mapView.frame.size.width, mapView.frame.size.height+200)];
        }
    }

    
    
    
    if ([version floatValue]==7.0)
    {
        if(viewHeight  == 568)
        {
            [addressTextView  setTextContainerInset:UIEdgeInsetsMake(-5,0 , 0, 0)];
            
            self.automaticallyAdjustsScrollViewInsets=NO;
        }
        else
        {
            [addressTextView setContentInset:UIEdgeInsetsMake(-10,0 , 0, 0)];
        }
        
        

    }
    else
    {
        [addressTextView setContentInset:UIEdgeInsetsMake(-10,0 , 0, 0)];
        
    }

    [self.view setBackgroundColor:[UIColor colorWithHexString:@"f0f0f0"]];
    
 

    version = [[UIDevice currentDevice] systemVersion];

    [addressTextView.layer setCornerRadius:6.0f];
    
    [addressTextView.layer setBorderWidth:1.0];
    
    [addressTextView.layer setBorderColor:[UIColor colorWithHexString:@"dcdcda"].CGColor];
    
    addressTextView.textColor=[UIColor colorWithHexString:@"9c9b9b"];
    
    [toolBar setHidden:YES];
    
    SWRevealViewController *revealController;
    
    if (!isFromOtherViews)
    {
        revealController = [self revealViewController];
        
        revealController.delegate=self;
        
       // [self.view addGestureRecognizer:revealController.panGestureRecognizer];
        
        revealController.rightViewRevealWidth=0;
        
        revealController.rightViewRevealOverdraw=0;
    }

    /*Design the NavigationBar here*/
    
    if (version.floatValue<7.0)
    {
        self.navigationController.navigationBarHidden=NO;
        self.navigationItem.title=@"Business Address";
//        
//        CGFloat width = self.view.frame.size.width;
//        
//        navBar = [[UINavigationBar alloc] initWithFrame:
//                                   CGRectMake(0,0,width,44)];
//        
//        [self.view addSubview:navBar];
//        
//        if (!isFromOtherViews)
//        {            
//            UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
//            
//            [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
//            
//            [leftCustomButton setImage:[UIImage imageNamed:@"detail-btn.png"] forState:UIControlStateNormal];
//            
//            [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [navBar addSubview:leftCustomButton];
//
//        }
//        else
//        {
//            UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
//            
//            [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
//            
//            [leftCustomButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
//            
//            [leftCustomButton addTarget:self  action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//            
//            [navBar addSubview:leftCustomButton];
//
//        }
//        
//        
//        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 13,160, 20)];
//        
//        headerLabel.text=@"Business Address";
//        
//        headerLabel.backgroundColor=[UIColor clearColor];
//        
//        headerLabel.textAlignment=NSTextAlignmentCenter;
//        
//        headerLabel.font=[UIFont fontWithName:@"Helvetica" size:18.0];
//        
//        headerLabel.textColor=[UIColor colorWithHexString:@"464646"];
//        
//        [navBar addSubview:headerLabel];
//        
//        
//        doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [doneButton setFrame:CGRectMake(270,0,50,44)];
//        
//        [doneButton setTitle:@"Edit" forState:UIControlStateNormal];
//        
//        [doneButton addTarget:self action:@selector(makeAddressEditable:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [navBar addSubview:doneButton];
//
//
//        customButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [customButton setFrame:CGRectMake(280,5, 30, 30)];
//        
//        [customButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
//        
//        [customButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"]  forState:UIControlStateNormal];
//        
//        [navBar addSubview:customButton];
        
       // [customButton setHidden:YES];
    
    }
    
//    else
//    {
//        self.navigationController.navigationBarHidden=NO;
//        
//        self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"ffb900"];
//        
//        self.navigationController.navigationBar.translucent = NO;
//        
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        
        self.navigationItem.title=@"Business Address";
//        
//        [contentSubView setFrame:CGRectMake(0,-44, contentSubView.frame.size.width, contentSubView.frame.size.height)];
//        
//        if (isFromOtherViews) {
//            UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
//            
//            [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
//            
//            [leftCustomButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
//            
//            [leftCustomButton addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc]initWithCustomView:leftCustomButton];
//            
//            self.navigationItem.leftBarButtonItem = leftBtnItem;
//
//        }
//        
//        else
//        {
//            
//        UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [leftCustomButton setFrame:CGRectMake(5,0,50,44)];
//        
//        [leftCustomButton setImage:[UIImage imageNamed:@"detail-btn.png"] forState:UIControlStateNormal];
//        
//        [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc]initWithCustomView:leftCustomButton];
//        
//        self.navigationItem.leftBarButtonItem = leftBtnItem;
//        }
//        doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [doneButton setFrame:CGRectMake(270,0,50,44)];
//        
//        [doneButton setTitle:@"Edit" forState:UIControlStateNormal];
//        
//        [doneButton addTarget:self action:@selector(makeAddressEditable:) forControlEvents:UIControlEventTouchUpInside];
//        
//        rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
//        
//        
//        self.navigationItem.rightBarButtonItem = rightBtnItem;
//
//        
//        customButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [customButton setFrame:CGRectMake(280,5, 30, 30)];
//        
//        [customButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
//        
//        [customButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"]  forState:UIControlStateNormal];
//        
////        rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
////
////          self.navigationItem.rightBarButtonItem = rightBtnItem;
////        
////        [customButton setHidden:YES];
//        
//    }

    
    
    [self setRighttNavBarButton];
}

-(void)setRighttNavBarButton
{
    
    customRighNavButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [customRighNavButton addTarget:self action:@selector(updateAddress) forControlEvents:UIControlEventTouchUpInside];
    
    //[customRighNavButton setBackgroundImage:[UIImage imageNamed:@"checkmark.png"]  forState:UIControlStateNormal];
    
    
    
    
    [customRighNavButton setTitle:@"Save" forState:UIControlStateNormal];
    [customRighNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    customRighNavButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue-Regular" size:17.0f];
    
    
    if (version.floatValue<7.0) {
        
        [customRighNavButton setFrame:CGRectMake(260,21, 60, 30)];
        [navBar addSubview:customRighNavButton];
        UIBarButtonItem *rightBarBtn=[[UIBarButtonItem alloc]initWithCustomView:customRighNavButton];
        
        self.navigationItem.rightBarButtonItem=rightBarBtn;
        
    }
    
    else
    {
        [customRighNavButton setFrame:CGRectMake(260,21, 60, 30)];
        
        [navBar addSubview:customRighNavButton];
        
        UIBarButtonItem *rightBarBtn=[[UIBarButtonItem alloc]initWithCustomView:customRighNavButton];
        
        self.navigationItem.rightBarButtonItem=rightBarBtn;
        
    }
    
   // [customRighNavButton setHidden:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.businessAddTable1)
    {
        return 1;
    }
    else
        
    return 2;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BusinessAddressCell *cell = [self.businessAddTable1 dequeueReusableCellWithIdentifier:@"businessAdd"];
    
    
    businessAddressCell1 *cell1 = [self.businessAddTable2 dequeueReusableCellWithIdentifier:@"businessAdd2"];
    
    if(tableView==self.businessAddTable1)
    {
    if(!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"BusinessAddressCell" bundle:nil] forCellReuseIdentifier:@"businessAdd"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"businessAdd"];
        
        cell.addressText.text = addressLine;
    }
    }
    
    if(tableView==self.businessAddTable2)
    {
        if(!cell1)
        {
            [tableView registerNib:[UINib nibWithNibName:@"businessAddressCell1" bundle:nil] forCellReuseIdentifier:@"businessAdd2"];
            
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"businessAdd2"];
        }
        cell1.addressText1.delegate = self;
        cell1.addressText2.delegate = self;
        
        if(indexPath.row==0)
        {
            
            if([appDelegate.storeDetailDictionary objectForKey:@"City"] == [NSNull null])
            {
                    cell1.addressText1.placeholder = @"Town/City";
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"City"]isEqualToString:@""])
                {
                    cell1.addressText1.placeholder = @"Town/City";
                }
                else
                {
                    cell1.addressText1.text=[appDelegate.storeDetailDictionary objectForKey:@"City"];
                }
            }
            
            if([appDelegate.storeDetailDictionary objectForKey:@"PinCode"] == [NSNull null])
            {
                cell1.addressText2.placeholder = @"Pincode/Zipcode";
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"PinCode"]isEqualToString:@""])
                {
                    cell1.addressText2.placeholder = @"Pincode/Zipcode";
                }
                else
                {
                    cell1.addressText2.text=[appDelegate.storeDetailDictionary objectForKey:@"PinCode"];
                }
            }
            
            
        
        
        }
        if(indexPath.row==1)
        {
            
            if([appDelegate.storeDetailDictionary objectForKey:@"Country"] == [NSNull null])
            {
                cell1.addressText2.placeholder = @"Country";
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"Country"]isEqualToString:@""])
                {
                    cell1.addressText2.placeholder = @"Country";
                }
                else
                {
                    cell1.addressText2.text=[appDelegate.storeDetailDictionary objectForKey:@"Country"];
                }
            }
        
            cell1.addressText1.placeholder = @"State";
            
       
        }
        
        return cell1;
    }

    return cell;
    
   
    
    
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
    
    [appDelegate.storeDetailDictionary removeObjectForKey:@"changedAddress"];
    
    center.latitude=[[appDelegate.storeDetailDictionary objectForKey:@"lat"] doubleValue];
    
    center.longitude=[[appDelegate.storeDetailDictionary objectForKey:@"lng"] doubleValue];
    
    GMSCameraUpdate *cams = [GMSCameraUpdate setTarget:center zoom:18];
    
    storeMapView.delegate = self;
    
    [storeMapView animateWithCameraUpdate:cams];
    
   
}


#pragma mark - Textview Delegate methods.
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [toolBar setHidden:NO];
    textView.inputAccessoryView = toolBar;
     customRighNavButton.hidden = NO;
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customRighNavButton];
    
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    customRighNavButton.hidden = NO;
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
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
    //[toolBar setHidden:YES];
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
    
    
    addressTextView.text = [addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(viewHeight == 568)
    {
       
    }
    else
    {
       
        [customButton setHidden:NO];
    }
    
    
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

//    NSString *uploadString=[NSString stringWithFormat:@"%f,%f",storeLatitude ,storeLongitude];
//    
//    NSDictionary *upLoadDictionary=@{@"value":uploadString,@"key":@"GEOLOCATION"};
    
    NSString *uploadAddressString ;
    NSString *uploadAddressString1;
    
    for (int i=0; i <3; i++){
        
        businessAddressCell1 *theCell;
        theCell = (id)[self.businessAddTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [theCell.addressText1 resignFirstResponder];
        [theCell.addressText2 resignFirstResponder];
        
      // uploadAddressString =@"Ravindra";
        
  
        
        
        
        if (i==0)
        {
            uploadAddressString           = theCell.addressText1.text;
            uploadAddressString1            = theCell.addressText2.text;

        }
        if (i==1)
        {
            NSString *changedText           = theCell.addressText1.text;
            uploadAddressString1            = theCell.addressText2.text;
            
        }
        if (i==2)
        {
            
            
        }
        
    }

    
    
    
   
   
    NSDictionary *uploadAddressDictionary1 = @{@"value":uploadAddressString,@"key":@"CITY"};
    
    NSDictionary *uploadAddressDictionary2 = @{@"value":uploadAddressString1,@"key":@"COUNTRY"};
    
    [uploadArray addObject:uploadAddressDictionary1];
    [uploadArray addObject:uploadAddressDictionary2];
    [strData updateStore:uploadArray];
}


-(void)storeUpdateComplete
{
    
    Mixpanel *mixPanel=[Mixpanel sharedInstance];
    
    [mixPanel track:@"update_Business Address"];
    

    [customButton setHidden:YES];
    
//    UIAlertView *successAlert=[[UIAlertView alloc]initWithTitle:@"Business Address Updated!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
//    
//    [successAlert show];
//    
//    successAlert=nil;
    
    [AlertViewController CurrentView:self.view errorString:@"Business Address Updated!" size:0 success:YES];

}


-(void)storeUpdateFailed
{
//    UIAlertView *failedAlert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Business Address could not be updated." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    
//    [failedAlert show];
//    
//    failedAlert=nil;
    
    [AlertViewController CurrentView:self.view errorString:@"Business Address could not be updated" size:0 success:NO];
    
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
    isMapClicked = NO;
   
    [self presentViewController:businessMapView animated:YES completion:nil];
}


- (IBAction)cancelButton:(id)sender
{
    [self.view endEditing:YES];
}

-(IBAction)cancelToolBarButton:(id)sender{
    [self cancelButton:nil];
}

-(IBAction)doneToolBarButton:(id)sender
{
    [self doneButton:nil];
}

- (IBAction)doneButton:(id)sender
{
    [addressTextView resignFirstResponder];
    
    if(viewHeight == 568)
    {
        rightBtnItem = nil;
        customButton.hidden = NO;
        rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }
    else
    {
        if(version.floatValue < 7.0)
        {
           
            [customButton setHidden:NO];
        }
        else
        {
            rightBtnItem = nil;
            customButton.hidden = NO;
            rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
            self.navigationItem.rightBarButtonItem = rightBtnItem;
        }
        
    }
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




-(void)backBtnClicked
{
    if (isFromOtherViews) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (version.floatValue<7.0)
    {
        if(isMapClicked)
        {
        self.navigationController.navigationBarHidden=YES;
           
        }
         isMapClicked = YES;
    }
    
    
}
- (void)viewDidUnload
{
    addressTextView = nil;
    [super viewDidUnload];
}





@end
