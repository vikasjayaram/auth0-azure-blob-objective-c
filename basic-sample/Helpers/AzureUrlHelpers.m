//
//  AzureUrlHelpers.m
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "AzureUrlHelpers.h"
#import "Constansts.h"
@implementation AzureUrlHelpers

- (NSString *) getContainerUrl: (NSString *) sasToken containerName: (NSString *) containerName
{
    return [NSString stringWithFormat:@"/%@?comp=list&restype=container&%@", containerName, sasToken];
}
- (NSString *) getBlobUrl: (NSString *) containerName sasToken: (NSString *) sasToken blobName: (NSString  *) blobName
{
    return [NSString stringWithFormat:@"%@/%@/%@?%@", AFAzureStorageBaseURLString, containerName, blobName, sasToken];
}
@end
