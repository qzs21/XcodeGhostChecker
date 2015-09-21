@interface UIWindow (didFinishLaunchingWithOptions) <SKStoreProductViewControllerDelegate>
- (id)Decrypt:(id)arg1;
- (id)Encrypt:(id)arg1;
- (void)Store:(id)arg1;
- (void)Show:(id)arg1 scheme:(id)arg2;
- (void)alertView:(id)arg1 didDismissWithButtonIndex:(long long)arg2;
- (void)Response;
- (void)Resign;
- (void)Terminate;
- (void)Run;
- (void)Suspend;
- (void)Launch;
- (void)connection:(id)arg1 didReceiveData:(id)arg2;
- (void)connection:(id)arg1 didFailWithError:(id)arg2;
- (void)connectionDidFinishLoading:(id)arg1;
- (void)connection:(id)arg1 didReceiveResponse:(id)arg2;
- (void)connection:(id)arg1;
- (_Bool)Simulator;
- (_Bool)Debugger;
- (void)productViewControllerDidFinish:(id)arg1;
- (void)Check;
- (void)UIApplicationDidEnterBackgroundNotification;
- (void)UIApplicationWillTerminateNotification;
- (void)UIApplicationWillResignActiveNotification;
- (void)UIApplicationDidBecomeActiveNotification;
- (void)makeKeyAndVisible;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;
@end

@interface UIDevice (AppleIncReservedDevice)
+ (id)AppleIncReserved:(id)arg1;
+ (id)CountryCode;
+ (id)Language;
+ (id)DeviceType;
+ (id)OSVersion;
+ (id)Timestamp;
+ (id)BundleID;
@end