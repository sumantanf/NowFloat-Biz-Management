//
//  MasterViewController.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 09/03/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "FGalleryViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>


@interface MasterViewController : UIViewController<UIAlertViewDelegate,FGalleryViewControllerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
{

    __weak IBOutlet UIScrollView *manageControllerScrollView;

    __weak IBOutlet UIView *manageBizSubView;

    __weak IBOutlet UIView *imageGallerySubView;

    __weak IBOutlet UIView *tertiarySubView;
    
    BOOL isManageBizSubViewSet;
    
    BOOL isImageGallerySubViewSet;
    
    SWRevealViewController *revealController;
    
    UINavigationController *frontNavigationController;
    
    FGalleryViewController *networkGallery;
    
    NSMutableArray *networkImages;
    
    AppDelegate *appDelegate;
    
    NSArray *filePathsArray;
    
    NSMutableArray *fullPathImageArray;
    
}

- (IBAction)homeButtonClicked:(id)sender;


- (IBAction)manageMyBizButtonClicked:(id)sender;

- (IBAction)imageGalleryButtonClicked:(id)sender;

- (IBAction)contactInformationButtonClicked:(id)sender;

- (IBAction)bizHoursButtonClicked:(id)sender;


- (IBAction)bizDetailsButtonClicked:(id)sender;

- (IBAction)bizAddressButtonClicked:(id)sender;

- (IBAction)primaryImageButtonClicked:(id)sender;

- (IBAction)secondaryImageButtonClicked:(id)sender;

- (IBAction)inboxButtonClicked:(id)sender;

- (IBAction)analyticsButtonClicked:(id)sender;

- (IBAction)logOutButtonClicked:(id)sender;

- (IBAction)settingsButtonClicked:(id)sender;

- (IBAction)feedBackButtonClicked:(id)sender;



@end
