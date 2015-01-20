//
//  MAVENameParsingUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/12/15.
//
//

#import "MAVENameParsingUtils.h"

@implementation MAVENameParsingUtils

+ (NSString *)joinFirstName:(NSString *)firstName
                andLastName:(NSString *)lastName {
    NSString *full;
    if ([firstName length] > 0 && [lastName length] > 0) {
        full = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else if ([firstName length] > 0 && [lastName length] == 0) {
        full = firstName;
    } else if ([firstName length] == 0 && [lastName length] > 0) {
        full = lastName;
    } else {
        full = nil;
    }
    return full;
}

+ (void)fillFirstName:(NSString *__autoreleasing *)firstName
             lastName:(NSString *__autoreleasing *)lastName
       fromDeviceName:(NSString *)deviceName {

    // Regex to catch matches of names of the type "<person name><device type>" e.g. Danny's iPhone 6
    NSString *nameMatch;
    NSString *regexPattern = @"^(.*?)(?:['’]s)?(?: |-|_)?(?:iPhone|iPad|iPod).*";
    NSRegularExpression *nameRegex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [nameRegex matchesInString:deviceName
                                          options:0
                                            range:NSMakeRange(0, [deviceName length])];
    if ([matches count] >= 1) {
        NSTextCheckingResult *match = [matches objectAtIndex:0];
        NSRange matchRange = [match rangeAtIndex:1];
        nameMatch = [deviceName substringWithRange:matchRange];
    }

    // Now try to split first & last name
    NSString *fn, *ln;
    if (nameMatch) {
        NSString *firstLastRegexPattern = @"^(.*)(?: |-|_)(.*)$";
        NSRegularExpression *firstLastRegex = [NSRegularExpression regularExpressionWithPattern:
                                               firstLastRegexPattern options:0 error:nil];
        NSArray *firstLastMatches = [firstLastRegex matchesInString:nameMatch
                                                            options:0
                                                              range:NSMakeRange(0, [nameMatch length])];
        if ([firstLastMatches count] >= 1) {
            NSTextCheckingResult *firstMatch = [firstLastMatches objectAtIndex:0];
            NSRange firstMatchRange = [firstMatch rangeAtIndex:1];
            fn = [deviceName substringWithRange:firstMatchRange];
            NSTextCheckingResult *lastMatch = [firstLastMatches objectAtIndex:0];
            NSRange lastMatchRange = [lastMatch rangeAtIndex:2];
            ln = [deviceName substringWithRange:lastMatchRange];
        } else {
            fn = nameMatch;
        }
    }

    // Strip any numbers from the names
    NSString *numbersToReplaceRegexPattern = @"[0-9]";
    NSRegularExpression *numbersToReplaceRegex = [NSRegularExpression regularExpressionWithPattern:numbersToReplaceRegexPattern options:0 error:nil];
    if (fn) {
        fn = [numbersToReplaceRegex stringByReplacingMatchesInString:fn options:0 range:NSMakeRange(0, [fn length]) withTemplate:@""];
    }
    if (ln) {
        ln = [numbersToReplaceRegex stringByReplacingMatchesInString:ln options:0 range:NSMakeRange(0, [ln length]) withTemplate:@""];
    }

    // If either of the names are swear words throw them out
    if ([self isBadWord:fn] || [self isBadWord:ln]) {
        fn = nil;
        ln = nil;
    }

    // clean up empty strings to be nil
    if ([fn length] == 0) {
        fn = nil;
    }
    if ([ln length] == 0) {
        ln = nil;
    }
    *firstName = fn;
    *lastName = ln;
}

+ (BOOL)isBadWord:(NSString *)word {
    NSString *lowerWord = [word lowercaseString];
    if ([[self badWordsList] objectForKey:lowerWord]) {
        return YES;
    } else {
        return NO;
    }
}

static NSDictionary *MAVEBadWordsList;
+ (NSDictionary *)badWordsList {
    if (!MAVEBadWordsList) {
        // This is Google's list of bad words http://fffff.at/googles-official-list-of-bad-words/
        MAVEBadWordsList =
        @{
          @"4r5e": @YES,
          @"5h1t": @YES,
          @"5hit": @YES,
          @"a55": @YES,
          @"anal": @YES,
          @"anus": @YES,
          @"ar5e": @YES,
          @"arrse": @YES,
          @"arse": @YES,
          @"ass": @YES,
          @"ass-fucker": @YES,
          @"asses": @YES,
          @"assfucker": @YES,
          @"assfukka": @YES,
          @"asshole": @YES,
          @"assholes": @YES,
          @"asswhole": @YES,
          @"a_s_s": @YES,
          @"b!tch": @YES,
          @"b00bs": @YES,
          @"b17ch": @YES,
          @"b1tch": @YES,
          @"ballbag": @YES,
          @"balls": @YES,
          @"ballsack": @YES,
          @"bastard": @YES,
          @"beastial": @YES,
          @"beastiality": @YES,
          @"bellend": @YES,
          @"bestial": @YES,
          @"bestiality": @YES,
          @"bi+ch": @YES,
          @"biatch": @YES,
          @"bitch": @YES,
          @"bitcher": @YES,
          @"bitchers": @YES,
          @"bitches": @YES,
          @"bitchin": @YES,
          @"bitching": @YES,
          @"bloody": @YES,
          @"blow job": @YES,
          @"blowjob": @YES,
          @"blowjobs": @YES,
          @"boiolas": @YES,
          @"bollock": @YES,
          @"bollok": @YES,
          @"boner": @YES,
          @"boob": @YES,
          @"boobs": @YES,
          @"booobs": @YES,
          @"boooobs": @YES,
          @"booooobs": @YES,
          @"booooooobs": @YES,
          @"breasts": @YES,
          @"buceta": @YES,
          @"bugger": @YES,
          @"bum": @YES,
          @"bunny fucker": @YES,
          @"butt": @YES,
          @"butthole": @YES,
          @"buttmuch": @YES,
          @"buttplug": @YES,
          @"c0ck": @YES,
          @"c0cksucker": @YES,
          @"carpet muncher": @YES,
          @"cawk": @YES,
          @"chink": @YES,
          @"cipa": @YES,
          @"cl1t": @YES,
          @"clit": @YES,
          @"clitoris": @YES,
          @"clits": @YES,
          @"cnut": @YES,
          @"cock": @YES,
          @"cock-sucker": @YES,
          @"cockface": @YES,
          @"cockhead": @YES,
          @"cockmunch": @YES,
          @"cockmuncher": @YES,
          @"cocks": @YES,
          @"cocksuck ": @YES,
          @"cocksucked ": @YES,
          @"cocksucker": @YES,
          @"cocksucking": @YES,
          @"cocksucks ": @YES,
          @"cocksuka": @YES,
          @"cocksukka": @YES,
          @"cok": @YES,
          @"cokmuncher": @YES,
          @"coksucka": @YES,
          @"coon": @YES,
          @"cox": @YES,
          @"crap": @YES,
          @"cum": @YES,
          @"cummer": @YES,
          @"cumming": @YES,
          @"cums": @YES,
          @"cumshot": @YES,
          @"cunilingus": @YES,
          @"cunillingus": @YES,
          @"cunnilingus": @YES,
          @"cunt": @YES,
          @"cuntlick ": @YES,
          @"cuntlicker ": @YES,
          @"cuntlicking ": @YES,
          @"cunts": @YES,
          @"cyalis": @YES,
          @"cyberfuc": @YES,
          @"cyberfuck ": @YES,
          @"cyberfucked ": @YES,
          @"cyberfucker": @YES,
          @"cyberfuckers": @YES,
          @"cyberfucking ": @YES,
          @"d1ck": @YES,
          @"damn": @YES,
          @"dick": @YES,
          @"dickhead": @YES,
          @"dildo": @YES,
          @"dildos": @YES,
          @"dink": @YES,
          @"dinks": @YES,
          @"dirsa": @YES,
          @"dlck": @YES,
          @"dog-fucker": @YES,
          @"doggin": @YES,
          @"dogging": @YES,
          @"donkeyribber": @YES,
          @"doosh": @YES,
          @"duche": @YES,
          @"dyke": @YES,
          @"ejaculate": @YES,
          @"ejaculated": @YES,
          @"ejaculates ": @YES,
          @"ejaculating ": @YES,
          @"ejaculatings": @YES,
          @"ejaculation": @YES,
          @"ejakulate": @YES,
          @"f u c k": @YES,
          @"f u c k e r": @YES,
          @"f4nny": @YES,
          @"fag": @YES,
          @"fagging": @YES,
          @"faggitt": @YES,
          @"faggot": @YES,
          @"faggs": @YES,
          @"fagot": @YES,
          @"fagots": @YES,
          @"fags": @YES,
          @"fanny": @YES,
          @"fannyflaps": @YES,
          @"fannyfucker": @YES,
          @"fanyy": @YES,
          @"fatass": @YES,
          @"fcuk": @YES,
          @"fcuker": @YES,
          @"fcuking": @YES,
          @"feck": @YES,
          @"fecker": @YES,
          @"felching": @YES,
          @"fellate": @YES,
          @"fellatio": @YES,
          @"fingerfuck ": @YES,
          @"fingerfucked ": @YES,
          @"fingerfucker ": @YES,
          @"fingerfuckers": @YES,
          @"fingerfucking ": @YES,
          @"fingerfucks ": @YES,
          @"fistfuck": @YES,
          @"fistfucked ": @YES,
          @"fistfucker ": @YES,
          @"fistfuckers ": @YES,
          @"fistfucking ": @YES,
          @"fistfuckings ": @YES,
          @"fistfucks ": @YES,
          @"flange": @YES,
          @"fook": @YES,
          @"fooker": @YES,
          @"fuck": @YES,
          @"fucka": @YES,
          @"fucked": @YES,
          @"fucker": @YES,
          @"fuckers": @YES,
          @"fuckhead": @YES,
          @"fuckheads": @YES,
          @"fuckin": @YES,
          @"fucking": @YES,
          @"fuckings": @YES,
          @"fuckingshitmotherfucker": @YES,
          @"fuckme ": @YES,
          @"fucks": @YES,
          @"fuckwhit": @YES,
          @"fuckwit": @YES,
          @"fudge packer": @YES,
          @"fudgepacker": @YES,
          @"fuk": @YES,
          @"fuker": @YES,
          @"fukker": @YES,
          @"fukkin": @YES,
          @"fuks": @YES,
          @"fukwhit": @YES,
          @"fukwit": @YES,
          @"fux": @YES,
          @"fux0r": @YES,
          @"f_u_c_k": @YES,
          @"gangbang": @YES,
          @"gangbanged ": @YES,
          @"gangbangs ": @YES,
          @"gaylord": @YES,
          @"gaysex": @YES,
          @"goatse": @YES,
          @"God": @YES,
          @"god-dam": @YES,
          @"god-damned": @YES,
          @"goddamn": @YES,
          @"goddamned": @YES,
          @"hardcoresex ": @YES,
          @"hell": @YES,
          @"heshe": @YES,
          @"hoar": @YES,
          @"hoare": @YES,
          @"hoer": @YES,
          @"homo": @YES,
          @"hore": @YES,
          @"horniest": @YES,
          @"horny": @YES,
          @"hotsex": @YES,
          @"jack-off ": @YES,
          @"jackoff": @YES,
          @"jap": @YES,
          @"jerk-off ": @YES,
          @"jism": @YES,
          @"jiz ": @YES,
          @"jizm ": @YES,
          @"jizz": @YES,
          @"kawk": @YES,
          @"knob": @YES,
          @"knobead": @YES,
          @"knobed": @YES,
          @"knobend": @YES,
          @"knobhead": @YES,
          @"knobjocky": @YES,
          @"knobjokey": @YES,
          @"kock": @YES,
          @"kondum": @YES,
          @"kondums": @YES,
          @"kum": @YES,
          @"kummer": @YES,
          @"kumming": @YES,
          @"kums": @YES,
          @"kunilingus": @YES,
          @"l3i+ch": @YES,
          @"l3itch": @YES,
          @"labia": @YES,
          @"lmfao": @YES,
          @"lust": @YES,
          @"lusting": @YES,
          @"m0f0": @YES,
          @"m0fo": @YES,
          @"m45terbate": @YES,
          @"ma5terb8": @YES,
          @"ma5terbate": @YES,
          @"masochist": @YES,
          @"master-bate": @YES,
          @"masterb8": @YES,
          @"masterbat*": @YES,
          @"masterbat3": @YES,
          @"masterbate": @YES,
          @"masterbation": @YES,
          @"masterbations": @YES,
          @"masturbate": @YES,
          @"mo-fo": @YES,
          @"mof0": @YES,
          @"mofo": @YES,
          @"mothafuck": @YES,
          @"mothafucka": @YES,
          @"mothafuckas": @YES,
          @"mothafuckaz": @YES,
          @"mothafucked ": @YES,
          @"mothafucker": @YES,
          @"mothafuckers": @YES,
          @"mothafuckin": @YES,
          @"mothafucking ": @YES,
          @"mothafuckings": @YES,
          @"mothafucks": @YES,
          @"mother fucker": @YES,
          @"motherfuck": @YES,
          @"motherfucked": @YES,
          @"motherfucker": @YES,
          @"motherfuckers": @YES,
          @"motherfuckin": @YES,
          @"motherfucking": @YES,
          @"motherfuckings": @YES,
          @"motherfuckka": @YES,
          @"motherfucks": @YES,
          @"muff": @YES,
          @"mutha": @YES,
          @"muthafecker": @YES,
          @"muthafuckker": @YES,
          @"muther": @YES,
          @"mutherfucker": @YES,
          @"n1gga": @YES,
          @"n1gger": @YES,
          @"nazi": @YES,
          @"nigg3r": @YES,
          @"nigg4h": @YES,
          @"nigga": @YES,
          @"niggah": @YES,
          @"niggas": @YES,
          @"niggaz": @YES,
          @"nigger": @YES,
          @"niggers ": @YES,
          @"nob": @YES,
          @"nob jokey": @YES,
          @"nobhead": @YES,
          @"nobjocky": @YES,
          @"nobjokey": @YES,
          @"numbnuts": @YES,
          @"nutsack": @YES,
          @"orgasim ": @YES,
          @"orgasims ": @YES,
          @"orgasm": @YES,
          @"orgasms ": @YES,
          @"p0rn": @YES,
          @"pawn": @YES,
          @"pecker": @YES,
          @"penis": @YES,
          @"penisfucker": @YES,
          @"phonesex": @YES,
          @"phuck": @YES,
          @"phuk": @YES,
          @"phuked": @YES,
          @"phuking": @YES,
          @"phukked": @YES,
          @"phukking": @YES,
          @"phuks": @YES,
          @"phuq": @YES,
          @"pigfucker": @YES,
          @"pimpis": @YES,
          @"piss": @YES,
          @"pissed": @YES,
          @"pisser": @YES,
          @"pissers": @YES,
          @"pisses ": @YES,
          @"pissflaps": @YES,
          @"pissin ": @YES,
          @"pissing": @YES,
          @"pissoff ": @YES,
          @"poop": @YES,
          @"porn": @YES,
          @"porno": @YES,
          @"pornography": @YES,
          @"pornos": @YES,
          @"prick": @YES,
          @"pricks ": @YES,
          @"pron": @YES,
          @"pube": @YES,
          @"pusse": @YES,
          @"pussi": @YES,
          @"pussies": @YES,
          @"pussy": @YES,
          @"pussys ": @YES,
          @"rectum": @YES,
          @"retard": @YES,
          @"rimjaw": @YES,
          @"rimming": @YES,
          @"s hit": @YES,
          @"s.o.b.": @YES,
          @"sadist": @YES,
          @"schlong": @YES,
          @"screwing": @YES,
          @"scroat": @YES,
          @"scrote": @YES,
          @"scrotum": @YES,
          @"semen": @YES,
          @"sex": @YES,
          @"sh!+": @YES,
          @"sh!t": @YES,
          @"sh1t": @YES,
          @"shag": @YES,
          @"shagger": @YES,
          @"shaggin": @YES,
          @"shagging": @YES,
          @"shemale": @YES,
          @"shi+": @YES,
          @"shit": @YES,
          @"shitdick": @YES,
          @"shite": @YES,
          @"shited": @YES,
          @"shitey": @YES,
          @"shitfuck": @YES,
          @"shitfull": @YES,
          @"shithead": @YES,
          @"shiting": @YES,
          @"shitings": @YES,
          @"shits": @YES,
          @"shitted": @YES,
          @"shitter": @YES,
          @"shitters ": @YES,
          @"shitting": @YES,
          @"shittings": @YES,
          @"shitty ": @YES,
          @"skank": @YES,
          @"slut": @YES,
          @"sluts": @YES,
          @"smegma": @YES,
          @"smut": @YES,
          @"snatch": @YES,
          @"son-of-a-bitch": @YES,
          @"spac": @YES,
          @"spunk": @YES,
          @"s_h_i_t": @YES,
          @"t1tt1e5": @YES,
          @"t1tties": @YES,
          @"teets": @YES,
          @"teez": @YES,
          @"testical": @YES,
          @"testicle": @YES,
          @"tit": @YES,
          @"titfuck": @YES,
          @"tits": @YES,
          @"titt": @YES,
          @"tittie5": @YES,
          @"tittiefucker": @YES,
          @"titties": @YES,
          @"tittyfuck": @YES,
          @"tittywank": @YES,
          @"titwank": @YES,
          @"tosser": @YES,
          @"turd": @YES,
          @"tw4t": @YES,
          @"twat": @YES,
          @"twathead": @YES,
          @"twatty": @YES,
          @"twunt": @YES,
          @"twunter": @YES,
          @"v14gra": @YES,
          @"v1gra": @YES,
          @"vagina": @YES,
          @"viagra": @YES,
          @"vulva": @YES,
          @"w00se": @YES,
          @"wang": @YES,
          @"wank": @YES,
          @"wanker": @YES,
          @"wanky": @YES,
          @"whoar": @YES,
          @"whore": @YES,
          @"willies": @YES,
          @"willy": @YES,
          @"xrated": @YES,
          @"xxx": @YES
          };
    }
    return MAVEBadWordsList;
}

@end