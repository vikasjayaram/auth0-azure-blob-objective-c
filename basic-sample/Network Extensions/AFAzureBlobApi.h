//
//  AFAzureBlobApi.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AFAzureBlobApi : NSObject
+ (instancetype)sharedClient;
//-(void) listContainerBlobs: (NSString *) sasToken containerName : (NSString *) containerName success: (void(^)(NSURLSessionDataTask *task, id response)) success failure: (void(^) (NSURLSessionDataTask *task, NSError *error)) failure;
-(void)listBlobsInContainer:(NSString *) sasToken containerName : (NSString *) containerName completionHandler:(void (^)(NSError *, NSArray*))completionHandler;
- (void)uploadImage:(UIImage *)image blobName:(NSString *)blobName sasToken :(NSString *) sasToken containerName : (NSString *) containerName completionHandler:(void(^)(NSError * error))completionHandler;
@end
