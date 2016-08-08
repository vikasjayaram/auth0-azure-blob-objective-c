//
//  NSString+Hashes.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *NSStringNotNull(NSString *string);

@interface NSString (Hashes)

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)sha256;
- (NSString *)sha512;

@end
