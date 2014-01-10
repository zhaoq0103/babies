
//TASK
/*
 week             int        week id
 
 weektasks        NSArray     
 */

#import "BaseModel.h"

@interface TaskModel : BaseModel

@property(nonatomic,retain)NSNumber         * weekID;
@property(nonatomic,retain)NSMutableArray   * tasksData;

@end



//task detail
@interface TaskDetailModel : BaseModel

@property(nonatomic,copy)NSString           * name;
@property(nonatomic,copy)NSString           * detail;

@end