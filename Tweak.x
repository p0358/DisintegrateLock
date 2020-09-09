#import <HBLog.h>
#import <Cephei/HBPreferences.h>
#import <DisintegrateLock-Swift.h>

#define kIdentifier @"net.p0358.disintegratelock"
#define kSettingsChangedNotification (CFStringRef)@"net.p0358.disintegratelock/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/net.p0358.disintegratelock.plist"


//	=============================== Globals ===============================

HBPreferences *preferences;
bool isAnimationInProgress = false;
int animationCounter = 0;

//	=========================== Preference vars ===========================

bool enabled = true;
bool disableInLPM = false;

double maxAnimationBeginTime = 0.5;
double animationDuration = 1.5;
CGFloat animationTimingRandomFactor = 0.1;

float totalTime = 2.0;

NSInteger estimatedTrianglesCount = 66;
NSInteger direction = 0;

//	=========================== Debugging stuff ===========================

NSString *LogTweakName = @"DisintegrateLock";
bool springboardReady = false;

UIWindow* GetKeyWindow() {
    UIWindow        *foundWindow = nil;
    NSArray         *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow   *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}

//	Shows an alert box. Used for debugging 
void ShowAlert(NSString *msg, NSString *title) {
	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons
    UIAlertAction* dismissButton = [UIAlertAction
                                actionWithTitle:@"Cool!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle dismiss button action here
									
                                }];

    //Add your buttons to alert controller
    [alert addAction:dismissButton];

    [GetKeyWindow().rootViewController presentViewController:alert animated:YES completion:nil];
}

// For some reason HBLog* doesn't work, weird

//	Show log with tweak name as prefix for easy grep
/*static inline void Log(NSString *msg) {
	NSLog(@"NSLog %@: %@", LogTweakName, msg);
	HBLogDebug(@"HBLogDebug %@: %@", LogTweakName, msg);
}*/
#ifdef __DEBUG__
#define Log(...) HBLogDebug(@"[%@] %@", LogTweakName, __VA_ARGS__)
#else
#define Log(...)
#endif

//	Log exception info
static inline void LogException(NSException *e) {
	/*HBLogError(@"%@", @"NSException caught");
	HBLogError(@"Name: %@", e.name);
	HBLogError(@"Reason: %@", e.reason);*/
	NSLog(@"[%@] NSException caught", LogTweakName);
	NSLog(@"[%@] Name:%@", LogTweakName, e.name);
	NSLog(@"[%@] Reason:%@", LogTweakName, e.reason);
	//ShowAlert([NSString stringWithFormat:@"DisintegrateLock Crash Avoided!\nName: %@\nReason: %@", e.name, e.reason], @"Exception Alert");
}



//	=========================== Classes stuff ===========================

extern UIImage* _UICreateScreenUIImage();


@interface SBBacklightController : NSObject
	@property (nonatomic,readonly) BOOL screenIsOn; 
	@property (nonatomic,readonly) BOOL screenIsDim;
@end



@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end


@interface DisintegrateLock:NSObject {
	UIWindow *springboardWindow;
	UIView *mainView;
	UIView *subView;
	UIImageView *imageView;
	UIView *whiteOverlay;
	/*@public bool isAnimationInProgress;
	int animationCounter;*/
}
	-(id)init;
	//-(UIImage*)screenshot;
	-(void)showLockAnimation:(float)arg1;
	-(void)reset;
@end




static DisintegrateLock *__strong disintegrateLock;



