//
//  AzureBlob.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AzureBlob : NSObject
@property(nonatomic, strong) NSString* blobName;
@property(nonatomic, strong) NSString* containerName;
@property(nonatomic, strong) NSString* serviceEndPoint;

@end
