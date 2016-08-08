//
//  AFAzureBlobApi.m
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "AFAzureBlobApi.h"
#import "AzureUrlHelpers.h"
#import "AzureBlob.h"
#import <AZSClient/AZSClient.h>
#import "Constansts.h"
@implementation AFAzureBlobApi
+ (instancetype)sharedClient {
    static AFAzureBlobApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAzureBlobApi alloc] init];
    });
    
    return _sharedClient;
}

-(void)listBlobsInContainer:(NSString *) sasToken containerName : (NSString *) containerName completionHandler:(void (^)(NSError *, NSArray*))completionHandler{
    NSError *accountCreationError;
    
    // Create a storage account object from a connection string.
    NSString * sharedAccessSignature = [NSString stringWithFormat:@"SharedAccessSignature=%@;BlobEndpoint=%@", sasToken, AFAzureStorageBaseURLString];
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString: sharedAccessSignature error:&accountCreationError];

    if(accountCreationError){
        NSLog(@"Error in creating account.");
    }
    
    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:containerName];
    
    //List all blobs in container
    [self listBlobsInContainerHelper:blobContainer continuationToken:nil prefix:nil blobListingDetails:AZSBlobListingDetailsAll maxResults:-1 completionHandler:^(NSError *error, NSArray *list) {
        completionHandler(error, list);
    }];
}

//List blobs helper method
-(void)listBlobsInContainerHelper:(AZSCloudBlobContainer *)container continuationToken:(AZSContinuationToken *)continuationToken prefix:(NSString *)prefix blobListingDetails:(AZSBlobListingDetails)blobListingDetails maxResults:(NSUInteger)maxResults completionHandler:(void (^)(NSError *, NSArray*))completionHandler
{
    [container listBlobsSegmentedWithContinuationToken:continuationToken prefix:prefix useFlatBlobListing:YES blobListingDetails:blobListingDetails maxResults:maxResults completionHandler:^(NSError *error, AZSBlobResultSegment *results) {
        if (error)
        {
            completionHandler(error, nil);
        }
        else
        {
            NSMutableArray * result = [[NSMutableArray alloc] init];

            for (int i = 0; i < results.blobs.count; i++) {
                NSLog(@"%@",[(AZSCloudBlockBlob *)results.blobs[i] blobName]);
                AzureBlob *b = [[AzureBlob alloc] init];
                b.blobName = [(AZSCloudBlockBlob *)results.blobs[i] blobName];
                b.containerName = container.name;
                b.serviceEndPoint = AFAzureStorageBaseURLString;
                [result addObject:b];

            }
            if (results.continuationToken)
            {
                [self listBlobsInContainerHelper:container continuationToken:results.continuationToken prefix:prefix blobListingDetails:blobListingDetails maxResults:maxResults completionHandler:completionHandler];
            }
            else
            {
                completionHandler(nil, result);
            }
        }
    }];
}

- (void)uploadImage:(UIImage *)image blobName:(NSString *)blobName sasToken :(NSString *) sasToken containerName : (NSString *) containerName completionHandler:(void(^)(NSError * error))completionHandler {
    // Get the image data (JPEG)
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSError *accountCreationError = nil;
    
    NSString * sharedAccessSignature = [NSString stringWithFormat:@"SharedAccessSignature=%@;BlobEndpoint=%@", sasToken, AFAzureStorageBaseURLString];
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString: sharedAccessSignature error:&accountCreationError];

    // Create a blob service client object.
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    // Create a local container object.
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName: containerName];
    
    AZSCloudBlockBlob *blockBlob = [blobContainer blockBlobReferenceFromName:blobName];
    
    // Upload blob to Storage
    blockBlob.properties.contentType = @"image/jpeg";
    [blockBlob uploadFromData:data completionHandler:^(NSError *error) {
        if (error){
            NSLog(@"Error in creating blob.");
        }
        completionHandler(error);
    }];

}

@end
