#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <UserNotifications/UserNotifications.h>
#include <stdlib.h>
#include <string.h>

// ============================================================
// NSApplication
// ============================================================

void appkit_init(void) {
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
}

// Forcer le nom affiché dans la barre de menu macOS
void appkit_set_app_name(const char *name) {
    // Le nom dans la barre de menu est déterminé par le titre du premier submenu
    // On le force aussi via le bundle name si possible
    NSString *nsName = [NSString stringWithUTF8String:name];
    [[NSProcessInfo processInfo] performSelector:@selector(setProcessName:) withObject:nsName];
}

void appkit_activate(void) {
    [NSApp activateIgnoringOtherApps:YES];
}

// ============================================================
// NSMenu — Barre de menu native macOS
// ============================================================

static NSMenu *mainMenuBar = nil;

// --- Callback system for menu actions ---
typedef void (*MenuActionCallback)(const char* action_id);
static MenuActionCallback globalMenuCallback = NULL;

@interface AppKitMenuTarget : NSObject
- (void)handleMenuAction:(NSMenuItem *)sender;
@end

@implementation AppKitMenuTarget
- (void)handleMenuAction:(NSMenuItem *)sender {
    if (globalMenuCallback) {
        // Use the representedObject as action ID
        NSString *actionId = [sender representedObject];
        if (actionId) {
            globalMenuCallback([actionId UTF8String]);
        }
    }
}
@end

static AppKitMenuTarget *menuTarget = nil;

void appkit_menu_set_callback(MenuActionCallback callback) {
    globalMenuCallback = callback;
    if (!menuTarget) {
        menuTarget = [[AppKitMenuTarget alloc] init];
    }
}

void appkit_menu_create(void) {
    mainMenuBar = [[NSMenu alloc] init];
    [NSApp setMainMenu:mainMenuBar];
    if (!menuTarget) {
        menuTarget = [[AppKitMenuTarget alloc] init];
    }
}

// Ajouter un menu de premier niveau (Fichier, Édition, etc.)
// Retourne l'index du menu pour y ajouter des items
int appkit_menu_add_submenu(const char *title) {
    NSString *nsTitle = [NSString stringWithUTF8String:title];
    NSMenuItem *item = [[NSMenuItem alloc] init];
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:nsTitle];
    [item setSubmenu:submenu];
    [mainMenuBar addItem:item];
    return (int)[mainMenuBar numberOfItems] - 1;
}

// Ajouter un item à un sous-menu
// action_id: identifiant unique pour le callback (peut être NULL pour pas de callback)
void appkit_menu_add_item(int submenu_index, const char *title, const char *key,
                          int modifier_flags, const char *action_id) {
    if (submenu_index < 0 || submenu_index >= [mainMenuBar numberOfItems]) return;

    NSMenuItem *parentItem = [mainMenuBar itemAtIndex:submenu_index];
    NSMenu *submenu = [parentItem submenu];
    if (!submenu) return;

    NSString *nsTitle = [NSString stringWithUTF8String:title];
    NSString *nsKey = key ? [NSString stringWithUTF8String:key] : @"";

    SEL action = (action_id && menuTarget) ? @selector(handleMenuAction:) : nil;
    id target = (action_id && menuTarget) ? menuTarget : nil;

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:nsTitle
                                                 action:action
                                          keyEquivalent:nsKey];
    [item setTarget:target];

    if (action_id) {
        [item setRepresentedObject:[NSString stringWithUTF8String:action_id]];
    }

    // Modifier flags: 1=Cmd, 2=Shift, 4=Alt, 8=Ctrl
    NSEventModifierFlags flags = 0;
    if (modifier_flags & 1) flags |= NSEventModifierFlagCommand;
    if (modifier_flags & 2) flags |= NSEventModifierFlagShift;
    if (modifier_flags & 4) flags |= NSEventModifierFlagOption;
    if (modifier_flags & 8) flags |= NSEventModifierFlagControl;
    [item setKeyEquivalentModifierMask:flags];

    [submenu addItem:item];
}

