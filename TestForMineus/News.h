//
//  News.h
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject <NSCoding>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *postDate;
@property (strong, nonatomic) NSString *snippet;

- (void)saveCustomObject:(id)object key:(NSString *)key;
- (id)loadCustomObjectWithKey:(NSString *)key;

@end
