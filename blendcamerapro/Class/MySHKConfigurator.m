
#import "MySHKConfigurator.h"

@implementation MySHKConfigurator

/* 
 App Description 
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
    NSString *appname = @"Fast Fx";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appname = @"Fast Fx";
	return appname;
    
}

- (NSString*)appURL {
	return @"http://applistar.com";
}

/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */

// Vkontakte
// SHKVkontakteAppID is the Application ID provided by Vkontakte
- (NSString*)vkontakteAppId {
	return @"";
}

// Facebook - https://developers.facebook.com/apps
// SHKFacebookAppID is the Application ID provided by Facebook
// SHKFacebookLocalAppID is used if you need to differentiate between several iOS apps running against a single Facebook app. Useful, if you have full and lite versions of the same app,
// and wish sharing from both will appear on facebook as sharing from one main app. You have to add different suffix to each version. Do not forget to fill both suffixes on facebook developer ("URL Scheme Suffix"). Leave it blank unless you are sure of what you are doing. 
// The CFBundleURLSchemes in your App-Info.plist should be "fb" + the concatenation of these two IDs.
// Example: 
//    SHKFacebookAppID = 555
//    SHKFacebookLocalAppID = lite
// 
//    Your CFBundleURLSchemes entry: fb555lite
- (NSString*)facebookAppId {
    NSString *fbid = @"715233731824509";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fbid = @"173604609459899";
	return fbid;
}

- (NSString*)facebookLocalAppId {
	return @"";
}

// Read It Later - http://readitlaterlist.com/api/signup/ 
- (NSString*)readItLaterKey {
	return @"";
}

// Diigo - http://www.diigo.com/api_keys/new/
- (NSString*)diigoKey {
    return @"";
}
// Twitter - http://dev.twitter.com/apps/new
/*
 Important Twitter settings to get right:
 
 Differences between OAuth and xAuth
 --
 There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
 present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth to your app (you have to request it from them).
 If your app has been approved for xAuth, set SHKTwitterUseXAuth to 1.
 
 Callback URL (important to get right for OAuth users)
 --
 1. Open your application settings at http://dev.twitter.com/apps/
 2. 'Application Type' should be set to BROWSER (not client)
 3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is redirected.  It just needs to match.
 */

/*
 If you want to force use of old-style, pre-IOS5 twitter framework, for example to ensure
 twitter accounts don't end up in the devices account store, set this to true.
 */

- (NSString*)twitterConsumerKey {
	return @"9kISEhPOgvYxqlyNxrPpLQ";
}

- (NSString*)twitterSecret {
	return @"RFwecjCrqvQJOF0gnwbY5WgUfPGrK10bLmphLPlvOsY";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}
// Evernote - http://www.evernote.com/about/developer/api/
/*	You need to set to sandbox until you get approved by evernote. If you use sandbox, you can use it with special sandbox user account only. You can create it here: https://sandbox.evernote.com/Registration.action
 // Sandbox
 #define SHKEvernoteUserStoreURL    @"https://sandbox.evernote.com/edam/user"
 #define SHKEvernoteNetStoreURLBase @"http://sandbox.evernote.com/edam/note/"
 
 // Or production
 #define SHKEvernoteUserStoreURL    @"https://www.evernote.com/edam/user"
 #define SHKEvernoteNetStoreURLBase @"http://www.evernote.com/edam/note/"
 */

- (NSString*)evernoteUserStoreURL {
	return @"";
}

- (NSString*)evernoteNetStoreURLBase {
	return @"";
}

- (NSString*)evernoteConsumerKey {
	return @"";
}

- (NSString*)evernoteSecret {
	return @"";
}
// Flickr - http://www.flickr.com/services/apps/create/
/*
 1 - This requires the CFNetwork.framework 
 2 - One needs to setup the flickr app as a "web service" on the flickr authentication flow settings, and enter in your app's custom callback URL scheme. 
 3 - make sure you define and create the same URL scheme in your apps info.plist. It can be as simple as yourapp */
- (NSString*)flickrConsumerKey {
    NSString *str = @"01c4b005143177b484beaeb88b5556c4";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        str = @"01c4b005143177b484beaeb88b5556c4";
	return str;
}

- (NSString*)flickrSecretKey {
    NSString *str = @"cbd97be707bd3a0e";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        str = @"cbd97be707bd3a0e";
	return str;    
}
// The user defined callback url
- (NSString*)flickrCallbackUrl{
    NSString *str = @"fastFx";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        str = @"fastFx";
	return str;
}

// Bit.ly for shortening URLs in case you use original SHKTwitter sharer (pre iOS5). If you use iOS 5 builtin framework, the URL will be shortened anyway, these settings are not used in this case. http://bit.ly/account/register - after signup: http://bit.ly/a/your_api_key If you do not enter bit.ly credentials, URL will be shared unshortened.
- (NSString*)bitLyLogin {
	return @"";
}

- (NSString*)bitLyKey {
	return @"";
}

// LinkedIn - https://www.linkedin.com/secure/developer
- (NSString*)linkedInConsumerKey {
	return @"";
}

- (NSString*)linkedInSecret {
	return @"";
}

- (NSString*)linkedInCallbackUrl {
	return @"";
}

// Readability - http://www.readability.com/publishers/api/
- (NSString*)readabilityConsumerKey {
	return @"";
}

- (NSString*)readabilitySecret {
	return @"";
}
// To use xAuth, set to 1, Currently ONLY supports XAuth
- (NSNumber*)readabilityUseXAuth {
	return [NSNumber numberWithInt:1];
}
// Foursquare V2 - https://developer.foursquare.com
- (NSString*)foursquareV2ClientId {
    return @"";
}

- (NSString*)foursquareV2RedirectURI {
    return @"";
}

@end