//
//  YelpBusiness.h
//  yelp
//
//  Created by Xin Suo on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YelpClient.h"

@interface YelpBusiness : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) NSString *categories;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSURL *ratingImageUrl;
@property (strong, nonatomic) NSNumber *reviewCount;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (NSArray *)businessesFromJsonArray:(NSArray *)jsonArray;

+ (void)searchWithTerm:(NSString *)term
            completion:(void (^)(NSArray *businesses, NSError *error))completion;

+ (void)searchWithTerm:(NSString *)term
              sortMode:(YelpSortMode)sortMode
            categories:(NSArray *)categories
                 deals:(BOOL)hasDeal
                radius:(NSNumber *)radius
            completion:(void (^)(NSArray *businesses, NSError *error))completion;

@end
