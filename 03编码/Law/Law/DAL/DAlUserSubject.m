//
//  DAlUserSubject.m
//  Law
//
//  Created by shulianyong on 13-3-25.
//  Copyright (c) 2013年 shulianyong. All rights reserved.
//

#import "DAlUserSubject.h"
#import "UserInfo.h"
#import "Subjects.h"

@implementation DAlUserSubject

//- (NSArray*)queryFromParentId:(NSInteger)aParentId
//{
//    NSString *queryValue = @"SELECT"
//    @" Id"
//    @" FROM Subjects"
//    @" WHERE ParentId = ?";
//    __block FMResultSet *dataSet = nil;
//    NSMutableArray *subjects = [[NSMutableArray alloc] init];
//    [self.db executeDataBaseOPeration:^{
//        dataSet = [self.db executeQuery:queryValue,[NSNumber numberWithInteger:aParentId]];
//        while ([dataSet next]) {
//            NSDictionary *result = [dataSet resultDictionary];
//            Subjects *entity = [[Subjects alloc] init];
//            [entity reflectDataFromOtherObject:result];
//            [subjects addObject:entity];
//        }
//    }];
//    return subjects;
//}

- (void)addSubjects:(NSArray*)aSubjects atUserID:(NSInteger)aUserID
{
//    for (Subjects *subjectValue in aSubjects) {
//        NSArray *childSubjects = [self queryFromParentId:subjectValue.Id];
//        if ([childSubjects count]>0) {
//            [self addSubjects:childSubjects atUserID:aUserID];
//        }
//    }    
    
    NSString *values = @":UserId,:SubjectId,:SubscriptionStart,:SubscriptionEnd";
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO UserSubject VALUES (%@)",values];
    NSMutableDictionary *dictionaryArgs = [NSMutableDictionary dictionary];
    __block BOOL ret = NO;
    [self.db executeDataBaseOPeration:^{
        [self.db beginTransaction];        
        ret = [self.db executeUpdate:@"DELETE FROM UserSubject WHERE UserId=?",[NSNumber numberWithInteger:aUserID]];
        if (!ret) {
            ERROR(@"db Error:%@",self.db.lastErrorMessage);
        }
        for (Subjects *subject in aSubjects) {
            [dictionaryArgs setObject:[NSNumber numberWithInteger:aUserID] forKey:@"UserId"];
            [dictionaryArgs setObject:[NSNumber numberWithInteger:subject.Id] forKey:@"SubjectId"];
            [dictionaryArgs setObject:subject.SubscriptionStart forKey:@"SubscriptionStart"];
            [dictionaryArgs setObject:subject.SubscriptionEnd forKey:@"SubscriptionEnd"];
            ret = [self.db executeUpdate:sql withParameterDictionary:dictionaryArgs];
        }
        [self.db commit];
    }];
    return;
}

- (NSArray*)userSubject:(NSInteger)aUserId
{
    NSString *sql =  @"SELECT DISTINCT Subjects.Name"
    @",UserSubject.SubscriptionStart"
    @",UserSubject.SubscriptionEnd"
    @" FROM Subjects"
    @" INNER JOIN UserSubject"
    @" ON UserSubject.SubjectId = Subjects.Id"
    @" WHERE UserSubject.UserId = ?"
    @" ORDER BY Subjects.OrderId";
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

@end
