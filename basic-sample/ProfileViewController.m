// ProfileViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProfileViewController.h"
#import "Application.h"
#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "AFAuth0NetworkApi.h"
#import "AFAzureBlobApi.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSString+Hashes.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

- (IBAction)callAPI:(id)sender;
- (IBAction)logout:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    [self.profileImage setImageWithURL:profile.picture];
    self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), profile.name];
    
    
}

- (void)callAPI:(id)sender {
    //[self updateUserData];
    //[self getDelegationToken];
    //[self performSegueWithIdentifier:@"azureStorage" sender:self];
}

- (void)logout:(id)sender {
    A0Lock *lock = [[Application sharedInstance] lock];
    [lock clearSessions];
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    [keychain clearAll];
    [self performSegueWithIdentifier:@"showSignin" sender:self];
}

- (void)showMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (NSURLRequest *)buildAPIRequest {
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    NSString *token = [keychain stringForKey:@"id_token"];
    NSString *baseURLString = [[NSBundle mainBundle] infoDictionary][@"SampleAPIBaseURL"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURLString]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    return request;
}

- (void) updateUserData {
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *token = [keychain stringForKey:@"id_token"];
    NSString * baseURLString = [NSString stringWithFormat:@"/api/v2/users/%@", profile.userId];
    NSDictionary *dict = @{@"user_metadata": @{
                           @"firstName" : @"Vikas",
                           @"lastName" : @"Kannurpatti Jayaram",
                           @"team" : @"DSE"
                           }};
    [[AFAuth0NetworkApi sharedClient] updateUser:dict success:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"blah blah %@", response);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error);
    }];
}

- (void) getDelegationToken
{
    [[AFAuth0NetworkApi sharedClient] getAzureSasToken:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"SAASTOKEN %@", response);
        NSString * azure_blob_sas = [response valueForKeyPath:@"azure_blob_sas"];
        [self callAzureApi:azure_blob_sas];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"ERROR CALLING DELEGATION %@", error.localizedDescription);
    }];
}
- (void) callAzureApi: (NSString *) azure_blob_sas
{
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *hashedUserId = [profile.userId sha1];
//
//    [[AFAzureBlobApi sharedClient] listContainerBlobs:azure_blob_sas containerName:hashedUserId success:^(NSURLSessionDataTask *task, id response) {
//        NSLog(@"LIST %@", response);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"LIST ERROR %@", error.localizedDescription);
//    }];
}
@end
