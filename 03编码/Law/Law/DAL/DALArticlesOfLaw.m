//
//  DALArticlesOfLaw.m
//  Law
//
//  Created by shulianyong on 13-3-24.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALArticlesOfLaw.h"
#import "ArticlesOfLaw.h"

@implementation DALArticlesOfLaw

- (BOOL)insertWithArticles:(NSArray*)aArticleList
{
    NSString *fields =  @" Id"
    @",Title"
    @",Contents"
    @",Keywords"
    @",LastUpdateTime"
    @",Level"
    @",Synchronized"
    @",isNew";
    
    NSString *filedValues = @":Id"
    ",:Title"
    ",:Contents"
    ",:Keywords"
    ",:LastUpdateTime"
    ",:Level"
    ",:Synchronized"
    ",:isNew";   
    
    __block BOOL ret = YES;
    static BOOL isProcessedNew = NO;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO ArticlesOfLaw(%@) VALUES (%@)",fields,filedValues];   
    NSString *sqlUpdate = @"UPDATE ArticlesOfLaw SET "
    @"Id=:Id"
    ",Title=:Title"
    ",Contents=:Contents"
    ",Keywords=:Keywords"
    ",LastUpdateTime=:LastUpdateTime"
    ",Level=:Level"
    ",Synchronized=:Synchronized"
    ",isNew=:isNew"
    " WHERE Id=:Id";
    
    [self.db executeDataBaseOPeration:^{        
        NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
        [self.db beginTransaction];        
        //设置之前的更新，都不是最新
        if (!isProcessedNew){            
            ret = [self.db executeUpdate:@"UPDATE ArticlesOfLaw SET isNew=? Where isNew=?",[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES]];
        }
        isProcessedNew = YES;
        for (ArticlesOfLaw *article in aArticleList) {
            [dictionaryArgs setObject:[NSNumber numberWithInteger:article.Id] forKey:@"Id"];
            [dictionaryArgs setObject:article.Title          forKey:@"Title"];
            [dictionaryArgs setObject:article.Contents       forKey:@"Contents"];
            [dictionaryArgs setObject:article.Keywords       forKey:@"Keywords"];
            [dictionaryArgs setObject:[NSNumber numberWithDouble:article.LastUpdateTime] forKey:@"LastUpdateTime"];
            [dictionaryArgs setObject:[NSNumber numberWithInteger:article.Level] forKey:@"Level"];
            [dictionaryArgs setObject:[NSNumber numberWithBool:article.Synchronized] forKey:@"Synchronized"];
            [dictionaryArgs setObject:[NSNumber numberWithBool:YES] forKey:@"isNew"];
            ret = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
            if (!ret) {
                ret = [self.db executeUpdate:sqlUpdate withParameterDictionary:dictionaryArgs];
            }
        }
        [self.db commit];
        
    }];
    return ret;
}

- (BOOL)deleteArticlesWithIds:(NSString*)aArticlesIds
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM ArticlesOfLaw WHERE Id in (%@)",aArticlesIds];
    __block BOOL ret = YES;
    [self.db executeDataBaseOPeration:^{
        ret = [self.db executeUpdate:sql];
        if (!ret) {
//            ERROR(@"db Error:%@",[self.db lastErrorMessage]);
        }
    }];
    return ret;
}


#pragma mark --------Search Articles

