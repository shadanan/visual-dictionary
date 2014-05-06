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
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;

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
    [self.helpLabel sizeToFit];
    
    float height = self.helpLabel.frame.origin.y + self.helpLabel.frame.size.height + 20;
    float width = self.aboutContentView.frame.size.width;
    CGPoint origin = self.aboutContentView.frame.origin;
    self.aboutContentView.frame = CGRectMake(origin.x, origin.y, width, height);
    
    self.aboutScrollView.contentSize = self.aboutContentView.bounds.size;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.aboutContentView addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