@implementation DisintegrateLock
	-(id)init {
		Log(@"init()");
		self = [super init];

		if(self != nil) {
			@try {
				isAnimationInProgress = false;
				animationCounter = 0;

				springboardWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
				//springboardWindow.windowLevel = UIWindowLevelAlert + 2;
				springboardWindow.windowLevel = 10000; // to display above some tweaks that have too big window levels like 9999 (requested for MilkyWay2 in this case)
				[springboardWindow setHidden:YES];
				[springboardWindow _setSecure:YES];
				[springboardWindow setUserInteractionEnabled:NO];
				[springboardWindow setAlpha:1.0];
				springboardWindow.backgroundColor = [UIColor blackColor];
				//[springboardWindow makeKeyAndVisible];

				subView = [[UIView alloc] initWithFrame:springboardWindow.bounds];
				[subView setAlpha:1.0f];
				subView.backgroundColor = [UIColor blackColor];
				subView.layer.masksToBounds = YES;
				[springboardWindow addSubview:subView];

				imageView = [[UIImageView alloc] initWithFrame:springboardWindow.bounds];
				imageView.frame = springboardWindow.bounds;
				imageView.contentMode = UIViewContentModeScaleAspectFill;
				[subView addSubview:imageView];
				
			} @catch (NSException *e) {
				LogException(e);
			}
		}
		return self;
	}

	-(void)showLockAnimation:(float)totalTime {
		Log(@"showLockAnimation()");
		
		@try {
			isAnimationInProgress = true;
			animationCounter++;
			int localAnimationCounter = animationCounter;
			//[self reset];
			
			//	This is stupid and took too long to figure out. _UICreateScreenUIImage returns 
			//	a UIImage but doesn't give ownership to ARC, so it is done manually.
			CFTypeRef ref = (__bridge CFTypeRef)_UICreateScreenUIImage();
			UIImage *img = (__bridge_transfer UIImage*)ref;
			imageView.image = img;
			

			//	Show animation window
			[springboardWindow setHidden:NO];
			
			//	Play first animation, which will also play the second one
			//anim1();

			NSInteger localDirection = direction;
			if (localDirection < 0 || localDirection > 7)
				localDirection = 0;

			[subView disintegrate:localDirection estimatedTrianglesCount:estimatedTrianglesCount
			maxAnimationBeginTime:maxAnimationBeginTime animationDuration:animationDuration animationTimingRandomFactor:animationTimingRandomFactor
			completion:^{
			//[subView disintegrate:0 estimatedTrianglesCount:66 completion:^{
			//[subView disintegrate:0 estimatedTrianglesCount:200 completion:^{
				if (isAnimationInProgress && localAnimationCounter == animationCounter) {
					// the purpose of animationCounter is to prevent this block from a stray cancelled animation reset a new ongoing animation
					[self reset];
					isAnimationInProgress = false;
				}
				//ShowAlert(@"This alert is shown in callback after the animation has been finished, it should mean it works (at least the Swift)", @"Animation finished");
			}];

			//[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(reset) userInfo:nil repeats:NO];

		}
		@catch (NSException *e) {
			isAnimationInProgress = false;
			LogException(e);
		}
		
	}

	-(void)reset {
		Log(@"reset()");

		[springboardWindow setHidden:YES];

		[imageView removeFromSuperview];
		[subView removeFromSuperview];

		subView = [[UIView alloc] initWithFrame:springboardWindow.bounds];
		[subView setAlpha:1.0f];
		subView.backgroundColor = [UIColor blackColor];
		subView.layer.masksToBounds = YES;
		//[mainView addSubview:subView];
		[springboardWindow addSubview:subView];

		imageView = [[UIImageView alloc] initWithFrame:springboardWindow.bounds];
		imageView.frame = springboardWindow.bounds;
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		[subView addSubview:imageView];

		subView.layer.cornerRadius = 0;

		imageView.frame = springboardWindow.bounds;
		imageView.transform = CGAffineTransformIdentity;
		imageView.image = nil;

	}

@end



//	=========================== Hooks ===========================

%hook SpringBoard

	//	Called when springboard is finished launching
	-(void)applicationDidFinishLaunching:(id)application {
		%orig;

		Log(@"============== DisintegrateLock started ==============");

		//[DisintegrateLock sharedInstance];
		disintegrateLock = [[DisintegrateLock alloc] init];
		//ShowAlert(@"DisintegrateLock started", @"Title");

		springboardReady = true;
	}

%end



