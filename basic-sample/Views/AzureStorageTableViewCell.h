//
//  AzureStorageCellTableViewCell.h
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 5/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AzureStorageTableViewCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UIImageView* image;
@property(nonatomic,strong) IBOutlet UILabel* blobName;

@end
