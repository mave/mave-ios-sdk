## Mave SDK releases

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