%hook SBBacklightController
	-(void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(id)arg5 {
		// source
		// 3 = manual lock
		// 8 = after timeout
		// f = SpringBoard launch
		Log([NSString stringWithFormat:@"_animateBacklightToFactor()  Backlight:%f Duration:%f Source:%llx Silently:%i", arg1, arg2, arg3, arg4]);
		if (enabled && 
			arg2 > 0 && // before screen is about to turn on, it shows "_animateBacklightToFactor()  Backlight:0.000000 Duration:0.000000 Source:3 Silently:0"
			(!disableInLPM || (![[NSProcessInfo processInfo] isLowPowerModeEnabled])) && 
			(arg1==0 && [self screenIsOn])
			///*&& !disintegrateLock->isAnimationInProgress*/) {
			&& !isAnimationInProgress) {

			//arg2 = totalTime;
			//arg2 = 10;
			//arg2 = 5;
			//arg2 = 2;
			arg2 = totalTime;


			//for (int i = 0; i < 20; i++)	// For stress testing memory leak (all fixed now)
			[disintegrateLock showLockAnimation:arg2];

			/*[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:^{
				%orig(arg1, arg2, arg3, arg4, arg5);
			} userInfo:nil repeats:NO];*/
			//int64_t delayInSeconds = 5;

			/*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				%orig(arg1, arg2, arg3, arg4, arg5);
			});*/
			/*[NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer *timer) {
				%orig(arg1, arg2, arg3, arg4, arg5);
			}];*/


		//} else if (/*disintegrateLock->isAnimationInProgress &&*/ arg1 > 0 && ![self screenIsOn]) {
		} 

		/*else if (isAnimationInProgress && arg1 > 0 && ![self screenIsOn]) {
			[disintegrateLock reset];
			//disintegrateLock->isAnimationInProgress = false;
			isAnimationInProgress = false;
		}*/

		//else
		%orig(arg1, arg2, arg3, arg4, arg5);
	}

	/* Turning the screen on produces the following log:
	_animateBacklightToFactor()  Backlight:0.000000 Duration:0.000000 Source:3 Silently:0
	turnOnScreenFullyWithBacklightSource:3
	_animateBacklightToFactor()  Backlight:0.010000 Duration:0.000000 Source:3 Silently:1
	_animateBacklightToFactor()  Backlight:1.000000 Duration:0.185000 Source:3 Silently:0
	*/

	-(void)turnOnScreenFullyWithBacklightSource:(long long)arg1 {
		// manual power button press = 3
		// home button press = 2
		Log([NSString stringWithFormat:@"turnOnScreenFullyWithBacklightSource:%llx", arg1]);
		if (isAnimationInProgress) {
			[disintegrateLock reset];
			isAnimationInProgress = false;
		}
		%orig;
	}
	
%end


//	Called whenever any preferences are changed to update variables
static void prefsDidUpdate() {
	Log(@"prefsDidUpdate()");
	/*CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
			if (prefs == nil)
				prefs = [NSDictionary dictionary];
			CFRelease(keyList);
		}
	} else {
		prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}


	enabled = [prefs objectForKey:@"kEnabled"] ? [(NSNumber *)[prefs objectForKey:@"kEnabled"] boolValue] : enabled;
	disableInLPM = [prefs objectForKey:@"kLPM"] ? [(NSNumber *)[prefs objectForKey:@"kLPM"] boolValue] : disableInLPM;*/


	totalTime = maxAnimationBeginTime + animationDuration + (2.0 * animationTimingRandomFactor);
}

#if DEBUG
static void DisLockShow() {
	Log(@"DisLockShow()");
	[disintegrateLock showLockAnimation:totalTime];
}
static void DisLockReset() {
	Log(@"DisLockReset()");
	//disintegrateLock->isAnimationInProgress = false;
	[disintegrateLock reset];
	isAnimationInProgress = false;
}
#endif

%ctor {
	//reloadPrefs();
	//CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
#if DEBUG
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)DisLockShow, (CFStringRef)@"DisLockShow", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)DisLockReset, (CFStringRef)@"DisLockReset", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
#endif

	preferences = [[HBPreferences alloc] initWithIdentifier:@"net.p0358.disintegratelock"];

    [preferences registerBool:&enabled default:YES forKey:@"kEnabled"];
    [preferences registerBool:&disableInLPM default:NO forKey:@"kLPM"];

    [preferences registerDouble:&maxAnimationBeginTime default:0.5 forKey:@"kMaxAnimationBeginTime"];
    [preferences registerDouble:&animationDuration default:1.5 forKey:@"kAnimationDuration"];
    [preferences registerFloat:&animationTimingRandomFactor default:0.1 forKey:@"kAnimationTimingRandomFactor"];

    [preferences registerInteger:&estimatedTrianglesCount default:66 forKey:@"kEstimatedTrianglesCount"];
    [preferences registerInteger:&direction default:0 forKey:@"kDirection"];

    [preferences registerPreferenceChangeBlock:^{
        prefsDidUpdate();
    }];
	//totalTime = animTime1 + pauseTime1 + animTime2 + animTime3;
}