//
//  RolloutPrimitiveTypeWrapper.h
//  Rollout
//
//  Created by Sergey Ilyevsky on 9/3/14.
//  Copyright (c) 2014 DeDoCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RolloutEnum.h"

typedef enum {
    RolloutTypeUShort,
    RolloutTypeChar16,
    RolloutTypeChar_U,
    RolloutTypeChar32,
    RolloutTypeInt128,
    RolloutTypeUInt128,
    RolloutTypeBool,
    RolloutTypeFloat,
    RolloutTypeShort,
    RolloutTypeLong,
    RolloutTypeWChar,
    RolloutTypeULong,
    RolloutTypeDouble,
    RolloutTypeInt,
    RolloutTypeVoid,
    RolloutTypeChar_S,
    RolloutTypeUChar,
    RolloutTypeSChar,
    RolloutTypeLongLong,
    RolloutTypeULongLong,
    RolloutTypeUInt,
    RolloutTypeLongDouble,
    RolloutTypeEnum,
    RolloutTypeBlockPointer,
    RolloutTypePointer,
    RolloutTypeRecordPointer,
    RolloutTypeDefaultObjCObjectPointer,
    RolloutTypeNSData,
    RolloutTypeNSString,
    RolloutTypesCount
} RolloutType;

@class RolloutInvocationDynamicData;

@interface RolloutTypeWrapper : NSObject

-(id)initWithInt:(int)value;
-(id)initWithUShort:(unsigned short)value;
-(id)initWithInt128:(int)value;
-(id)initWithUInt128:(unsigned int)value;
-(id)initWithShort:(short)value;
-(id)initWithLong:(long)value;
-(id)initWithULong:(unsigned long)value;
-(id)initWithLongLong:(long long)value;
-(id)initWithULongLong:(unsigned long long)value;
-(id)initWithUInt:(unsigned int)value;
-(id)initWithLongDouble:(long double)value;
-(id)initWithFloat:(float)value;
-(id)initWithDouble:(double)value;
-(id)initWithBool:(bool)value;
-(id)initWithChar16:(char)value;
-(id)initWithChar32:(char)value;
-(id)initWithChar_U:(char)value;
-(id)initWithWChar:(wchar_t)value;
-(id)initWithUChar:(unsigned char)value;
-(id)initWithSChar:(char)value;
-(id)initWithChar_S:(char)value;
-(id)initWithEnum:(__rollout_enum)value;
-(id)initWithObjCObjectPointer:(id)value type:(RolloutType)type;
-(id)initWithObjCObjectPointer:(id)value;
-(id)initWithBlockPointer:(id)value;
-(id)initWithPointer:(void*)value;
-(id)initWithRecordPointer:(void *)pointer ofSize:(size_t)size shouldBeFreedInDealloc:(BOOL)shouldBeFreedOnDealloc;
-(id)initWithVoid;

@property (nonatomic, readonly) RolloutType type;

@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) unsigned short uShortValue;
@property (nonatomic, readonly) int int128Value;
@property (nonatomic, readonly) unsigned int uInt128Value;
@property (nonatomic, readonly) short shortValue;
@property (nonatomic, readonly) long longValue;
@property (nonatomic, readonly) unsigned long uLongValue;
@property (nonatomic, readonly) long long longLongValue;
@property (nonatomic, readonly) unsigned long long uLongLongValue;
@property (nonatomic, readonly) unsigned int uIntValue;
@property (nonatomic, readonly) long double longDoubleValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) bool boolValue;
@property (nonatomic, readonly) char char16Value;
@property (nonatomic, readonly) char char32Value;
@property (nonatomic, readonly) char char_UValue;
@property (nonatomic, readonly) wchar_t wCharValue;
@property (nonatomic, readonly) unsigned char uCharValue;
@property (nonatomic, readonly) char sCharValue;
@property (nonatomic, readonly) char char_SValue;
@property (nonatomic, readonly) id objCObjectPointerValue;
@property (nonatomic, readonly) id blockPointerValue;
@property (nonatomic, readonly) __rollout_enum enumValue;
@property (nonatomic, readonly) void* pointerValue;
@property (nonatomic, readonly) void* recordPointer;
@property (nonatomic, readonly) size_t recordSize;

@end
