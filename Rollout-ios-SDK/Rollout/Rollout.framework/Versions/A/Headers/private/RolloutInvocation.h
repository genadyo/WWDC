//
//  RolloutInvocation.h
//  MoMe
//
//  Created by eyal keren on 5/21/14.
//  Copyright (c) 2014 eyal keren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef IMP *IMPPointer;

@class RolloutActionProducer;
@class RolloutConfiguration;

typedef enum {
    dummy
} __rollout_enum;

#define ROLLOUT_TYPE_WITH_SIZE(s) __rollout_type_ ## s
#define CREATE_ROLLOUT_TYPE_WITH_SIZE(s) typedef struct { unsigned char buff[s];} ROLLOUT_TYPE_WITH_SIZE(s);

typedef enum{
    TRY_CATCH =0,
    DISABLE,
    NORMAL
} RolloutInvocationType;

extern  BOOL rollout_swizzleInstanceMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) ;
extern  BOOL rollout_swizzleClassMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) ;


@interface RolloutInvocation : NSObject
+ (void) setupWithConfiguation: (RolloutConfiguration*)configuration withProducer: (RolloutActionProducer*) producer;
+ (instancetype) invocationForInstanceMethod:(NSString*) method forClass:(NSString*) clazz;
+ (instancetype) invocationForClassMethod:(NSString*) method forClass:(NSString*) clazz;

+ (void) markInstanceSwizzle:(NSString*) method forClass:(NSString*) clazz;
+ (void) markClassSwizzle:(NSString*) method forClass:(NSString*) clazz;

+ (BOOL) shouldSetupInstanceSwizzle:(NSString*) method forClass:(NSString*) clazz;
+ (BOOL) shouldSetupClassSwizzle:(NSString*) method forClass:(NSString*) clazz;


- (void) runBefore;
- (void) runAfter;
- (void) runAfterExceptionCaught;
- (RolloutInvocationType) invocationType;
- (BOOL) shouldReplaceReturnValue;

#pragma mark - values for Enum
-(__rollout_enum) Enum_replaceReturnValue;
-(__rollout_enum) Enum_tryCatchDefaultValue;

#pragma mark - values for BlockPointer
-(id) BlockPointer_replaceReturnValue;
-(id) BlockPointer_tryCatchDefaultValue;

#pragma mark - values for Pointer (void*)
-(void*) Pointer_replaceReturnValue;
-(void*) Pointer_tryCatchDefaultValue;

#pragma mark - values for id
-(id) ObjCObjectPointer_replaceReturnValue;
-(id) ObjCObjectPointer_tryCatchDefaultValue;

#pragma mark - values for UShort
-(unsigned short) UShort_replaceReturnValue;
-(unsigned short) UShort_tryCatchDefaultValue;

#pragma mark - values for Char16
-(char) Char16_replaceReturnValue;
-(char) Char16_tryCatchDefaultValue;

#pragma mark - values for Char_U
-(char) Char_U_replaceReturnValue;
-(char) Char_U_tryCatchDefaultValue;

#pragma mark - values for Char32
-(char) Char32_replaceReturnValue;
-(char) Char32_tryCatchDefaultValue;

#pragma mark - values for Int128
-(int) Int128_replaceReturnValue;
-(int) Int128_tryCatchDefaultValue;

#pragma mark - values for UInt128
-(unsigned int) UInt128_replaceReturnValue;
-(unsigned int) UInt128_tryCatchDefaultValue;

#pragma mark - values for Bool
-(bool) Bool_replaceReturnValue;
-(bool) Bool_tryCatchDefaultValue;

#pragma mark - values for Float
-(float) Float_replaceReturnValue;
-(float) Float_tryCatchDefaultValue;

#pragma mark - values for Short
-(short) Short_replaceReturnValue;
-(short) Short_tryCatchDefaultValue;

#pragma mark - values for Long
-(long) Long_replaceReturnValue;
-(long) Long_tryCatchDefaultValue;

#pragma mark - values for WChar
-(wchar_t) WChar_replaceReturnValue;
-(wchar_t) WChar_tryCatchDefaultValue;

#pragma mark - values for ULong
-(unsigned long) ULong_replaceReturnValue;
-(unsigned long) ULong_tryCatchDefaultValue;

#pragma mark - values for Double
-(double) Double_replaceReturnValue;
-(double) Double_tryCatchDefaultValue;

#pragma mark - values for Int
-(int) Int_replaceReturnValue;
-(int) Int_tryCatchDefaultValue;

#pragma mark - values for Char_S
-(char) Char_S_replaceReturnValue;
-(char) Char_S_tryCatchDefaultValue;

#pragma mark - values for UChar
-(unsigned char) UChar_replaceReturnValue;
-(unsigned char) UChar_tryCatchDefaultValue;

#pragma mark - values for SChar
-(char) SChar_replaceReturnValue;
-(char) SChar_tryCatchDefaultValue;

#pragma mark - values for LongLong
-(long long) LongLong_replaceReturnValue;
-(long long) LongLong_tryCatchDefaultValue;

#pragma mark - values for ULongLong
-(unsigned long long) ULongLong_replaceReturnValue;
-(unsigned long long) ULongLong_tryCatchDefaultValue;

#pragma mark - values for UInt
-(unsigned int) UInt_replaceReturnValue;
-(unsigned int) UInt_tryCatchDefaultValue;

#pragma mark - values for LongDouble
-(long double) LongDouble_replaceReturnValue;
-(long double) LongDouble_tryCatchDefaultValue;


@end

