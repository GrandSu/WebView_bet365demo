//
//  DataBase.m
//  ZhongLiLotter
//
//  Created by SuGrand on 16/1/13.
//  Copyright © 2016年 SuGrand. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase

/** 打开数据库*/
- (void)OpenDataBase {
    NSArray * arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = arr[0];
    //    NSLog(@"path:%@", path);
    NSString * dataBasepath = [path stringByAppendingPathComponent:@"USER.db"];
    _dataBase = [FMDatabase databaseWithPath:dataBasepath];
    
    if ([_dataBase open]) {
        NSLog(@"数据库打开成功");
        
    }else {
        NSLog(@"数据库打开失败");
    }
}

/** 创建数据库的表和表的字段名*/
- (void)createHostTable {
    NSString * str = [NSString stringWithFormat:@"CREATE TABLE User_Host (id integer primary key autoincrement, Host text)"];
    
    BOOL b = [_dataBase executeUpdate:str];
    if (b) {
        NSLog(@"表创建成功");
        
        // 插入默认数据
        NSString * sql = [NSString stringWithFormat:@"INSERT INTO User_Host (Host) VALUES(?)"];
        BOOL b = [_dataBase executeUpdate:sql, Host_default];
        if (b) {
            NSLog(@"原始数据添加成功");
        }else{
            NSLog(@"原始数据添加失败");
        }
        
    }else{
        NSLog(@"表创建失败");
    }
}

/** 查询数据*/
- (NSArray *)selectHost {
    NSString * select = [NSString stringWithFormat:@"SELECT * FROM User_Host"];
    FMResultSet * set = [_dataBase executeQuery:select];
    NSMutableArray * muArr = [[NSMutableArray alloc] init];
    while (set.next) {
        NSString * str = [set stringForColumn:@"Host"];
        [muArr addObject:str];
        //        NSLog(@"host:%@", str);
    }
    NSLog(@"共查询到%ld个主机名", muArr.count);
    NSArray * arr = [NSArray arrayWithArray:muArr];
    
    return arr;
}

/** 更新数据*/
- (void)updateHost:(NSString *)host {
    NSString * sql = [NSString stringWithFormat:@"UPDATE User_Host SET Host = ? Where id = 1"];
    BOOL b = [_dataBase executeUpdate:sql, host];
    if (b) {
        NSLog(@"数据更新成功");
    }else {
        NSLog(@"数据更新失败");
    }
}

/** 删除表*/
- (void)deleteHostTable {
    NSString * delete = [NSString stringWithFormat:@"DROP TABLE User_Host"];
    BOOL b = [_dataBase executeUpdate:delete];
    if (b) {
        NSLog(@"旧表删除成功");
    }else {
        NSLog(@"旧表删除失败");
    }
}

@end
