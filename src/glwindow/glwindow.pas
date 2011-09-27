{
  Copyright 2001-2011 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Windows with associated OpenGL context (TGLWindow).

  @link(Application) object (instance of class @link(TGLApplication))
  is a central manager of all open @link(TGLWindow) windows.

  Using this unit:

  @orderedList(
    @item(Declare and create @link(TGLWindow) instance. (Or a descendant
      like @link(TGLUIWindow) or @link(TGLWindowDemo).))

    @item(Assign Glw properties and callbacks like
      @link(TGLWindow.OnDraw OnDraw),
      @link(TGLWindow.OnResize OnResize),
      @link(TGLWindow.Width Width),
      @link(TGLWindow.Height Height),
      @link(TGLWindow.Caption Caption).)

    @item(Call @link(TGLWindow.Open Window.Open),
      this will actually show the window and it's
      associated OpenGL context. It also calls
      @link(TGLWindow.EventOpen EventOpen)
      (@link(TGLWindow.OnOpen OnOpen) callback)
      and @link(TGLWindow.EventResize EventResize)
      (@link(TGLWindow.OnResize OnResize) callback).)

    @item(Call @link(TGLApplication.Run Application.Run).
      This will enter message loop that will call
      appropriate windows' callbacks at appropriate times
      (OnDraw, OnKeyDown, OnResize, OnIdle and many more).
      There are also some Application callbacks, like
      @link(TGLApplication.OnIdle Application.OnIdle).

      For more advanced needs you can use something like
        @longCode(#  while Application.ProcessMessage do <something>;#)
      instead of Application.Run.

      You can also call @link(TGLWindow.OpenAndRun Window.OpenAndRun),
      this is just a shortcut for Window.Open + Application.Run.)

    @item(Application.Run ends when you call @link(TGLApplication.Quit Application.Quit)
      or when you close last visible window using @link(TGLWindow.Close Close(true)).

      User is also allowed to close a window using WindowManager facilities
      (clicking on "X" button in the frame corner, pressing Alt+F4 or something
      like that). By default, such user action will make window close
      (but you can freely customize what your program does when user
      tries to close the window using callback
      @link(TGLWindow.OnCloseQuery OnCloseQuery)).)
  )

  So the simplest example of using this unit can look like this:

@longcode(#
  uses GLWindow;

  var
    Window: TGLUIWindow;

  procedure Draw(Window: TGLWindow);
  begin  ...  end;

  procedure Resize(Window: TGLWindow);
  begin  ...  end;

  begin
    Window := TGLUIWindow.Create(Application);
    Window.OnResize := @Resize;
    Window.OnDraw := @Draw;
    Window.Caption := 'Simplest GLWindow example';
    Window.OpenAndRun;
  end.
#)

  @italic(More object-oriented approach):
  Instead of assigning callbacks (OnDraw, OnResize etc.) you can
  also derive a new class from TGLWindow and override some of virtual
  methods, like EventDraw, EventResize etc. Every callback OnXxx
  has a corresponding EventXxx method. In TGLWindow class,
  all EventXxx methods simply call appropriate OnXxx callbacks
  (this way you can use whatever approach you like -- OOP or not-OOP).

  This is a second version of the "simplest example" program above,
  this time using OOP approach:

@longcode(#
  uses GLWindow;

  type
    TMyWindow = class(TGLUIWindow)
      procedure EventDraw; override;
      procedure EventResize; override;
    end;

  procedure TMyWindow.EventDraw;
  begin  ...  end;

  procedure TMyWindow.EventResize;
  begin  ...  end;

  var
    Window: TMyWindow;
  begin
    Window := TMyWindow.Create(Application);
    Window.Caption := 'Simplest GLWindow example using more OOP';
    Window.OpenAndRun;
  end.
#)

  The non-OOP approach has one advantage: you can easily switch all callbacks
  to some other set of callbacks using TGLWindowCallbacks,
  TGLWindow.GetCallbacksState, TGLWindow.SetCallbacksState.
  Using these functions I implemented unit
  @link(GLWinModes) and then, on top of this, I implemented some very
  handy things like modal message boxes (unit @link(GLWinMessages))
  and progress bar (unit @link(GLProgress)). These units give you some typical
  GUI capabilities, and they are in pure OpenGL.

  Using OOP approach (overriding EventXxx methods instead of registering OnXxx
  callbacks) you can not do such things so easily -- in general, you have
  to define something to turn off special EventXxx functionality
  (like SetDemoOptions in TGLWindowDemo and UseControls in TGLUIWindow)
  and you have to turn them off/on when using GLWinModes
  (mentioned TGLWindowDemo and TGLUIWindow are already handled in
  GLWinModes). TODO: I shall do some virtual methods in TGLWindow
  to make this easy.

  Random features list:

  @unorderedList(

    @item(TGLApplication.ProcessMessage method.
      This allows you to reimplement
      event loop handling, which is crucial for implementing things
      like @link(MessageInputQuery) function that does modal GUI dialog box.)

    @item(TGLWindow.Pressed to easily and reliably check which keys
      are pressed.)

    @item(Frames per second measuring, see @link(TGLWindow.Fps),)

    @item(A menu bar under WinAPI and GTK backends.

      You can attach a menu to a window. Menu structure is constructed using
      various descendants of TMenuEntry class.
      Then you have to assign such menu structure
      to TGLWindow.MainMenu property. When GLWindow is implemented on top
      of GTK_1 or GTK_2 or WINAPI or GLUT we will show this menu and call
      TGLWindow.EventMenuCommand (TGLWindow.OnMenuCommand) when user clicks some menu item.
      Other backends (XLIB for now) ignore MainMenu.

      See @code(castle_game_engine/examples/glwindow/glwindow_menu.lpr)
      for an example how to use the menu.)

    @item(Changing screen resolution and bit depth,
      see TGLApplication.VideoChange.

      Also you can request various OpenGL buffers: color buffer with alpha
      channel (@link(TGLWindow.AlphaBits AlphaBits)),
      stencil buffer (@link(TGLWindow.StencilBufferBits StencilBufferBits)),
      double buffer (@link(TGLWindow.DoubleBuffer DoubleBuffer)), accumulation buffer
      (@link(TGLWindow.AccumBufferBits AccumBufferBits)),
      multisampling (full-screen antialiasing) buffers (@link(TGLWindow.MultiSampling MultiSampling))?
      )

    @item(You can use native modal dialogs for things such as file selection.
      GTK backend will use GTK dialogs, WinAPI backend
      will use Windows dialog boxes, XLib backend will fall back
      on GLWinMessages text input.

      See TGLWindow.FileDialog (for opening and saving files) and
      TGLWindow.ColorDialog (for choosing RGB colors).)

    @item(TGLWindow.ParseParameters method allows you to easily initialize TGLWindow
      properties like initial size and position using command-line
      parameters like @code(@--geometry WIDTHxHEIGHT), @code(@--display) etc.)
  )
}

unit GLWindow;

{$I kambiconf.inc}

{ Choose GLWindow backend ------------------------------------------ }

{ You must define one of the symbols GLWINDOW_GTK_1, GLWINDOW_GTK_2,
  GLWINDOW_WINAPI (only under Windows),  GLWINDOW_XLIB (only where X11
  and Xlib are available, which usually means "only under UNIX"),
  GLWINDOW_GLUT.

  Of course the list of available backends may be extended
  with time (although I do not plan it for now, since I'm happy with
  available backends).

  Here are short descriptions for each backend:

  GLWINDOW_GTK_1 and GLWINDOW_GTK_2
    GLWINDOW_GTK_1 is based on GTK 1.x (>= 1.2) using GtkGLArea widget.
    Made around beginning of march 2004. Historically the first,
    it is now by all means superseded by GTK 2 version.
    Saying it clearly: @bold(do not use GTK_1, use GTK_2 instead).

    GLWINDOW_GTK_2 is based on GTK 2.x, using GtkGLExt extension.
    Made 2005-02.

    MainMenu is implemented as a nice-looking GTK menu bar.
    Dialog windows implemented using GTK dialog windows.
    Generally, has a nice native look of GTK application.

    Backends on top of GTK should work under any OS where GTK works.
    Currently both GTK_1 and GTK_2 are tested under Linux, FreeBSD and Windows.
    GTK_2 is also tested on Mac OS X.

    GLWINDOW_GTK_1:
    Known problems of only GLWINDOW_GTK_1 (fixed in GTK_2):
    - Some keys simply cannot work as menu item shortcuts:
      Delete, BackSpace, '?' key, Tab. For GLWINDOW_GTK_2 version,
      only Tab key cannot work as menu item shortcut (it's always only
      for switching focus). This is an issue with GTK 1/2,
      that simply can't be fixed in GLWindow.
    - When FullScreen = true and MainMenu <> nil, result is not perfect
      because things like gnome-panel may cover your fullscreen window.
      Solved in GLWINDOW_GTK_2, can't be cleanly solved with GTK_1.
    - Under Windows be warned that GTK 1.3 has somewhat buggy
      key events handling - sometimes I don't get keyup events for
      appropriate keys, sometimes keydown events for some keys
      are temporarily blocked. A little code in glwindow_gtk.inc
      was added to workaround some problems, but definitely
      this still does not work as smoothly as it should.
    - Menu mnemonics are not implemented (I don't know how to *easily*
      do them in GTK_1, and I don't really care since GTK_2 version
      is completely stable now). They are simply removed when Caption
      is displayed.
    - File filters are not implemented. This is fixed in GTK_2 by
      using newer GtkFileChooser.
    - TGLWindow.Message*, TGLWindow.SetMousePosition are not implemented
      with GTK 1 backend (raise "not implemented" exceptions).
      They probably could be implemented, but (since GTK 1 is obsolete now)
      I didn't feel the need.

    GLWINDOW_GTK_2:
    This is now stable and tested and is much better than GTK_1.
    At some point, this may be renamed to simply GLWINDOW_GTK
    and compatilibity with GTK 1.x may be dropped.

    Also FullScreen is cleanly implemented in GTK_2,
    never using override_redirect,
    so Alt+Tab always works (even when your window is fullscreen),
    and things like gnome-panel will never cover your fullscreen window.

    Known problems:
    - TryVideoChange is not implemented, i.e. always returns false.
      I don't know how to cleanly implement it using GTK.
    - Under Windows, window will be always resizeable by user, even if
      you set ResizeAllowed <> raAllowed.
      This is masked in our unit (so your OnResize callback will not get
      to know such thing), so it's harmless for correctness of your programs,
      but, anyway, user can do it.

  GLWINDOW_WINAPI
    Based on Windows API.

    MainMenu is implemented as WinAPI menu bar. So it looks nice.
    Dialog windows are implemented as common Windows dialog boxes.
    Has a nice native look on Windows.

  GLWINDOW_XLIB
    Based on XLib units. No X toolkit is used.

    MainMenu is not implemented (it's ignored).
    That's not easy to implement when you don't want to use any X toolkit.
    And it's not a good idea to implement it yourself (without any standard
    GUI toolkit) --- this makes many Xlib programs ugly, because every single one
    uses his own GUI. In other words:
    if you want to have MainMenu then just use GLWINDOW_GTK_1/2.

    Dialog boxes are implemented using GLWinMessages.MessageXxx.
    So they are not very comfortable to user, but they work.

    On Unix platforms, whether you should use GLWINDOW_GTK_2 or
    this GLWINDOW_XLIB depends on your program.

    - For utility programs, usually GLWINDOW_GTK_2.
      You want the menu bar and native (GTK-themed) look of dialog boxes.

    - For fullscreen games, usually GLWINDOW_XLIB.
      You usually do not use the menu bar in fullscreen games,
      and do not want popup dialog boxes. Instead you draw everything
      inside your OpenGL context, which makes your game look the same
      regardless of the platform and GUI can be styled to your game theme.
      For example, menu may be done by TGLMenu, and dialog boxes
      by GLWinMessages.

      As a bonus, XLIB allows you to change screen resolution when
      starting the game, which may be useful. And has one dependency less
      (GTK is commonly installed, but gtkglext is not, and GLWINDOW_GTK_2
      requires gtkglext).

  GLWINDOW_GLUT
    Based on glut library. There's little use of implementing
    GLWindow on top of glut library since the initial idea of GLWindow
    was to overcome many glut shortcomings. The only advantage of this is that
    such version of GLWindow may be used for various testing purposes.

    MainMenu is implemented as glut pop-up menu. Activated by right mouse button.
    Looks ugly and has a lot of usability problems, but works.

    TryVideoChange is simply not implemented, always returns false.

    Known problems:
    (they are specific to GLWINDOW_GLUT and will not be fixed.
    Just use other GLWINDOW_xxx backend if you don't want these problems):
    - When original glut (the one by Mark Kilgard,
      as opposed to newer freeglut from http://freeglut.sourceforge.net/)
      is used, Application.ProcessMesssages cannot be implemented.
    - Application.Run does never return (because it must be implemented as a
      single call to glutMainLoop)
    - Key up / down (with K_xxx constants) are rather poorly simulated.
    - FlushRedisplay always redraws the window
      (it can't know whether window really needs redraw or not,
      so it redraws it always).
    - Even when ResizeAllowed <> raNotAllowed user will be able
      to change size of our window (using window manager-specific
      things, like dragging our window's border)
      but we will simply "pretend" that nothing happened
      (TGLWindow instance will not change it's Width/Height,
      will not do OnResize event etc.).
      Similar with (Min|Max)(Width|Height) constraints:
      they can't be forced using glut, we will simply ignore
      the fact if they will be broken by user.
    - I can't pass to glut value of StencilBufferBits so
      I'm simply saying to glut that I want stencil buffer
      when StencilBufferBits > 0, and then I'm checking
      using glutGet(GLUT_WINDOW_STENCIL_SIZE) how many stencil bits I have.
      Analogous for DepthBufferBits, AlphaBits, AccumBufferBits.
    - Menu mnemonics are not implemented.
      They are simply removed when Caption is displayed.
    - CustomCursor is not implemented. Cursor = gcCursor is treated like mcDefault.

  GLWINDOW_TEMPLATE
    This is a special dummy backend, useful only as an example
    for programmers that want to implement another GLWindow backend
    (e.g. based on Mac OS X Carbon).
    It compiles, but actually nothing works.
    See file glwindow_backend_template.inc.
}

{ If GLWindow backend is not choosen at this point, choose
  default (best, most functional and stable) for a given OS.

  This way you can override configuration below by compiling GLWindow
  with some GLWINDOW_xxx symbol already defined. }
{$ifndef GLWINDOW_WINAPI}
 {$ifndef GLWINDOW_XLIB}
  {$ifndef GLWINDOW_GLUT}
   {$ifndef GLWINDOW_GTK_1}
    {$ifndef GLWINDOW_GTK_2}
     {$ifdef MSWINDOWS}
       {$define GLWINDOW_WINAPI}
       { $define GLWINDOW_GTK_2}
       { $define GLWINDOW_GTK_1}
       { $define GLWINDOW_GLUT}
       { $define GLWINDOW_TEMPLATE}
     {$endif}
     {$ifdef UNIX}
       {$define GLWINDOW_GTK_2}
       { $define GLWINDOW_GTK_1}
       { $define GLWINDOW_XLIB}
       { $define GLWINDOW_GLUT}
       { $define GLWINDOW_TEMPLATE}
     {$endif}
    {$endif}
   {$endif}
  {$endif}
 {$endif}
{$endif}

{ To make new GL Window backend -------------------------------------

  - Define a symbol like GLWINDOW_FOO for a new backend,
    document it in the "available backends list" above.
  - Create a file glwindow_foo.inc with contents from
    glwindow_backend_template.inc
    and conditionally include it from glwindow_backend.inc.
  - Adjust defining
    GLWINDOW_HAS_VIDEO_CHANGE and GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN
    for your backend.
  - Implement all methods in glwindow_foo.inc. You wil find the specification
    what each method should do in the specification of the interface of this
    module.
  - Call all TGLWindow.DoXxx functions at appropriate places from your
    backend.
    You can call all DoIdle and DoTimer for all Application.OpenWindows
    using Application.FOpenWindows.DoIdle/Timer (this will give usually
    inefficient but working backend)
  - Call TGLApplication.DoSelfIdle and DoSelfTimer when appropriate.
    Remember that you can always assume that the ONLY existing instance of
    TGLApplication is Application.
  Some important things that can be easily forgotten:
  - Remember that probably you will have to call ReleaseAllKeysAndMouse
    when user switches to another window or activates MainMenu.
}

{ Configure some debugging options of GLWindow ------------------------------- }

{ When GLWINDOW_LOG_EVENTS is defined, TGLWindow events will be logged.
  This means logging (using KambiLog) at begin, end, and at exception exit
  inside all TGLWindow events (EventXxx methods).
  Very useful, although floods your log with incredible amount of messages
  very quickly.

  Actually, GLWINDOW_LOG_EVENTS by itself turns logging for @italic(almost)
  all events. For the really really often events (draw, idle, timer,
  mouse move for now), you'll need to define also GLWINDOW_LOG_EVENTS_ALL
  (relevant only if GLWINDOW_EVENTS_LOG).
}
{ $define GLWINDOW_EVENTS_LOG}
{ $define GLWINDOW_EVENTS_LOG_ALL}
{$ifndef GLWINDOW_EVENTS_LOG}
  {$undef GLWINDOW_EVENTS_LOG_ALL}
{$endif}

{ Define GLWINDOW_CHECK_GL_ERRORS_AFTER_DRAW to check OpenGL errors
  after TGLWindow.EventDraw (TGLWindow.OnDraw callback) calls.
  This is done by DoDraw, that is: when a backend initiates the drawing.
  The check is done by KambiGLUtils.CheckGLErrors, checks glGetError
  and eventually raises an exception. }
{$ifdef DEBUG}
  {$define GLWINDOW_CHECK_GL_ERRORS_AFTER_DRAW}
{$endif}

{ Configure internal things -------------------------------------------------- }

{$ifdef GLWINDOW_GTK_1} {$define GLWINDOW_GTK_ANY} {$endif}
{$ifdef GLWINDOW_GTK_2} {$define GLWINDOW_GTK_ANY} {$endif}

{ Two reasons why sometimes GTK backend call some X-specific things:

  1. Grrrr. Implementing TGLWindow.SetMousePosition is a real hack for GTK.

     First of all, there is no GDK or GTK function for this.
     (confirmed by google, e.g. see here
     [http://mail.gnome.org/archives/gtk-list/2001-January/msg00035.html]).
     You have to bypass GTK and use things like Xlib's XWarpPointer or
     Windows' SetCursorPos. So this is getting very dirty already ---
     suddenly GLWindow's GTK backend stops to be portable.

     Moreover, to use XWarpPointer, you have to get Xlib parameters
     (X window id and display pointer) from GTK window. And here comes
     another surprise, this time caused by FPC bindings: GTK 1 bindings
     don't include macro GDK_WINDOW_XID. They include macro
     GDK_WINDOW_XDISPLAY but it seems incorrectly defined
     (should take GdkWindow not PGdkWindowPrivate?).
     GTK 2 bindings don't include these macros too, but GTK 2 library contains
     functions gdk_x11_drawable_get_xid/xdisplay and I can get to them.

     All in all, right now I implemented TGLWindow.SetMousePosition
     only for GTK 2 under Unix. It's possible to do this for GTK 1 under Unix,
     but more hacking is needed (hint: fix GTK 1 bindings in this regard).
     It's possible to do this for Windows, you have to use SetCursorPos
     (see the real Windows backend TGLWindow.SetMousePosition implementation).

  2. Screen resizing.

     I have to use there XF86VidMode extension, just like for GLWINDOW_XLIB
     backend. And, just like for TGLWindow.SetMousePosition, I'll need
     for this some functions available only in GTK 2 library that
     "uncover" X11 internals related to GTK for me. }
{$ifdef GLWINDOW_GTK_2}
  {$ifdef UNIX}
    {$define GLWINDOW_GTK_WITH_XLIB}
  {$endif}
{$endif}

{ Does backend implement TryVideoChange and VideoReset methods?
  (if this will not be defined, we will use TryVideoChange that always
  returns false and VideoReset that is NOOP). }
{$undef GLWINDOW_HAS_VIDEO_CHANGE}
{$ifdef GLWINDOW_WINAPI}
  {$define GLWINDOW_HAS_VIDEO_CHANGE}
{$endif}
{$ifdef GLWINDOW_XLIB}
  {$define GLWINDOW_HAS_VIDEO_CHANGE}
  {$define GLWINDOW_USE_XF86VMODE}
{$endif}
{$ifdef GLWINDOW_GTK_ANY}
  {$ifdef UNIX}
    { Hmm. This compiles and basically works, but the new screen is still
      virtual. For now this is disabled. TODO. }
    { $define GLWINDOW_HAS_VIDEO_CHANGE}
    { $define GLWINDOW_USE_XF86VMODE}
  {$endif}
{$endif}

{ See glwindow_private_modifiers_down.inc for description in what
  situations you want to define GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN. }
{$ifdef GLWINDOW_GTK_ANY} {$define GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN} {$endif}
{$ifdef GLWINDOW_XLIB}    {$define GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN} {$endif}

{ Only relevant for GLWINDOW_GLUT backend:
  Define to use FPC Glut/FreeGlut unit. Otherwise, our KambiGlut will be used.

  In the future, our KambiGlut unit will be removed. But currently,
  you need FPC >= 2.5.1 for FreeGlut unit, so keep using KambiGlut by default. }
{ $define FPC_GLUT_UNIT}

{ TODO list ------------------------------------------------------------------

  (? means "I'm not sure whether to implement it")

  Only winapi:
  - Is it even possible to cleanly catch K_Alt key press in WinAPI?
    We would have to catch sys_keydown message but then we also
    block using standard Alt+F4 or Alt+Space? Another trouble:
    if you enter system menu by Alt+Down, we will not get Alt+Up?

  Only glut:
  - Is is possible to cleanly capture close event (possibly under freeglut).
  - ReleaseAllKeysAndMouse: call this when user switches to another window
    or activates a menu.

  Only GLWINDOW_GTK_1/2:
  - in OpenBackend implement MaxWidth/Height
    (Or maybe these properties should be removed?
    They are made for symmetry with MinWidth/Height. Are they really useful?)

  - with GTK 2:
    - Implement better fullscreen toggle now (that doesn't need
      recreating window).
      Update docs about capabilities of GTK_2 backend.
    - Value of propery FullScreen should change at runtime,
      and parts of things that I'm doing now in OpenBackend
      should be done on such changes.
      This way I should be able to react to fullscreen changes
      forced by user (using window manager, not F11) really cleanly.

  General:
  - Allow changing Width, Height, Left, Top from code after the window
    is created.
  - SDL backend is possible, although doesn't seem really needed now?
  - use EnumDisplaySettings instead of such variables as
    VideoColorBits / VideoScreenWidth / VideoFrequency,
    do some proc DisplayExists and EnumDisplays
  - Allow passing VideoColorBits, VideoFrequency for --fullscreen-custom
    param.
  - OnTimer interface sucks -- it doesn't allow you to register many timeout
    functions for different timeouts.
  - Add to multi_glwindow testing call to FileDialog and ColorDialog.

  Menu things:
  - For WinAPI, glut: impl Enabled
}

interface

uses SysUtils, Classes, VectorMath, GL, GLU, GLExt,
  {$ifdef GLWINDOW_GLUT} {$ifdef FPC_GLUT_UNIT} FreeGlut, Glut, {$else} KambiGlut, {$endif} {$endif}
  {$ifdef GLWINDOW_WINAPI} Windows,
    { In FPC < 2.2.2, CommDlg stuff was inside Windows unit. }
    {$ifndef VER2_2_0} {$ifndef VER2_0_0} CommDlg, {$endif} {$endif}
  {$endif}
  {$ifdef GLWINDOW_XLIB} Xlib, XlibUtils, XUtil, X, KeySym, CursorFont, KambiGlx, {$endif}
  {$ifdef GLWINDOW_USE_XF86VMODE} KambiXF86VMode, {$endif}
  {$ifdef GLWINDOW_GTK_WITH_XLIB} X, Xlib, {$endif}
  {$ifdef GLWINDOW_GTK_1} Glib, Gdk, Gtk, GtkGLArea, {$endif}
  {$ifdef GLWINDOW_GTK_2} Glib2, Gdk2, Gtk2, GdkGLExt, GtkGLExt, KambiDynLib, {$endif}
  KambiUtils, KambiClassUtils, KambiGLUtils, Images, KeysMouse,
  KambiStringUtils, KambiFilesUtils, KambiTimeUtils, FileFilters, UIControls,
  FGL {$ifdef VER2_2}, FGLObjectList22 {$endif}, GenericStructList;

{$define read_interface}

{ ---------------------------------------------------------------------

  I'm aliasing here TKey type and key constants from Keys unit,
  this way code that uses GLWindow unit has automcatically
  available TKey type and key constants (because a lot of code
  using GLWindow unit uses also these type/constant, so I want
  to avoid adding "Keys" unit to uses clauses).

  Once the "reuse" keyword will be implemented in FPC,
  this can be done using something like "reuse Keys".
}

type
  { }
  TKey = KeysMouse.TKey;
const
  K_None = KeysMouse.K_None;

  K_BackSpace = KeysMouse.K_BackSpace;
  K_Tab = KeysMouse.K_Tab;
  K_Enter = KeysMouse.K_Enter;

  K_Minus = KeysMouse.K_Minus;
  K_Shift = KeysMouse.K_Shift;
  K_Ctrl = KeysMouse.K_Ctrl;
  K_Alt = KeysMouse.K_Alt;
  K_Plus = KeysMouse.K_Plus;

  K_Escape = KeysMouse.K_Escape;
  K_Space = KeysMouse.K_Space;
  K_PageUp = KeysMouse.K_PageUp;
  K_PageDown = KeysMouse.K_PageDown;
  K_End = KeysMouse.K_End;
  K_Home = KeysMouse.K_Home;
  K_Left = KeysMouse.K_Left;
  K_Up = KeysMouse.K_Up;
  K_Right = KeysMouse.K_Right;
  K_Down = KeysMouse.K_Down;
  K_Insert = KeysMouse.K_Insert;
  K_Delete = KeysMouse.K_Delete;

  K_Numpad_Plus = KeysMouse.K_Numpad_Plus;
  K_Numpad_Minus = KeysMouse.K_Numpad_Minus;

  K_0 = KeysMouse.K_0;  K_1 = KeysMouse.K_1;  K_2 = KeysMouse.K_2;  K_3 = KeysMouse.K_3;
  K_4 = KeysMouse.K_4;  K_5 = KeysMouse.K_5;  K_6 = KeysMouse.K_6;  K_7 = KeysMouse.K_7;
  K_8 = KeysMouse.K_8;  K_9 = KeysMouse.K_9;

  K_A = KeysMouse.K_A;  K_B = KeysMouse.K_B;  K_C = KeysMouse.K_C;  K_D = KeysMouse.K_D;
  K_E = KeysMouse.K_E;  K_F = KeysMouse.K_F;  K_G = KeysMouse.K_G;  K_H = KeysMouse.K_H;
  K_I = KeysMouse.K_I;  K_J = KeysMouse.K_J;  K_K = KeysMouse.K_K;  K_L = KeysMouse.K_L;
  K_M = KeysMouse.K_M;  K_N = KeysMouse.K_N;  K_O = KeysMouse.K_O;  K_P = KeysMouse.K_P;
  K_Q = KeysMouse.K_Q;  K_R = KeysMouse.K_R;  K_S = KeysMouse.K_S;  K_T = KeysMouse.K_T;
  K_U = KeysMouse.K_U;  K_V = KeysMouse.K_V;  K_W = KeysMouse.K_W;  K_X = KeysMouse.K_X;
  K_Y = KeysMouse.K_Y;  K_Z = KeysMouse.K_Z;

  K_F1 = KeysMouse.K_F1;  K_F2 = KeysMouse.K_F2;  K_F3 = KeysMouse.K_F3;  K_F4 = KeysMouse.K_F4;
  K_F5 = KeysMouse.K_F5;  K_F6 = KeysMouse.K_F6;  K_F7 = KeysMouse.K_F7;  K_F8 = KeysMouse.K_F8;
  K_F9 = KeysMouse.K_F9;  K_F10 = KeysMouse.K_F10;  K_F11 = KeysMouse.K_F11;  K_F12 = KeysMouse.K_F12;

  K_Comma = KeysMouse.K_Comma;
  K_Period = KeysMouse.K_Period;


{ Also export types and consts related to mouse from KeysMouse unit. }

type
  { }
  TMouseButton = KeysMouse.TMouseButton;
  TMouseButtons = KeysMouse.TMouseButtons;

const
  mbLeft = KeysMouse.mbLeft;
  mbMiddle = KeysMouse.mbMiddle;
  mbRight = KeysMouse.mbRight;

{ --------------------------------------------------------------------- }

const
  { }
  GLWindowPositionCenter = -1000000;
  GLWindowDefaultSize = -1000000;

type
  TGLWindowParseOption = (poGeometry, poScreenGeometry, poDisplay);
  TGLWindowParseOptions = set of TGLWindowParseOption;
  PGLWindowParseOptions = ^TGLWindowParseOptions;

const
  { All "normal" command-line options,
    that most programs using GLWindow should be able to handle
    without any problems.

    In other words, most programs calling @link(TGLWindow.ParseParameters)
    method can safely pass as the 1st parameter this constant,
    StandardParseOptions.
    Or they can simply call overloaded version of TGLWindow.ParseParameters
    that doesn't take any parameters, it is always equivalent to
    calling TGLWindow.ParseParameters(StandardParseOptions). }
  StandardParseOptions = [poGeometry, poScreenGeometry, poDisplay];

  DefaultDepthBufferBits = 16;

  DefaultFpsCaptionUpdateInterval = 5000;

  DefaultTooltipDelay = 1000;
  DefaultTooltipDistance = 10;

type
  TGLWindow = class;

  {$I glwindowmenu.inc}

  { Type of message box, for TGLWindow.MessageOK and TGLWindow.MessageYesNo. }
  TGLWindowMessageType = (mtInfo, mtWarning, mtQuestion, mtError, mtOther);

  TIdleFunc = procedure;
  TGLWindowFunc = procedure(Window: TGLWindow);
  TDrawFunc = TGLWindowFunc;
  TKeyCharFunc = procedure(Window: TGLWindow; Key: TKey; C: char);
  TMouseMoveFunc = procedure(Window: TGLWindow; NewX, NewY: Integer);
  TMouseUpDownFunc = procedure(Window: TGLWindow; Button: TMouseButton);
  TMouseWheelFunc = procedure(Window: TGLWindow; const Scroll: Single; const Vertical: boolean);
  TMenuCommandFunc = procedure(Window: TGLWindow; Item: TMenuItem);
  TGLContextLoweredFunc = procedure(Window: TGLWindow; const FailureMessage: string);

  { List of @link(TGLWindowFunc) procedures. }
  TGLWindowFuncList = class(specialize TGenericStructList<TGLWindowFunc>)
  public
    { Call all (non-nil) Items. }
    procedure ExecuteAll(Window: TGLWindow);
  end;

  { Saved state of all callbacks
    of @link(TGLWindow), with the exception of OnOpen and OnClose callbacks.
    This is used in @link(TGLWindow.GetCallbacksState)
    and @link(TGLWindow.SetCallbacksState).
    See unit GLWinModes for example when such thing is useful. }
  TGLWindowCallbacks = record
    MouseMove: TMouseMoveFunc;
    MouseDown, MouseUp: TMouseUpDownFunc;
    MouseWheel: TMouseWheelFunc;
    KeyDown, KeyUp: TKeyCharFunc;
    BeforeDraw, Draw, CloseQuery, Idle, Timer: TGLWindowFunc;
    Resize: TGLWindowFunc;
    MenuCommand: TMenuCommandFunc;
    { When expanding this type: remember to also expand
      implementation of TGLWindow.GetCallbacksState and
      TGLWindow.SetCallbacksState.

      @seealso DefaultCallbacksState }
  end;

  { }
  TResizeAllowed = (raNotAllowed, raOnlyAtOpen, raAllowed);

  EGLContextNotPossible = class(Exception);

  {$define read_interface_types}
  {$I glwindow_backend.inc}
  {$undef read_interface_types}

  { Window with an OpenGL context.
    See GLWindow unit description for more info and examples of use. }
  TGLWindow = class(TComponent)

  { Include GLWindow-backend-specific parts of TGLWindow class.
    Remember to explicitly specify the scope
    (usually "private") of things that you add to TGLWindow class in backends,
    this is safest. Some backends may expose some protected or even public
    things that are specific for them. }

  {$define read_tglwindow_interface}
  {$I glwindow_backend.inc}
  {$undef read_tglwindow_interface}

  private
    FWidth, FHeight, FLeft, FTop: Integer;
    FOnOpen: TGLWindowFunc;
    FOnOpenList: TGLWindowFuncList;
    FOnBeforeDraw, FOnDraw: TDrawFunc;
    FOnResize: TGLWindowFunc;
    FOnClose: TGLWindowFunc;
    FOnCloseList: TGLWindowFuncList;
    FOnCloseQuery: TGLWindowFunc;
    FOnKeyDown, FOnKeyUp: TKeyCharFunc;
    FMouseMove: TMouseMoveFunc;
    FMouseDown, FMouseUp: TMouseUpDownFunc;
    FMouseWheel: TMouseWheelFunc;
    FOnIdle, FOnTimer: TGLWindowFunc;
    FFullScreen, FDoubleBuffer: boolean;
    FResizeAllowed: TResizeAllowed;
    FMousePressed: TMouseButtons;
    FMouseX, FMouseY: integer;
    FColorBits: integer;
  private
    FCursor: TMouseCursor;
    procedure SetCursor(const Value: TMouseCursor);
  private
    FCustomCursor: TRGBAlphaImage;
    procedure SetCustomCursor(const Value: TRGBAlphaImage);
  private
    FAutoRedisplay: boolean;
    procedure SetAutoRedisplay(value: boolean);
  private
    FCaption: string;
    procedure SetCaption(const Value: string);
  private
    { FClosed = are we outside of Open..Close }
    FClosed: boolean;

    { EventOpenCalled = has OnOpen been called from Open? }
    EventOpenCalled: boolean;
    closeerrors: string; { Used by Close. }

    MenuUpdateInside: Cardinal;
    MenuUpdateNeedsInitialize: boolean;
    MenuInitialized: boolean;

    { Used in particular backend, open OpenGL context and do
      Application.OpenWindowsAdd(Self) there.

      Here's a list of properties that should be made "visible" to the user
      in OpenBackend:

        Width, Height, Left, Top, FullScreen
        Cursor, CustomCursor (remember that changes to this after OpenBackend
          should also be allowed)
        ResizeAllowed (DoResize already implements appropriate
          checks, but implementation should provide user with visual clues that
          the window may / may not be resized)
        MainMenu (display MainMenu and provide way to call DoMenuCommand)

      OpenGL context must be initialized honouring these properties:
        DoubleBuffer, StencilBufferBits, DepthBufferBits, AlphaBits,
        AccumBufferBits, MultiSampling }
    procedure OpenBackend;

    { Close OpenGL context, for particular backend.

      No need to call OpenWindowsRemove here, it's done by universal Close already.
      It's advised (although not totally required) that all errors during
      CloseBackend should be caught and cause only CloseError.
      Reasoning: Close should, regardless of trouble, try to finalize as much
      as possible. }
    procedure CloseBackend;

    { Make the OpenGL context of this window current (active for following
      OpenGL commands). }
    procedure BackendMakeCurrent;

    procedure CloseError(const error: string);

    { Swap OpenGL buffers.
      Call this method only when DoubleBuffered and if you already did
      MakeCurrent. (Implicit glFlush is guaranteed.) }
    procedure SwapBuffers;

    { BackendMenuInitialize should cause backend to build whole menu resources
      for MainMenu, BackendMenuFinalize to free them.

      BackendMenuFinalize is called before changing MainMenu structure
      in arbitrary way, BackendMenuInitialize is called after.
      Backend should just free / initialize resources related to menu.
      BackendMenuInitialize may assume that BackendMenuFinalize was already called
      (so no need to try to free in BackendMenuInitialize again).

      They are never called directly: always call MenuInitialize / Finalize.
      These make sure to care about eventual MenuUpdateBegin / MenuUpdateEnd
      around, and make sure BackendMenuFinalize is called only when menu is
      already initialized (by BackendMenuInitialize), and
      BackendMenuInitialize is called only when menu is not initialized yet.

      Implementation of these can assume that MainMenu <> nil now.
      Also it may assume that Closed = false.

      Note: if backend wants, it may itself call these from
      OpenBackend / CloseBackend. Of course, when you call them
      yourself, you have to make sure on your own that all assumptions
      are satisfied. In practice, BackendMenuFinalize should clear all the variables
      to the state right after constructor (zero, nil etc.),
      and BackendMenuInitialize expect them as such, and then everything will work Ok.

      @groupBegin }
    procedure BackendMenuInitialize;
    procedure BackendMenuFinalize;
    { @groupEnd }

    { These call corresponding BackendMenuInitialize or BackendMenuFinalize,
      unless we're inside MenuUpdateBegin / MenuUpdateEnd,
      and take care to only initialize when finalized,
      and finalize only when initialized.
      @groupBegin }
    procedure MenuInitialize;
    procedure MenuFinalize;
    { @groupEnd }

    { For optimization purposes, you may surround many menu changes
      inside MenuUpdateBegin + MenuUpdateEnd calls.
      Make sure window is not closed / opened between them.
      @groupBegin }
    procedure MenuUpdateBegin;
    procedure MenuUpdateEnd;
    { @groupEnd }

    { Notification that menu Entry properties changed.
      This is called only when MainMenu <> nil and Entry is contained
      inside our MainMenu. Also, this is called only when not Closed.

      Only appropriate local Entry properties changed, no other menu entry
      (even child menu entry for submenus) was changed. The idea is that sloppy
      backend may simply do here MenuFinalize + MenuInitialize,
      but a better backend may do something more efficient,
      like updating only this specific Entry resources.

      @groupBegin }
    procedure MenuUpdateCaption(Entry: TMenuEntryWithCaption);
    procedure MenuUpdateEnabled(Entry: TMenuEntryWithCaption);
    procedure MenuUpdateChecked(Entry: TMenuItemChecked);
    function MenuUpdateCheckedFast: boolean;
    { @groupEnd }

    procedure CreateBackend;

    { Simulate that all the keys and mouse buttons were released.
      For all keys that are down (Pressed[k]) calls DoKeyUp(k).
      For all mouse buttons that are down (mb in MousePressed) calls DoMouseUp(mb).
      If GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN is defined,
      this calls at the beginning SetPrivateModifiersDown(..., ..., false)
      to say that all keys are up.

      Useful when user somehow switches to another window / control
      (e.g. when he opens our MainMenu), such that we are then unable to catch
      following KeyUps and MouseUps. So user simply STOPS controlling outr
      program with mouse and keyboard, so we have to assume that he releases
      all keys and mouse buttons.

      Nie widze chwilowo zastosowania dla MousePressed[*] := false,
      ale jest to konsekwentne. Z punktu widzenia programu w momencie wejscia
      usera do menu user przestaje kontrolowac program (tzn. okienko OpenGLa)
      przy pomocy myszy i klawiatury. }
    procedure ReleaseAllKeysAndMouse;

    { Should DoKeyDown be able to call DoMenuCommand, that is should
      we handle menu key shortcuts ourselves.

      This is implemented in backend-specific GLWindow parts.
      When in DoKeyDown we get some key event that specifies that
      some menu item should be called -- if RedirectKeyDownToMenuCommand,
      DoKeyDown will do DoMenuCommand. Else DoKeyDown will do nothing.

      This should be implemened as "Result := true" if we have to process
      keypresses in GLWindow to pass them as menu commands, e.g. when GLWindow
      works on top of glut or Xlib.
      When GLWindow works on top of GTK or WinAPI that allow us to do a "real"
      menu, this should be implemented as "Result := false". }
    function RedirectKeyDownToMenuCommand: boolean;

    { DoXxx methods ------------------------------------------------------------

      DoXxx method should be called by GLWindow backend when an event
      Xxx happens. DoXxx methods take care of various backend-independent
      stuff, and take care of calling EventXxx (that calls OnXxx in turn).
      GLWindow backend should never call EventXxx directly.
      (And nothing should call OnXxx directly except EventXxx.)

      Remember that no DoXxx may be called from CloseBackend.

      Below is the detailed specification, but summing some things up
      you don't have to worry about these things when you use DoXxx methods
      (these things are fully handled by DoXxx methods):
      - updating state of MousePressed
      - updating state of Pressed (Pressed.Keys, Pressed.Characters etc.)
      - updating state of MouseX, MouseY
      - calling MakeCurrent before every EventXxx
      - flushing gl commands (and swapping gl buffers when DoubleBuffer'ing)
      - taking care of AutoRedisplay
      - updating Width, Height (and updating it with accordance to
        Min/MaxWidth/Height and ResizeAllowed)
      - checking MainMenu.Enabled
    }

    { DoResize with FromIndependentOpen = true is called only once
      (and exactly once) from TGLWindow.Open implementation.
      So all GLWindow-backend code should always
      pass FromIndependentOpen = false (EVEN if it may be called from
      OpenBackend (that is called before DoResize in Open) !).

      Some more notes about calling DoResize from OpenBackend:
      in this case DoResize will NOT call EventResize (since the first callback
      that should be called for a window is EventOpen). We will always after
      EventOpen call DoResize(..., true), so this should not be a problem
      anywhere. You can simply call DoResize from OpenBackend to tell us what
      real Width/Height we have, and the real EventResize will be called
      just at a later time.

      You can pass here ANY AWidth, AHeight. It will be automatically clipped
      here to fit in Min/MaxWidth/Height and to satisfy ResizeAllowed.

      Also MakeCurrent + EventResize will be called (probably; sometimes
      DoResize may decide to not call EventResize - e.g. when ResizeAllowed
      =raNotAllowed and FirstTime = false then it's useless to call here
      EventResize).

      Remember : this function does not automatically call PostRedisplay.
      You must make sure that soon after changing size of the window
      you will call DoDraw (e.g. you can call PostRedisplay after
      calling DoResize; but usually (under WinAPI, Xlib, glut, gtk)
      it's not needed, i.e. WinAPI, Xlib, glut and gtk all take care of this
      automatically). }
    procedure DoResize(AWidth, AHeight: integer; FromIndependentOpen: boolean);
    { Wywoluj kiedy user kliknie na przycisku "Zamknij" itp.
      Wywola EventCloseQuery i ew. Close (and Close will execute EventClose,
      CloseBackend etc.). Note that there is no DoClose method and there
      should not be such method : always use DoCloseQuery. }
    procedure DoCloseQuery;

    { Do MakeCurrent,
         EventBeforeDraw,
         EventDraw (inside Fps._RenderBegin/End)
         flush gl command pipeline (and swap gl buffers if DoubleBuffer)

      - Take care of AutoRedisplay, like

          @code(if AutoRedisplay then PostRedisplay;)

        So specific GLWindow backends need not to worry about
        AutoRedisplay. They only have to implement PostRedisplay. }
    procedure DoDraw;
  private
    { DoKeyDown/Up: pass here key that is pressed down or released up.

      Only DoKeyDown: pass also CharKey. Pass Key = K_None if this is not
      representable as TKey, pass CharKey =#0 if this is not representable
      as char. But never pass both Key = K_None and CharKey =#0
      (this would have no meaning).

      Only DoKeyUp: never pass Key = K_None.

      If you call DoKeyUp while (not Pressed[Key]) it will be ignored
      (will not do any EventKeyUp etc. - just NOOP).

      This will
         update Pressed (Pressed.Keys, Pressed.Characters, etc.) accordingly,
         DoKeyDown: may here call DoMenuCommand
           (and then it will NOT call MakeCurrent and EventKeyDown)
         MakeCurrent,
         EventKeyDown/Up.
    }
    procedure DoKeyDown(key: TKey; CharKey: char);
    procedure DoKeyUp(key: TKey);
    { Do MakeCurrent,
         EventMouseMove,
         update MouseX, Y }
    procedure DoMouseMove(x, y: integer);
    { DoMouseDown/Up:
        update FMouseX, FMouseY (so that before EventMouseDown/Up position
          of the mouse is set to the current, precise, position)
        update MousePressed
        MakeCurrent
        EventMouseDown/Up }
    procedure DoMouseDown(x, y: integer; btn: TMouseButton);
    procedure DoMouseUp(x, y: integer; btn: TMouseButton);
    procedure DoMouseWheel(const Scroll: Single; const Vertical: boolean);
    procedure DoIdle;
    procedure DoTimer;
    { Just call it when user presses some MenuItem.
      This takes care of MainMenu.Enabled,
        MakeCurent,
        Item.DoCommand,
        optional EventMenuCommand or EventKeyDown }
    procedure DoMenuCommand(Item: TMenuItem);
  private
    FFps: TFramesPerSecond;
  private
    { Current OpenGL buffers configuration required.
      Stuff like DoubleBuffer, AlphaBits, DepthBufferBits,
      StencilBufferBits, AccumBufferBits etc.
      This simply returns a text description of these properties.

      It does not describe the current OpenGL context parameters.
      (It doesn't even need an OpenGL context open.)

      Useful for constructing messages e.g. for EGLContextNotPossible exceptions. }
    function RequestedBufferAttributes: string;
    { Check do given OpenGL buffers configuration satisfies the
      requested configuration.

      So it checks do

@preformatted(
  ProvidedStencilBits >= StencilBufferBits and
  ProvidedDepthBits >= DepthBufferBits ...
)
      and so on. If not, EGLContextNotPossible is raised with detailed
      description (which buffer constraint is not satisfied -- e.g. maybe
      the stencil buffer is not available).

      Note that ProvidedMultiSampling is not checked if MultiSampling is <= 1.
      In other words, if multisampling was not required, ProvidedMultiSampling
      doesn't matter --- it's Ok even ProvidedMultiSampling = 0 and
      MultiSampling = 1, which happens commonly (since our MultiSampling = 1 means
      "no multisampling" and is default, but most backends returns num_samples
      (or something equivalent) as = 0 when multisampling not supported). }
    procedure CheckRequestedBufferAttributes(const ProviderName: string;
      ProvidedStencilBits, ProvidedDepthBits, ProvidedAlphaBits,
      ProvidedAccumRedBits, ProvidedAccumGreenBits, ProvidedAccumBlueBits,
      ProvidedAccumAlphaBits, ProvidedMultiSampling: Cardinal);

  private
    FDepthBufferBits: Cardinal;
    FStencilBufferBits: Cardinal;
    FAlphaBits: Cardinal;
    FMultiSampling: Cardinal;
    FGtkIconName: string;
    FVisible: boolean;
    FPressed: TKeysPressed;
    FMinWidth: Integer;
    FMinHeight: Integer;
    FMaxWidth: Integer;
    FMaxHeight: Integer;

    { For IUIContainer interface. Private, since when you have a class
      instance, you just use class properties (that read directly from a field,
      without the overhead of a function call). }
    function GetMouseX: Integer;
    function GetMouseY: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetMousePressed: TMouseButtons;
    function GetPressed: TKeysPressed;
  public

    { Handle appropriate event.

      In the TGLWindow class, these methods simply call appropriate OnXxx
      callbacks (if assigned). In case of list callbacks (OnOpenList,
      OnCloseList) --- these are called here too.

      You can override them to do anything you want.

      You can also call these methods directly for some tricks.
      You may want to do MakeCurrent before calling them directly,
      if your application may have many OpenGL windows.
      When EventXxx are called internally from this unit, they are always
      preceded by MakeCurrent call.

      Notes for overriding OnIdle and OnTimer: you will usually also
      want to override then AllowSuspendForInput, to disallow suspending
      when you want to keep receiving idle/timer calls.

      Notes for overriding OnCloseQuery: you have to return @true
      to allow closing of the window.
      @groupBegin }
    procedure EventResize; virtual;
    procedure EventOpen; virtual;
    procedure EventClose; virtual;
    function EventCloseQuery: boolean; virtual;
    procedure EventDraw; virtual;
    procedure EventBeforeDraw; virtual;
    procedure EventKeyDown(Key: TKey; C: char); virtual;
    procedure EventKeyUp(key: TKey; C: char); virtual;
    procedure EventMouseMove(newX, newY: integer); virtual;
    procedure EventMouseDown(btn: TMouseButton); virtual;
    procedure EventMouseUp(btn: TMouseButton); virtual;
    procedure EventMouseWheel(const Scroll: Single; const Vertical: boolean); virtual;
    procedure EventIdle; virtual;
    procedure EventTimer; virtual;
    procedure EventMenuCommand(Item: TMenuItem); virtual;
    { @groupEnd }

    { Is it allowed to suspend (for an indefinite amount of time) waiting
      for user input.

      Allowing this is a good thing, as it means our process doesn't eat
      your CPU when it simply waits, doing nothing, for user input.
      On the other hand, you cannot allow this if you want to do some
      things continously, regardless of user input.

      In this class, this simply checks if OnIdle or OnTimer events
      are assigned. If one of them is, we do not allow to suspend.
      In descendants, you typically want to override this if there's
      a chance you may do something in overridden EventIdle or EventTimer. }
    function AllowSuspendForInput: boolean; virtual;

    { ------------------------------------------------------------------------
      Stuff that may be initialized only when the window is not open yet.
      When the window is open, these are read-only (may only change
      through internal methods, e.g. we'll update @link(Width), @link(Height),
      @link(Left), @link(Top) to reflect current size and position).  }

    { Size of the window OpenGL area. Together with frame and border
      sizes, and eventually menu bar size, this determines the final
      window size.

      MinWidth / MaxWidth / MinHeight / MaxHeight place constraints
      on these values (rigorously honored when window is open):
      always @code(MinWidth <= Width <= MaxWidth) and
      @code(MinHeight <= Height <= MaxHeight).

      ResizeAllowed places constrains when window manager and user may change
      window size. In particular, when ResizeAllowed <> raAllowed then
      window sizes cannot change when window is open.

      Note that for some window managers, we cannot always reliably
      force the size constraints and block resizing on the desktop.
      If you set rigorous size constraints, or ResizeAllowed <> raAllowed,
      you may find that window manager still resizes the window.
      In such cases, we may fake our size a little ---
      @link(Width) and @link(Height) values may not correspond to actual
      size as seen on the desktop. This is comfortable, as in such cases
      you usually want to just ignore window managers limits and just
      proceed as if your size requirements are satisfied.

      Special GLWindowDefaultSize value of these properties
      means: at @link(Open), use some comfortable size slightly
      smaller than desktop size.
      @groupBegin }
    property Width: integer read FWidth write FWidth default GLWindowDefaultSize;
    property Height: integer read FHeight write FHeight default GLWindowDefaultSize;
    { @groupEnd }

    { Window position on the screen. If one (or both) of them is equal
      to GLWindowPositionCenter at the initialization (Open) time,
      then it will be set to position the window at the screen center.
      @groupBegin }
    property Left: integer
      read {$ifdef GLWINDOW_GLUT}GetLeft{$else}FLeft{$endif}
      write FLeft default GLWindowPositionCenter;
    property Top :integer
      read {$ifdef GLWINDOW_GLUT}GetTop{$else}FTop{$endif}
      write FTop default GLWindowPositionCenter;
    { @groupEnd }

    property FullScreen: boolean read FFullScreen write FFullScreen default false;

    { Should we request and use the double buffer.
      After every draw, we automatically swap buffers (if DoubleBuffer)
      or call glFlush (if not DoubleBuffer). }
    property DoubleBuffer: boolean read FDoubleBuffer write FDoubleBuffer default true;

    { Colors precision for this window.
      When 0, then we'll use Application.VideoColorBits.
      When Application.VideoColorBits is also 0, then the default window
      system color precision will be used.

      After @link(Open), this is updated to the actual color bits used.

      In most situations, you will have to change the screen color precision
      to have the best chance for a given window color precision.
      So use Application.VideoColorBits and Application.VideoChange.

      This is deprecated, don't use. This isn't cross-platform (only Windows),
      there's no guarantee you actually get the required color bits,
      and the fact that we change ColorBits after Open is ugly (we should
      have another property for this).

      @deprecated }
    property ColorBits: integer
      read FColorBits write FColorBits default 0;

    { Sets mouse cursor appearance over this window.
      See TMouseCursor for a list of possible values and their meanings.

      TODO: for now, mcCustom is not handled anywhere. }
    property Cursor: TMouseCursor read FCursor write SetCursor default mcDefault;

    { Image for cursor, used only when @link(Cursor) = mcCustom.
      We will try hard to use any cursor image as appropriate, but on some platforms
      cursor size may be limited (16 x 16 seems standard for GTK) and cursor
      may be forced to monochrome.

      Note that you still own the TRGBAlphaImage instance passed here --- you're
      responsible for freeing it etc. If this is @nil, and @link(Cursor) = mcCustom,
      then it will be treated like @link(Cursor) = mcDefault. (I don't raise error
      in such case, as that would make changing both Cursor and CustomCursor values
      unnecessarily tricky for the programmer.)

      TODO: for now, this is not implemented. @link(Cursor) ignores mcCustom value,
      under every GLWindow backend... sorry, CustomCursor is only a plan. }
    property CustomCursor: TRGBAlphaImage read FCustomCursor
      write SetCustomCursor;

    { Place mouse cursor at NewMouseX and NewMouseY.
      Position is specified relative to this window's upper-top corner
      (more specifically, OpenGL area upper-top corner),
      just like MouseX and MouseY properties.

      Note that the actually set position may be different than requested,
      for example if part of the window is offscreen then
      window manager will probably refuse to move mouse cursor offscreen.

      This @italic(may) generate normal OnMouseMove event, just as if the
      user moved the mouse. But it's also allowed to not do this.

      Ignored when window is closed. }
    procedure SetMousePosition(const NewMouseX, NewMouseY: Integer);

    { When (if at all) window size may be changed.

      @unorderedList(
        @item(raNotAllowed

          @link(Width) and @link(Height) can only change
          to honor MinWidth / MaxWidth / MinHeight / MaxHeight constraints.
          Absolutely nothing else may cause them to change,
          user cannot resize the window.

          This may even force FullScreen change from @true to @false
          at @link(Open) call, when you will request a fullscreen window
          but @link(Width) / @link(Height) will not match screen size.

          You can be sure that EventResize (OnResize) will be called only
          once, when window is opened (right after initial EventOpen (OnOpen)).)

        @item(raOnlyAtOpen

          @link(Width) and @link(Height) may be adjusted when the window
          is opened, by @link(Open) call. For example window manager
          may decide that the size is too large for the current screen.
          Or when you request FullScreen window and window size has to be
          adjusted to match current screen size. Also they will always be
          adjusted to fit in MinWidth / MaxWidth / MinHeight / MaxHeight constraints.

          After opening, window size cannot change anymore.
          In particular user cannot resize the window (by dragging border
          or such). After the first EventOpen (OnOpen) call,
          the window size becomes constant. From the first EventResize
          (OnResize) the window size is constant, as long as the window
          remains open.

          You can be sure that EventResize (OnResize) will be called only
          once, when window is opened (right after initial EventOpen (OnOpen)).)

        @item(raAllowed

          @link(Width) and @link(Height) may be adjusted at open time,
          and later user can resize the window too.
          This is the default value, giving user and window manager
          the most flexibility.

          You have to be prepared for this, handling OnResize and adjusting
          stuff like OpenGL viewport and projection matrix.)
      )

      Note that the we call the first glViewport automatically in @link(Open).
      So in typical cases, you don't have to call glViewport ever yourself,
      when ResizeAllowed <> raAllowed. }
    property ResizeAllowed: TResizeAllowed
      read FResizeAllowed write FResizeAllowed default raAllowed;

    { Event called when OpenGL context is initialized.

      It's guaranteed that every newly opened window will get
      EventOpen (OnOpen) first, and then EventResize (OnResize),
      and only then --- the other callbacks, as the user uses the window.
      This is consistent EventOpen (OnOpen)
      is always the first executed callback and EventClose (OnClose)
      is always the last. This allows you to cleanly initialize / finalize
      OpenGL resources.

      During EventOpen (OnOpen) you already have valid
      Width / Height values, that is those values were already adjusted
      if ResizeAllowed <> raNotAllowed. }
    property OnOpen: TGLWindowFunc read FOnOpen write FOnOpen;

    { Callbacks called when OpenGL context is initialized.
      Called always after OnOpen. Useful when one callback is not enough.

      The list instance (TGLWindowFuncList) is created / destroyed
      in this class. You can add / remove freely your callbacks from this class. }
    property OnOpenList: TGLWindowFuncList read FOnOpenList;

    { Minimum and maximum window sizes. Always

@preformatted(
  0 < MinWidth <= MaxWidth and
  0 < MinHeight <= MaxHeight
)

      We do not allow user to resize the window outside of these constraints.

      We also fix window @link(Width) and @link(Height) to fit within
      these constraints when you @link(Open) the window. We do it regardless
      of ResizeAllowed (even when it's raNotAllowed).

      In other words, these constraints have a higher priority than
      ResizeAllowed and your desired @link(Width) and @link(Height)
      and even @link(FullScreen). So you can be sure that (as long as window
      is open) @link(Width) / @link(Height) will always fit in these constraints.
      @groupBegin }
    property MinWidth: Integer read FMinWidth write FMinWidth default 100;
    property MinHeight: Integer read FMinHeight write FMinHeight default 100;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth default 4000;
    property MaxHeight: Integer read FMaxHeight write FMaxHeight default 4000;
    { @groupEnd }

    { Required depth buffer precision. Zero means that we don't need
      depth buffer at all. We may get depth buffer with more precision
      than requested (we may even get depth buffer when we set
      DepthBufferBits = 0), this all depends on graphic card.

      Default value is 16 (DefaultDepthBufferBits),
      which is a reasonable default for 3D programs
      that want to work with depth test enabled.

      @italic(Design notes:) One may ask why default value is not 0?

      @orderedList(
        @item(
          Most programs using OpenGL use depth testing, so many programs
          would have to call something like @code(Window.DepthBufferBits := 16).)

        @item(
          Often graphic cards / window systems / OSes give you an OpenGL
          context with depth buffer @italic(even if you don't need depth buffer).
          I don't say that it's bad. But it makes very easy to forget about
          doing @code(DepthBufferBits := something-non-zero;).
          If you're writing 3d program and sitting on some
          system that always gives you depth buffer (even if DepthBufferBits = 0)
          then it may happen that you forget to write in your program
          @longCode(#  Window.DepthBufferBits := 16;#)

          And while on your system everything will work, you will
          receive errors on other systems because you forgot to request a
          depth buffer.)
      )

      Of course, if you are writing a program that does not need depth buffer
      you should set Window.DepthBufferBits := 0. The only advantage of having
      default DepthBufferBits = 16 is that if you forget to set
      Window.DepthBufferBits := 0 your programs will still work (most graphic cards
      will give you some depth buffer anyway).
      They will just use more resources than they should.
    }
    property DepthBufferBits: Cardinal
      read FDepthBufferBits write FDepthBufferBits default DefaultDepthBufferBits;

    { Required stencil buffer precision, zero means that stencil buffer is
      not needed.

      Just like with other XxxBufferBits property, we may get more
      bits than we requested. But we will never get less --- if window system
      will not be able to provide GL context with requested number of bits,
      @link(Open) will raise an error.

      Note that after initializing OpenGL context (when opening the window),
      StencilBufferBits is @italic(not) updated to the current (provided)
      stencil buffer bit size. For example, if you requested StencilBufferBits := 8,
      and you got 16-bits buffer: StencilBufferBits value will still remain 8.
      This is sensible in case you close the window, tweak some settings
      and try to open it again. Use @code(glGetInteger(GL_STENCIL_BITS))
      when window is open to query current (actual) buffer size. }
    property StencilBufferBits: Cardinal
      read FStencilBufferBits write FStencilBufferBits default 0;

    { How many samples are required for multisampling.
      1 means that no multisampling is required.
      Values larger than 1 means that we require OpenGL context with
      multisampling capabilities (GLX_ARB_multisample for glX on Unix
      or WGL_ARB_multisample for wgl on Windows). MultiSampling says how
      many samples per pixel should be done (try typical 2 or 4 values).

      So the only thing remaining for your program to make anti-aliasing
      working is to use core OpenGL extension GL_ARB_multisample:
      [http://opengl.org/registry/specs/ARB/multisample.txt].
      In the usual case, this means simply to call

      @longCode(#  if GL_ARB_multisample then glEnable(GL_MULTISAMPLE_ARB); #)

      and

      @longCode(#  if GL_ARB_multisample then glDisable(GL_MULTISAMPLE_ARB); #)

      Just like with other XxxBufferBits property, we may get more
      samples than we requested (e.g. if you request 3, you will most probably
      get 4...). But we will never get less --- if window system
      will not be able to provide GL context with requested number of bits,
      @link(Open) will raise an error. }
    property MultiSampling: Cardinal
      read FMultiSampling write FMultiSampling default 1;

    { Required number of bits in alpha channel of color buffer.
      Zero means that alpha channel is not needed.

      Just like with other XxxBufferBits property, we may get more
      bits than we requested. But we will never get less --- if window system
      will not be able to provide GL context with requested number of bits,
      @link(Open) will raise an error.

      It's undefined how I'll treat this variable when indexed color mode
      will be possible in TGLWindow. }
    property AlphaBits: Cardinal
      read FAlphaBits write FAlphaBits default 0;
  public
    { Required number of bits in color channels of accumulation buffer.
      Color channel is 0..3: red, green, blue, alpha.
      Zero means that given channel of accumulation buffer is not needed,
      so when the vector is all zeros (default value) this means that
      accumulation buffer is not needed at all.

      Just like with other XxxBufferBits property, we may get more
      bits than we requested. But we will never get less --- if window system
      will not be able to provide GL context with requested number of bits,
      @link(Open) will raise an error. }
    AccumBufferBits: TVector4Cardinal;

    (* TODO: zrobic od razu
         IndexBufferBits: Cardinal; = ????
         IndexedColorBuffer: boolean; { = false }
    *)

    { Name of the icon for this window used by GTK 2 backend.

      This is simply passed to @code(gtk_window_set_icon_name),
      see [http://library.gnome.org/devel/gtk/stable/GtkWindow.html#gtk-window-set-icon-name].
      This allows you to use an installed icon (in /usr/share/icons/
      or ~/.local/share/icons/) for your program. See
      [http://library.gnome.org/devel/integration-guide/stable/icons.html.en]
      for short information how and where to install your icons.

      It's ignored on non-GTK 2 backends. }
    property GtkIconName: string read FGtkIconName write FGtkIconName;

    (*Should this window be actually displayed on the desktop.
      In all normal programs you want to leave this as @true, as the
      main purpose of the window is to actually be visible and interactive
      on the desktop.

      Setting this to @false allows you to get an OpenGL context without
      showing anything on the desktop. This can be used for rendering
      and capturing OpenGL stuff without showing it on the desktop.
      One example is the @--screenshot option of view3dscene, see
      [http://castle-engine.sourceforge.net/view3dscene.php#section_screenshot].

      If you implement such thing, remember that you should not render
      and capture the normal front or back buffer contents.
      OpenGL makes no guarantee that a hidden window will have any allocated
      memory, so capturing hidden window contents isn't useful (you may
      get something valid, or you may get random / blank screen, depending
      on OS and GPU). However, you can create Framebuffer Object
      on modern GPUs, and capture it's contents. An example code snippet:

@longCode(#
{ add GLImages, Images to your uses clause }

var
  ScreenshotRender: TGLRenderToTexture;
  Image: TRGBImage;
begin
  ScreenshotRender := TGLRenderToTexture.Create(Width, Height);
  try
    ScreenshotRender.Buffer := tbNone;
    ScreenshotRender.GLContextOpen;
    ScreenshotRender.RenderBegin;

    { render your stuff here }

    { capture the screen }
    glFlush;
    Image := SaveScreen_NoFlush(0, 0, Width, Height, GL_BACK);
    try
      SaveImage(Image, 'aaa.png');
    finally FreeAndNil(Image) end;

    ScreenshotRender.RenderEnd;
  finally FreeAndNil(ScreenshotRender) end;
end;
#)
       *)
    property Visible: boolean read FVisible write FVisible default true;

    { Caption of the window. By default it's initialized to ProgramName.
      May be changed even when the window is already open. }
    property Caption: string read FCaption write SetCaption;

    { Draw your window contents here.

      Called when your window contents must be redrawn,
      e.g. after creating a window, after resizing a window, after uncovering
      the window etc. You can also request yourself a redraw of the window
      by the PostRedisplay method, which will cause this event to be called
      at nearest good time.

      Note that calling PostRedisplay while in EventDraw (OnDraw) is not ignored.
      It means that in a short time next EventDraw (OnDraw) will be called. }
    property OnDraw: TDrawFunc read FOnDraw write FOnDraw;

    { Always called right before EventDraw (OnDraw).
      These two events, EventBeforeDraw (OnBeforeDraw) and EventDraw (OnDraw),
      will be always called sequentially as a pair.

      The only difference between these two events is that
      time spent in EventBeforeDraw (OnBeforeDraw)
      is NOT counted as "frame time"
      by Fps.FrameTime. This is useful when you have something that needs
      to be done from time to time right before OnDraw and that is very
      time-consuming. It such cases it is not desirable to put such time-consuming
      task inside OnDraw because this would cause a sudden big change in
      Fps.FrameTime value. So you can avoid this by putting
      this in OnBeforeDraw. }
    property OnBeforeDraw: TDrawFunc read FOnBeforeDraw write FOnBeforeDraw;

    { Called when the window size (@link(Width), @link(Height)) changes.
      It's also guaranteed to be called during @link(Open),
      right after the EventOpen (OnOpen) event.

      Our OpenGL context is already "current" when this event is called
      (MakeCurrent is done right before), like for other events.
      This is a good place to set OpenGL viewport and projection matrix.

      See also ResizeAllowed.

      Simple 2D OpenGL programs may want to register here simple
      @link(Resize2D). }
    property OnResize: TGLWindowFunc read FOnResize write FOnResize;

    { Called when the window is closed, right before the OpenGL context
      is destroyed. This is your last chance to release OpenGL resources,
      like textures, shaders, display lists etc. This is a counterpart
      to OnOpen event. }
    property OnClose: TGLWindowFunc read FOnClose write FOnClose;

    { List of callbacks called when the window is closed,
      right before the OpenGL context is destroyed.
      Just like OnClose. Use when one callback is not enough. }
    property OnCloseList: TGLWindowFuncList read FOnCloseList;

    { Called when user presses a key.
      Only for keys that can be represented as TKey or Char types.

      Not all keyboard keys can be represented as TKey value. There are
      some keys that generate sensible char values, but still cannot be
      represented as TKey value, e.g. key '/' does not have any K_Xxx
      constant for now but can be expressed as char '/'.
      So you can get Key = K_None is such situations, e.g. OnKeyDown
      will be called like OnKeyDown(Self, K_None, '/').

      Character c is based on pressed key, current Modifiers state,
      state of keys like "Caps-Lock" , maybe some OS configurarion
      (like locale-specific chars, e.g. polish "ogonki"), etc. In general,
      it is operating-system (and window-system, and GLWindow-backend)
      specific. Not all key presses are representable as
      char, so you may get c = #0 in such situations.
      E.g. "up arrow" key does not have a corresponding char code,
      so OnKeyDown may be called like OnKeyDown(Self, K_Up, #0).

      Never will both Key = K_None and c = #0 (this would be rather useless
      event...). (Unless you will explicitely call EventKeyDown(K_None, #0),
      which you should never do.)

      Note: once I had here separate events, OnKeyPress (with only c: char)
      and OnKeyDown (with only Key: TKey). But this was very error-prone:
      for one user key press you could get two events (e.g.
      OnKeyDown(K_C) and then OnKeyPress('c')). Problems with this were easily
      avoidable in small programs (where you can see all your OnKeyDown and
      OnKeyPress handlers in one file), but in large programs they were producing
      very nasty bugs. E.g. imagine that you handle in OnKeyDown key K_Enter
      by doing GLWinMessages.MessageOK. But then each time user presses
      Enter key you

      @orderedList(
        @item(handle it in OnKeyDown calling GLWinMessages.MessageOK)
        @item(GLWinMessages.MessageOK changes your GLWindow callbacks
         so that OnKeyPress(#13) makes GLWinMessages.MessageOK exit.)
        @item(but then you're getting OnKeyPress(#13) event (because K_Enter
         is converted to #13 char). So GLWinMessages.MessageOK ends.)
      )

      This looked like a bug in GLWinMessages.MessageOK. But actually
      it was a bug in callbacks design: you were getting two callbacks
      (OnKeyDown amd OnKeyPress) for one event (user presses a key).

      When the user holds the key pressed, we will get consecutive
      key down events. Under some OSes, you will also get consecutive
      key up events, but it's not guaranteed (on some OSes, you may
      simply get only consecutive key down). So the more precise
      definition when OnKeyDown occurs is: it's a notification that
      the key is (still) pressed down. }
    property OnKeyDown: TKeyCharFunc read FOnKeyDown write FOnKeyDown;

    { Called when user releases a pressed key. It's called right after
      Pressed[Key] changed from true to false.

      Key is never K_None.

      C may be #0 is no representable character is released.
      When C is <> #0, we detected that some character is released.
      This is connected with setting Characters[C] from @true to @false.

      Note that reporting characters for "key release" messages is not
      perfect, as various key combinations (sometimes more than one?) may lead
      to generating given character. We have some intelligent algorithm
      for this, used to make Characters table and to detect
      this C for OnKeyUp callback. The idea is that a character is released
      when the key that initially caused the press of this character is
      also released.

      This solves in a determined way problems like
      "what happens if I press Shift, then X,
      then release Shift, then release X". (will "X" be correctly
      released as pressed and then released? yes.
      will small "x" be reported as released at the end? no, as it was never
      pressed.) }
    property OnKeyUp: TKeyCharFunc read FOnKeyUp write FOnKeyUp;

    { Called when user tries to close the window.
      This is called when you use window manager features to close the window,
      like clicking on the "close" icon on the window frame or using Alt+F4
      on most desktops. This is @italic(not) called when you explicitly
      close the window by calling the @link(Close) method.

      When this callback is not assigned, we will
      just let the window be closed. When it's assigned,
      the window will not closed --- you should call here @link(Close)
      explicitly if you want to (for example, after asking user for
      confirmation "do you really want to quit?").

      When handling this event, you must remember that user
      may try to close our window at any time.
      E.g. if you're implementing here somehing like showing user
      text "You cannot quit now" or asking user "Do you really want to quit"
      remember that while you display such message to user and you're
      processing events (e.g. looking for keypress "Yes" or "No"),
      user may try to close your window again.

      GLWinMessages unit offers some nice routines that you can safely
      use here, e.g. you can use it inside OnCloseQuery like

        if MessageYesNo(Window, 'Are you sure you want to quit?') then
         Close;

      Inside MessageYesNo, when we're processing events,
      and waiting for user's answer (yes or no),
      futher OnCloseQuery events will be ignored, so everything will work OK.

      This event is also useful if you want to call Close(false)
      on closing the window (i.e. QuitWhenLastWindowClosed = false).
      By default, if this event is undefined, we call Close(true)
      when user tries to close the window. }
    property OnCloseQuery: TGLWindowFunc read FOnCloseQuery write FOnCloseQuery; { = nil }

    { Called when mouse is moved. Remember you always have the currently
      pressed mouse buttons in MousePressed. When this is called,
      the MouseX, MouseY properties describe the @italic(previous)
      mouse position, while callback parameters NewX, NewY describe
      the @italic(new) mouse position. }
    property OnMouseMove :TMouseMoveFunc read FMouseMove write FMouseMove;

    { Called when you press mouse button. Remember you always have the current
      mouse position in MouseX, MouseY.

      When user presses the mouse over
      our window, mouse is automatically captured, so all further OnMouseMove
      OnMouseUp will be passed to this window (even if user moves mouse
      outside of this window), until user releases all mouse buttons.
      Note that this means that mouse positions may be outside
      of [0..Width - 1, 0..Height - 1] range.

       @groupBegin }
    property OnMouseDown :TMouseUpDownFunc read FMouseDown write FMouseDown;
    property OnMouseUp :TMouseUpDownFunc read FMouseUp write FMouseUp;
    { @groupEnd }

    { Event called when user scrolled with mouse wheel.

      Positive value of Scroll means user scrolled up or left,
      negative means user scrolled down or right. It is never zero.

      Scroll units are such that 1.0 should be treated like a "one operation",
      like a one click. On most normal mouses only an integer scroll will be
      possible to make. On the other hand, on touchpads it's common to be able
      to scroll by flexible amounts.

      Backends: GTK and Xlib cannot generate Scroll values different than 1 or -1. }
    property OnMouseWheel: TMouseWheelFunc read FMouseWheel write FMouseWheel;

    { Idle event is called for all open windows, all the time.
      It's called when we have no more events to process,
      and have nothing to do @italic(with the exception of redraw).
      Our idle events are called at least as regularly as redraw.
      This last condition is important --- otherwise your game
      could get overwhelmed my messages (like mouse moves) and time-consuming
      redraw, and you would not have time to actually update animations
      in idle events.

      Called at the same time when
      @link(TGLApplication.OnIdle Application.OnIdle) is called.

      You should add code to this window's OnIdle event
      (not to TGLApplication.OnIdle) when you do something related
      to this window. For example when you check this window's
      @link(Pressed) keys state, or animate something displayed on this window.
      This allows various "modal boxes" and such (see GLWinMessages)
      to nicely "pause" such processing by temporarily replacing
      OnIdle and other events of a window that displays a modal box. }
    property OnIdle: TGLWindowFunc read FOnIdle write FOnIdle;

    { Timer event is called approximately after each
      @link(TGLApplication.TimerMilisec Application.TimerMilisec)
      miliseconds passed.

      Called at the same time when
      @link(TGLApplication.OnTimer Application.OnTimer) is called. }
    property OnTimer: TGLWindowFunc read FOnTimer write FOnTimer;

    { Should we automatically redraw the window all the time,
      without a need for PostRedisplay call.
      If @true, window will behave like a redraw is always needed,
      and EventDraw (OnDraw) will be always called as often as posible.
      This may be a waste of OS resources, so don't use it, unless
      you know that you really have some animation displayed
      all the time. }
    property AutoRedisplay: boolean read fAutoRedisplay write SetAutoRedisplay; { = false }

    { -------------------------------------------------------------------------
      Menu things (menu may be modified at runtime, everything will be
      automatically properly redisplayed etc.) }

  private
    FMainMenu: TMenu;
    FOwnsMainMenu: boolean;
    FOnMenuCommand: TMenuCommandFunc;
    FUserData: Pointer;
    procedure SetMainMenu(Value: TMenu);
  public
    { Menu bar of this window.
      When not assigned, we have no menu bar.

      Note that MainMenu.Caption will be ignored.

      You can change this freely while Closed.

      You can change this almost freely while not Closed: you can use
      various properties of TMenuEntry descendants (adding, deleting items
      from TMenu, changing Caption, Key, CharKey, Checked properties --
      anything) and you can change value of MainMenu BUT you must not
      change MainMenu <> nil state when the window is not Closed.
      I.e. if you called Open with MainMenu = nil, then MainMenu must stay
      nil unit Close. If you called Open with MainMenu <> nil, then you
      can assign other MainMenu values while not Closed, but only values
      <>nil. I.e. you can't set MainMenu to nil if you called Open
      with MainMenu <> nil.
      See @code(castle_game_engine/examples/glwindow/glwindow_menu.lpr)
      for demo of changing value of MainMenu while window is not Closed.

      Note that MainMenu.Enabled is honoured (as well as Enabled
      for all menu items inside, of course).
      You can use this to disallow user from clicking on the whole
      menu. When MainMenu.Enabled = @false then
      no MenuItem.DoCommand, no EventMenuCommand
      will be called when user presses some menu item.
      When user presses some keyboard shortcut for some menu item,
      no MenuItem.DoCommand and no EventMenuCommand will be called,
      but instead normal EventKeyDown (OnKeyDown) will be called.

      When it is useful to set this to false?
      For example hen using GLWinModes. When you're changing modes (e.g. at the
      beginning of GLWinMessages.MessageOk) you're temporary setting
      OnMenuCommand to nil, but this doesn't block TMenuItem.DoCommand
      functions. The only way to block menu from triggering ANY event is to
      set this to MainMenu.Enabled to @false. }
    property MainMenu: TMenu read FMainMenu write SetMainMenu;

    { If true then in TGLWindow destructor MainMenu will be destroyed too
      (if not nil, od course). Usually this is something useful. }
    property OwnsMainMenu: boolean read FOwnsMainMenu write FOwnsMainMenu default true;

    { Called each time user chooses some menu item and it's not handled
      in TMenuItem.DoCommand. By default, menu item handling is passed
      to TMenuItem.DoCommand. Only when it return @false (not handled) then
      we call this window's event. }
    property OnMenuCommand: TMenuCommandFunc read FOnMenuCommand write FOnMenuCommand;

    { @section(Mouse state) -------------------------------------------------- }

    { Currently pressed mouse buttons. When this changes, you're always
      notified by OnMouseDown or OnMouseUp calls.

      This value is always current, in particular it's already updated
      when we call events OnMouseDown and OnMouseUp. }
    property MousePressed: TMouseButtons read FMousePressed;

    { Mouse position. This is the mouse position relative to this window,
      more precisely relative to the OpenGL control of this window.

      Left-top corner is (0, 0), and right-bottom is (Width - 1, Height - 1).
      This is consistent with most window libraries (GTK, LCL etc.).
      Plese note that Y coordinate is reversed with respect to the typical OpenGL
      Ortho2D projection, if needed you'll have to adjust it (by using
      @code(Height - MouseY)).

      Note that we have mouse capturing (when user presses and holds
      the mouse button, all the following mouse events are reported to this
      window, even when user moves the mouse outside of the window).
      This is typical of all window libraries (GTK, LCL etc.).
      This implicates that mouse positions are sometimes tracked also
      when mouse is outside the window, which means that mouse position
      may be outside the rectangle (0, 0) - (Width - 1, Height - 1),
      so it may even be negative.

      In all situations the MouseX, MouseY is the latest known mouse position.
      The only exception is within EventMouseMove (and so, also in OnMouseMove
      callback): MouseX, MouseY is then the previous known mouse position,
      while new mouse position is provided as NewX, NewY arguments to
      EventMouseMove (and OnMouseMove).

      @groupBegin }
    property MouseX: integer read FMouseX;
    property MouseY: integer read FMouseY;
    { @groupEnd }

    { Place for your pointer, for any purposes.
      No code in this unit touches the value of this field.
      This is similar to TComponent.Tag property. }
    property UserData: Pointer read FUserData write FUserData;

    property Closed: boolean read FClosed default true;

    (*Open the window (create window with GL context, show window).

      @unorderedList(
        @item(Create window, it's OpenGL area, optionally it's menu.)
        @item(Create OpenGL context associated with it's OpenGL area.)
        @item(Show the window.)
        @item(Call LoadAllExtensions.
          This way every information initialized by this
          is ready, like GLVersion, GLUVersion, extensions are checked
          and initialized.)

        @item(Initial events called:@br
          Call MakeCurrent, EventOpen (OnOpen)@br
          Call MakeCurrent, EventResize (OnResize)@br
          Call MakeCurrent once again, to be sure that after Open
          active OpenGL context is the one associated with newly created
          window (in case you would change active OpenGL context inside
          EventResize (OnResize), which is allowed).)
      )

      Call to Open is ignored if not Closed., i.e. if window is already inited.

      Raises EGLContextNotPossible if it's not possible to obtain
      OpenGL context with specified attributes.
      For example, maybe you set (Depth|Stencil|Accum)BufferBits properties
      to too high values. It's guaranteed that even when EGLContextNotPossible
      was raised, the window remains in correct (Closed) state, so you
      can try to lower some requirements and call init once again.
      For example:

@longCode(#
  Shadows := true;
  Window.StencilBufferBits := 8;
  try
    Window.Open;
  except
    on EGLContextNotPossible do
    begin
      Shadows := false;
      Window.StencilBufferBits := 0;
      { try to open once again, this time without requesting stencil buffer }
      Window.Open;
    end;
  end;
#)

      @raises(EGLContextNotPossible If it's not possible to obtain
        OpenGL context with specified attributes.)
    *)
    procedure Open;

    { Version of Open that will eventually turn off multisampling and
      stencil buffer, if display doesn't support them.

      @orderedList(
        @item(First it tries to initialize requested OpenGL context,
          simply by calling regular @link(Open).)

        @item(When this fails, and multisampling was requested (MultiSampling > 1),
          it will set MultiSampling to 1, call MultiSamplingOff, and retry.)

        @item(When this also fails, and stencil buffer was requested
          (StencilBufferBits > 0), it will set StencilBufferBits to 0,
          call StencilOff, and retry.)

        @item(When this also fails, you will get EGLContextNotPossible
          exception, just like from regular @link(Open) call when
          initialization failed.)
      )

      At failures, right before retrying, MultiSamplingOff and
      StencilOff callbacks are called (if assigned).
      It's important to note that they are called before actually
      retrying. This means that MultiSamplingOff/StencilOff
      will be always called before TGLWindow.Open that eventually
      succeeds, so they will be always called before eventual TGLWindow.OnOpen
      and such. This is usually what you want.

      FailureMessage passed to *Off callbacks will be the multiline
      (separated, but not terminated, by newline) messages describing
      why previous try failed.

      @raises(EGLContextNotPossible If it's not possible to obtain
        requested OpenGL context, even without multisampling and
        stencil buffer.) }
    procedure OpenOptionalMultiSamplingAndStencil(
      const MultiSamplingOff, StencilOff: TGLContextLoweredFunc);

    { Close window.

      @unorderedList(
        @item(Calls EventClose (and OnClose).)
        @item(Hides window, destroys it.)
        @item(
          if this was the only open TGLWindow window
          and QuitWhenLastWindowClosed = true then
          this calls Application.Quit.)
      )

      Note that often there's no need to call Close explicitly in your program,
      because in destructor of this object we call Close, to be sure
      that window is closed.

      TODO: zrobic param boolean CloseFromDestroyQuitWhenLastWindowClosed?
      As for now Close from destructor is called always with
      QuitWhenLastWindowClosed = true.

      Call to Close is ignored if window is already Closed. }
    procedure Close(QuitWhenLastWindowClosed: boolean = true);

    { Make contents of OpenGL area of this window
      redrawn, at the nearest good time. The redraw will not happen
      immediately, we will only "make a note" that we should do it soon.
      Redraw means that we call EventBeforeDraw (OnBeforeDraw), EventDraw
      (OnDraw), then we flush OpenGL commands, swap buffers etc.

      Calling this on a closed window is allowed and ignored. }
    procedure PostRedisplay;

    { Force redraw of OpenGL area @italic(right now),
      only if any redraw is needed.

      If we know we should redraw a window (for example, because window
      manager just said that window is brought to front of the desktop,
      or because you called PostRedisplay) then we will redraw
      the window @italic(right now). This method will directly
      call EventBeforeDraw (OnBeforeDraw), EventDraw
      (OnDraw), flush OpenGL commands, swap buffers and such.

      You really should not use this method too often. It's best to leave
      to this unit's internals decision when the redraw should happen,
      and allow us to redraw only once even if you called PostRedisplay
      many times in a short time.

      The one valid reason for using this function is when you need
      to read back the drawn window contents (e.g. by glReadPixels).
      Then you want to make sure first that any pending redraws are
      actually done --- this method allows you to do this. }
    procedure FlushRedisplay;

    { Make the OpenGL context of this window "current" (following OpenGL
      commands will apply to this). When the window is opened, and right
      before calling any window callback, we always automatically call
      this, so you should not need to call this method yourself
      in normal circumstances. }
    procedure MakeCurrent;

    { Capture the current window contents to an image (file).

      These functions take care of flushing any pending redraw operations
      (like FlushRedisplay) and capturing the screen contents correctly.

      @unorderedList(
        @item(@italic(When we use OpenGL double buffer), we do something like

@longCode(#
  EventBeforeDraw;
  EventDraw;
  KambiGLUtils.SaveScreenXxx_noflush(..,GL_BACK);
#)

          This draws to the back buffer and captures it's contents,
          which is reliable.)

        @item(@italic(When we do not use OpenGL double buffer),
          we do something like

@longCode(#
  FlushRedisplay;
  KambiGLUtils.SaveScreenXxx_noflush(..,GL_FRONT);
#)

          This isn't absolutely reliable. Read
          KambiGLUtils.SaveScreenXxx_noflush docs, and OpenGL FAQ:
          capturing the front buffer contents is generally not reliable
          with OpenGL.)
      )

      @groupBegin }
    procedure SaveScreen(const fname: string); overload;
    function SaveScreen: TRGBImage; overload;
    { Saves screen, making sure Image width is a multiple of 4 on buggy Radeon
      drivers. The meaningful image width is equal to window's @link(Width). }
    function SaveAlignedScreen: TRGBImage;
    function SaveScreen_ToDisplayList: TGLuint; overload;
    { @groupEnd }

    function SaveScreen(
      const xpos, ypos, SavedAreaWidth,
        SavedAreaHeight: integer): TRGBImage; overload;
    function SaveScreen_ToDisplayList(
      const xpos, ypos, SavedAreaWidth,
        SavedAreaHeight: integer): TGLuint; overload;

    { Asks and saves current screenshot.
      Asks user where to save the file (using @link(FileDialog),
      as default filename taking ProposedFname).
      If user accepts calls Window.SaveScreen.
      In case of problems with saving, shows a dialog (doesn't raise exception). }
    procedure SaveScreenDialog(ProposedFileName: string);

    { @groupbegin

      Methods for simply saving and restoring value of all OnXxx
      callbacks (with the exception of OnOpen, OnOpenList and
      OnClose, OnCloseList).

      @seealso DefaultCallbacksState }
    function GetCallbacksState: TGLWindowCallbacks;
    procedure SetCallbacksState(const Callbacks: TGLWindowCallbacks);
    { @groupend }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  public
    { Tracks which keys, characters, modifiers are pressed. }
    property Pressed: TKeysPressed read FPressed;

    { Fps -------------------------------------------------------------------- }

    { }
    property Fps: TFramesPerSecond read FFps;

    { Set Caption to WindowTitle with description of
      Fps.FrameTime and Fps.RealTime. }
    procedure FpsToCaption(const WindowTitle: string);

    { OpenAndRun stuff --------------------------------------------------------- }

    { Shortcut for Open (create and show the window with GL contex)
      and Application.Run (run the event loop). }
    procedure OpenAndRun; overload;

    { Shortcut for setting Caption, OnDraw,
      then calling Open (create and show the window with GL contex)
      and Application.Run (run the event loop). }
    procedure OpenAndRun(const ACaption: string; AOnDraw: TDrawFunc); overload;

    { Parsing parameters ------------------------------------------------------- }

    { Parse some command-line options and remove them from @link(Parameters)
      list. AllowedOptions specify which command-line options are handled.
      See [http://castle-engine.sourceforge.net/opengl_options.php] for
      documentaion what these options actually do from user's point of view.

      @definitionList(
        @itemLabel poGeometry
        @item(Handle these command-line options:
          @unorderedList(
            @itemSpacing Compact
            @item(@--fullscreen: sets FullScreen to @true.)
            @item(@--geometry: sets FullScreen to @false
              and changes @link(Width), @link(Height), @link(Left), @link(Top)
              as user wants.)
          )
        )

        @itemLabel poScreenGeometry
        @item(Handle @--fullscreen-custom: sets FullScreen and VideoResize
          to @true, initializes VideResizeWidth and VideResizeHeight
          and actually tries to change your desktop resolution by VideoChange.)

        @itemLabel poDisplay
        @item(Handle @--display: sets Application.XDisplayName under Unix.)
      )

      Multiple options of the same kind are allowed, for example two options
      @code(--fullscreen --geometry 100x100+0+0) are allowed. Each of them will
      have appropriate effect, in the above example, @--fullscreen param
      will be overridden by following @--geometry param. Such overridding
      is sometimes useful from shell scripts.

      Overloaded version with SpecifiedOptions says which command-line
      options were found and handled. For example, if poGeometry, then
      you know that user requested some window size.

      @raises(EInvalidParams When some of our options have invalid arguments.) }
    procedure ParseParameters(
      const AllowedOptions: TGLWindowParseOptions = StandardParseOptions); overload;
    procedure ParseParameters(
      const AllowedOptions: TGLWindowParseOptions;
      out SpecifiedOptions: TGLWindowParseOptions); overload;

    { Help text for options in AllowedOptions.
      The idea is that if you call @code(ParseParameters(AllowedOptions))
      in your program then you should also show your users somwhere
      (e.g. in response to "--help" option) the list of allowed
      options obtained by @code(ParseParametersHelp(AllowedOptions))
      (i.e. with the same value of AllowedOptions).

      Returned string may be multiline, but it does not contain
      the trailing newline (newline char after the last line).

      Returned help text conforms to rules in
      @code(castle_game_engine/doc/various/kambi_command_line_params.txt).

      If AddHeader then it adds text @code('Window options:' +nl).
      at the beginning. This is just a small thing that allows you
      to comfortably use the output of this function as a whole
      paragraph (separated from the rest of your "--help" text
      by e.g. empty lines around). }
    class function ParseParametersHelp(
      const AllowedOptions: TGLWindowParseOptions;
      AddHeader: boolean): string;

    { dialog boxes using GUI ------------------------------------------------ }

    { About all dialogs:
      - Behaviour of callbacks:
        callbacks of Application and callbacks of other TGLWindow MAY be called while
        the dialog is open. Callbacks of THIS object (OnXxx) will not be
        called. You should treat XxxDialog like
          TGLMode.Create(Self, ...)
          TGLWindowState.SetStandardState
          ....
          TGLMode.Free
      - How does these dialogs look like?
        Under GTK and WinAPI backends we use native dialogs of these.
        Under Xlib and freeglut backend we simply fallback on
        GLWinMessages.Message*.
    }

    { Select a file to open or save.

      This dialog may also allow user for some typical file-management
      operations by the way (create some directories, rename some files etc.).

      Returns @true and sets FileName accordingly if user chooses some
      filename and accepts it. Returns @false if user cancels.

      @param(Title A dialog title.)

      @param(FileName Specifies default filename (path and/or name, or '' if current dir
        is the default dir and there is no default filename). Note that if you
        have to specify only path in FileName you have to end this paths with
        PathDelim (otherwise '/tmp/blah' would not be clear: whether it's
        filename 'blah' in '/tmp/' dir or whether it's only dir '/tmp/blah/'?).)

      @param(OpenDialog Is this an open (@true) or save (@false) file dialog.

        If OpenDialog: force the user to only choose existing
        (and readable) file. The intention is that you should be able to open
        FileName for at least reading. We may be unable to force this
        (especially the "readable" requirement),
        so you still should watch for some exceptions when opening a file
        (as is always the case when opening files, anyway).

        If not OpenDialog: allows user to select a non-existent filename.
        Still, it may try to force ExtractFilePath(FileName) to be valid,
        i.e. user may be forced to choose only filenames with existing paths.
        (But, again, no guarantees.)
        Some warning to user may be shown if FileName already exists, like
        "are you sure you want to overwrite this file?".
        The intention is that you should be able to open FileName for writing.)

      @param(FileFilters A set of file filters to present to user.
        Pass @nil (default) if you do not want to use file file filters,
        so user will just always see everything. An overloaded version
        allows you to pass file filters encoded in a single string,
        this may be slightly more comfortable for call, see
        TFileFilterList.AddFiltersFromString
        for explanation how to encode filters in a string.) }
    function FileDialog(const Title: string; var FileName: string;
      OpenDialog: boolean; FileFilters: TFileFilterList = nil): boolean; overload;
    function FileDialog(const Title: string; var FileName: string;
      OpenDialog: boolean; const FileFilters: string): boolean; overload;

    { Shows a dialog window allowing user to choose an RGB color.
      Initial value of Color specifies initial RGB values proposed to the user.
      If user accepts, returns true and sets Color accordingly, else
      returns false (and does not modify Color).

      @groupBegin }
    function ColorDialog(var Color: TVector3Single): boolean;
    function ColorDialog(var Color: TVector3Byte): boolean;
    { @groupEnd }

    { Simple "OK" dialog box. }
    procedure MessageOK(const S: string; const MessageType: TGLWindowMessageType);

    { Simple yes/no question dialog box. }
    function MessageYesNo(const S: string;
      const MessageType: TGLWindowMessageType = mtQuestion): boolean;
  end;

  { Window with OpenGL context and some functionality typically useful
    for simple demo programs.

    The additional "demo" functionality
    is purely optional and may be turned off by appropriate properties.
    And, for larger non-demo programs, I would advice to @italic(not)
    use features of this class. For example, by default this allows
    user to close a window by the Escape key. This is comfortable
    for small demo programs, but it's too accident-prone for large programs
    (when you may prefer to ask user for confirmation, maybe save some game
    and such).

    Call SetDemoOptions method to be forced to configure all "demo" options.
    By default they are all off.

    It also always turns on FPS calculation (Fps.Active), regardless
    of "demo" options. FPS calculation is used for various, also non-debugging,
    features (like time-based animation) so it's generally always wanted. }
  TGLWindowDemo = class(TGLWindow)
  private
    wLeft, wTop, wWidth, wHeight: integer;
    { Are we in the middle of fullscreen swap. }
    DuringSwapFullScreen: boolean;
    lastFpsOutputTick: DWORD;
    FFpsBaseCaption: string;
    FFpsShowOnCaption: boolean;
    FSwapFullScreen_Key: TKey;
    FClose_CharKey: char;
    FFpsCaptionUpdateInterval: TMilisecTime;
    procedure SetFpsBaseCaption(const Value: string);
  public
    { Show current frames per second on window caption.
      You can modify this property only @italic(before calling @link(Open).) }
    property FpsShowOnCaption: boolean
      read FFpsShowOnCaption write FFpsShowOnCaption default false;

    { Key to use to switch between FullScreen and not FullScreen.
      Set to K_None (default) to disable this functionality.
      Suggested value to enable this functionality is K_F11, this is consistent
      will fullscreen key in other programs.
      You can freely modify it at any time, even after calling @link(Open).

      The fullscreen is switched by closing it, changing @link(FullScreen)
      property and opening it again. So be sure to have good OnOpen / OnClose
      implementations: you have to be able to recreate in OnOpen everything
      that was released in OnClose. }
    property SwapFullScreen_Key: TKey
      read FSwapFullScreen_Key write FSwapFullScreen_Key default K_None;

    { Key to use to close the window.
      Set to #0 (default) to disable this functionality.
      Suggested value to enable this functionality is CharEscape.
      You can freely modify it at any time, even after calling @link(Open). }
    property Close_CharKey: char
      read FClose_CharKey write FClose_CharKey default #0;

    { Caption prefix to use when you have FpsShowOnCaption = @true.
      When FpsShowOnCaption = @true, you should not set Caption directly,
      set only this property and leave to us setting final Caption.

      FpsBaseCaption will be initialized from Caption at EventOpen. }
    property FpsBaseCaption: string read FFpsBaseCaption write SetFpsBaseCaption;

    { The amount of time (in miliseconds) between updating Caption
      with current FPS value. Used when FpsShowOnCaption.

      Note that updating Caption of the window too often @italic(may) cause
      a significant FPS dropdown, in other words: don't set this to too small value.
      I once used here value 200. It's 5 times per second,
      this didn't seem too often, until once I checked my program
      with this turned off and found that my program runs now
      much faster (you can see that looking at FpsRealTime
      (FpsFrameTime does not change)).

      That's why I use here quite big value by default,
      DefaultFpsCaptionUpdateInterval.

      If you really want to show FPS counts updated more constantly,
      you should display them each frame as a text in OpenGL
      (like I do in view3dscene). }
    property FpsCaptionUpdateInterval: TMilisecTime
      read FFpsCaptionUpdateInterval write FFpsCaptionUpdateInterval
      default DefaultFpsCaptionUpdateInterval;

    procedure SwapFullScreen;

    procedure EventOpen; override;
    procedure EventKeyDown(Key: TKey; c: char); override;
    procedure EventIdle; override;
    function AllowSuspendForInput: boolean; override;

    procedure SetDemoOptions(ASwapFullScreen_Key: TKey;
      AClose_CharKey: char;
      AFpsShowOnCaption: boolean);

    constructor Create(AOwner: TComponent); override;
  end;

  { OpenGL window keeping a @link(Controls) list. This allows you to
    trivially add to the window any TUIControl descendants.

    We pass our inputs (mouse / key events) to the top-most
    (that is, first on the @link(Controls) list) control under the current mouse position
    (we check control's PositionInside method for this).
    As long as the event is not handled,
    we look for next controls under the mouse position.
    Only if no control handled the event, we pass it to the inherited
    EventXxx method, which calls normal window callbacks OnKeyDown etc.

    We also call other methods on every control,
    like TUIControl.Idle, TUIControl.Draw2D, TUIControl.WindowResize.

    We use OnVisibleChange event of our controls to make
    PostRedisplay when something visible changed. If you want to use
    OnVisibleChange for other purposes, you can reassign OnVisibleChange
    yourself. This window will only change OnVisibleChange from @nil
    to it's own internal callback (when adding a control),
    and from it's own internal callback to @nil (when removing a control).
    This means that if you assign OnVisibleChange callback to your own
    method --- window will not touch it anymore.

    TCamera descendants can be treated like any other TUIControl,
    that is you can add them directly to the @link(Controls) list.
    Note that usually, when using TKamSceneManager, you should only
    assign camera to TKamSceneManager.Camera, so most programs
    @italic(should not) add their TCamera intances directly to the
    Controls list. }
  TGLUIWindow = class(TGLWindowDemo, IUIContainer)
  private
    FControls: TUIControlList;
    FUseControls: boolean;
    FOnDrawStyle: TUIControlDrawStyle;
    FFocus: TUIControl;
    FTooltipDelay: TMilisecTime;
    FTooltipDistance: Cardinal;
    FTooltipVisible: boolean;
    FTooltipX, FTooltipY: Integer;
    LastPositionForTooltip: boolean;
    LastPositionForTooltipX, LastPositionForTooltipY: Integer;
    LastPositionForTooltipTime: TKamTimerResult;
    procedure ControlsVisibleChange(Sender: TObject);
    procedure SetUseControls(const Value: boolean);
    procedure UpdateFocusAndMouseCursor;
    function GetTooltipX: Integer;
    function GetTooltipY: Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    { Enable @link(Controls) list processing.

      @italic(Messing with this is very dangerous), that's why it's
      visibility is only protected (although could be even pubilshed, technically).
      This makes all controls miss all their events, including some critical
      notification events like TUIControl.GLContextOpen, TUIControl.GLContextClose,
      TUIControl.ContainerResize.

      You can reliably only turn this off temporarily, when you know that
      no events (or at least no meaningful events, like resize or control
      add/remove) will reach the window during this time. }
    property UseControls: boolean
      read FUseControls write SetUseControls default true;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Controls listening for user input (keyboard / mouse) to this window.

      Usually you explicitly add / delete controls to this list.
      Also, freeing the control that is on this list
      automatically removes it from this list (using the TComponent.Notification
      mechanism).

      Controls on the list should be specified in front-to-back order.
      That is, controls at the beginning of this list are first to catch
      some events, and are rendered as the last ones (to cover controls
      beneath them). }
    property Controls: TUIControlList read FControls;

    { Returns the control that should receive input events first,
      or @nil if none. More precisely, this is the first on Controls
      list that is enabled and under the mouse cursor.
      @nil is returned when there's no enabled control under the mouse cursor,
      or when UseControls = @false. }
    property Focus: TUIControl read FFocus;

    { How OnDraw callback fits within various Draw methods of our
      @link(Controls).

      @unorderedList(
        @item(dsNone means that OnDraw is called at the end,
          after all our @link(Controls) are drawn.

          OpenGL projection matrix is not modified (so projection
          is whatever you set yourself, by EventResize, OnResize,
          or whatever TKamSceneManager set for you).

          Note that the interpretation of dsNone is different than for
          TUIControl.DrawStyle: for TUIControl.DrawStyle, dsNone
          means "do not draw". For OnDrawStyle property,
          dsNone means "draw at the end without any tricks".

          This is suitable if you want to draw something over other
          controls, and you want to set projection yourself (or use
          the current projection, whatever it is).)

        @item(ds2D means that OnDraw is also called at the end,
          after all our @link(Controls) are drawn. But this time
          we're called within 2D orthographic projection,
          the same as set for TUIControl.DrawStyle = ds2D.

          This is suitable if you want to draw 2D contents,
          and our simple 2D orthographic projection suits you.)

        @item(ds3D means that OnDraw is called after all other
          @link(Controls) with ds3D draw style, but before any 2D
          controls.

          OpenGL projection matrix is not modified (so projection
          is whatever you set yourself, by EventResize, OnResize,
          or whatever TKamSceneManager set for you).

          This is suitable if you want to draw something 3D,
          that may be later covered by 2D controls.)
      )
    }
    property OnDrawStyle: TUIControlDrawStyle
      read FOnDrawStyle write FOnDrawStyle default dsNone;

    property TooltipDelay: TMilisecTime read FTooltipDelay write FTooltipDelay
      default DefaultTooltipDelay;
    property TooltipDistance: Cardinal read FTooltipDistance write FTooltipDistance
      default DefaultTooltipDistance;

    { When the tooltip should be shown (mouse hovers over a control
      with a tooltip) then the TooltipVisible is set to @true,
      and TooltipX, TooltipY indicate left-bottom suggested position
      of the tooltip.

      The tooltip is only detected when TUIControl.TooltipStyle <> dsNone.
      See TUIControl.TooltipStyle and TUIControl.DrawTooltip.
      For simple purposes just set TKamGLFontControl.Tooltip to something
      non-empty.
      @groupBegin }
    property TooltipVisible: boolean read FTooltipVisible;
    property TooltipX: Integer read FTooltipX;
    property TooltipY: Integer read FTooltipY;
    { @groupEnd }

    procedure EventOpen; override;
    procedure EventKeyDown(Key: TKey; Ch: char); override;
    procedure EventKeyUp(Key: TKey; Ch: char); override;
    procedure EventIdle; override;
    procedure EventMouseDown(Button: TMouseButton); override;
    procedure EventMouseUp(Button: TMouseButton); override;
    procedure EventMouseWheel(const Scroll: Single; const Vertical: boolean); override;
    procedure EventMouseMove(NewX, NewY: Integer); override;
    function AllowSuspendForInput: boolean; override;
    procedure EventBeforeDraw; override;
    procedure EventDraw; override;
    procedure EventResize; override;
    procedure EventClose; override;
  end;

  { Deprecated name for TGLUIWindow. @deprecated }
  TGLWindowNavigated = TGLUIWindow;

  TGLWindowList = class(specialize TFPGObjectList<TGLWindow>)
  private
    { Call wszystkie OnIdle / OnTimer for all windows on this list.
      Using Application.OpenWindows.DoIdle / DoTimer  is a simplest
      way for GLWindow backend to handle these events.
      @groupBegin }
    procedure DoIdle;
    procedure DoTimer;
    { @groupEnd }
  public
    { Simply calls PostRedisplay on all items. }
    procedure PostRedisplay;
  end;

  { Application, managing all open TGLWindow (OpenGL windows).
    This tracks all open instances of TGLWindow
    and implements message loop. It also handles some global tasks
    like managing the screen (changing current screen resolution and/or
    bit depth etc.)

    The only instance of this class should be in @link(Application) variable.
    Don't create any other instances of class TGLApplication, there's no
    point in doing that. }
  TGLApplication = class(TComponent)

  { Include GLWindow-backend-specific parts of
    TGLApplication class. Rules and comments that apply here are
    the same as in analogous place at TGLWindow class,
    when read_tglwindow_interface is defined. }

  {$define read_tglwindowmanager_interface}
  {$I glwindow_backend.inc}
  {$undef read_tglwindowmanager_interface}

  private
    FOnIdle :TIdleFunc;
    FOnTimer :TProcedure;
    FTimerMilisec :Cardinal;
    FVideoColorBits: integer;
    FVideoFrequency: Cardinal;
    { Current window with OpenGL context active.
      Update in TGLWindow.MakeCurrent, also TGLWindow.Close. }
    Current: TGLWindow;

    FOpenWindows: TGLWindowList;
    function GetOpenWindows(Index: integer): TGLWindow;

    { Add new item to OpenWindows.
      Windows must not be already on OpenWindows list. }
    procedure OpenWindowsAdd(Window: TGLWindow);

    { Delete window from OpenWindows.

      glwin don't have to be on the OpenWindows list. If it is not, this
      method is NOOP. This is useful when this is called from TGLWindow.Close
      because TGLWindow.Close should work even for partially constructed
      Windows.

      If glwin was present on OpenWindows and after removing glwin
      OpenWindowsCount = 0 and QuitWhenLastWindowClosed then it calls Quit. }
    procedure OpenWindowsRemove(Window: TGLWindow; QuitWhenLastWindowClosed: boolean);

    { Find window on the OpenWindows list. Returns index, or -1 if not found. }
    function FindWindow(Window: TGLWindow): integer;

    procedure CreateBackend;
    procedure DestroyBackend;

    { The GLWindow-backend specific part of Quit method implementation.
      In non-backend-specific part of Quit we already closed all windows,
      so this will be called only when OpenWindowsCount = 0.
      So the only things you have to do here is:
      - make ProcessMessage to return false
      - terminate Run method, if it works (if Run is implemented using
        "while ProcessMessage do ;" then the first condition is all that is
        really needed)

        Note: it is NOT guaranteed that we are inside Run method
        when calling this function, i.e. it may be the case that noone ever
        called Application.Run (e.g. in @code(kambi_lines) game, where everything is done
        using while ProcessMessages do ...), but still it must be valid to call
        Quit and QuitWhenNoOpenWindows in such situation.
        Also it must be valid to call Quit and QuitWhenNoOpenWindows more
        then once. }
    procedure QuitWhenNoOpenWindows;

    { This simply checks Assigned(FOnIdle) and only then calls FOnIdle.
      ALWAYS use this method instead of directly calling FOnIdle. }
    procedure DoSelfIdle;

    { Same as DoSelfIdle, but here with FOnTimer. }
    procedure DoSelfTimer;

    { Something useful for some GLWindow backends. This will implement
      (in a simple way) calling of DoSelfOpen and OpenWindows.DoTimer.

      Declare in TGLApplication some variable like
        LastDoTimerTime: TMilisecTime
      initialized to 0. Then just call very often (probably at the same time
      you're calling DoSelfIdle)
        MaybeDoTimer(LastDoTimerTime);
      This will take care of calling DoSelfTimer and OpenWindows.DoTimer
      at the appropriate times. It will use and update LastDoTimerTime,
      you shouldn't read or write LastDoTimerTime yourself. }
    procedure MaybeDoTimer(var ALastDoTimerTime: TMilisecTime);

    { Just like TGLWindow.AllowSuspendForInput, except this is for
      the whole Application. Returns @true only if all open
      windows allow it, and we do not have OnIdle and OnTimer. }
    function AllowSuspendForInput: boolean;
  public
    { If VideoResize, then next VideoChange call will
      try to resize the screen to given VideoResizeWidth /
      VideoResizeHeight. Otherwise, next TryVideoChange and VideoChange will
      use default screen size.
      @groupBegin }
    VideoResize : boolean;
    VideoResizeWidth,
    VideoResizeheight : integer;
    { @groupEnd }

    { Color bits per pixel that will be set by next VideoChange call,
      and that are tried to be used at TGLWindow.Open.
      Zero means that system default is used. }
    property VideoColorBits: integer read FVideoColorBits write FVideoColorBits default 0;

    { Video frequency to set in next VideoChange call.
      Leave as 0 to use system default. }
    property VideoFrequency: Cardinal read FVideoFrequency write FVideoFrequency default 0;

    { Describe the changes recorded in variables VideoXxx,
      used by VideoChange and TryVideoChange.
      This is a multiline string, each line is indented by 2 spaces,
      always ends with KambiUtils.NL. }
    function VideoSettingsDescribe: string;

    { Change the screen size, color bits and such, following the directions
      you set in VideoColorBits, VideoResize,
      VideoResizeWidth / VideoResizeHeight, and VideoFrequency variables.
      Returns @true if success. }
    function TryVideoChange: boolean;

    { Change the screen size, color bits and such, following the directions
      you set in VideoColorBits, VideoResize,
      VideoResizeWidth / VideoResizeHeight, and VideoFrequency variables.
      This actually just calls TryVideoChange and checks the result.

      If not success: if OnErrorWarnUserAndContinue then we'll display
      a warning and continue. If not OnErrorWarnUserAndContinue then
      we'll raise an Exception.

      @raises(Exception If video mode change failed,
        and OnErrorWarnUserAndContinue = false.) }
    procedure VideoChange(OnErrorWarnUserAndContinue: boolean);

    { Return default screen video mode.
      If you never called TryVideoChange (with success), then this does nothing.
      This is automatically called in Application.Destroy,
      so at finalization of this unit. This way your game nicely restores
      screen resolution for user. }
    procedure VideoReset;

    function ScreenHeight: integer;
    function ScreenWidth: integer;

    { List of all open windows.
      @groupBegin }
    function OpenWindowsCount: integer;
    property OpenWindows[Index: integer]: TGLWindow read GetOpenWindows;
    { @groupEnd }

    { Called all the time.
      At least as regularly as OnDraw, see TGLWindow.OnIdle. }
    property OnIdle: TIdleFunc read FOnIdle write FOnIdle;

    { Event called approximately after each TimerMilisec miliseconds.
      The actual delay may be larger than TimerMilisec miliseconds,
      depending on how the program (and OS) is busy.

      You can of course change TimerMilisec (and OnTimer) even
      when some windows are already open.
      @groupBegin }
    property OnTimer: TProcedure read FOnTimer write FOnTimer;
    property TimerMilisec: Cardinal read FTimerMilisec write FTimerMilisec default 1000;
    { @groupEnd }

    { Process some messages from the window system.
      During this, messages are processed and passed
      to the appropriate TGLWindow windows, calling appropriate methods
      and callbacks like TGLWindow.OnDraw, TGLWindow.OnIdle and many others.

      This method is crucial for implementing modal dialog boxes and such,
      generally any kind of "display something until something happens".
      You want to control then yourself the event loop, like

@longCode(#
  while not SomethingHappened do Application.ProcessMessages;
#)

      Commonly this is used together with TGLWindow state push / pop
      routines in GLWinModes. They allow you to temporary replace
      all TGLWindow callbacks with new ones, and later restore the old ones.

      ProcessMessages returns @true if we should continue, that is
      if @link(Quit) method was not called (directly or by closing
      the last window). If you want to check it (if your state
      allows the user at all to close the application during modal box or such)
      you can do:

@longCode(#
  while not SomethingHappened do
    if not Application.ProcessMessage then break;
#)

      Notes:
      @unorderedList(
        @item(Not all ProcessMessage calls cause redraw, even if redraw
          is requested by PostRedisplay. When we have messages to process,
          we generally don't call redraw or OnIdle.)

        @item(ProcessMessage may hang, waiting for an event,
          if AllowSuspend and if OnIdle is not assigned and some other
          conditions. This way we wait for the next window system message
          in a nice way, without eating CPU just for a loop that continously
          tests for new event (such bad loop is called "busy waiting").

          If you make some processing in your event loop, for example
          you load some resources or you raytrace some image
          (examples used by GLProgress or RaytraceToWindow units),
          then you surely want to pass AllowSuspend = false.
          You want in such case to make ProcessMessage quickly return
          control to your code, so you can continue whatever you're doing.

          If your event loop simply waits for some condition,
          for example @code(repeat ProcessMessage(AllowSuspend) until B)
          then you can give AllowSuspend = true if the condition B may
          only be changed by some event (for example, you wait until
          user presses a key). If the condition B may be changed
          without a window system event (for example, you wait until
          5 minutes pass) then AllowSuspend must be false.
        )
      )
    }
    function ProcessMessage(AllowSuspend: boolean): boolean;

    { Processes @italic(all) pending messages.

      Contrast this with ProcessMessage method, that processes only a single
      event. Or no event at all (when no events were pending and
      AllowSuspend = @false). This means that after calling ProcessMessage
      once, you may have many messages left in the queue (especially
      mouse move together with key presses typically makes a lot of
      events). So it's not good to use if you want to react timely to
      some user requests, e.g. when you do something time-consuming
      and allow user to break the task with Escape key.

      ProcessAllMessages is like
      calling in a loop something like ProcessMessage(false), ends when
      ProcessMessage didn't process any message (it's internally returned
      by ProcessMessage2) or when quit was called (or last window closed).

      So ProcessAllMessages makes sure we have processed all pending events,
      thus we are up-to-date with window system requests. }
    function ProcessAllMessages: boolean;

    { Close all open windows, make ProcessMessage return @false,
      finish the @link(Run) method (if working), and thus finish the
      application work. }
    procedure Quit;

    { Run the program using TGLWindow, by doing the event loop.
      Think of it as just a shortcut for "while ProcessMessage do ;".

      Note that this does nothing if OpenWindowsCount = 0, that is there
      are no open windows. Besides the obvious reason (you didn't call
      TGLWindow.Open on any window...) this may also happen if you called
      Close (or Application.Quit) from your window OnOpen / OnResize callback.
      In such case no event would probably reach
      our program, and user would have no chance to quit, so Run just refuses
      to work and exits immediately without any error. }
    procedure Run;

    function BackendName: string;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  { One global instance of TGLApplication.

    Don't change value of this variable, don't Free this object.
    This will be handled in initialization / finalization of this module.
    Many things in this unit, also in TGLWindow class implementation,
    depend on having this variable present all the time. }
  Application: TGLApplication;

const
  DefaultCallbacksState: TGLWindowCallbacks =
  ( MouseMove: nil; MouseDown: nil; MouseUp: nil; MouseWheel: nil;
    KeyDown: nil; KeyUp: nil;
    BeforeDraw: nil; Draw: nil; CloseQuery: nil; Idle: nil; Timer: nil; Resize: nil;
    MenuCommand: nil);

{ A simple TGLWindow.OnResize callback implementation, that sets 2D projection.
  You can use it like @code(Window.OnResize := Resize2D;) or just by calling
  it directly from your OnResize callback.

  It does
@longCode(#
  glViewport(0, 0, Window.Width, Window.Height);
  ProjectionGLOrtho(0, Window.Width, 0, Window.Height);
#) }
procedure Resize2D(Window: TGLWindow);

{$undef read_interface}

{$define read_interface_2}
{$i glwindowmenu.inc}
{$undef read_interface_2}

implementation

uses KambiParameters, KambiLog, GLImages, GLVersionUnit
  { using here GLWinModes/Messages makes recursive uses,
    but it's needed for FileDialog }
  {$ifdef GLWINDOW_GTK_ANY}, GLWinModes {$endif}
  {$ifdef GLWINDOW_WINAPI}, GLWinModes, GLWindowWinAPIMenu {$endif}
  {$ifdef GLWINDOW_XLIB}, GLWinMessages {$endif}
  {$ifdef GLWINDOW_GLUT}, GLWinMessages {$endif};

{$define read_implementation}

{$I glwindowmenu.inc}
{$I glwindow_backend.inc}

{ TGLWindowFuncList ------------------------------------------------ }

procedure TGLWindowFuncList.ExecuteAll(Window: TGLwindow);
var i: integer;
begin
 for i := 0 to Count-1 do
  if Assigned(L[i]) then
  begin
   L[i](Window);
  end;
end;

{ ----------------------------------------------------------------------------
  niezalezne od GLWINDOW_xxx rzeczy TGLWindow }

constructor TGLWindow.Create(AOwner: TComponent);
begin
 inherited;
 FOnOpenList := TGLWindowFuncList.Create;
 FOnCloseList := TGLWindowFuncList.Create;
 FClosed := true;
 FWidth  := GLWindowDefaultSize;
 FHeight := GLWindowDefaultSize;
 FLeft  := GLWindowPositionCenter;
 FTop   := GLWindowPositionCenter;
 FDoubleBuffer := true;
 FCaption := ProgramName;
 FResizeAllowed := raAllowed;
 minWidth := 100;  maxWidth := 4000;
 minHeight := 100; maxHeight := 4000;
 DepthBufferBits := DefaultDepthBufferBits;
 FCursor := mcDefault;
 FMultiSampling := 1;
 FVisible := true;
 OwnsMainMenu := true;
 FPressed := TKeysPressed.Create;
 FFps := TFramesPerSecond.Create;

 CreateBackend;
end;

destructor TGLWindow.Destroy;
begin
 Close; { <- This will be ignored if already Closed }

 if OwnsMainMenu then
   FreeAndNil(FMainMenu) else
 if FMainMenu <> nil then
 begin
   FMainMenu.ParentWindow := nil; { clear Self from FMainMenu.ParentWindow }
   FMainMenu := nil;
 end;

 FreeAndNil(FFps);
 FreeAndNil(FPressed);
 FreeAndNil(FOnOpenList);
 FreeAndNil(FOnCloseList);
 inherited;
end;

procedure TGLWindow.Open;
begin
 if not FClosed then Exit;

 try
  { Adjust Left/Top/Width/Height/FullScreen as needed.
    Note: calculations below try to correct window geometry but they
    can fail to foresee some things. In particular, they do not take
    into account a potential menu bar that may be visible when MainMenu <> nil.
    E.g., when MainMenu <> nil and implementation supports MainMenu as
    menu bar (GTK and WINAPI implementations) and FullScreen then
    the actual OpenGL window size will NOT match ScreenWidth/Height,
    it will be slightly smaller (menu bar takes some space).
  }
  if FFullscreen and
    ((not between(Application.ScreenWidth, minWidth, maxWidth)) or
     (not between(Application.ScreenHeight, minHeight, maxHeight)) or
     ((ResizeAllowed = raNotAllowed) and
       ((Application.ScreenWidth <> Width) or (Application.ScreenHeight <> Height)) )
    ) then
   FFullscreen := false;

  if FFullScreen then
  begin
   fleft := 0;
   ftop := 0;
   fwidth := Application.ScreenWidth;
   fheight := Application.ScreenHeight;
  end else
  begin
   if Width  = GLWindowDefaultSize then FWidth  := Application.ScreenWidth  * 4 div 5;
   if Height = GLWindowDefaultSize then FHeight := Application.ScreenHeight * 4 div 5;

   Clamp(fwidth, minWidth, maxWidth);
   Clamp(fheight, minHeight, maxHeight);

   if left = GLWindowPositionCenter then fleft := (Application.ScreenWidth-width) div 2;
   if top  = GLWindowPositionCenter then ftop := (Application.ScreenHeight-height) div 2;
  end;

  { reset some window state variables }
  Pressed.Clear;
  fmousePressed := [];
  EventOpenCalled := false;

  { Set Closed to false.
    W tym miejscu, przed OpenBackend i wywolaniem  OnOpen + OnResize, bo
   - te rzeczy moga rzucic wyjatki a w reakcji na wyjatek
     chcemy wywolac Close ktore do dzialania wymaga aby bylo not FClosed. }
  FClosed := false;

  { Najwazniejsze : zrob to co implementacja zrobic musi.
    Mozesz stad smialo wywolywac DoResize, beda ignorowane dzieki temu
    ze EventOpenCalled = false.  }
  OpenBackend;

  { Do MakeCurrent before glViewport and EventOpen. }
  MakeCurrent;

  LoadAllExtensions;

  if Log then
    WritelnLogMultiline('OpenGL context initialization', GLInformationString);

  { zsynchronizuj glViewport z naszymi Width/Height (bo one moga sie roznic od
    rzeczywistych rozmiarow okienka) }
  glViewport(0, 0, Width, Height);

  { call first EventOpen and EventResize. Zwroc uwage ze te DoResize i DoOpen
    MUSZA byc wykonane na samym koncu procedury Open - jak juz wszystko inne
    zostalo wykonane. Wszystko po to ze juz w pierwszym OnOpen lub OnResize
    moze zostac wywolane Application.ProcessMessages np. w wyniku wywolania w OnOpen
    GLWinMessages.MessageOk. }
  EventOpenCalled := true;
  EventOpen;

  { Check Closed here, in case OnOpen closed the window
    (by calling Application.Quit (that calls Close on all windows) or direct Close
    on this window). Note that Close calls
    CloseBackend and generally has *immediate* effect --- that's why
    doing anything more with window now (like MakeCurrent) would be wrong. }
  if Closed then Exit;

  DoResize(FWidth, FHeight, true);

  { Check Closed here, in case OnResize closed the window. }
  if Closed then Exit;

  { to be SURE that current window's gl context is active,
    even if someone in EventOpen changed current gl context }
  MakeCurrent;
 except
  Close; raise;
 end;
end;

procedure TGLWindow.OpenOptionalMultiSamplingAndStencil(
  const MultiSamplingOff, StencilOff: TGLContextLoweredFunc);
const
  SFailureMessage =
    'GL context init failed with message "%s".' + NL +
    '%s turned off, trying to init once again';
  STurnedOffMultiSampling = 'Multi-sampling (anti-aliasing)';
  STurnedOffStencil = 'Stencil buffer (shadow volumes)';

  procedure TryOpenContext;
  begin
    Open;
  end;

  procedure TryOpenContext_Shadows;
  begin
    try
      Open;
    except
      on E: EGLContextNotPossible do
      begin
        if StencilBufferBits > 0 then
        begin
          StencilBufferBits := 0;
          if Assigned(StencilOff) then
            StencilOff(Self, Format(SFailureMessage, [E.Message, STurnedOffStencil]));
          TryOpenContext;
        end else
          raise;
      end;
    end;
  end;

begin
  try
    Open;
  except
    on E: EGLContextNotPossible do
    begin
      if MultiSampling > 1 then
      begin
        MultiSampling := 1;
        if Assigned(MultiSamplingOff) then
          MultiSamplingOff(Self, Format(SFailureMessage, [E.Message, STurnedOffMultiSampling]));
        TryOpenContext_Shadows;
      end else
      if StencilBufferBits > 0 then
      begin
        StencilBufferBits := 0;
        if Assigned(StencilOff) then
          StencilOff(Self, Format(SFailureMessage, [E.Message, STurnedOffStencil]));
        TryOpenContext;
      end else
        raise;
    end;
  end;
end;

procedure TGLWindow.CloseError(const error: string);
begin
 if closeerrors <> '' then
  closeerrors := closeerrors+nl+error else
  closeerrors := error
end;

procedure TGLWindow.Close(QuitWhenLastWindowClosed: boolean);
begin
 if FClosed then Exit;

 try
  if EventOpenCalled then
  begin
   MakeCurrent;
   EventClose;
  end;
 finally
  closeerrors := '';
  CloseBackend;

  FClosed := true;

  Application.Current := nil;

  { Note: it is important here that OpenWindowsRemove will not raise any error
    if Self is not on OpenWindows list. This is useful if the window was partially
    constructed.

    E.g. when StencilBufferBits was too high and OpenBackend
    method raised an exception EGLContextNotPossible. Then this method, Close,
    is called, but Self is not on OpenWindows list. And this fact should not be
    reported as an error -- error is EGLContextNotPossible ! }
  Application.OpenWindowsRemove(Self, QuitWhenLastWindowClosed);

  { dopiero tutaj rzucamy wyjatek. Zawsze bedziemy probowac wykonac cala
    powyzsza procedure, w szczegolnosci cale CloseImplDepened,
    bez wzgledu na bledy - a ewentualny wyjatek rzucimy dopiero teraz.}
  if closeerrors <> '' then
   raise Exception.Create('Error(errors?) while trying to close GlWindow : '+nl+closeerrors);
 end;
end;

procedure TGLWindow.MakeCurrent;
begin
  { Calling BackendMakeCurrent is done very often (before every event,
    so a couple of times for every frame). And usually it's useless,
    as most games have only 1 open window. }
  if Application.Current <> Self then
  begin
    BackendMakeCurrent;
    Application.Current := Self;
  end;
end;

procedure TGLWindow.SetAutoRedisplay(value: boolean);
begin
 fAutoRedisplay := value;
 if value and (not Closed) then PostRedisplay;
end;

procedure TGLWindow.ReleaseAllKeysAndMouse;
var k: TKey;
    mb: TMouseButton;
    {$ifdef GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN}
    mk: TModifierKey;
    b: boolean;
    {$endif}
begin
 {$ifdef GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN}
 { When GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN, I *HAVE* to use below
   SetPrivateModifiersDown. It would be an error to do DoKeyUp(K_Ctrl)
   directly when GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN, instead we have to
   use SetPrivateModifiersDown(mkCtrl, ...).
   This is the only way to make values in PrivateModifiersDown[]
   and Pressed[] arrays consistent. }
 for mk := Low(mk) to High(mk) do
  for b := Low(b) to High(b) do
   SetPrivateModifiersDown(mk, b, false);
 {$endif GLWINDOW_USE_PRIVATE_MODIFIERS_DOWN}

 { Since we do DoKeyUp, this should also take care of Characters. }

 for k := Low(k) to High(k) do
  if Pressed[k] then DoKeyUp(k);

 for mb := Low(mb) to High(mb) do if mb in MousePressed then
  DoMouseUp(MouseX, MouseY, mb);
end;

{ wszystkie zdarzenia TGLWindow - opakowujace je procedury DoXxx ktore
  robia wszystkie rzeczy niezalezne od implementacji dla danego zdarzenia
  (m.in. wywoluja EventXxx ktore m.in. wywoluje OnXxx jesli jest assigned).
  Implementacje GLWindow powinny wywolywac te funkcje, NIE wywolywac
  bezposrednio EventXxx ani tym bardziej OnXxx !
  ------------------------------------------------------------------------------------ }

procedure TGLWindow.DoResize(AWidth, AHeight: integer; FromIndependentOpen: boolean);
begin
 { zabezpiecz sie przed
   1) glutem, ktoremu nie mamy jak powiedziec ze ResizeAllowed <> raNotAllowed
   2) Windowsem, ktory moze zresizowac nasze okno np. gdy sie nie miescimy na ekranie
   3) XWindow-Managerem ktory zawsze moze nas zresizowac, mimo ze prosimy go
      zeby tego nie robil.
   wiec pod wszystkimi trzema implementacjami musimy sprawdzic warunek ze
     albo ResizeAllowed = raAllowed albo naprawde fwidth = w itd.
   Sprawdzamy tez czy w i h sa w odpowiednim zakresie minXxx .. maxXxx.
     Oczywiscie implementacje powinny starac sie zeby nic spoza tego zakresu do nas
     nie dotarlo, ale nigdy nie ma pewnosci. Zwracam uwage, ze wymagamy aby zawsze
     minWidth > 0 i minHeight > 0 wiec jednoczesnie ponizej gwarantujemy sobie ze nie
     zachodzi sytuacja w = 0 lub h = 0.

   Apropos wywolywania DoResize(.., false) z OpenBackend:
   zabezpieczamy sie przed tym zawsze. Ale mozna tu odnotowac ze z pewnoscia
   OpenBackend moze wywolywac DoResize(.., false) w przypadku
   implementacji WINAPI i GTK.
 }

 { update FWidth, FHeight.
   Below we are explicitly forcing assertions about ResizeAllowed:
   when ResizeAllowed
     = raNotAllowed: FWidth and FHeight cannot change
     = raOnlyAtOpen: FWidth and FHeight can change only once, at first EventResize
     = raAllowed: FWidth and FHeight can change freely
 }
 if (ResizeAllowed = raAllowed) or
    ((ResizeAllowed = raOnlyAtOpen) and FromIndependentOpen) then
 begin
  FWidth := Clamped(AWidth,  MinWidth,  MaxWidth);
  FHeight := Clamped(AHeight, MinHeight, MaxHeight);
 end;

 { do not call EventResize before EventOpen (this check is needed
   because OpenBackend is allowed to call DoResize) }
 if not EventOpenCalled then Exit;

 { jezeli ResizeAllowed <> raAllowed to nie powinnismy wywolywac EventResize
   poza pierwszym razem (gdy FromIndependentOpen).
   Kazdy nastepny raz i tak bylby pozbawiony
   znaczenia, bo przeciez Width i Height i tak nie ulegly zmianie. }
 if (not FromIndependentOpen) and (ResizeAllowed <> raAllowed) then Exit;

 MakeCurrent;
 EventResize;
end;

procedure TGLWindow.DoCloseQuery;
begin
  MakeCurrent;
  if EventCloseQuery then Close;
end;

procedure TGLWindow.DoDraw;
begin
  MakeCurrent;

  EventBeforeDraw;
  if Closed then Exit; { check, in case window got closed in the event }

  Fps._RenderBegin;
  try
    EventDraw;
    if Closed then Exit; { check, in case window got closed in the event }

    if DoubleBuffer then SwapBuffers else glFlush;
    if AutoRedisplay then PostRedisplay;
  finally Fps._RenderEnd end;

  {$ifdef GLWINDOW_CHECK_GL_ERRORS_AFTER_DRAW} CheckGLErrors('End of TGLWindow.DoDraw'); {$endif}
end;

procedure TGLWindow.DoKeyDown(Key: TKey; CharKey: char);

  function SeekMatchingMenuItem: TMenuItem;

    function SeekMe(Entry: TMenuEntry): TMenuItem;
    var i: Integer;
    begin
     Result := nil;
     if Entry is TMenu then
     begin
      for i := 0 to TMenu(Entry).EntriesCount-1 do
      begin
       Result := SeekMe(TMenu(Entry).Entries[i]);
       if Result <> nil then Break;
      end;
     end else
     if (Entry is TMenuItem) and
        TMenuItem(Entry).KeyMatches(Key, CharKey) then
      Result := TMenuItem(Entry);
    end;

  begin
   if MainMenu <> nil then
    Result := SeekMe(MainMenu) else
    Result := nil;
  end;

var MatchingMI: TMenuItem;
begin
 Pressed.KeyDown(Key, CharKey);

 MatchingMI := SeekMatchingMenuItem;
 if (MainMenu <> nil) and
    MainMenu.Enabled and
    (MatchingMI <> nil) then
 begin
  if RedirectKeyDownToMenuCommand then
   DoMenuCommand(MatchingMI);
 end else
 begin
  MakeCurrent;
  EventKeyDown(Key, CharKey);
 end;
end;

procedure TGLWindow.DoKeyUp(key: TKey);
var
  C: char;
begin
  if Pressed[Key] then
  begin
    { K_None key is never pressed, DoKeyDown guarentees this }
    Assert(Key <> K_None);
    Pressed.KeyUp(Key, C);
    MakeCurrent;
    EventKeyUp(key, C);
  end;
end;

procedure TGLWindow.DoMouseMove(x, y: integer);
begin
 MakeCurrent;
 EventMouseMove(x, y);
 FMouseX := x; { odswiezamy FMouseXY dopiero PO wywolaniu EventMouseMove }
 FMouseY := y;
end;

procedure TGLWindow.DoMouseDown(x, y: integer; btn: TMouseButton);
begin
 FMouseX := x;
 FMouseY := y;
 Include(FMousePressed, btn);
 MakeCurrent;
 EventMouseDown(btn);
end;

procedure TGLWindow.DoMouseUp(x, y: integer; btn: TMouseButton);
begin
 FMouseX := x;
 FMouseY := y;
 Exclude(FMousePressed, btn);
 MakeCurrent;
 EventMouseUp(btn);
end;

procedure TGLWindow.DoMouseWheel(const Scroll: Single; const Vertical: boolean);
begin
  MakeCurrent;
  EventMouseWheel(Scroll, Vertical);
end;

procedure TGLWindow.DoIdle;
begin
  Fps._IdleBegin;
  MakeCurrent;
  EventIdle;
end;

procedure TGLWindow.DoTimer; begin  MakeCurrent; EventTimer end;

procedure TGLWindow.DoMenuCommand(Item: TMenuItem);
begin
 if (MainMenu <> nil) and (not MainMenu.Enabled) then Exit;

 MakeCurrent;
 if Item.DoCommand then Exit;

 { Maybe Item.DoCommand changed current OpenGL context and returned false?
   We want to be safe, so we do here MakeCurrent again. }
 MakeCurrent;
 EventMenuCommand(Item);
end;

{ funkcje EventXxx ktore sa wirtualne i sa GWARANTOWANE ze w klasie bazowej
  wywoluja po prostu OnXxx. Te funkcje moga byc pokrywane w podklasach.
  ---------------------------------------------------------------------------- }

function TGLWindow.EventCloseQuery: boolean;
const EventName = 'CloseQuery';
begin
 result := not Assigned(OnCloseQuery);
 {$I glwindow_eventbegin.inc}
 if Assigned(OnCloseQuery) then
   OnCloseQuery(Self);
 {$I glwindow_eventend.inc}
end;

procedure TGLWindow.EventOpen;                              const EventName = 'Open';       begin {$I glwindow_eventbegin.inc} if Assigned(OnOpen)        then begin OnOpen(Self);              end;   OnOpenList .ExecuteAll(Self); {$I glwindow_eventend.inc} end;
procedure TGLWindow.EventClose;                             const EventName = 'Close';      begin {$I glwindow_eventbegin.inc} if Assigned(OnClose)       then begin OnClose(Self);             end;   OnCloseList.ExecuteAll(Self); {$I glwindow_eventend.inc} end;
{$define BONUS_LOG_STRING := Format('NewSize : %d,%d', [Width, Height])}
procedure TGLWindow.EventResize;                            const EventName = 'Resize';     begin {$I glwindow_eventbegin.inc} if Assigned(OnResize)      then begin OnResize(Self);            end;   {$I glwindow_eventend.inc} end;
{$undef BONUS_LOG_STRING}
{$define BONUS_LOG_STRING := Format('Key %s, character %s (ord: %d)', [KeyToStr(Key), CharToNiceStr(c), Ord(c)])}
procedure TGLWindow.EventKeyDown(Key: TKey; C: char);       const EventName = 'KeyDown';    begin {$I glwindow_eventbegin.inc} if Assigned(OnKeyDown)     then begin OnKeyDown(Self, Key, C);   end;   {$I glwindow_eventend.inc} end;
{$undef BONUS_LOG_STRING}
{$define BONUS_LOG_STRING := Format('Key %s, character %s (ord: %d)', [KeyToStr(Key), CharToNiceStr(c), Ord(c)])}
procedure TGLWindow.EventKeyUp(key: TKey; C: char);         const EventName = 'KeyUp';      begin {$I glwindow_eventbegin.inc} if Assigned(OnKeyUp)       then begin OnKeyUp(Self, key, C);     end;   {$I glwindow_eventend.inc} end;
{$undef BONUS_LOG_STRING}
{$define BONUS_LOG_STRING := Format('Button: %s', [MouseButtonStr[btn]])}
procedure TGLWindow.EventMouseDown(btn: TMouseButton);      const EventName = 'MouseDown';  begin {$I glwindow_eventbegin.inc} if Assigned(OnMouseDown)   then begin OnMouseDown(Self, btn);    end;   {$I glwindow_eventend.inc} end;
procedure TGLWindow.EventMouseUp(btn: TMouseButton);        const EventName = 'MouseUp';    begin {$I glwindow_eventbegin.inc} if Assigned(OnMouseUp)     then begin OnMouseUp(Self, btn);      end;   {$I glwindow_eventend.inc} end;
{$undef BONUS_LOG_STRING}
procedure TGLWindow.EventMouseWheel(const Scroll: Single; const Vertical: boolean);  const EventName = 'MouseWheel'; begin {$I glwindow_eventbegin.inc} if Assigned(OnMouseWheel)  then begin OnMouseWheel(Self, Scroll, Vertical); end;{$I glwindow_eventend.inc} end;
procedure TGLWindow.EventMenuCommand(Item: TMenuItem);      const EventName = 'MenuCommand';begin {$I glwindow_eventbegin.inc} if Assigned(OnMenuCommand) then begin OnMenuCommand(Self, Item); end;   {$I glwindow_eventend.inc} end;

{ Events below happen so often, that they are logged only when
  GLWINDOW_EVENTS_LOG_ALL is defined.

  For glwindow_eventbegin/end.inc to work, we do here a little trick
  with GLWINDOW_EVENTS_LOG symbol: undefine GLWINDOW_EVENTS_LOG temporarily if
  GLWINDOW_EVENTS_LOG_ALL not defined. }
{$ifndef GLWINDOW_EVENTS_LOG_ALL}
  {$ifdef GLWINDOW_EVENTS_LOG}
    {$define WAS_GLWINDOW_EVENTS_LOG}
    {$undef GLWINDOW_EVENTS_LOG}
  {$endif}
{$endif}

  {$define BONUS_LOG_STRING := Format('New position: %d %d', [newX, newY])}
  procedure TGLWindow.EventMouseMove(newX, newY: integer);const EventName = 'MouseMove'; begin {$I glwindow_eventbegin.inc} if Assigned(OnMouseMove) then begin OnMouseMove(Self, newX, newY); end;   {$I glwindow_eventend.inc} end;
  {$undef BONUS_LOG_STRING}

  procedure TGLWindow.EventBeforeDraw;                    const EventName = 'BeforeDraw';begin {$I glwindow_eventbegin.inc} if Assigned(OnBeforeDraw)then begin OnBeforeDraw(Self);            end;   {$I glwindow_eventend.inc} end;
  procedure TGLWindow.EventDraw;                          const EventName = 'Draw';      begin {$I glwindow_eventbegin.inc} if Assigned(OnDraw)      then begin OnDraw(Self);                  end;   {$I glwindow_eventend.inc} end;
  procedure TGLWindow.EventIdle;                          const EventName = 'Idle';      begin {$I glwindow_eventbegin.inc} if Assigned(OnIdle)      then begin OnIdle(Self);                  end;   {$I glwindow_eventend.inc} end;
  procedure TGLWindow.EventTimer;                         const EventName = 'Timer';     begin {$I glwindow_eventbegin.inc} if Assigned(OnTimer)     then begin OnTimer(Self);                 end;   {$I glwindow_eventend.inc} end;

{$ifndef GLWINDOW_EVENTS_LOG_ALL}
  {$ifdef WAS_GLWINDOW_EVENTS_LOG}
    {$define GLWINDOW_EVENTS_LOG}
  {$endif}
{$endif}

function TGLWindow.AllowSuspendForInput: boolean;
begin
 result := not (Assigned(OnIdle) or Assigned(OnTimer));
end;

{ Menu things ------------------------------------------------------------ }

procedure TGLWindow.SetMainMenu(Value: TMenu);
begin
 if MainMenu <> Value then
 begin
  if (not Closed) and ((MainMenu <> nil) <> (Value <> nil)) then
   raise EInternalError.Create('While TGLWindow is not Closed, '+
     'you can''t set MainMenu from nil to non-nil or from non-nil to nil');

  if FMainMenu <> nil then
  begin
    if not Closed then MenuFinalize;
    FMainMenu.ParentWindow := nil;
  end;

  FMainMenu := Value;

  if FMainMenu <> nil then
  begin
    FMainMenu.ParentWindow := Self;
    if not Closed then MenuInitialize;
  end;
 end;
end;

{ SaveScreen wykonane na GLWindow (robimy najpierw FlushRedisplay)
  -------------------------------------------------------------------------- }

procedure TGLWindow.SaveScreen(const fname: string);
var
  Image: TRGBImage;
begin
  Image := SaveScreen;
  try
    SaveImage(Image, fname);
  finally FreeAndNil(Image) end;
end;

function TGLWindow.SaveScreen: TRGBImage;
begin
  if DoubleBuffer then
  begin
    EventBeforeDraw;
    EventDraw;
    Result := SaveScreen_noflush(0, 0, Width, Height, GL_BACK);
  end else
  begin
    FlushRedisplay;
    Result := SaveScreen_noflush(0, 0, Width, Height, GL_FRONT);
  end;
end;

function TGLWindow.SaveAlignedScreen: TRGBImage;
begin
  if DoubleBuffer then
  begin
    EventBeforeDraw;
    EventDraw;
    Result := SaveAlignedScreen_noflush(0, 0, Width, Height, GL_BACK);
  end else
  begin
    FlushRedisplay;
    Result := SaveAlignedScreen_noflush(0, 0, Width, Height, GL_FRONT);
  end;
end;

function TGLWindow.SaveScreen(
  const xpos, ypos, SavedAreaWidth, SavedAreaHeight: integer): TRGBImage;
var
  ReadBuffer: TGLenum;
begin
  if DoubleBuffer then
  begin
    EventBeforeDraw;
    EventDraw;
    ReadBuffer := GL_BACK;
  end else
  begin
    FlushRedisplay;
    ReadBuffer := GL_FRONT;
  end;
  Result := SaveScreen_noflush(xpos, ypos,
    SavedAreaWidth, SavedAreaHeight, ReadBuffer);
end;

function TGLWindow.SaveScreen_ToDisplayList: TGLuint;
begin
  if DoubleBuffer then
  begin
    EventBeforeDraw;
    EventDraw;
    Result := SaveScreen_ToDisplayList_noflush(0, 0, Width, Height, GL_BACK);
  end else
  begin
    FlushRedisplay;
    Result := SaveScreen_ToDisplayList_noflush(0, 0, Width, Height, GL_FRONT);
  end;
end;

function TGLWindow.SaveScreen_ToDisplayList(
  const xpos, ypos, SavedAreaWidth, SavedAreaHeight: integer): TGLuint;
var
  ReadBuffer: TGLenum;
begin
  if DoubleBuffer then
  begin
    EventBeforeDraw;
    EventDraw;
    ReadBuffer := GL_BACK;
  end else
  begin
    FlushRedisplay;
    ReadBuffer := GL_FRONT;
  end;
  Result := SaveScreen_ToDisplayList_noflush(xpos, ypos,
    SavedAreaWidth, SavedAreaHeight, ReadBuffer);
end;

procedure TGLWindow.SaveScreenDialog(ProposedFileName: string);
begin
  if FileDialog('Save screen to file', ProposedFileName, false,
    SaveImage_FileFilters) then
  try
    SaveScreen(ProposedFileName);
  except
    on E: Exception do MessageOK('Unable to save screen: ' + E.Message, mtError);
  end;
end;

function TGLWindow.FileDialog(const Title: string; var FileName: string;
  OpenDialog: boolean; const FileFilters: string): boolean;
var
  FFList: TFileFilterList;
begin
  FFList := TFileFilterList.Create(true);
  try
    FFList.AddFiltersFromString(FileFilters);
    Result := FileDialog(Title, FileName, OpenDialog, FFList);
  finally FreeAndNil(FFList) end;
end;

function TGLWindow.ColorDialog(var Color: TVector3Byte): boolean;
var
  ColorSingle: TVector3Single;
begin
  ColorSingle[0] := Color[0] / High(Byte);
  ColorSingle[1] := Color[1] / High(Byte);
  ColorSingle[2] := Color[2] / High(Byte);
  Result := ColorDialog(ColorSingle);
  if Result then
    Color := Vector3Byte(ColorSingle);
end;

{ ----------------------------------------------------------------------------
  Get/Set callbacks State }

function TGLWindow.GetCallbacksState: TGLWindowCallbacks;
begin
 with result do
 begin
  MouseMove := OnMouseMove;
  MouseDown := OnMouseDown;
  MouseUp := OnMouseUp;
  MouseWheel := OnMouseWheel;
  KeyDown := OnKeyDown;
  KeyUp := OnKeyUp;
  BeforeDraw := OnBeforeDraw;
  Draw := OnDraw;
  CloseQuery := OnCloseQuery;
  Resize := OnResize;
  Idle := OnIdle;
  Timer := OnTimer;
  MenuCommand := OnMenuCommand;
 end;
end;

procedure TGLWindow.SetCallbacksState(const Callbacks: TGLWindowCallbacks);
begin
 with Callbacks do
 begin
  OnMouseMove := MouseMove;
  OnMouseDown := MouseDown;
  OnMouseUp := MouseUp;
  OnMouseWheel := MouseWheel;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  OnBeforeDraw := BeforeDraw;
  OnDraw := Draw;
  OnCloseQuery := CloseQuery;
  OnResize := Resize;
  OnIdle := Idle;
  OnTimer := Timer;
  OnMenuCommand := MenuCommand;
 end;
end;

{ OpenAndRun ----------------------------------------------------------------- }

procedure TGLWindow.OpenAndRun(const ACaption: string; AOnDraw: TDrawFunc);
begin
 FCaption := ACaption;
 OnDraw := AOnDraw;
 OpenAndRun;
end;

procedure TGLWindow.OpenAndRun;
begin
 Open;
 Application.Run;
end;

{ TGLWindow ParseParameters -------------------------------------------------- }

type
  TOptionProcData = record
    SpecifiedOptions: TGLWindowParseOptions;
    Window: TGLWindow;
  end;
  POptionProcData = ^TOptionProcData;

procedure GeometryOptionProc(OptionNum: Integer; HasArgument: boolean;
  const Argument: string; const SeparateArgs: TSeparateArgs; Data: Pointer);
var ProcData: POptionProcData absolute Data;

  procedure ApplyGeometryParam(const geom: string);
  var p: integer;
      parWidth, parHeight, parXoff, parYoff: integer;
      xoffPlus, yoffPlus, sizeSpecified, positionSpecified: boolean;
      { p to znak w stringu geom ktory teraz chcemy czytac.
        parWidth i parHeight sa valid tylko o ile sizeSpecified.
        parXoff, parYoff, xoffPlus, yoffPlus sa valid tylko o ile positionSpecified.
      }

    procedure ParseSize;
    { parsuje width i height }
    var startp: integer;
    begin
     sizeSpecified := true;

     {width}
     startp := p;
     while SCharIs(geom, p, ['0'..'9']) do Inc(p);
     parWidth := StrToInt(CopyPos(geom, startp, p-1));

     {height}
     if not SCharIs(geom, p, ['x','X']) then
      raise EInvalidParams.Create(
        'Invalid --geometry parameter : expected "x" between WIDTH and HEIGHT');
     Inc(p);
     startp := p;
     while SCharIs(geom, p, ['0'..'9']) do Inc(p);
     parHeight := StrToInt(CopyPos(geom, startp, p-1));
    end;

    procedure ParsePosition;
    { parsuje xoff, yoff i koniec stringa. }
    var startp: integer;
    begin
     positionSpecified := true;

     {xoff}
     if not SCharIs(geom, p, ['-','+']) then
      raise EInvalidParams.Create(
        'Invalid --geometry parameter : expected "-" or "+" before XOFF');
     xoffPlus := geom[p] = '+';
     Inc(p);
     startp := p;
     if SCharIs(geom, p, ['-','+']) then Inc(p);
     while SCharIs(geom, p, ['0'..'9']) do Inc(p);
     parXoff := StrToInt(CopyPos(geom, startp, p-1));

     {yoff}
     if not SCharIs(geom, p, ['-','+']) then
      raise EInvalidParams.Create(
        'Invalid --geometry parameter : expected "-" or "+" before YOFF');
     yoffPlus := geom[p] = '+';
     Inc(p);
     startp := p;
     if SCharIs(geom, p, ['-','+']) then Inc(p);
     while SCharIs(geom, p, ['0'..'9']) do Inc(p);
     parYoff := StrToInt(CopyPos(geom, startp, p-1));

     {end of string}
     if not (p = Length(geom)+1) then
      raise EInvalidParams.Create(
        'Invalid --geometry parameter : expected end of parameter');
    end;

  begin
   ProcData^.Window.FullScreen := false;
   try
    sizeSpecified := false;
    positionSpecified := false;
    p := 1;

    if SCharIs(geom, p,['+','-']) then
     ParsePosition else
    begin
     ParseSize;
     if p <= Length(geom) then ParsePosition;
    end;

    {ok, now we can apply what we have}
    if sizeSpecified then
    begin
     ProcData^.Window.Width := parWidth;
     ProcData^.Window.Height := parHeight;
    end;
    if positionSpecified then
    begin
     if xoffPlus then
      ProcData^.Window.Left := parXoff else
      ProcData^.Window.Left := Application.ScreenWidth-parXoff-parWidth;
     if yoffPlus then
      ProcData^.Window.Top := parYoff else
      ProcData^.Window.Top := Application.ScreenHeight-parYoff-parHeight;
    end;

   except
    on E: EConvertError do
     raise EInvalidParams.Create('Invalid --geometry parameter : '+E.Message);
   end;
  end;

begin
 Include(ProcData^.SpecifiedOptions, poGeometry);
 case OptionNum of
  0: ProcData^.Window.FullScreen := true;
  1: ApplyGeometryParam(Argument);
 end;
end;

procedure ScreenGeometryOptionProc(OptionNum: Integer; HasArgument: boolean;
  const Argument: string; const SeparateArgs: TSeparateArgs; Data: Pointer);
var ProcData: POptionProcData absolute Data;

  procedure ApplyFullScreenCustomParam(const option: string);
  var p: integer;
  begin
   ProcData^.Window.FullScreen := true;
   try
    p := CharsPos(['x','X'], option);
    if p = 0 then
     raise EInvalidParams.Create(
       'Invalid --fullscreen-custom parameter - format is not WIDTHxHEIGHT');
    Application.VideoResizeWidth := StrToInt(Copy(option, 1, p-1));
    Application.VideoResizeHeight := StrToInt(SEnding(option, p+1));
    Application.VideoResize := true;
    Application.VideoChange(true);
   except
    on E: EConvertError do
     raise EInvalidParams.Create('Invalid --fullscreen-custom parameter : '+E.Message);
   end;
  end;

begin
 Include(ProcData^.SpecifiedOptions, poScreenGeometry);
 case OptionNum of
  0: ApplyFullScreenCustomParam(Argument);
 end;
end;

procedure DisplayOptionProc(OptionNum: Integer; HasArgument: boolean;
  const Argument: string; const SeparateArgs: TSeparateArgs; Data: Pointer);
var
  ProcData: POptionProcData absolute Data;
begin
  Include(ProcData^.SpecifiedOptions, poDisplay);
  case OptionNum of
    0: {$ifdef GLWINDOW_XLIB}
       if Application.FOpenWindows.Count <> 0 then
         WarningWrite(ProgramName + ': some windows are already open ' +
           'so --display option is ignored.') else
         Application.XDisplayName := Argument;
       {$else}
         {$ifdef GLWINDOW_GTK_2}
         Application.XDisplayName := Argument;
         {$else}
         WarningWrite(ProgramName + ': warning: --display option is ignored ' +
           'when we don''t use directly Xlib');
         {$endif}
       {$endif}
  end;
end;

procedure TGLWindow.ParseParameters(const AllowedOptions: TGLWindowParseOptions;
  out SpecifiedOptions: TGLWindowParseOptions);

const
  GeometryOptions: array[0..1]of TOption =
  ( (Short:#0; Long:'fullscreen'; Argument: oaNone),
    (short:#0; Long:'geometry'; Argument: oaRequired) );

  ScreenGeometryOptions: array[0..0]of TOption =
  ( (Short:#0; Long:'fullscreen-custom'; Argument: oaRequired) );

  DisplayOptions: array[0..0]of TOption =
  ( (Short:#0; Long:'display'; Argument: oaRequired) );

  OptionsForParam: array[TGLWindowParseOption] of
    record
      pOptions: POption_Array;
      Count: Integer;
      OptionProc: TOptionProc;
    end =
  ( ( pOptions: @GeometryOptions;
      Count: High(GeometryOptions)+1;
      OptionProc: {$ifdef FPC_OBJFPC} @ {$endif} GeometryOptionProc),
    ( pOptions: @ScreenGeometryOptions;
      Count: High(ScreenGeometryOptions) + 1;
      OptionProc: {$ifdef FPC_OBJFPC} @ {$endif} ScreenGeometryOptionProc),
    ( pOptions: @DisplayOptions;
      Count: High(DisplayOptions) + 1;
      OptionProc: {$ifdef FPC_OBJFPC} @ {$endif} DisplayOptionProc)
  );

var Data: TOptionProcData;
    ParamKind: TGLWindowParseOption;
begin
 Data.SpecifiedOptions := [];
 Data.Window := Self;

 for ParamKind := Low(ParamKind) to High(ParamKind) do
  if ParamKind in AllowedOptions then
   Parameters.Parse(OptionsForParam[ParamKind].pOptions,
     OptionsForParam[ParamKind].Count,
     OptionsForParam[ParamKind].OptionProc, @Data, true);

 SpecifiedOptions := Data.SpecifiedOptions;
end;

procedure TGLWindow.ParseParameters(const AllowedOptions: TGLWindowParseOptions);
var
  dummy: TGLWindowParseOptions;
begin
  ParseParameters(AllowedOptions, dummy);
end;

class function TGLWindow.ParseParametersHelp(
  const AllowedOptions: TGLWindowParseOptions;
  AddHeader: boolean): string;
const
  HelpForParam: array[TGLWindowParseOption] of string =
  ('  --geometry WIDTHxHEIGHT<sign>XOFF<sign>YOFF' +nl+
   '                        Set initial window size and/or position' +nl+
   '  --fullscreen          Set initial window size to cover whole screen',
   '  --fullscreen-custom WIDTHxHEIGHT' +nl+
   '                        Try to resize the screen to WIDTHxHEIGHT and' +nl+
   '                        then set initial window size to cover whole screen',
   '  --display DISPLAY-NAME' +nl+
   '                        Use given XWindows display name.'
   );
var ParamKind: TGLWindowParseOption;
begin
 if AddHeader then
  result := 'Window options:' else
  result := '';

 for ParamKind := Low(ParamKind) to High(ParamKind) do
  if ParamKind in AllowedOptions then
  begin
   if result <> '' then result += nl;
   result += HelpForParam[ParamKind];
  end;
end;

{ Fps ------------------------------------------------------------------------ }

procedure TGLWindow.FpsToCaption(const WindowTitle: string);
begin
  Caption := WindowTitle +
    Format(' - FPS : %f (real : %f)', [Fps.FrameTime, Fps.RealTime]);
end;

{ TGLWindow miscella ---------------------------------------- }

function TGLWindow.RequestedBufferAttributes: string;
begin
 if DoubleBuffer then
  result := 'double buffered' else
  result := 'single buffered';
 if DepthBufferBits > 0 then
  result += Format(', with %d-bits sized depth buffer', [DepthBufferBits]);
 if StencilBufferBits > 0 then
  result += Format(', with %d-bits sized stencil buffer', [StencilBufferBits]);
 if AlphaBits > 0 then
  result += Format(', with %d-bits sized alpha channel', [AlphaBits]);
 if not ZeroVector(AccumBufferBits) then
  result += Format(', with (%d,%d,%d,%d)-bits sized accumulation buffer',
    [AccumBufferBits[0], AccumBufferBits[1],
     AccumBufferBits[2], AccumBufferBits[3]]);
 if MultiSampling > 1 then
  result += Format(', with multisampling (%d samples)', [MultiSampling]);
end;

procedure TGLWindow.CheckRequestedBufferAttributes(const ProviderName: string;
  ProvidedStencilBits, ProvidedDepthBits, ProvidedAlphaBits,
  ProvidedAccumRedBits, ProvidedAccumGreenBits, ProvidedAccumBlueBits,
  ProvidedAccumAlphaBits, ProvidedMultiSampling: Cardinal);

  procedure CheckRequestedBits(const Name: string; RequestedBits, ProvidedBits: Cardinal);
  begin
   if ProvidedBits < RequestedBits then
    raise EGLContextNotPossible.CreateFmt('%s provided OpenGL context with %s'
      +' %d-bits sized but at least %d-bits sized is required',
      [ ProviderName, Name, ProvidedBits, RequestedBits ]);
  end;

begin
 CheckRequestedBits('stencil buffer', StencilBufferBits, ProvidedStencilBits);
 CheckRequestedBits('depth buffer', DepthBufferBits, ProvidedDepthBits);
 CheckRequestedBits('alpha channel', AlphaBits, ProvidedAlphaBits);
 CheckRequestedBits('accumulation buffer''s red channel'  , AccumBufferBits[0], ProvidedAccumRedBits);
 CheckRequestedBits('accumulation buffer''s green channel', AccumBufferBits[1], ProvidedAccumGreenBits);
 CheckRequestedBits('accumulation buffer''s blue channel' , AccumBufferBits[2], ProvidedAccumBlueBits);
 CheckRequestedBits('accumulation buffer''s alpha channel', AccumBufferBits[3], ProvidedAccumAlphaBits);

 { If MultiSampling <= 1, this means that multisampling not required,
   so don't check it. Even if MultiSampling = 1 and ProvidedMultiSampling = 0
   (as most backends report no multisampling as num samples = 0), it's all Ok. }

 if MultiSampling > 1 then
 begin
   if ProvidedMultiSampling < MultiSampling then
    raise EGLContextNotPossible.CreateFmt('%s provided OpenGL context with %d ' +
      'samples for multisampling (<= 1 means that no multisampling was provided) ' +
      'but at last %d samples for multisampling is required',
      [ ProviderName, ProvidedMultiSampling, MultiSampling ]);
 end;
end;

function TGLWindow.GetMouseX: Integer;
begin
  Result := FMouseX;
end;

function TGLWindow.GetMouseY: Integer;
begin
  Result := FMouseY;
end;

function TGLWindow.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TGLWindow.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TGLWindow.GetMousePressed: TMouseButtons;
begin
  Result := FMousePressed;
end;

function TGLWindow.GetPressed: TKeysPressed;
begin
  Result := FPressed;
end;

procedure TGLWindow.MenuUpdateBegin;
begin
  { MenuUpdateNeedsInitialize = false always when MenuUpdateInside = 0. }
  Assert((MenuUpdateInside <> 0) or (not MenuUpdateNeedsInitialize));

  Inc(MenuUpdateInside);
end;

procedure TGLWindow.MenuUpdateEnd;
begin
  Dec(MenuUpdateInside);
  if (MenuUpdateInside = 0) and MenuUpdateNeedsInitialize then
  begin
    MenuUpdateNeedsInitialize := false;
    { We could also manually call BackendMenuInitialize now,
      as we know MenuUpdateInside = 0. But MenuInitialize takes
      care also about some checks and updating MenuInitialized variable. }
    MenuInitialize;
  end;
end;

procedure TGLWindow.MenuInitialize;
begin
  if MenuUpdateInside = 0 then
  begin
    if (not MenuInitialized) and (not Closed) then
    begin
      BackendMenuInitialize;
      MenuInitialized := true;
    end;
  end else
    MenuUpdateNeedsInitialize := true;
end;

procedure TGLWindow.MenuFinalize;
begin
  { MenuFinalize ignores MenuUpdateInside state, not needed. }
  if MenuInitialized and (not Closed) then
  begin
    MenuInitialized := false;
    BackendMenuFinalize;
  end;
end;

{ TGLWindowDemo ---------------------------------------------------------------- }

procedure TGLWindowDemo.SwapFullScreen;

  procedure SaveRect;
  begin
   wLeft := Left;
   wTop := Top;
   wWidth := Width;
   wHeight := Height;
  end;

begin
 DuringSwapFullScreen := true;
 try
  Close(false);
  if not FFullScreen then SaveRect; { save window rect }
  FFullScreen := not FFullScreen;
  if not FFullScreen then
  begin
   Left := wLeft;
   Top := wTop;
   Width := wWidth;
   Height := wHeight;
  end;
  Open;
 finally DuringSwapFullScreen := false end;
end;

procedure TGLWindowDemo.EventIdle;
begin
 inherited;
 {ponizej udalo mi sie zaimplementowac cos jak timer, a jednak nie uzylem
  zadnego callbacka, w szczegolnosci OnTimer okienka ! A wiec sukces -
  ten timer moze sobie dzialac w sposob zupelnie przezroczysty dla okienka,
  ktore moze swobodnie modyfikowac swoje OnTimer, Application.OnTimer,
  Application.TimerMilisec. }
 if FpsShowOnCaption and
    ((lastFpsOutputTick = 0) or
     (TimeTickDiff(lastFpsOutputTick, GetTickCount) >= FpsCaptionUpdateInterval)) then
 begin
  lastFpsOutputTick := GetTickCount;
  FpsToCaption(FFpsBaseCaption);
 end;
end;

function TGLWindowDemo.AllowSuspendForInput: boolean;
begin
 result := (inherited AllowSuspendForInput) and (not FpsShowOnCaption);
end;

procedure TGLWindowDemo.EventOpen;
begin
 if not DuringSwapFullScreen then
 begin
  if FpsShowOnCaption then
  begin
   { init frames per second write in timer }
   Fps.Active := true;
   FFpsBaseCaption := Caption;
  end;

  { set initial window rect (wLeft/top/width/height) if fullscreen = true }
  if FFullScreen then
  begin
   wWidth  := GLWindowDefaultSize;
   wHeight := GLWindowDefaultSize;
   wLeft   := GLWindowPositionCenter;
   wTop    := GLWindowPositionCenter;
  end;
 end;

 inherited;
end;

procedure TGLWindowDemo.EventKeyDown(Key: TKey; c: char);
begin
 if (c <> #0) and (c = Close_CharKey) then
   Close else
 if (Key <> K_None) and (Key = SwapFullScreen_Key) then
   SwapFullScreen else
   inherited;
   { nie wywoluj inherited jesli to byl klawisz Close_CharKey lub
     SwapFullScreen_Key bo te klawisze zmienily okienko na tyle ze mozna
     podejrzewac ze wcisniecie klawisza mozna juz uznac za nieaktualne. }
end;

procedure TGLWindowDemo.SetDemoOptions(ASwapFullScreen_Key: TKey;
  AClose_CharKey: char;
  AFpsShowOnCaption: boolean);
begin
  SwapFullScreen_Key := ASwapFullScreen_Key;
  Close_CharKey := AClose_CharKey;
  FpsShowOnCaption := AFpsShowOnCaption;
end;

procedure TGLWindowDemo.SetFpsBaseCaption(const Value: string);
begin
  if FFpsBaseCaption <> Value then
  begin
    FFpsBaseCaption := Value;
    { Update Caption now, otherwise Caption would get updated with
      some latency (because only when FpsCaptionUpdateInterval is reached). }
    FpsToCaption(FFpsBaseCaption);
  end;
end;

constructor TGLWindowDemo.Create(AOwner: TComponent);
begin
  inherited;
  Close_CharKey := #0; { CharEscape; }
  SwapFullScreen_Key := K_None; { K_F11; }
  FpsShowOnCaption := false;
  FFpsCaptionUpdateInterval := DefaultFpsCaptionUpdateInterval;
end;

{ TControlledUIControlList ----------------------------------------------------- }

type
  { TUIControlList descendant that takes care to react to list add/remove
    notifications, doing appropriate operations with parent Container. }
  TControlledUIControlList = class(TUIControlList)
  private
    Container: TGLUIWindow;
  public
    constructor Create(const FreeObjects: boolean; const AContainer: TGLUIWindow);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

constructor TControlledUIControlList.Create(const FreeObjects: boolean;
  const AContainer: TGLUIWindow);
begin
  inherited Create(FreeObjects);
  Container := AContainer;
end;

procedure TControlledUIControlList.Notify(Ptr: Pointer; Action: TListNotification);
var
  C: TUIControl absolute Ptr;
begin
  inherited;

  C := TUIControl(Ptr);
  case Action of
    lnAdded:
      begin
        { Make sure Container.ControlsVisibleChange will be called
          when a control calls OnVisibleChange. }
        if C.OnVisibleChange = nil then
          C.OnVisibleChange := @Container.ControlsVisibleChange;

        { Register Container to be notified of control destruction. }
        C.FreeNotification(Container);

        C.Container := Container;

        if not Container.Closed then
        begin
          if C.DisableContextOpenClose = 0 then
            C.GLContextOpen;
          { Call initial ContainerResize for control.
            If window OpenGL context is not yet initialized, defer it to
            the Open time, then our initial EventResize will be called
            that will do ContainerResize on every control. }
          C.ContainerResize(Container.Width, Container.Height);
        end;
      end;
    lnExtracted, lnDeleted:
      begin
        if (not Container.Closed) and
           (C.DisableContextOpenClose = 0) then
          C.GLContextClose;

        if C.OnVisibleChange = @Container.ControlsVisibleChange then
          C.OnVisibleChange := nil;

        C.RemoveFreeNotification(Container);

        C.Container := nil;
      end;
    else raise EInternalError.Create('TControlledUIControlList.Notify action?');
  end;

  { This notification may get called during FreeAndNil(FControls)
    in TGLUIWindow.Destroy. Then FControls is already nil, and we're
    getting remove notification for all items (as FreeAndNil first sets
    object to nil). Testcase: lets_take_a_walk exit. }
  if Container.FControls <> nil then
    Container.UpdateFocusAndMouseCursor;
end;

{ TGLUIWindow --------------------------------------------------------- }

constructor TGLUIWindow.Create(AOwner: TComponent);
begin
  inherited;
  FControls := TControlledUIControlList.Create(false, Self);
  FUseControls := true;
  FOnDrawStyle := dsNone;
  FTooltipDelay := DefaultTooltipDelay;
  FTooltipDistance := DefaultTooltipDistance;
end;

destructor TGLUIWindow.Destroy;
begin
  FreeAndNil(FControls);
  inherited;
end;

procedure TGLUIWindow.Notification(AComponent: TComponent; Operation: TOperation);
begin
  { We have to remove a reference to the object from Controls list.
    This is crucial: TControlledUIControlList.Notify,
    and some Controls.MakeSingle calls, assume that all objects on
    the Controls list are always valid objects (no invalid references,
    even for a short time). }
  if (Operation = opRemove) and (AComponent is TUIControl) then
  begin
    Controls.DeleteAll(AComponent);
    if AComponent = FFocus then FFocus := nil;
  end;
end;

procedure TGLUIWindow.UpdateFocusAndMouseCursor;

  function CalculateFocus: TUIControl;
  var
    I: Integer;
  begin
    if not UseControls then Exit(nil);

    for I := 0 to Controls.Count - 1 do
    begin
      Result := Controls[I];
      if Result.PositionInside(MouseX, MouseY) then
        Exit;
    end;

    Result := nil;
  end;

  function CalculateMouseCursor: TMouseCursor;
  begin
    if Focus <> nil then
      Result := Focus.Cursor else
      Result := mcDefault;
  end;

var
  NewFocus: TUIControl;
begin
  NewFocus := CalculateFocus;

  if NewFocus <> Focus then
  begin
    if (Focus <> nil) and UseControls then Focus.Focused := false;
    FFocus := NewFocus;
    { No need to check UseControls above: if Focus <> nil then we know
      UseControls was true during CalculateFocus. }
    if (Focus <> nil) then Focus.Focused := true;
  end;

  Cursor := CalculateMouseCursor;
end;

procedure TGLUIWindow.EventIdle;

  procedure UpdateTooltip;
  var
    T: TKamTimerResult;
    NewTooltipVisible: boolean;
  begin
    { Update TooltipVisible and LastPositionForTooltip*.
      Idea is that user must move the mouse very slowly to activate tooltip. }

    T := Fps.IdleStartTime;
    if (not LastPositionForTooltip) or
       (Sqr(LastPositionForTooltipX - MouseX) +
        Sqr(LastPositionForTooltipY - MouseY) > Sqr(TooltipDistance)) then
    begin
      LastPositionForTooltip := true;
      LastPositionForTooltipX := MouseX;
      LastPositionForTooltipY := MouseY;
      LastPositionForTooltipTime := T;
      NewTooltipVisible := false;
    end else
      NewTooltipVisible :=
        { make TooltipVisible only when we're over a control that has
          focus. This avoids unnecessary changing of TooltipVisible
          (and related PostRedisplay) when there's no tooltip possible. }
        (Focus <> nil) and
        (Focus.TooltipStyle <> dsNone) and
        ( (1000 * (T - LastPositionForTooltipTime)) div
          KamTimerFrequency > TooltipDelay );

    if FTooltipVisible <> NewTooltipVisible then
    begin
      FTooltipVisible := NewTooltipVisible;

      if TooltipVisible then
      begin
        { when setting TooltipVisible from false to true,
          update LastPositionForTooltipX/Y. We don't want to hide the tooltip
          at the slightest jiggle of the mouse :) On the other hand,
          we don't want to update LastPositionForTooltipX/Y more often,
          as it would disable the purpose of TooltipDistance: faster
          mouse movement should hide the tooltip. }
        LastPositionForTooltipX := MouseX;
        LastPositionForTooltipY := MouseY;
        { also update TooltipX/Y }
        FTooltipX := MouseX;
        FTooltipY := MouseY;
      end;

      PostRedisplay;
    end;
  end;

var
  I: Integer;
  C: TUIControl;
  HandleMouseAndKeys: boolean;
  Dummy: boolean;
begin
  if UseControls then
  begin
    UpdateTooltip;

    { Although we call Idle for all the controls, we look
      at PositionInside and track HandleMouseAndKeys values.
      See TUIControl.Idle for explanation. }

    HandleMouseAndKeys := true;

    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if HandleMouseAndKeys and C.PositionInside(MouseX, MouseY) then
      begin
        HandleMouseAndKeys := not C.ExclusiveEvents;
        C.Idle(Fps.IdleSpeed, true, HandleMouseAndKeys);
      end else
      begin
        Dummy := not C.ExclusiveEvents;
        C.Idle(Fps.IdleSpeed, false, Dummy);
      end;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventKeyDown(Key: TKey; Ch: char);
var
  C: TUIControl;
  I: Integer;
begin
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.KeyDown(Key, Ch) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventKeyUp(Key: TKey; Ch: char);
var
  C: TUIControl;
  I: Integer;
begin
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.KeyUp(Key, Ch) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventMouseDown(Button: TMouseButton);
var
  C: TUIControl;
  I: Integer;
begin
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.MouseDown(Button) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventMouseUp(Button: TMouseButton);
var
  C: TUIControl;
  I: Integer;
begin
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.MouseUp(Button) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventMouseWheel(const Scroll: Single; const Vertical: boolean);
var
  C: TUIControl;
  I: Integer;
begin
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.MouseWheel(Scroll, Vertical) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.EventOpen;
var
  I: Integer;
begin
  inherited;

  { call GLContextOpen on controls after inherited (OnOpen). }
  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
      Controls[I].GLContextOpen;
  end;
end;

function TGLUIWindow.AllowSuspendForInput: boolean;
var
  I: Integer;
begin
  Result := inherited;
  if not Result then Exit;

  if UseControls then
  begin
    { Do not suspend when you're over a control that may have a tooltip,
      as EventIdle must track and eventually show tooltip. }
    if (Focus <> nil) and (Focus.TooltipStyle <> dsNone) then
      Exit(false);

    for I := 0 to Controls.Count - 1 do
    begin
      Result := Controls[I].AllowSuspendForInput;
      if not Result then Exit;
    end;
  end;
end;

procedure TGLUIWindow.SetUseControls(const Value: boolean);
begin
  if Value <> UseControls then
  begin
    FUseControls := Value;
    { Focus must always be @nil when UseControls = false }
    UpdateFocusAndMouseCursor;
  end;
end;

procedure TGLUIWindow.EventMouseMove(NewX, NewY: Integer);
var
  C: TUIControl;
  I: Integer;
begin
  UpdateFocusAndMouseCursor;

  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
    begin
      C := Controls[I];
      if C.PositionInside(MouseX, MouseY) then
        if C.MouseMove(MouseX, MouseY, NewX, NewY) then Exit;
    end;
  end;

  inherited;
end;

procedure TGLUIWindow.ControlsVisibleChange(Sender: TObject);
begin
  PostRedisplay;
end;

procedure TGLUIWindow.EventBeforeDraw;
var
  I: Integer;
begin
  inherited;

  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
      Controls[I].BeforeDraw;
  end;
end;

procedure TGLUIWindow.EventDraw;

  { Call Draw for all controls having DrawStyle = ds3D.

    Also (since we call DrawStyle for everything anyway)
    calculates AnythingWants2D = if any control returned DrawStyle = ds2D.
    If not, you can later avoid even changing projection to 2D. }
  procedure Draw3D(out AnythingWants2D: boolean);
  var
    I: Integer;
    C: TUIControl;
  begin
    AnythingWants2D := false;

    if UseControls then
    begin
      { draw controls in "downto" order, back to front }
      for I := Controls.Count - 1 downto 0 do
      begin
        C := Controls[I];
        case C.DrawStyle of
          ds2D: AnythingWants2D := true;
          { Set OpenGL state that may be changed carelessly, and has some
            guanteed value, for TUIControl.Draw calls.
            For now, just glLoadIdentity. }
          ds3D: begin glLoadIdentity; C.Draw; end;
        end;
      end;

      if TooltipVisible and (Focus <> nil) then
        case Focus.TooltipStyle of
          ds2D: AnythingWants2D := true;
          ds3D: begin glLoadIdentity; Focus.DrawTooltip; end;
        end;
    end;

    case OnDrawStyle of
      ds2D: AnythingWants2D := true;
      ds3D: begin glLoadIdentity; inherited EventDraw; end;
    end;
  end;

  procedure Draw2D;
  var
    C: TUIControl;
    I: Integer;
  begin
    glPushAttrib(GL_ENABLE_BIT or GL_VIEWPORT_BIT);
      { Set and push/pop OpenGL state that is guaranteed for Draw2D calls,
        but TUIControl.Draw cannot change it carelessly. }
      glDisable(GL_LIGHTING);
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_TEXTURE_2D);
      if GL_ARB_texture_cube_map then glDisable(GL_TEXTURE_CUBE_MAP_ARB);
      if GL3DTextures <> gsNone  then glDisable(GL_TEXTURE_3D);
      glViewport(0, 0, Width, Height); // saved by GL_VIEWPORT_BIT

      glMatrixMode(GL_PROJECTION);
      glPushMatrix;
      glLoadIdentity;
      gluOrtho2D(0, Width, 0, Height);
      glMatrixMode(GL_MODELVIEW);
      try

        if UseControls then
        begin
          { draw controls in "downto" order, back to front }
          for I := Controls.Count - 1 downto 0 do
          begin
            C := Controls[I];

            if C.DrawStyle = ds2D then
            begin
              { Set OpenGL state that may be changed carelessly, and has some
                guanteed value, for Draw2d calls. }
              glLoadIdentity;
              glRasterPos2i(0, 0);
              C.Draw;
            end;
          end;

          if TooltipVisible and (Focus <> nil) and (Focus.TooltipStyle = ds2D) then
          begin
            glLoadIdentity;
            glRasterPos2i(0, 0);
            Focus.DrawTooltip;
          end;
        end;

        if OnDrawStyle = ds2D then
        begin
          glLoadIdentity;
          glRasterPos2i(0, 0);
          inherited EventDraw;
        end;

      finally
        glMatrixMode(GL_PROJECTION);
        glPopMatrix;
        glMatrixMode(GL_MODELVIEW);
      end;
    glPopAttrib;
  end;

var
  AnythingWants2D: boolean;
begin
  Draw3D(AnythingWants2D);

  if AnythingWants2D then
    Draw2D;

  if OnDrawStyle = dsNone then
    inherited;
end;

procedure TGLUIWindow.EventResize;
var
  I: Integer;
begin
  inherited;

  if UseControls then
  begin
    for I := 0 to Controls.Count - 1 do
      Controls[I].ContainerResize(Width, Height);
  end;
end;

procedure TGLUIWindow.EventClose;
var
  I: Integer;
begin
  { call GLContextClose on controls before inherited (OnClose).
    This may be called from Close, which may be called from TGLWindow destructor,
    so prepare for Controls being possibly nil now. }
  if UseControls and (Controls <> nil) then
  begin
    for I := 0 to Controls.Count - 1 do
      Controls[I].GLContextClose;
  end;

  inherited;
end;

function TGLUIWindow.GetTooltipX: Integer;
begin
  Result := FTooltipX;
end;

function TGLUIWindow.GetTooltipY: Integer;
begin
  Result := FTooltipY;
end;

{ TGLWindowList ------------------------------------------------------------ }

procedure TGLWindowList.PostRedisplay;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do Items[i].PostRedisplay;
end;

procedure TGLWindowList.DoIdle;
var
  i: integer;
begin
  for i := 0 to Count - 1 do Items[i].DoIdle;
end;

procedure TGLWindowList.DoTimer;
var
  i: integer;
begin
  for i := 0 to Count - 1 do Items[i].DoTimer;
end;

{ --------------------------------------------------------------------------
  Generic part of implementation of TGLApplication,
  that does not depend what GLWINDOW_xxx backend you want. }

constructor TGLApplication.Create(AOwner: TComponent);
begin
  inherited;
  FOpenWindows := TGLWindowList.Create(false);
  FTimerMilisec := 1000;
  CreateBackend;
end;

destructor TGLApplication.Destroy;
begin
  { Close any windows possibly open now.
    This is necessary --- after destroying Application there would be really
    no way for them to close properly (that is, TGLWindow.CloseBackend
    may, and usually will, fail with very strange errors when called
    after freeing central Application). }
  Quit;

  { nil now the Application variable. For reasoning, see this units
    finalization. }
  Application := nil;

  VideoReset;
  DestroyBackend;
  FreeAndNil(FOpenWindows);
  inherited;
end;

function TGLApplication.GetOpenWindows(Index: integer): TGLWindow;
begin
  result := FOpenWindows[Index];
end;

function TGLApplication.OpenWindowsCount: integer;
begin
  result := FOpenWindows.Count;
end;

procedure TGLApplication.OpenWindowsAdd(Window: TGLWindow);
begin
  FOpenWindows.Add(Window);
end;

procedure TGLApplication.OpenWindowsRemove(Window: TGLWindow;
  QuitWhenLastWindowClosed: boolean);
begin
  if (FOpenWindows.Remove(Window) <> -1) and
     (OpenWindowsCount = 0) and QuitWhenLastWindowClosed then Quit;
end;

function TGLApplication.FindWindow(Window: TGLWindow): integer;
begin
  for result := 0 to OpenWindowsCount-1 do
    if OpenWindows[result] = Window then exit;
  result := -1;
end;

procedure TGLApplication.Quit;
var
  OldOpenWindowsCount: Integer;
begin
  { We're calling here Close(false) so we will not cause infinite recursive
    Quit calls.

    Remember that calling Close actually calls Application.OpenWindowsRemove.
    In fact, it's guaranteed that calling Close on open
    window will remove it from OpenWindows list (we even check it by assert,
    otherwise our "while" could never finish).
    So the number of open windows will drop during while
    (that's why "for I := 0 to OpenWindowsCount - 1 do ..." would be stupid
    code here, but "while OpenWindowsCount > 0 ..." is Ok). }

  while OpenWindowsCount > 0 do
  begin
    OldOpenWindowsCount := OpenWindowsCount;
    OpenWindows[0].Close(false);
    Assert(OpenWindowsCount = OldOpenWindowsCount - 1);
  end;

  QuitWhenNoOpenWindows;
end;

procedure TGLApplication.DoSelfIdle;
begin
  if Assigned(FOnIdle) then FOnIdle;
end;

procedure TGLApplication.DoSelfTimer;
begin
  if Assigned(FOnTimer) then FOnTimer;
end;

procedure TGLApplication.MaybeDoTimer(var ALastDoTimerTime: TMilisecTime);
var
  Now: TMilisecTime;
begin
  Now := GetTickCount;
  if ((ALastDoTimerTime = 0) or
      (MilisecTimesSubtract(Now, ALastDoTimerTime) >= FTimerMilisec)) then
  begin
    ALastDoTimerTime := Now;
    DoSelfTimer;
    FOpenWindows.DoTimer;
  end;
end;

function TGLApplication.AllowSuspendForInput: boolean;
var
  I: Integer;
begin
  Result := not (Assigned(OnIdle) or Assigned(OnTimer));
  if not Result then Exit;

  for I := 0 to OpenWindowsCount - 1 do
  begin
    Result := OpenWindows[I].AllowSuspendForInput;
    if not Result then Exit;
  end;
end;

{ TGLApplication.Video* things ---------------------------------------- }

{$ifndef GLWINDOW_HAS_VIDEO_CHANGE}
function TGLApplication.TryVideoChange: boolean;
begin
 Result := false;
end;

procedure TGLApplication.VideoReset;
begin
end;
{$endif not GLWINDOW_HAS_VIDEO_CHANGE}

function TGLApplication.VideoSettingsDescribe: string;
begin
  Result := '';
  if VideoResize then
    Result += Format('  Screen size :  %dx%d', [VideoResizeWidth, VideoResizeHeight]) + nl;
  if VideoColorBits <> 0 then
    Result += Format('  Color bits per pixel : %d', [VideoColorBits]) + nl;
  if VideoFrequency <> 0 then
    Result += Format('  Display frequency : %d', [VideoFrequency]) + nl;

  if Result = '' then
    Result := '  No display settings change' + nl;
end;

procedure TGLApplication.VideoChange(OnErrorWarnUserAndContinue: boolean);
var s: string;
begin
 if not TryVideoChange then
 begin
  s := 'Can''t change display settings to : ' + nl + VideoSettingsDescribe;

  {$ifndef GLWINDOW_HAS_VIDEO_CHANGE}
    s += ' (changing Video properties not implemented when GLWindow is '+
      'made on top of ' +BackendName +')';
  {$endif}

  if OnErrorWarnUserAndContinue then
   WarningWrite(s+'. Trying to continue anyway.') else
   raise Exception.Create(s);
 end;
end;

{ Resize2D ------------------------------------------------------------ }

procedure Resize2D(Window: TGLWindow);
begin
 glViewport(0, 0, Window.Width, Window.Height);
 ProjectionGLOrtho(0, Window.Width, 0, Window.Height);
end;

{ init/fini --------------------------------------------------------------- }

initialization
 GLWindowMenu_Init;
 Application := TGLApplication.Create(nil);
finalization
 { Instead of using FreeAndNil, just call Free.
   In our constructor we take care of setting Application variable to @nil,
   when it becomes really useless.

   Otherwise FreeAndNil first nils, then frees Application, and we really
   want to keep Application during first stage of TGLApplication destruction:
   when calling Quit, which may close windows, which may use Application
   variable in their Close or CloseBackend implementations. }
 Application.Free;
 Assert(Application = nil);

 { Order is important: GLWindowMenu_Fini frees MenuItems, which is needed
   by TMenu destructor. And some TGLWindow instances may be freed
   only by Application destructor (when they are owned by Application). }
 GLWindowMenu_Fini;
end.
