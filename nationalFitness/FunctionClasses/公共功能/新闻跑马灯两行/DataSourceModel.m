/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "DataSourceModel.h"

@implementation DataSourceModel

+ (instancetype)dataSourceModelWithType:(NSString *)type title:(NSString *)title URLString:(NSString *)URLString {
    DataSourceModel *model = [[DataSourceModel alloc] init];
    model.type = type;
    model.title = title;
    model.URLString = URLString;
    return model;
}


+ (instancetype)dataSourceModelWithType:(NSString *)type title:(NSString *)title URLString:(NSString *)URLString tailTime:(NSString *)time{
    DataSourceModel *model = [[DataSourceModel alloc] init];
    model.type = type;
    model.title = title;
    model.URLString = URLString;
    model.time = time;
    return model;
}


@end
