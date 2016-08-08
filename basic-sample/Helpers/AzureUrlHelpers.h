//
//  AzureUrlHelpers.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AzureUrlHelpers : NSObject
- (NSString *) getContainerUrl: (NSString *) sasToken containerName: (NSString *) containerName;
- (NSString *) getBlobUrl: (NSString *) containerName sasToken: (NSString *) sasToken blobName: (NSString  *) blobName;
@end
