local nldecl = require 'nldecl'

nldecl.exclude_foregin_pointers = true

nldecl.include_names = {
  '^X',
  '^x[A-Z][a-z]+',

  Mask = true,
  Atom = true,
  VisualID = true,
  Time = true,

  Window = true,
  Drawable = true,
  Font = true,
  Pixmap = true,
  Cursor = true,
  Colormap = true,
  GContext = true,
  KeySym = true,
  KeyCode = true,

  Visual = true,
  Screen = true,
  Depth = true,
  GC = true,
  Display = true,
  ScreenFormat = true,
  Region = true,
  _LockInfoRec = true,
}

nldecl.include_macros = {
  cint = {
    None           = false,
    ParentRelative = false,
    CopyFromParent = false,

    PointerWindow   = false,
    InputFocus      = false,
    PointerRoot     = false,
    AnyPropertyType = false,
    AnyKey          = false,
    AnyButton       = false,
    AllTemporary    = false,
    CurrentTime     = false,
    NoSymbol        = false,

    -- Input Event Masks
    NoEventMask              = false,
    KeyPressMask             = false,
    KeyReleaseMask           = false,
    ButtonPressMask          = false,
    ButtonReleaseMask        = false,
    EnterWindowMask          = false,
    LeaveWindowMask          = false,
    PointerMotionMask        = false,
    PointerMotionHintMask    = false,
    Button1MotionMask        = false,
    Button2MotionMask        = false,
    Button3MotionMask        = false,
    Button4MotionMask        = false,
    Button5MotionMask        = false,
    ButtonMotionMask         = false,
    KeymapStateMask          = false,
    ExposureMask             = false,
    VisibilityChangeMask     = false,
    StructureNotifyMask      = false,
    ResizeRedirectMask       = false,
    SubstructureNotifyMask   = false,
    SubstructureRedirectMask = false,
    FocusChangeMask          = false,
    PropertyChangeMask       = false,
    ColormapChangeMask       = false,
    OwnerGrabButtonMask      = false,

    -- Event names
    KeyPress         = false,
    KeyRelease       = false,
    ButtonPress      = false,
    ButtonRelease    = false,
    MotionNotify     = false,
    EnterNotify      = false,
    LeaveNotify      = false,
    FocusIn          = false,
    FocusOut         = false,
    KeymapNotify     = false,
    Expose           = false,
    GraphicsExpose   = false,
    NoExpose         = false,
    VisibilityNotify = false,
    CreateNotify     = false,
    DestroyNotify    = false,
    UnmapNotify      = false,
    MapNotify        = false,
    MapRequest       = false,
    ReparentNotify   = false,
    ConfigureNotify  = false,
    ConfigureRequest = false,
    GravityNotify    = false,
    ResizeRequest    = false,
    CirculateNotify  = false,
    CirculateRequest = false,
    PropertyNotify   = false,
    SelectionClear   = false,
    SelectionRequest = false,
    SelectionNotify  = false,
    ColormapNotify   = false,
    ClientMessage    = false,
    MappingNotify    = false,
    GenericEvent     = false,
    LASTEvent        = false,

    -- Key masks
    ShiftMask   = false,
    LockMask    = false,
    ControlMask = false,
    Mod1Mask    = false,
    Mod2Mask    = false,
    Mod3Mask    = false,
    Mod4Mask    = false,
    Mod5Mask    = false,

    -- Modifier names
    ShiftMapIndex   = false,
    LockMapIndex    = false,
    ControlMapIndex = false,
    Mod1MapIndex    = false,
    Mod2MapIndex    = false,
    Mod3MapIndex    = false,
    Mod4MapIndex    = false,
    Mod5MapIndex    = false,

    -- Button masks
    Button1Mask = false,
    Button2Mask = false,
    Button3Mask = false,
    Button4Mask = false,
    Button5Mask = false,
    AnyModifier = false,

    -- Button names
    Button1 = false,
    Button2 = false,
    Button3 = false,
    Button4 = false,
    Button5 = false,

    -- Notify modes
    NotifyNormal       = false,
    NotifyGrab         = false,
    NotifyUngrab       = false,
    NotifyWhileGrabbed = false,
    NotifyHint         = false,

    -- Notify detail
    NotifyAncestor         = false,
    NotifyVirtual          = false,
    NotifyInferior         = false,
    NotifyNonlinear        = false,
    NotifyNonlinearVirtual = false,
    NotifyPointer          = false,
    NotifyPointerRoot      = false,
    NotifyDetailNone       = false,

    -- Visibility notify
    VisibilityUnobscured        = false,
    VisibilityPartiallyObscured = false,
    VisibilityFullyObscured     = false,

    -- Circulation request
    PlaceOnTop    = false,
    PlaceOnBottom = false,

    -- Protocol families
    FamilyInternet  = false,
    FamilyDECnet    = false,
    FamilyChaos     = false,
    FamilyInternet6 = false,
    FamilyServerInterpreted = false,

    -- Property notification
    PropertyNewValue = false,
    PropertyDelete   = false,

    -- Color Map notification
    ColormapUninstalled = false,
    ColormapInstalled   = false,

    -- GrabKey Modes
    GrabPointer = false,
    GrabButton = false,
    GrabKeyboard = false,
    GrabModeSync  = false,
    GrabModeAsync = false,

    -- Reply status
    GrabSuccess     = false,
    AlreadyGrabbed  = false,
    GrabInvalidTime = false,
    GrabNotViewable = false,
    GrabFrozen      = false,

    -- AllowEvents modes
    AsyncPointer   = false,
    SyncPointer    = false,
    ReplayPointer  = false,
    AsyncKeyboard  = false,
    SyncKeyboard   = false,
    ReplayKeyboard = false,
    AsyncBoth      = false,
    SyncBoth       = false,

    -- Used in SetInputFocus, GetInputFocus
    RevertToNone        = false,
    RevertToPointerRoot = false,
    RevertToParent      = false,

    -- Error codes
    Success           = false,
    BadRequest        = false,
    BadValue          = false,
    BadWindow         = false,
    BadPixmap         = false,
    BadAtom           = false,
    BadCursor         = false,
    BadFont           = false,
    BadMatch          = false,
    BadDrawable       = false,
    BadAccess         = false,
    BadAlloc          = false,
    BadColor          = false,
    BadGC             = false,
    BadIDChoice       = false,
    BadName           = false,
    BadLength         = false,
    BadImplementation = false,

    FirstExtensionError = false,
    LastExtensionError  = false,

    -- Window classes used by CreateWindow
    InputOutput = false,
    InputOnly   = false,

    -- Window attributes for CreateWindow and ChangeWindowAttributes
    CWBackPixmap       = false,
    CWBackPixel        = false,
    CWBorderPixmap     = false,
    CWBorderPixel      = false,
    CWBitGravity       = false,
    CWWinGravity       = false,
    CWBackingStore     = false,
    CWBackingPlanes    = false,
    CWBackingPixel     = false,
    CWOverrideRedirect = false,
    CWSaveUnder        = false,
    CWEventMask        = false,
    CWDontPropagate    = false,
    CWColormap         = false,
    CWCursor           = false,

    -- ConfigureWindow structure
    CWX           = false,
    CWY           = false,
    CWWidth       = false,
    CWHeight      = false,
    CWBorderWidth = false,
    CWSibling     = false,
    CWStackMode   = false,

    -- Bit Gravity
    ForgetGravity    = false,
    NorthWestGravity = false,
    NorthGravity     = false,
    NorthEastGravity = false,
    WestGravity      = false,
    CenterGravity    = false,
    EastGravity      = false,
    SouthWestGravity = false,
    SouthGravity     = false,
    SouthEastGravity = false,
    StaticGravity    = false,

    -- Window gravity + bit gravity above
    UnmapGravity = false,

    -- Used in CreateWindow for backing-store hint
    NotUseful  = false,
    WhenMapped = false,
    Always     = false,

    -- Used in GetWindowAttributes reply
    IsUnmapped   = false,
    IsUnviewable = false,
    IsViewable   = false,

    -- Used in ChangeSaveSet
    SetModeInsert = false,
    SetModeDelete = false,

    -- Used in ChangeCloseDownMode
    DestroyAll      = false,
    RetainPermanent = false,
    RetainTemporary = false,

    -- Window stacking method (in configureWindow)
    Above    = false,
    Below    = false,
    TopIf    = false,
    BottomIf = false,
    Opposite = false,

    -- Circulation direction
    RaiseLowest  = false,
    LowerHighest = false,

    -- Property modes
    PropModeReplace = false,
    PropModePrepend = false,
    PropModeAppend  = false,

    -- Graphics definitions
    GXclear        = false,
    GXand          = false,
    GXandReverse   = false,
    GXcopy         = false,
    GXandInverted  = false,
    GXnoop         = false,
    GXxor          = false,
    GXor           = false,
    GXnor          = false,
    GXequiv        = false,
    GXinvert       = false,
    GXorReverse    = false,
    GXcopyInverted = false,
    GXorInverted   = false,
    GXnand         = false,
    GXset          = false,

    -- Line style
    LineSolid      = false,
    LineOnOffDash  = false,
    LineDoubleDash = false,

    -- Cap style
    CapNotLast    = false,
    CapButt       = false,
    CapRound      = false,
    CapProjecting = false,

    -- Join style
    JoinMiter = false,
    JoinRound = false,
    JoinBevel = false,

    FillSolid          = false,
    FillTiled          = false,
    FillStippled       = false,
    FillOpaqueStippled = false,

    -- fillRule

    EvenOddRule = false,
    WindingRule = false,

    -- Subwindow mode
    ClipByChildren   = false,
    IncludeInferiors = false,

    -- SetClipRectangles ordering
    Unsorted = false,
    YSorted  = false,
    YXSorted = false,
    YXBanded = false,

    -- CoordinateMode for drawing routines
    CoordModeOrigin   = false,
    CoordModePrevious = false,

    -- Polygon shapes
    Complex   = false,
    Nonconvex = false,
    Convex    = false,

    -- Arc modes for PolyFillArc
    ArcChord    = false,
    ArcPieSlice = false,

    -- GC components
    GCFunction          = false,
    GCPlaneMask         = false,
    GCForeground        = false,
    GCBackground        = false,
    GCLineWidth         = false,
    GCLineStyle         = false,
    GCCapStyle          = false,
    GCJoinStyle         = false,
    GCFillStyle         = false,
    GCFillRule          = false,
    GCTile              = false,
    GCStipple           = false,
    GCTileStipXOrigin   = false,
    GCTileStipYOrigin   = false,
    GCFont              = false,
    GCSubwindowMode     = false,
    GCGraphicsExposures = false,
    GCClipXOrigin       = false,
    GCClipYOrigin       = false,
    GCClipMask          = false,
    GCDashOffset        = false,
    GCDashList          = false,
    GCArcMode           = false,
    GCLastBit = false,

    -- Fonts
    FontLeftToRight = false,
    FontRightToLeft = false,
    FontChange = false,

    -- Imaging
    XYBitmap = false,
    XYPixmap = false,
    ZPixmap  = false,

    -- For CreateColormap
    AllocNone = false,
    AllocAll  = false,

    -- Flags used in StoreNamedColor, StoreColors
    DoRed   = false,
    DoGreen = false,
    DoBlue  = false,

    -- QueryBestSize Class
    CursorShape  = false,
    TileShape    = false,
    StippleShape = false,

    -- Keyboard
    AutoRepeatModeOff     = false,
    AutoRepeatModeOn      = false,
    AutoRepeatModeDefault = false,

    LedModeOff = false,
    LedModeOn  = false,

    -- Masks for ChangeKeyboardControl
    KBKeyClickPercent = false,
    KBBellPercent     = false,
    KBBellPitch       = false,
    KBBellDuration    = false,
    KBLed             = false,
    KBLedMode         = false,
    KBKey             = false,
    KBAutoRepeatMode  = false,

    MappingSuccess = false,
    MappingBusy    = false,
    MappingFailed  = false,

    MappingModifier = false,
    MappingKeyboard = false,
    MappingPointer  = false,

    -- Screen saver
    DontPreferBlanking = false,
    PreferBlanking     = false,
    DefaultBlanking    = false,

    DisableScreenSaver    = false,
    DisableScreenInterval = false,

    DontAllowExposures = false,
    AllowExposures     = false,
    DefaultExposures   = false,

    ScreenSaverReset  = false,
    ScreenSaverActive = false,

    -- Hosts
    HostInsert = false,
    HostDelete = false,

    EnableAccess  = false,
    DisableAccess = false,

    -- Display classes
    StaticGray  = false,
    GrayScale   = false,
    StaticColor = false,
    PseudoColor = false,
    TrueColor   = false,
    DirectColor = false,

    -- Byte order
    LSBFirst = false,
    MSBFirst = false,
  },
}
