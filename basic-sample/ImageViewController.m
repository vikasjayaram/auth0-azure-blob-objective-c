//
//  ImageViewController.m
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 6/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "ImageViewController.h"
#import "AFAuth0NetworkApi.h"
#import "AFAzureBlobApi.h"
#import "Application.h"
#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSString+Hashes.h"
#import "AzureStorageTableViewCell.h"
#import "AzureBlob.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+Random.h"

//ImageViewController.m

@interface ImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, weak) IBOutlet UIImageView * imageView;
@property (nonatomic, weak) IBOutlet UILabel *imageLabel;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;

@end



@implementation ImageViewController
{
    UIImagePickerController *_imagePicker; //
    UIActionSheet *_actionSheet; //show Photo Menu
    UIImage *_image;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    self.imageLabel.text = @"Image shows here";
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

#pragma mark - ImagePicker Controller

- (IBAction)showPhotoMenu:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        
        [_actionSheet showInView:self.view];
        
    } else {
        
        [self choosePhotoFromLibrary];
    }
}


- (IBAction)upload:(id)sender
{
    [self getDelegationForBlob];
}

- (void)takePhoto
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}



- (void)choosePhotoFromLibrary
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}




#pragma mark - Image

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageLabel.hidden = YES;
}




#pragma mark - UIImagePickerController Delegate

//must conform to both UIImagePickerControllerDelegate and UINavigationControllerDelegate
//but don’t have to implement any of the UINavigationControllerDelegate methods.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    _image = info[UIImagePickerControllerEditedImage];
    [self showImage:_image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self takePhoto];
        
    } else if (buttonIndex == 1) {
        
        [self choosePhotoFromLibrary];
    }
    
    _actionSheet = nil;
}




#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}




#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegation

- (void) getDelegationForBlob
{
    [self showHud];
    NSString *identifier = [NSString randomStringWithLength: 6];
    NSString *  imageName = [NSString stringWithFormat:@"%@.jpg", identifier];
    [[AFAuth0NetworkApi sharedClient] getAzureSasTokenForBlobName:imageName success:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"SAASTOKEN %@", response);
        NSString * azure_blob_sas = [response valueForKeyPath:@"azure_blob_sas"];
        [self uploadImageToAzure:azure_blob_sas name:imageName];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHud];
    }];
}

- (void) uploadImageToAzure: (NSString *) sasToken name: (NSString *) name
{
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *hashedUserId = [profile.userId sha1];
    [[AFAzureBlobApi sharedClient] uploadImage:self.imageView.image blobName:name sasToken:sasToken containerName:hashedUserId completionHandler:^(NSError * error) {
        [self hideHud];
        if (error) {
            NSLog(@"ERROR UPLOADING %@", error.localizedDescription);
        } else {
            NSLog(@"uploaded successfully");
        }
    }];
    
}
@end