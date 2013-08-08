//
//  DALFavorites.m
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALFavorites.h"
#import "Subjects.h"
#import "ArticlesOfLaw.h"

@implementation DALFavorites

//添加收藏
- (BOOL)insertFavoritesWithObject:(NSObject*)obj withUserId:(NSInteger)aUserId withSubjectParentId:(NSInteger)aSubjectParentId
{
    __block BOOL ret = YES;
    NSString *sql = @"INSERT INTO Favorites"
    " (Title,FavoriteType,FavoriteId,UserID,ParentId) "
    " VALUES"
    " (:Title,:FavoriteType,:FavoriteId,:UserID,:ParentId)";
    
    NSInteger FavoriteType = 1;
    NSInteger FavoriteId = 0;
    NSString *title = nil;
    if ([obj isKindOfClass:[Subjects class]]) {
        FavoriteType = 1;
        Subjects *value = (Subjects*)obj;
        title = value.Name;
        FavoriteId = value.Id;
    }
    else
    {
        FavoriteType = 2;
        ArticlesOfLaw *value = (ArticlesOfLaw*)obj;
        title = value.Title;
        FavoriteId = value.Id;
    }
    
    NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
    [dictionaryArgs setObject:title forKey:@"Title"];
    [dictionaryArgs setObject:[NSNumber numberWithInteger:FavoriteType] forKey:@"FavoriteType"];
    [dictionaryArgs setObject:[NSNumber numberWithInteger:aUserId] forKey:@"UserID"];
    [dictionaryArgs setObject:[NSNumber numberWithInteger:FavoriteId] forKey:@"FavoriteId"];
    [dictionaryArgs setObject:[NSNumber numberWithInteger:aSubjectParentId] forKey:@"ParentId"];
    [self.db executeDataBaseOPeration:^{
        ret = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
    }];
    return ret;
}
//删除收藏
- (BOOL)deleteWithObject:(NSObject*)obj withUserId:(NSInteger)aUserId
{    
    __block BOOL ret = YES;
    NSString *sql = nil;;
    
    NSInteger FavoriteType = 1;
    if ([obj isKindOfClass:[Subjects class]]) {
        FavoriteType = 1;
        Subjects *value = (Subjects*)obj;
        NSInteger FavoriteId = value.Id;
        sql = [NSString stringWithFormat:@"DELETE FROM Favorites WHERE FavoriteType=%d AND FavoriteId = %d AND UserID = %d",FavoriteType,FavoriteId,aUserId];
    }
    else
    {
        FavoriteType = 2;
        ArticlesOfLaw *value = (ArticlesOfLaw*)obj;
        sql = [NSString stringWithFormat:@"DELETE FROM Favorites WHERE FavoriteType=%d AND Title = '%@' AND UserID = %d",FavoriteType,value.Title,aUserId];
    }
    [self.db executeDataBaseOPeration:^{
        ret = [self.db executeUpdate:sql];
    }];
    return ret;
}
//查询收藏的专题
- (NSArray*)quertFavoriteSubjectWithUserId:(NSInteger)aUserId
{    
    NSString *sql =  @"SELECT"
    @" Subjects.Id"
    @",Subjects.ParentId"
    @",Subjects.Name"
    @",Subjects.Description"
    @",Subjects.OrderId"
    @",Subjects.IsPrivate"
    @",Subjects.LastUpdateTime"
    @",Subjects.Synchronized"
    @",Subjects.isNew"
    @",IFNULL(Favorites.FavoriteId,0) AS isFavorite"
    @",Favorites.ParentId AS FirstParentId"
    @" FROM Subjects"
    @" INNER JOIN Favorites"
    @" ON Favorites.FavoriteId = Subjects.Id"
    @" WHERE Favorites.UserId = ?"
    @" AND Favorites.FavoriteType=1"
    @" ORDER BY Favorites.Id DESC";
    __block FMResultSet *dataSet = nil;
    NSMutableArray *subjects = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        dataSet = [self.db executeQuery:sql,[NSNumber numberWithInteger:aUserId]];
        while ([dataSet next]) {
            NSDictionary *result = [dataSet resultDictionary];
            Subjects *entity = [[Subjects alloc] init];
            [entity reflectDataFromOtherObject:result];
            [subjects addObject:entity];
        }
    }];
    return subjects;
}
//查询法规
- (NSArray*)quertFavoriteArticlesWithUserId:(NSInteger)aUserId
{
    NSString *sql = @"SELECT DISTINCT ArticlesOfLaw.Title"
    @" FROM ArticlesOfLaw"
    @" INNER JOIN Favorites ON Favorites.Title = ArticlesOfLaw.Title"
    @" WHERE Favorites.UserId = ? AND Favorites.FavoriteType=2 ORDER BY Favorites.Id DESC";
    NSMutableArray *articleList = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        FMResultSet *dataSet = [self.db executeQuery:sql,[NSNumber numberWithInteger:aUserId]];
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

- (NSInteger)fistSubjectId:(NSInteger)aSubjectId
{
    __block NSInteger firstSubjectId = aSubjectId;
    [self.db executeDataBaseOPeration:^{
        firstSubjectId = [self.db intForQuery:@"SELECT Subjects.ParentId FROM Subjects WHERE Subjects.Id=?",[NSNumber numberWithInteger:aSubjectId]];
    }];
    if (firstSubjectId==0) {
        firstSubjectId = aSubjectId;
    }
    else
    {
        firstSubjectId = [self fistSubjectId:firstSubjectId];
    }    
    return firstSubjectId;
}

- (BOOL)isFavoriteToArticleTitle:(NSString*)aTitle ForUserId:(NSInteger)aUserId
{
    __block int ret = 0;
    [self.db executeDataBaseOPeration:^{
        ret = [self.db intForQuery:@"SELECT COUNT(Favorites.Id) FROM Favorites WHERE Favorites.Title=?"
               " AND Favorites.FavoriteType=2"
               " AND Favorites.UserId=?"
               ,aTitle
               ,[NSNumber numberWithInteger:aUserId]];
    }];
    return ret>0;
}

- (BOOL)isFavoriteToSubjectId:(NSInteger)aSubjectId ForUserId:(NSInteger)aUserId
{
    __block int ret = 0;
    [self.db executeDataBaseOPeration:^{
        ret = [self.db intForQuery:@"SELECT COUNT(Favorites.Id) FROM Favorites"
               " WHERE Favorites.FavoriteType=1"
               " AND Favorites.FavoriteId=?"
               " AND Favorites.UserId=?"
               ,[NSNumber numberWithInteger:aSubjectId]
               ,[NSNumber numberWithInteger:aUserId]];
    }];
    return ret>0;
}

@end
