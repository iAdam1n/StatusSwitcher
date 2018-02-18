%group iOS11
@interface LayoutContext : NSObject
- (id)layoutState;
@end

@interface SBFluidSwitcherViewController : UIViewController
- (BOOL)_isLayoutStateSwitcher:(id)arg1 allowTransitions:(BOOL)arg2;
- (LayoutContext *)layoutContext;
@end

@interface SBAppStatusBarSettingsAssertion : NSObject
- (void)invalidate;
- (void)acquire;
-(id)initWithStatusBarHidden:(BOOL)hidden atLevel:(NSUInteger)level reason:(NSString *)reason;
@property (nonatomic,readonly) NSUInteger level; 
@property (nonatomic,copy,readonly) NSString * reason;   
@end

SBAppStatusBarSettingsAssertion *assertion;


%hook SBFluidSwitcherViewController
- (void)_updateSpringBoardStatusBarAssertionAnimated:(BOOL)animated {
	%orig;
	if ([self _isLayoutStateSwitcher:[[self layoutContext] layoutState] allowTransitions:YES]) {
		if (!assertion) {
			assertion = [[NSClassFromString(@"SBAppStatusBarSettingsAssertion") alloc] initWithStatusBarHidden:NO atLevel:5 reason:@"Status Switcher"];
			[assertion acquire];
		}
	} else {
		if (assertion) {
			[assertion invalidate];
			assertion = nil;
		}
	}
	return;
}
%end
%end

%group iOS10
%hook SBSwitcherMetahostingHomePageContentView
	-(void)_createFakeStatusBar {
}
%end
%end

%ctor {
	if (kCFCoreFoundationVersionNumber > 1400) {
        %init(iOS11);
    } else {
        %init(iOS10);
    }
}