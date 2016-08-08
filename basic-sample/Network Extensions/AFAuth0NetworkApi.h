//
//  AFAuth0NetworkApi.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 25/05/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//


#import <Foundation/Foundation.h>
@import AFNetworking;

@interface AFAuth0NetworkApi : AFHTTPSessionManager

+ (instancetype)sharedClient;
- (void) updateUser: (NSDictionary *) userMetaData success: (void(^)(NSURLSessionDataTask *task, id response)) success failure: (void(^) (NSURLSessionDataTask *task, NSError *error)) failure;
-(void) getAzureSasToken: (void(^)(NSURLSessionDataTask *task, id response)) success failure: (void(^) (NSURLSessionDataTask *task, NSError *error)) failure;
-(void) getAzureSasTokenForBlobName:(NSString *) blobName success : (void(^)(NSURLSessionDataTask *task, id response)) success failure: (void(^) (NSURLSessionDataTask *task, NSError *error)) failure;
@end