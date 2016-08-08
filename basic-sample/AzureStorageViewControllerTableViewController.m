//
//  AzureStorageViewControllerTableViewController.m
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "AzureStorageViewControllerTableViewController.h"
#import "Application.h"
#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "AFAuth0NetworkApi.h"
#import "AFAzureBlobApi.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSString+Hashes.h"
#import "AzureStorageTableViewCell.h"
#import "AzureBlob.h"
#import "ImageViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
@interface AzureStorageViewControllerTableViewController ()

@end

@implementation AzureStorageViewControllerTableViewController {
    NSMutableArray *azureStorageData;
    MBProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"Azure Storage";
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *btnUpload = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleBordered target:self action:@selector(prepareForSegue)];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    self.navigationItem.rightBarButtonItem = btnUpload;
    azureStorageData = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //[self getDelegationToken];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDelegationToken];
}
- (void) showHud{
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD show:YES];
    });
}
- (void) hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD hide:YES];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [azureStorageData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"AzureStorageTableViewCell";

    AzureStorageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AzureStorageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    AzureBlob* data = (AzureBlob *)[azureStorageData objectAtIndex:indexPath.row];
    cell.blobName.text = data.blobName;
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@", data.serviceEndPoint, data.containerName, data.blobName];
    [cell.image setImageWithURL:[NSURL URLWithString:urlString]];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 132;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) getDelegationToken
{
    [self showHud];
    [[AFAuth0NetworkApi sharedClient] getAzureSasToken:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"SAASTOKEN %@", response);
        NSString * azure_blob_sas = [response valueForKeyPath:@"azure_blob_sas"];
        [self callAzureApi:azure_blob_sas];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"ERROR CALLING DELEGATION %@", error.description);
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        [self hideHud];
        NSLog(@"%@",ErrorResponse);
    }];
}
- (void) callAzureApi: (NSString *) azure_blob_sas
{
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *hashedUserId = [profile.userId sha1];
    [azureStorageData removeAllObjects];
    [[AFAzureBlobApi sharedClient] listBlobsInContainer:azure_blob_sas containerName:hashedUserId completionHandler:^(NSError *error, NSArray * list) {
        if (error) {
            NSLog(@"Could not get blob list");
        } else {
            for (int i = 0; i < list.count; i++) {
                [azureStorageData addObject:list[i]];
            }
            [self.tableView reloadData];
            [self hideHud];
        }
    }];
}
- (void)prepareForSegue {
    [self performSegueWithIdentifier:@"showImageUploader" sender:self];

}
@end
