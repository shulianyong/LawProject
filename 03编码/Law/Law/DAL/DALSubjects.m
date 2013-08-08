//
//  DALSubjects.m
//  Law
//
//  Created by shulianyong on 13-3-11.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DALSubjects.h"
#import "Subjects.h"

@implementation DALSubjects


- (NSArray*)queryFromParentId:(NSInteger)aParentId withUserId:(NSInteger)aUserId
{
    NSString *queryValue = @"SELECT"
    @" Subjects.Id"
    @",Subjects.ParentId"
    @",Subjects.Name"
    @",Subjects.Description"
    @",Subjects.OrderId"
    @",Subjects.IsPrivate"
    @",Subjects.LastUpdateTime"
    @",Subjects.Synchronized"
    @",Subjects.isNew"
    @",Subjects.Price"
    @",ifnull(Favorites.FavoriteId,0) AS isFavorite"
    @" FROM Subjects"
    @" LEFT JOIN Favorites"
    @" ON Favorites.FavoriteId = Subjects.Id"
    @" And Favorites.UserId = ?"
    @" And Favorites.FavoriteType = 1"
    @" WHERE Subjects.ParentId = ?"
    @" AND Subjects.IsPrivate=0"
    " ORDER BY Subjects.OrderId";
    __block FMResultSet *dataSet = nil;
    NSMutableArray *subjects = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{
        if (aParentId>0) {
            [self.db executeUpdate:@"UPDATE Subjects SET isNew=0 WHERE Subjects.Id=?",[NSNumber numberWithInteger:aParentId]];
        }
        dataSet = [self.db executeQuery:queryValue,[NSNumber numberWithInteger:aUserId],[NSNumber numberWithInteger:aParentId]];
        while ([dataSet next]) {
            NSDictionary *result = [dataSet resultDictionary];
            Subjects *entity = [[Subjects alloc] init];
            [entity reflectDataFromOtherObject:result];
            [subjects addObject:entity];
        }
    }]; 
    return subjects;    
}

- (NSArray*)quertFromUserId:(NSInteger)aUserId
{
    return [self queryFromParentId:0 withUserId:aUserId];
}

- (BOOL)insertSubjects:(NSArray*)aSubjects
{
    
    NSString *fields =  @" Id"
    @",ParentId"
    @",Name"
    @",Description"
    @",OrderId"
    @",IsPrivate"
    @",LastUpdateTime"
    @",Synchronized"
    @",isNew"
    @",Price";
    
    NSString *values = 	@":Id"
    @",:ParentId"
    @",:Name"
    @",:Description"
    @",:OrderId"
    @",:IsPrivate"
    @",:LastUpdateTime"
    @",:Synchronized"
    @",:isNew"
    @",:Price";
    
    __block BOOL ret = YES;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Subjects (%@) VALUES (%@)",fields,values];
    NSString *sqlUpdate = @"UPDATE Subjects SET"
    @" Id=:Id"
    @",ParentId=:ParentId"
    @",Name=:Name"
    @",Description=:Description"
    @",OrderId=:OrderId"
    @",IsPrivate=:IsPrivate"
    @",LastUpdateTime=:LastUpdateTime"
    @",Synchronized=:Synchronized"
    ",isNew=:isNew"
    ",Price=:Price"
    @" WHERE Id=:Id";
    NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
    [self.db executeDataBaseOPeration:^{
        
        [self.db beginTransaction];
        //设置之前的更新，都不是最新
        ret = [self.db executeUpdate:@"UPDATE Subjects SET isNew=? WHERE isNew=?",[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES]];
        for (Subjects *subjectValue in aSubjects) {
            [dictionaryArgs setObject:[NSNumber numberWithInteger:subjectValue.Id] forKey:@"Id"];
            [dictionaryArgs setObject:[NSNumber numberWithInteger:subjectValue.ParentId] forKey:@"ParentId"];
            [dictionaryArgs setObject:subjectValue.Name forKey:@"Name"];
            [dictionaryArgs setObject:subjectValue.Description forKey:@"Description"];
            [dictionaryArgs setObject:[NSNumber numberWithInteger:subjectValue.OrderId] forKey:@"OrderId"];
            [dictionaryArgs setObject:[NSNumber numberWithBool:subjectValue.IsPrivate] forKey:@"IsPrivate"];
            [dictionaryArgs setObject:[NSNumber numberWithDouble:subjectValue.LastUpdateTime]  forKey:@"LastUpdateTime"];
            [dictionaryArgs setObject:[NSNumber numberWithBool:subjectValue.Synchronized] forKey:@"Synchronized"];
            [dictionaryArgs setObject:[NSNumber numberWithBool:YES] forKey:@"isNew"];
            [dictionaryArgs setObject:[NSNumber numberWithFloat:subjectValue.Price] forKey:@"Price"];
            ret = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
            if (!ret) {
                ret = [self.db executeUpdate:sqlUpdate withParameterDictionary:dictionaryArgs];
//                ERROR(@"db Error:%@",[self.db lastErrorMessage]);
            }
        }
        [self.db commit];
    }];
    return ret;
}

