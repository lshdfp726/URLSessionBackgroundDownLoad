软件环境:xcode 8  iOS 10 
利用URLSession 进行后台下载
1.首先plist 里面需要手动添加 Required background modes  并且选择App downloads content from the network 值
2.App Transport Security Settings 设置一下，可以使用http协议，当然也可以用其它方法实现使用http
3.参考appdelegate 代码 建立后台的NSURLSessionConfiguration  - (void)backgroundSessionConfigurationWithIdentifier;
4.下载的数据最好稍微大一些，比如1M以上（根据网速决定），这样你才有时间切到后台观察后台系统调用的方法
5.切入后台时候URLSessionDownload 代理方法不执行，但是系统默默的帮你开启特殊线程下载,当下载完成或者出现错误，系统会调用- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
 方法 给你一个回调，在这里你可以保存 completionHandler() 
6.第五部完成后，系统会自动调用NSURLSessionDownloadTask 的完成代理方法，此时你做一些保存数据工作。
7.等你所有工作做完，系统会调用URLSessionDidFinishEventsForBackgroundURLSession 方法，在这里面你可以做一些必入操作UI，或者其它一些任务，最后调用第五部保存的completionHandler() ，告诉系统。所有下载任务已经完成。
