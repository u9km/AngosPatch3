void ShowUltimateMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        
        // الطريقة الحديثة للوصول للنافذة (iOS 13+) لمنع الكراش
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        
        // الطريقة القديمة كخيار احتياطي
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GEMINI ULTIMATE" 
                                                                           message:@"Anti-Ban Active" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *act = [UIAlertAction actionWithTitle:@"ACTIVATE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // استدعاء دالة الهوك هنا
            }];
            
            [act setValue:[UIColor systemGreenColor] forKey:@"titleTextColor"];
            [alert addAction:act];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