// Ajouter un séparateur
void appkit_menu_add_separator(int submenu_index) {
    if (submenu_index < 0 || submenu_index >= [mainMenuBar numberOfItems]) return;
    NSMenuItem *parentItem = [mainMenuBar itemAtIndex:submenu_index];
    NSMenu *submenu = [parentItem submenu];
    if (!submenu) return;
    [submenu addItem:[NSMenuItem separatorItem]];
}

// Ajouter le menu "app" standard (À propos, Préférences, Quitter)
void appkit_menu_add_app_menu(const char *app_name) {
    NSString *name = [NSString stringWithUTF8String:app_name];
    int idx = appkit_menu_add_submenu(app_name);

    NSMenuItem *parentItem = [mainMenuBar itemAtIndex:idx];
    NSMenu *submenu = [parentItem submenu];

    // À propos
    NSMenuItem *about = [[NSMenuItem alloc]
        initWithTitle:[NSString stringWithFormat:@"À propos de %@", name]
               action:@selector(orderFrontStandardAboutPanel:)
        keyEquivalent:@""];
    [submenu addItem:about];

    [submenu addItem:[NSMenuItem separatorItem]];

    // Masquer
    NSMenuItem *hide = [[NSMenuItem alloc]
        initWithTitle:[NSString stringWithFormat:@"Masquer %@", name]
               action:@selector(hide:)
        keyEquivalent:@"h"];
    [submenu addItem:hide];

    // Masquer les autres
    NSMenuItem *hideOthers = [[NSMenuItem alloc]
        initWithTitle:@"Masquer les autres"
               action:@selector(hideOtherApplications:)
        keyEquivalent:@"h"];
    [hideOthers setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
    [submenu addItem:hideOthers];

    // Tout afficher
    NSMenuItem *showAll = [[NSMenuItem alloc]
        initWithTitle:@"Tout afficher"
               action:@selector(unhideAllApplications:)
        keyEquivalent:@""];
    [submenu addItem:showAll];

    [submenu addItem:[NSMenuItem separatorItem]];

    // Quitter
    NSMenuItem *quit = [[NSMenuItem alloc]
        initWithTitle:[NSString stringWithFormat:@"Quitter %@", name]
               action:@selector(terminate:)
        keyEquivalent:@"q"];
    [submenu addItem:quit];
}

// Ajouter un menu Édition standard (Annuler, Copier, Coller...)
void appkit_menu_add_edit_menu(void) {
    int idx = appkit_menu_add_submenu("Édition");
    NSMenuItem *parentItem = [mainMenuBar itemAtIndex:idx];
    NSMenu *submenu = [parentItem submenu];

    NSMenuItem *undo = [[NSMenuItem alloc] initWithTitle:@"Annuler" action:@selector(undo:) keyEquivalent:@"z"];
    [submenu addItem:undo];

    NSMenuItem *redo = [[NSMenuItem alloc] initWithTitle:@"Rétablir" action:@selector(redo:) keyEquivalent:@"z"];
    [redo setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
    [submenu addItem:redo];

    [submenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *cut = [[NSMenuItem alloc] initWithTitle:@"Couper" action:@selector(cut:) keyEquivalent:@"x"];
    [submenu addItem:cut];

    NSMenuItem *copy = [[NSMenuItem alloc] initWithTitle:@"Copier" action:@selector(copy:) keyEquivalent:@"c"];
    [submenu addItem:copy];

    NSMenuItem *paste = [[NSMenuItem alloc] initWithTitle:@"Coller" action:@selector(paste:) keyEquivalent:@"v"];
    [submenu addItem:paste];

    NSMenuItem *selectAll = [[NSMenuItem alloc] initWithTitle:@"Tout sélectionner" action:@selector(selectAll:) keyEquivalent:@"a"];
    [submenu addItem:selectAll];
}

// Ajouter un menu Fenêtre standard
void appkit_menu_add_window_menu(void) {
    int idx = appkit_menu_add_submenu("Fenêtre");
    NSMenuItem *parentItem = [mainMenuBar itemAtIndex:idx];
    NSMenu *submenu = [parentItem submenu];

    NSMenuItem *minimize = [[NSMenuItem alloc] initWithTitle:@"Minimiser" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [submenu addItem:minimize];

    NSMenuItem *zoom = [[NSMenuItem alloc] initWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
    [submenu addItem:zoom];

    [submenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *front = [[NSMenuItem alloc] initWithTitle:@"Tout ramener au premier plan" action:@selector(arrangeInFront:) keyEquivalent:@""];
    [submenu addItem:front];

    [NSApp setWindowsMenu:submenu];
}

// ============================================================
// NSAlert — Dialogues
// ============================================================

// Afficher une alerte. Retourne 0=OK, 1=Cancel
int appkit_alert(const char *title, const char *message, int style) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithUTF8String:title]];
    [alert setInformativeText:[NSString stringWithUTF8String:message]];

    // style: 0=info, 1=warning, 2=critical
    if (style == 1) [alert setAlertStyle:NSAlertStyleWarning];
    else if (style == 2) [alert setAlertStyle:NSAlertStyleCritical];
    else [alert setAlertStyle:NSAlertStyleInformational];

    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Annuler"];

    NSModalResponse response = [alert runModal];
    return (response == NSAlertFirstButtonReturn) ? 0 : 1;
}

// Alerte simple (juste OK)
void appkit_alert_info(const char *title, const char *message) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithUTF8String:title]];
    [alert setInformativeText:[NSString stringWithUTF8String:message]];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

// ============================================================
// NSOpenPanel — Dialogue d'ouverture de fichier
// ============================================================

// Ouvrir un fichier. Retourne le chemin ou NULL
// types: extensions séparées par des virgules ("adoc,txt,md")
const char* appkit_open_panel(const char *title, const char *types) {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:[NSString stringWithUTF8String:title]];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];

    if (types && strlen(types) > 0) {
        NSString *typesStr = [NSString stringWithUTF8String:types];
        NSArray *exts = [typesStr componentsSeparatedByString:@","];
        NSMutableArray<UTType *> *utTypes = [NSMutableArray array];
        for (NSString *ext in exts) {
            NSString *trimmed = [ext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            UTType *t = [UTType typeWithFilenameExtension:trimmed];
            if (t) [utTypes addObject:t];
        }
        if (utTypes.count > 0) {
            [panel setAllowedContentTypes:utTypes];
        }
    }

    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [[panel URLs] firstObject];
        if (url) {
            const char *path = [[url path] UTF8String];
            return strdup(path); // L'appelant doit free()
        }
    }
    return NULL;
}

