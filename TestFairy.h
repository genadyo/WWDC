#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestFairy: NSObject

/**
 * Initialize a TestFairy session.
 *
 * @param APIKey
 */
+ (void)begin:(NSString *)APIKey;

/**
 * Hide a specific view from appearing in the video generated.
 *
 * @param view
 */
+ (void)hideView:(UIView *)view;

/**
 * (Optional) Push the feedback view controller. Hook a button
 * to this method to allow users to provide feedback about the current
 * session. All feedback will appear in your build report page, and in
 * the recorded session page.
 *
 */
+ (void)pushFeedbackController;

/**
 * (Optional) Proxy didUpdateLocation delegate values and these
 * locations will appear in the recorded sessions. Useful for debugging
 * actual long/lat values against what the user sees on screen.
 *
 * @param locations
 */
+ (void)updateLocation:(NSArray *)locations;

/**
 * (Optional) Mark a checkpoint in session. Use this text to tag a 
 * session with a checkpoint name. Later you can filter sessions
 * that passed through this checkpoint, for better understanding
 * user experience.
 *
 * @param name
 */
+ (void)checkpoint:(NSString *)name;

/**
 * (Optional) Set a correlation identifier for this session. This
 * value can be looked up via web dashboard. For example, setting
 * correlation id with user id after they logged in. Can be called
 * only once per session.
 *
 * @param correlationId
 */
+ (void)setCorrelationId:(NSString *)correlationId;

@end
