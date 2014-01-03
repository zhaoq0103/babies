//
//  ExpertPageUtils.m
//  babyfaq
//
//  Created by PRO on 13-6-28.
//  Copyright (c) 2013年 sina. All rights reserved.
//

#import "ExpertPageUtils.h"
#import "MessageManager.h"

@implementation ExpertPageUtils


+ (NSString*)getStringForAskingPreInfo
{
    NSDictionary* infoDcit = [[MessageManager getInstance]  readUserSettinginfo];
    NSString* genderStr = nil;
    NSString* babytime = nil;
    if (infoDcit)
    {
        NSString* gender = [infoDcit objectForKey:@"gender"];
        if (gender)
        {
            if ([gender intValue] == 1) {
                genderStr = [NSString stringWithFormat:@"男宝"];
            }
            if ([gender intValue] == 2) {
                genderStr = [NSString stringWithFormat:@"女宝"];
            }
            
            NSString* dateinfo = [infoDcit valueForKey:@"mDate"];
            if (dateinfo)
            {
                NSDate *now = [NSDate date];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                
                [dateFormatter setTimeZone:timeZone];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *then  = [dateFormatter dateFromString:dateinfo];
                [dateFormatter release];
                
                
                NSTimeInterval howLong = [now timeIntervalSinceDate:then];
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:howLong];
                NSString *dateStr = [date description];
                const char *dateStrPtr = [dateStr UTF8String];
                
                
                int year, month, day, hour, minute, sec;
                
                sscanf(dateStrPtr, "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &sec);
                year -= 1970;
                
                if (year > 0) {
                    if (month  == 1)
                    {
                        babytime = [NSString stringWithFormat:@"%d岁 ", year];
                    }
                    else
                    {
                        babytime = [NSString stringWithFormat:@"%d岁零%d个月 ", year, month - 1];
                    }
                }
                else
                {
                    if (month - 1 == 0) {
                        babytime = [NSString stringWithFormat:@"%d天 ", day];
                    }
                    else
                    {
                        babytime = [NSString stringWithFormat:@"%d个月 ", month - 1];
                    }
                }
                
            }
        }
        else
        {
            NSString* dateinfo = [infoDcit valueForKey:@"mDate"];            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];            
            NSTimeZone *timeZone = [NSTimeZone localTimeZone];            
            [dateFormatter setTimeZone:timeZone];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *then  = [dateFormatter dateFromString:dateinfo];
                                
            [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
            
            NSString* dateStr = [dateFormatter stringFromDate:then];
            [dateFormatter release];
            if (dateStr != nil) {
                 babytime = [NSString stringWithFormat:@"预产期%@", dateStr];
            }
            else
            {
                babytime = @"";
            }
            
        }
    }
    
    
    NSString* content = nil;
    
    if (genderStr && babytime)
    {
        content = [NSString stringWithFormat:@"提问：%@%@ ", babytime, genderStr];
    }
    else if(babytime)
    {
        content = [NSString stringWithFormat:@"提问：%@ ", babytime];
    }
    else
    {
        content = [NSString stringWithFormat:@"提问："];
    }

    return content;
}

@end