- (BOOL)deleteSubjectWithIds:(NSString*)subjectIds
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Subjects WHERE Id in (%@)",subjectIds];
    __block BOOL ret = YES;
    [self.db executeDataBaseOPeration:^{
        ret = [self.db executeUpdate:sql];
        if (!ret) {
//            ERROR(@"db Error:%@",[self.db lastErrorMessage]);
        }
    }];
    return ret;
}

#pragma mark --search
- (Subjects*)fistSubject:(Subjects*)aSubject
{
    if (aSubject.ParentId==0) {
        return aSubject;
    }
    Subjects *firstSubject = [[Subjects alloc] init];
    
    FMResultSet *dataSet = [self.db executeQuery:@"SELECT Subjects.ParentId,Subjects.IsPrivate FROM Subjects WHERE Subjects.Id=?",[NSNumber numberWithInteger:aSubject.ParentId]];
    [dataSet next];
    NSDictionary *result = [dataSet resultDictionary];
    [firstSubject reflectDataFromOtherObject:result];
    firstSubject.Id = aSubject.ParentId;
    
    if (firstSubject.ParentId==0) {
        return firstSubject;
    }
    else
    {
        firstSubject = [self fistSubject:firstSubject];
    }
    return firstSubject;
}

- (NSArray*)searchSubjectsWithName:(NSString*)aName withUserId:(NSInteger)aUserId
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
    @" FROM Subjects"
    @" LEFT JOIN Favorites"
    @" ON Favorites.FavoriteId = Subjects.Id"
    @" AND Favorites.UserId = ?"
    @" AND Favorites.FavoriteType = 1"
    @" WHERE Name LIKE ? "
    @" AND Subjects.IsPrivate=0"
    @" ORDER BY Subjects.OrderId";
    
    
    __block FMResultSet *dataSet = nil;
    NSMutableArray *subjects = [[NSMutableArray alloc] init];
    [self.db executeDataBaseOPeration:^{        
        NSString *searchName = @"%";
        searchName = [searchName stringByAppendingString:aName];
        searchName = [searchName stringByAppendingString:@"%"];
        dataSet = [self.db executeQuery:sql,[NSNumber numberWithInteger:aUserId],searchName];
        while ([dataSet next]) {
            NSDictionary *result = [dataSet resultDictionary];
            Subjects *entity = [[Subjects alloc] init];
            [entity reflectDataFromOtherObject:result];
            if (![self fistSubject:entity].IsPrivate) {                
                [subjects addObject:entity];                
            }
        }
    }];
    return subjects;
}

//验证
- (BOOL)isExistSubject
{
    __block BOOL isExist = YES;
    [self.db executeDataBaseOPeration:^{
        int rowNumber = [self.db intForQuery:@"select COUNT(*) AS RowNumber from Subjects"];
        isExist = (rowNumber>0);
    }];
    return isExist;
}


- (BOOL)isExistChildForParentId:(NSInteger)aSubjectId
{
    NSString *sql = @"SELECT COUNT(Subjects.Id) AS RowNumber"
    @" FROM Subjects"
    @" WHERE Subjects.ParentId = ?";
    
    __block int quertResult = 0;
    
    [self.db executeDataBaseOPeration:^{
        quertResult = [self.db intForQuery:sql,[NSNumber numberWithInteger:aSubjectId]];
    }];
    return (quertResult>0);
}

//验证,该subjectID是否支持使用，该subjectId是父id
- (BOOL)validateSubjectId:(NSInteger)aSubjectId forUserId:(NSInteger)aUserId
{
    __block int quertResult = 0;
    [self.db executeDataBaseOPeration:^{
        quertResult = [self.db intForQuery:@"SELECT COUNT(Subjects.Id) AS RowNumber"
                       " FROM Subjects"
                       " LEFT JOIN UserSubject"
                       " ON Subjects.Id = UserSubject.SubjectId"
                       " AND UserSubject.UserId = ?"
                       " WHERE Subjects.Id=? AND (Subjects.Price=0 OR UserSubject.SubjectId>0)"
                       ,[NSNumber numberWithInteger:aUserId]
                       ,[NSNumber numberWithInteger:aSubjectId]];
    }];
    return quertResult>0;
}

@end