// Ouvrir un dossier
const char* appkit_open_folder(const char *title) {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:[NSString stringWithUTF8String:title]];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];

    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [[panel URLs] firstObject];
        if (url) {
            return strdup([[url path] UTF8String]);
        }
    }
    return NULL;
}

// ============================================================
// NSSavePanel — Dialogue de sauvegarde
// ============================================================

const char* appkit_save_panel(const char *title, const char *default_name) {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setTitle:[NSString stringWithUTF8String:title]];
    if (default_name) {
        [panel setNameFieldStringValue:[NSString stringWithUTF8String:default_name]];
    }

    NSModalResponse result = [panel runModal];
    if (result == NSModalResponseOK) {
        NSURL *url = [panel URL];
        if (url) {
            return strdup([[url path] UTF8String]);
        }
    }
    return NULL;
}

// ============================================================
// NSNotification — Notification utilisateur
// ============================================================

void appkit_notify(const char *title, const char *message) {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString stringWithUTF8String:title];
    content.body = [NSString stringWithUTF8String:message];

    UNNotificationRequest *request = [UNNotificationRequest
        requestWithIdentifier:[[NSUUID UUID] UUIDString]
                      content:content
                      trigger:nil];

    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request
         withCompletionHandler:nil];
}

// ============================================================
// Cleanup
// ============================================================

void appkit_free(void *ptr) {
    if (ptr) free(ptr);
}