- (NSArray*)searchArticlesWithTitle:(NSString*)aTitle withUserId:(NSInteger)aUserId
{    
    NSString *sql = @"SELECT DISTINCT ArticlesOfLaw.Title"
    @",IFNULL(Favorites.FavoriteId,0) AS isFavorite"
    @" FROM ArticlesOfLaw"
    @" LEFT JOIN Favorites"
    @" ON Favorites.Title = ArticlesOfLaw.Title"
    @" AND Favorites.UserId = %d"
    @" AND Favorites.FavoriteType = 2"
    @" WHERE  ArticlesOfLaw.Title LIKE '%@'";
    
    NSString *searchTitle = @"%%@%";
    searchTitle = [searchTitle stringByReplacingOccurrencesOfString:@"%@" withString:aTitle];
    sql = [NSString stringWithFormat:sql,aUserId,searchTitle];
    
    NSMutableArray *articleList = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        FMResultSet *dataSet = [self.db executeQuery:sql];
        while ([dataSet next]) {
            ArticlesOfLaw *article = [[ArticlesOfLaw alloc] init];
            NSDictionary *dbResult = [dataSet resultDictionary];
            [article reflectDataFromOtherObject:dbResult];
            [articleList addObject:article];
        }
    }];
    return articleList;
}
//按内容搜索
- (NSArray*)searchArticlesWithContent:(NSString*)aContent withUserId:(NSInteger)aUserId
{    
    NSString *sql = @"SELECT DISTINCT ArticlesOfLaw.Title"
    @",IFNULL(Favorites.FavoriteId,0) AS isFavorite"
    @" FROM ArticlesOfLaw"
    @" LEFT JOIN Favorites"
    @" ON Favorites.Title = ArticlesOfLaw.Title"
    @" AND Favorites.UserId = %d"
    @" AND Favorites.FavoriteType = 2"
    @" WHERE  ArticlesOfLaw.Contents LIKE '%@'";
    
    NSString *searchText = @"%%@%";
    searchText = [searchText stringByReplacingOccurrencesOfString:@"%@" withString:aContent];
    sql = [NSString stringWithFormat:sql,aUserId,searchText];
    
    NSMutableArray *articleList = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        FMResultSet *dataSet = [self.db executeQuery:sql];
        while ([dataSet next]) {
            ArticlesOfLaw *article = [[ArticlesOfLaw alloc] init];
            NSDictionary *dbResult = [dataSet resultDictionary];
            [article reflectDataFromOtherObject:dbResult];
            [articleList addObject:article];
        }
    }];
    return articleList;
}



#pragma mark ------------获取相同标题的法条
- (NSArray*)articlesWithTitle:(NSString*)aTitle withUserId:(NSInteger)aUserId
{
    NSString *sql =  @"SELECT DISTINCT ArticlesOfLaw.Id"
    @",ArticlesOfLaw.Title"
    @",ArticlesOfLaw.Contents"
    @",ArticlesOfLaw.Keywords"
    @",ArticlesOfLaw.LastUpdateTime"
    @",ArticlesOfLaw.Level"
    @",ArticlesOfLaw.Synchronized"
    @",ArticlesOfLaw.isNew"
    @",IFNULL(Favorites.FavoriteId,0) AS isFavorite"
    @" FROM ArticlesOfLaw"
    @" LEFT JOIN Favorites"
    @" ON Favorites.Title = ArticlesOfLaw.Title"
    @" AND Favorites.UserId = ?"
    @" AND Favorites.FavoriteType = 2"
    @" WHERE ArticlesOfLaw.Title = ?";
    NSMutableArray *articleList = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        [self.db executeUpdate:@"UPDATE ArticlesOfLaw SET isNew=0 WHERE Title=?",aTitle];
        
        FMResultSet *dataSet = [self.db executeQuery:sql,[NSNumber numberWithInteger:aUserId],aTitle];
        while ([dataSet next]) {
            ArticlesOfLaw *article = [[ArticlesOfLaw alloc] init];
            NSDictionary *dbResult = [dataSet resultDictionary];
            [article reflectDataFromOtherObject:dbResult];
            [articleList addObject:article];
        }        
    }];
    return articleList;
}

//检查
- (BOOL)isNewArticles:(NSString*)aTitle
{
    __block int ret = 0;
    [self.db executeDataBaseOPeration:^{
        ret = [self.db intForQuery:@"SELECT COUNT(ArticlesOfLaw.Id) FROM ArticlesOfLaw WHERE ArticlesOfLaw.Title=? AND ArticlesOfLaw.isNew=1",aTitle];
    }];
    return ret>0;
}
@end
