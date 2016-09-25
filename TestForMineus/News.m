//
//  News.m
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import "News.h"

@implementation News

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        
        self.title = [decoder decodeObjectForKey:@"title"];
        self.link = [decoder decodeObjectForKey:@"link"];
        self.postDate = [decoder decodeObjectForKey:@"postDate"];
        self.snippet = [decoder decodeObjectForKey:@"snippet"];
    
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.link forKey:@"link"];
    [encoder encodeObject:self.postDate forKey:@"postDate"];
    [encoder encodeObject:self.snippet forKey:@"snippet"];
}

- (void)saveCustomObject:(id)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (id)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    News *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}


@end
