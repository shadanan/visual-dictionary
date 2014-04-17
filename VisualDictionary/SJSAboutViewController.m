//
//  SJSAboutViewController.m
//  VisualDictionary
//
//  Created by Shad Sharma on 4/7/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import "SJSAboutViewController.h"

@interface SJSAboutViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *aboutScrollView;
@property (strong, nonatomic) IBOutlet UIView *aboutContentView;

@end

@implementation SJSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.aboutScrollView layoutIfNeeded];
    self.aboutScrollView.contentSize = self.aboutContentView.bounds.size;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
