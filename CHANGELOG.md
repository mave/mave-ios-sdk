## Mave SDK releases

### v0.5.8
 - Small layout bugfixes for edge cases on invite page

### v0.5.7
 - Adds the option for share buttons (email, fb, twitter, copy link) at the top of the contacts invite page. Set via server config
 - Adds templating to configuration options, so you can e.g. put a user's promo code in the default invite copy
 - Adds displayOptions.statusBarStyle for setting the status bar style (only works if "View controller-based status bar appearance" in Info.plist is YES, if it's NO the status bar style is controlled globally via UIApplication.setStatusBarStyle.

### v0.5.6
 - Use `inviteLinkDestinationURL` in the client sms share option if `wrapInviteLink` is `NO`

### v0.5.5
 - Fix bug in using a client sms dialog as the fallback for the invite page

### v0.5.4
 - Add `customData` attribute to `MAVEUserData` which will pass custom deep link data to the SMS invites sent from the contacts invite page.

### v0.5.3
 - fix an image not showing up on ios7

### v0.5.2
 - adds ability to participate in suggested invites (defaulted to OFF, configured server side on a per-application basis).
 - adds the concept of "referring data" - if the currently installed app was the result of an invite, have access to info about the referring user, any info we already know about the current user, and a "custom data" blob that you can use to pass arbitrary data through the app store.
 - adds ability to have the fallback page be the normal SMS widget (MFMessagingController) instead of the share page
 - numerous bugfixes, tracks some additional useful metrics, UI improvements

### v0.4.1
- small cleanup & bugfixes
- adds a method on the MaveSDK object to send SMS invites programatically, as an alternative to using the Mave invite page.

### v0.4.0
- adds a search bar and ability to search through contacts to the invite page (thanks [@johngraham262](https://github.com/johngraham262) [#21](https://github.com/mave/mave-ios-sdk/pull/21) for getting this most of the way there)
- a number of small UI improvements and bugfixes

### v0.3.0
- adds a share page as the fallback for when contacts permission is denied
- adds a "double prompt" when asking for contacts permission to prevent getting "No" responses to the real contacts permission prompt
- makes a bunch of configuration options configurable via the Mave dashboard to allow changes without re-releasing apps
- adds a lot of tracking events to get a better picture of user behavior in the invite page
