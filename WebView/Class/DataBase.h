//
//  DataBase.h
//  ZhongLiLotter
//
//  Created by SuGrand on 16/1/13.
//  Copyright © 2016年 SuGrand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject
@property (strong,nonatomic) FMDatabase * dataBase;

/** 打开数据库*/
- (void)OpenDataBase;

/** 创建数据库的表和表的字段名*/
- (void)createHostTable;

/** 查询数据*/
- (NSArray *)selectHost;

/** 更新数据*/
- (void)updateHost:(NSString *)host;

/** 删除表*/
- (void)deleteHostTable;


@end
