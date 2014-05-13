//
//  GMMViewController.m
//  SampleApp
//
//  Created by Xtreme Dev on 2014-05-13.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "GMMViewController.h"



@interface GMMViewController ()

@end

@implementation GMMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self reload];
}

-(void)reload{
    
    [IMGGalleryRequest hotGalleryPage:0 withViralSort:YES success:^(NSArray *objects) {
        
        //random object from gallery
        id<IMGGalleryObjectProtocol> object = [objects objectAtIndex:arc4random_uniform((u_int32_t)objects.count)];
        NSLog(@"retrieved gallery");
        
        //get cover image
        IMGImage * cover = [object coverImage];
        //get link to 640x640 cover image
        NSURL * coverURL = [cover URLWithSize:IMGLargeThumbnailSize];
        
        //set the image view
        [self.coverView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:coverURL]]];
        
        //set the title
        self.titleLabel.text = [cover title];
        //description
        self.desriptionLabel.text = [cover imageDescription];
        
    } failure:^(NSError *error) {
        
        NSLog(@"gallery request failed - %@" ,error.localizedDescription);
    }];
    
    if([IMGSession sharedInstance].isAnonymous){
        
        self.stateLabel.text = @"Anonymous User";
    } else {
        
        self.stateLabel.text = [NSString stringWithFormat:@"Logged on as: %@",[IMGSession sharedInstance].user.username];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [self reload];
}

- (IBAction)loginTapped:(id)sender {
    
    if([IMGSession sharedInstance].isAnonymous){
        
        self.stateLabel.text = @"Logging In";
        
        //set your credentials to reset the session to your app
        [IMGSession authenticatedSessionWithClientID:@"" secret:@"" authType:IMGCodeAuth withDelegate:(id<IMGSessionDelegate>)[UIApplication sharedApplication].delegate];
        
        //force authentication by immediately sending request in reload, which will trigger AppDelegate methods to respond and send to imgur url to sign on
        
        [self reload];
    }
    
    
}

@end
