//
//  DALSubjectsOfArticles.m
//  Law
//
//  Created by shulianyong on 13-3-24.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALSubjectsOfArticles.h"
#import "ArticlesOfLaw.h"

@implementation DALSubjectsOfArticles

//查找所有专题中的法条
- (NSArray*)quertArticlesWithSubjectId:(NSInteger)aSubjectId withUserId:(NSInteger)aUserId
{  
    NSString *sql = @"SELECT  ArticlesOfLaw.Id"
    @",ArticlesOfLaw.Title"
    @",ArticlesOfLaw.Contents"
    @",ArticlesOfLaw.Keywords"
    @",ArticlesOfLaw.LastUpdateTime"
    @",ArticlesOfLaw.Level"
    @",ArticlesOfLaw.Synchronized"
    @",ArticlesOfLaw.isNew"
    @",IFNULL(Favorites.FavoriteId,0) AS isFavorite"
    @" FROM ArticlesOfLaw"
    @" INNER JOIN SubjectsOfArticles"
    @" ON ArticlesOfLaw.Id= SubjectsOfArticles.ArticleId"
    @" Left join Favorites"
    @" ON Favorites.FavoriteId = ArticlesOfLaw.Id"
    @" And Favorites.UserId = ?"
    @" And Favorites.FavoriteType = 2"
    @" WHERE  SubjectsOfArticles.SubjectId = ?"
    @" ORDER BY ArticlesOfLaw.Level,ArticlesOfLaw.Id";
    
    NSMutableArray *articleList = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        ArticlesOfLaw *previousArticle = nil;
        NSMutableDictionary *dicArticles = nil;
        NSMutableArray *titleArray = nil;
        
        FMResultSet *dataSet = [self.db executeQuery:sql,[NSNumber numberWithInteger:aUserId],[NSNumber numberWithInteger:aSubjectId]];
        BOOL isNew = NO;
        while ([dataSet next]) {
            ArticlesOfLaw *article = [[ArticlesOfLaw alloc] init];
            NSDictionary *dbResult = [dataSet resultDictionary];
            [article reflectDataFromOtherObject:dbResult];            
            if (previousArticle==nil || ![previousArticle.Title isEqualToString:article.Title]) {
                isNew = article.isNew;
                previousArticle = article;
                titleArray = [[NSMutableArray alloc] initWithObjects:article, nil];
                dicArticles = [[NSMutableDictionary alloc] initWithObjectsAndKeys:titleArray,article.Title,nil];
                [articleList addObject:dicArticles];
            }
            else
            {
                if (!isNew) {
                    isNew = article.isNew;
                    [(ArticlesOfLaw*)[titleArray objectAtIndex:0] setIsNew:isNew];
                }
                [titleArray addObject:article];
            }
        }
    }];
    return articleList;
}
//为专题，添加各种法条
- (BOOL)addArtilcesToSubjects:(NSArray*)aArtilces
{ 
    NSString *sql = @"INSERT INTO SubjectsOfArticles (ArticleId,SubjectId) VALUES (?,?)";    
    __block BOOL ret = YES;
    [self.db executeDataBaseOPeration:^{
        [self.db beginTransaction];        
        for (ArticlesOfLaw *article in aArtilces) {
            @autoreleasepool {
                NSString *subjectIds = [article Subjects];
                NSArray *subjectIdList = [subjectIds componentsSeparatedByString:@","];               
                for (NSString *subjectId in subjectIdList) {                    
                    [self.db executeUpdate:sql,[NSNumber numberWithInteger:article.Id],[NSNumber numberWithInteger:[subjectId integerValue]]];
                }
            }            
        }
        [self.db commit];
    }];
    return ret;
}

//验证该专题，是否存在法条
- (BOOL)validateExistArticlesForSubjectId:(NSInteger)aSubjectId
{
    __block int execResult = 0;
    [self.db executeDataBaseOPeration:^{
        execResult = [self.db intForQuery:@"SELECT COUNT(ArticleId) AS rowCount FROM SubjectsOfArticles WHERE SubjectId=?",[NSNumber numberWithInteger:aSubjectId]];
    }];
    return execResult>0;
}

@end
