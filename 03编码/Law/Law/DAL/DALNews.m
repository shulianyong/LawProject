//
//  DALNews.m
//  Law
//
//  Created by shulianyong on 13-3-21.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALNews.h"
#import "News.h"

@implementation DALNews

- (NSArray*)selectAllNew
{
    __block NSMutableArray *result = nil;
    NSString *field = @"NewsId         "
    ",Id             "
    ",Title          "
    ",Contents       "
    ",Source         "
    ",ValidTime      "
    ",LastUpdateTime "
    ",Synchronized   "
    ",DefaultImageUrl";
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM News ORDER BY LastUpdateTime DESC",field];
    [self.db executeDataBaseOPeration:^{
        FMResultSet *dataSet = [self.db executeQuery:sql];
        result = [[NSMutableArray alloc] init];
         while ([dataSet next]) {
             News *news = [[News alloc] init];
             NSDictionary *dicNews = [dataSet resultDictionary];
             [news reflectDataFromOtherObject:dicNews];
             [result addObject:news];
        }
        
    }];
    return result;
}

- (void)insertNews:(NSArray*)aNews
{
    NSString *field = @"Id             "
    ",Title          "
    ",Contents       "
    ",Source         "
    ",ValidTime      "
    ",LastUpdateTime "
    ",Synchronized   "
    ",DefaultImageUrl"
    ",ImageName";
    
    NSString *values = @":Id"
    ",:Title"
    ",:Contents"
    ",:Source"
    ",:ValidTime"
    ",:LastUpdateTime"
    ",:Synchronized"
    ",:DefaultImageUrl"
    ",:ImageName";

    NSString *sql= [NSString stringWithFormat:@"INSERT INTO News(%@) VALUES (%@)",field,values];    
    
    [self.db executeDataBaseOPeration:^{
        [self.db beginTransaction];        
        for (News *news in aNews) {
            int rowNumber = [self.db intForQuery:@"select COUNT(*) AS RowNumber from News"];
            if (rowNumber>=15) {
                NSInteger *minNewId = [self.db intForQuery:@"select MIN(NewsId) AS minNewId from News"];
                NSString *DefaultImageUrl = [self.db stringForQuery:@"SELECT DefaultImageUrl FROM News WHERE NewsId=?",[NSNumber numberWithInteger:minNewId]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:DefaultImageUrl];
                
                [self.db executeUpdate:@"DELETE FROM News WHERE NewsId=?",[NSNumber numberWithInteger:minNewId]];
            }
            NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
            [dictionaryArgs setObject:[NSNumber numberWithInteger:news.Id]forKey:@"Id"];
            [dictionaryArgs setObject:news.Title forKey:@"Title"];
            [dictionaryArgs setObject:news.Contents forKey:@"Contents"];
            [dictionaryArgs setObject:news.Source forKey:@"Source"];
            [dictionaryArgs setObject:[NSDate dateWithTimeIntervalSince1970:news.ValidTime] forKey:@"ValidTime"];
            [dictionaryArgs setObject:[NSDate dateWithTimeIntervalSince1970:news.LastUpdateTime] forKey:@"LastUpdateTime"];
            [dictionaryArgs setObject:[NSNumber numberWithChar:news.Synchronized] forKey:@"Synchronized"];
            [dictionaryArgs setObject:news.DefaultImageUrl forKey:@"DefaultImageUrl"];            
            NSString *imageName =  @"";
            [dictionaryArgs setObject:imageName forKey:@"ImageName"];
            
            BOOL ret = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
            if (!ret) {
//                ERROR(@"db error:%@",self.db.lastErrorMessage);
//                [self.db rollback];
//                return;
            }
        }       
        [self.db commit];
        
        
    }];
    
}

- (void)deleteNews:(News*)aNews
{
    NSString *sql = @"DELETE FROM News WHERE Id=?";
    [self.db executeDataBaseOPeration:^{
        [self.db executeUpdate:sql,[NSNumber numberWithInteger:aNews.Id]];
    }];
}



@end
