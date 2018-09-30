.386;
.model flat, stdcall;
option casemap:none;
assume fs:nothing;

include c:/masm32/include/windows.inc;

;const
  LoadLibraryExA           equ  DWORD PTR [PRC + 4*0000];
  ActivateActCtx           equ  DWORD PTR [PRC + 4*0001];
  CreateActCtxA            equ  DWORD PTR [PRC + 4*0002];
  ExitProcess              equ  DWORD PTR [PRC + 4*0003];
  GetSystemDirectoryA      equ  DWORD PTR [PRC + 4*0004];
  GetModuleHandleA         equ  DWORD PTR [PRC + 4*0005];
  SetCapture               equ  DWORD PTR [PRC + 4*0006];
  CreateWindowExA          equ  DWORD PTR [PRC + 4*0007];
  SendMessageA             equ  DWORD PTR [PRC + 4*0008];
  RegisterHotKey           equ  DWORD PTR [PRC + 4*0009];
  MapDialogRect            equ  DWORD PTR [PRC + 4*0010];
  ModifyMenuA              equ  DWORD PTR [PRC + 4*0011];
  GetClientRect            equ  DWORD PTR [PRC + 4*0012];
  UnhookWindowsHookEx      equ  DWORD PTR [PRC + 4*0013];
  IsWindow                 equ  DWORD PTR [PRC + 4*0014];
  SetForegroundWindow      equ  DWORD PTR [PRC + 4*0015];
  TrackPopupMenuEx         equ  DWORD PTR [PRC + 4*0016];
  ShowWindow               equ  DWORD PTR [PRC + 4*0017];
  SetMenuDefaultItem       equ  DWORD PTR [PRC + 4*0018];
  CallNextHookEx           equ  DWORD PTR [PRC + 4*0019];
  LoadCursorA              equ  DWORD PTR [PRC + 4*0020];
  ClientToScreen           equ  DWORD PTR [PRC + 4*0021];
  GetCapture               equ  DWORD PTR [PRC + 4*0022];
  SetCursor                equ  DWORD PTR [PRC + 4*0023];
  SetWinEventHook          equ  DWORD PTR [PRC + 4*0024];
  ReleaseCapture           equ  DWORD PTR [PRC + 4*0025];
  DialogBoxIndirectParamA  equ  DWORD PTR [PRC + 4*0026];
  CreatePopupMenu          equ  DWORD PTR [PRC + 4*0027];
  UnregisterHotKey         equ  DWORD PTR [PRC + 4*0028];
  GetForegroundWindow      equ  DWORD PTR [PRC + 4*0029];
  GetParent                equ  DWORD PTR [PRC + 4*0030];
  AppendMenuA              equ  DWORD PTR [PRC + 4*0031];
  CreateCursor             equ  DWORD PTR [PRC + 4*0032];
  ClipCursor               equ  DWORD PTR [PRC + 4*0033];
  UnhookWinEvent           equ  DWORD PTR [PRC + 4*0034];
  GetCursorPos             equ  DWORD PTR [PRC + 4*0035];
  LoadIconA                equ  DWORD PTR [PRC + 4*0036];
  IsWindowVisible          equ  DWORD PTR [PRC + 4*0037];
  SetWindowsHookExA        equ  DWORD PTR [PRC + 4*0038];
  EndDialog                equ  DWORD PTR [PRC + 4*0039];
  WindowFromPoint          equ  DWORD PTR [PRC + 4*0040];
  Shell_NotifyIconA        equ  DWORD PTR [PRC + 4*0041];

  WMC_TRAY equ (WM_USER + 100);
  ICN_MAIN equ 1;
  CUR_CROS equ 2;

  TXT_ACTV equ 82;
  TXT_DEAC equ 104;

  IDC_DONE equ 11;

  MNU_SHOW equ 3;
  MNU_CLIP equ 6;
  MNU_QUIT equ 12;

  TBL_SIZE equ 42;
  API_MULT equ 07AA1h;
  API_PLUS equ 02408h;

.data?

  PRC DD TBL_SIZE DUP(?);  <-- main function table
  NID DB SIZEOF(NOTIFYICONDATA) DUP(?);  <-- tray icon data
  RCT DB SIZEOF(RECT) DUP(?);  <-- clip rectangle
  EIB DD ?;  <-- executable image base
  PPM DD ?;  <-- tray context menu
  CUR DD ?;  <-- main cursor
  DLG DD ?;  <-- main dialog
  WND DD ?;  <-- foreground window
  IDW DD ?;  <-- WCBT hook handle
  IDH DD ?;

.code

  CRS DW 0FE9Fh, 06606h, 06680h, 006E0h, 00080h, 000F8h, 00080h, 000FEh;

  MTB DB "&Hide/show", 0;
      DW MF_STRING or MF_ENABLED or MF_DEFAULT;
  MED DB "&Enable/disable clipping", 0;
      DW MF_STRING or MF_GRAYED;
      DB "-", 0;
      DW MF_SEPARATOR;
      DB "&Quit", 0;
      DW MF_STRING or MF_ENABLED;
      DB 0;

  TBL DB (@F - $)/2;
      DW 015A3h;
  @@:
      DB "KERNEL32", 0, (@F - $)/2;
      DW 00CA8h, 00D04h, 06C11h, 09093h, 0D5D3h;
  @@:
      DB "USER32", 0, (@F - $)/2;
      DW 01610h, 01682h, 025D0h, 02A49h, 02EE4h, 043B6h, 051F5h, 05445h,
         05F14h, 060B7h, 0631Bh, 06729h, 06885h, 06F79h, 07AF7h, 07CF2h,
         09A84h, 09A92h, 09C45h, 0A865h, 0AC55h, 0AE15h, 0B99Ch, 0B9ABh,
         0BAF2h, 0C526h, 0C872h, 0CA56h, 0CDB4h, 0D170h, 0D912h, 0DF9Ah,
         0FD6Eh, 0FE2Fh, 0FF4Eh;
  @@:
  SHE DB "shell32.dll", 0, (@F - $)/2;
      DW 05A02h;
  @@:
      DB 0;
  CTL DB "COMCTL32", 0;

  version DB "Clipper, v0.6", 0;

  button DB "BUTTON", 0;
  static DB "STATIC", 0;

  pointer  DB "Pointer", 0;
  escape   DB "[Esc] to cancel", 0;
  settings DB "Settings", 0;
  active   DB "Current active window", 0;



Uncapture proc hWnd: DWORD;

  PUSH IDC_ARROW;
  PUSH 0;
  CALL LoadCursorA;
  PUSH EAX;
  CALL SetCursor;
  PUSH IDC_DONE;
  PUSH hWnd;
  CALL UnregisterHotKey;
  CALL ReleaseCapture;
  RET;

Uncapture endp;



ClipHook proc nAct: DWORD, wPrm: DWORD, lPrm: DWORD;

  PUSH EBX;
  MOV EBX, wPrm;
  CMP EBX, WM_MOUSEMOVE;
  JE @fail;
  CMP EBX, WM_MOUSEWHEEL;
  JE @fail;
  CMP EBX, WM_MOUSEHWHEEL;
  JE @fail;
    CALL GetForegroundWindow;
    XOR EDX, EDX;
    CMP EAX, WND;
    JNE @F;
    CMP EDX, IDH;
    JE @F;
      MOV EDX, OFFSET RCT;
    @@:
    PUSH EDX;
    CALL ClipCursor;
  @fail:
  TEST EBX, EBX;
  JE @F;
    PUSH lPrm;
    PUSH EBX;
    PUSH nAct;
    PUSH 0;
    CALL CallNextHookEx;
  @@:
  POP EBX;
  RET;

ClipHook endp;



WCBTHook proc H: DWORD, E: DWORD, W: DWORD,
              O: DWORD, X: DWORD, P: DWORD, T: DWORD;

  PUSH EBX;
  XOR ECX, ECX;
  CMP ECX, IDH;
  JE @nohk;
  MOV EBX, W;
  MOV EDX, E;
  CMP EDX, EVENT_OBJECT_LOCATIONCHANGE;
  JE @F;
  CMP EDX, EVENT_SYSTEM_FOREGROUND;
  @@:
  JNE @F;
    CMP EBX, WND;
    JNE @emph;
      MOV EAX, OFFSET RCT + 8;
      PUSH EAX;
      PUSH EBX;
      SUB EAX, 8;
      PUSH EAX;
      PUSH EBX;
      PUSH EAX;
      PUSH EBX;
      CALL GetClientRect;
      CALL ClientToScreen;
      CALL ClientToScreen;
    @emph:
    PUSH EAX;
    PUSH 0;
    PUSH EAX;
    CALL ClipHook;
  @@:
  MOV EBX, OFFSET WND;
  CMP DWORD PTR [EBX], 0;
  JE @nohk;
    PUSH DWORD PTR [EBX];
    CALL IsWindow;
    TEST EAX, EAX;
  JNE @nohk;
    MOV DWORD PTR [EBX], EAX;
    PUSH TXT_DEAC;
    CALL TrayMenuModify;
    CALL GetForegroundWindow;
    PUSH EAX;
    PUSH -1;
    PUSH WM_LBUTTONUP;
    PUSH DLG;
    CALL SendMessageA;
  @nohk:
  POP EBX;
  RET;

WCBTHook endp;



TrayMenuModify proc T: DWORD, N: DWORD;

  PUSHAD;
  MOV EDI, T;
  ADD EDI, EIB;
  MOV ESI, EDI;
  XOR EAX, EAX;
  LEA ECX, [EAX - 1];
  REPNE SCASB;
  MOV EDX, OFFSET NID;
  LEA EDI, (NOTIFYICONDATA PTR [EDX]).szTip;
  NOT ECX;
  REP MOVSB;
  LEA EBX, [ECX + MF_STRING];
  PUSH EDX;
  PUSH N;
  CALL Shell_NotifyIconA;
  PUSH WND;
  CALL IsWindow;
  TEST EAX, EAX;
  JNE @F;
    OR EBX, MF_GRAYED;
  @@:
  PUSH OFFSET MED;
  PUSH MNU_CLIP;
  PUSH EBX;
  PUSH MNU_CLIP;
  PUSH PPM;
  CALL ModifyMenuA;
  POPAD;
  RET;

TrayMenuModify endp;



ShowOrHide proc hWnd: DWORD;

  PUSH hWnd;
  CALL IsWindowVisible;
  TEST EAX, EAX;
  PUSH SW_HIDE;
  JNE @F;
    PUSH hWnd;
    CALL SetForegroundWindow;
    ADD DWORD PTR [ESP], SW_SHOWNORMAL - SW_HIDE;
  @@:
  PUSH hWnd;
  CALL ShowWindow;
  RET;

ShowOrHide endp;



CreateControl proc dXSt: DWORD, sCls: DWORD, sCap: DWORD, dSty: DWORD,
                   dBgX: DWORD, dBgY: DWORD, dEnX: DWORD, dEnY: DWORD,
                   wPar: DWORD, dDID: DWORD;

  PUSH 0;
  PUSH 0;
  PUSH WM_GETFONT;
  PUSH wPar;
  CALL SendMessageA;
  PUSH EAX;

  PUSH 0;
  PUSH EIB;
  PUSH dDID;
  PUSH wPar;

  PUSH dEnY;
  PUSH dEnX;
  PUSH dBgY;
  PUSH dBgX;

  PUSH ESP;
  PUSH wPar;
  CALL MapDialogRect;

  MOV EAX, dSty;
  OR EAX, WS_CHILD or WS_VISIBLE;
  PUSH EAX;
  PUSH sCap;
  PUSH sCls;
  PUSH dXSt;
  CALL CreateWindowExA;

  POP EDX;
  PUSH EAX;

  PUSH 1;
  PUSH EDX;
  PUSH WM_SETFONT;
  PUSH EAX;
  CALL SendMessageA;

  POP EAX;
  RET;

CreateControl endp;



WndProc proc hWnd: DWORD, uMsg: DWORD, wPrm: DWORD, lPrm: DWORD;

  XOR EAX, EAX;
  MOV EDX, uMsg;
  CMP EDX, WM_CLOSE;
  JE @WM_CLOSE;
  CMP EDX, WM_COMMAND;
  JE @WM_COMMAND;
  CMP EDX, WM_LBUTTONUP;
  JE @WM_LBUTTONUP;
  CMP EDX, WM_HOTKEY;
  JE @WM_HOTKEY;
  CMP EDX, WMC_TRAY;
  JE @WMC_TRAY;
  CMP EDX, WM_INITDIALOG;
  JE @WM_INITDIALOG;
  @EXIT:
    XOR EAX, EAX;
    RET;

  @WM_INITDIALOG:
    MOV ECX, hWnd;
    MOV DLG, ECX;

    PUSH OFFSET version;
    PUSH EAX;
    PUSH WM_SETTEXT;
    PUSH hWnd;

    PUSH WINEVENT_OUTOFCONTEXT or WINEVENT_SKIPOWNTHREAD;
    PUSH EAX;
    PUSH EAX;
    PUSH OFFSET WCBTHook;
    PUSH EIB;
    PUSH EVENT_OBJECT_LOCATIONCHANGE;
    PUSH EVENT_SYSTEM_FOREGROUND;
    CALL SetWinEventHook;
    MOV IDW, EAX;

    CALL SendMessageA;

    PUSH ICN_MAIN;
    PUSH EIB;
    CALL LoadIconA;

    MOV EDX, hWnd;
    MOV ECX, OFFSET NID;

    PUSH EAX;
    PUSH ICON_BIG;
    PUSH WM_SETICON;
    PUSH EDX;

    MOV (NOTIFYICONDATA PTR [ECX]).cbSize, SIZEOF(NOTIFYICONDATA);
    MOV (NOTIFYICONDATA PTR [ECX]).hwnd,   EDX;
    MOV (NOTIFYICONDATA PTR [ECX]).uID,    1;
    MOV (NOTIFYICONDATA PTR [ECX]).uFlags, NIF_MESSAGE or NIF_ICON or NIF_TIP;
    MOV (NOTIFYICONDATA PTR [ECX]).hIcon,  EAX;
    MOV (NOTIFYICONDATA PTR [ECX]).uCallbackMessage, WMC_TRAY;
    invoke TrayMenuModify, TXT_DEAC, NIM_ADD;

    invoke CreateControl, WS_EX_TRANSPARENT, OFFSET button, OFFSET pointer,
        BS_GROUPBOX or WS_GROUP or BS_CENTER,  4,  2,  60, 64, hWnd, 0;
    invoke CreateControl, WS_EX_TRANSPARENT, OFFSET button, OFFSET settings,
        BS_GROUPBOX or WS_GROUP,              68,  2, 128, 64, hWnd, 0;
    invoke CreateControl, WS_EX_TRANSPARENT, OFFSET button, OFFSET active,
        BS_GROUPBOX or WS_GROUP,               4, 68, 192, 64, hWnd, 0;

    invoke CreateControl, WS_EX_TRANSPARENT, OFFSET static, OFFSET escape,
        SS_CENTERIMAGE or SS_NOTIFY or SS_CENTER, 6, 54, 56, 10, hWnd, IDC_DONE;
    invoke CreateControl, WS_EX_TRANSPARENT, OFFSET static, 0,
        SS_CENTERIMAGE or SS_NOTIFY or SS_ICON, 6, 12, 56, 42, hWnd, IDC_DONE;

    PUSH EAX;
    PUSH CUR;
    PUSH STM_SETICON;
    PUSH EAX;
    CALL SendMessageA;

    CALL SendMessageA;

    PUSH VK_ESCAPE;
    PUSH MOD_WIN;
    PUSH MNU_CLIP;
    PUSH hWnd;
    CALL RegisterHotKey;
    JMP @EXIT;

  @WMC_TRAY:
    MOV EAX, lPrm;
    CMP AX, WM_RBUTTONDOWN;
    JE @F;
    CMP AX, WM_LBUTTONDOWN;
    JNE @EXIT;
    @@:

    PUSH 0;
    PUSH hWnd;

    PUSH EAX;
    PUSH EAX;
    PUSH ESP;
    CALL GetCursorPos;

    PUSH hWnd;
    CALL SetForegroundWindow;

    PUSH TPM_CENTERALIGN or TPM_RIGHTBUTTON;
    PUSH PPM;
    CALL TrackPopupMenuEx;
    JMP @EXIT;

  @WM_HOTKEY:
    MOV ECX, wPrm;
    CMP CL, IDC_DONE;
    JNE @F;
      invoke Uncapture, hWnd;
      invoke ShowOrHide, hWnd;
      JMP @EXIT;
    @@:
    CMP CL, MNU_CLIP;
    JNE @EXIT;
      XOR EAX, EAX;
      CMP EAX, WND;
    JE @EXIT;
      MOV ESI, OFFSET IDH;
      MOV EDI, DWORD PTR [ESI];
      TEST EDI, EDI;
      JNE @fail;
      DEC EAX;
      MOV wPrm, EAX;
      MOV EAX, WND;
      MOV lPrm, EAX;
      XOR EAX, EAX;

  @WM_LBUTTONUP:
    CALL GetCapture;
    CMP EAX, hWnd;
    JNE @EXIT;
    invoke Uncapture, hWnd;

    MOV EAX, lPrm;
    CMP wPrm, -1;
    JE @F;
      MOVSX EDX, AX;
      SAR EAX, 16;
      PUSH EAX;
      PUSH EDX;
      PUSH ESP;
      PUSH hWnd;
      CALL ClientToScreen;
      CALL WindowFromPoint;

    @@:
      MOV EBX, EAX;
      PUSH EAX;
      CALL GetParent;
      TEST EAX, EAX;
    JNE @B;

    PUSH EBX;
    CALL SetForegroundWindow;
    MOV ESI, OFFSET IDH;
    MOV EDI, DWORD PTR [ESI];
    TEST EDI, EDI;
    JNE @fail;
    CMP EBX, hWnd;
    JE @EXIT;

      MOV WND, EBX;
      MOV EDI, OFFSET RCT;
      MOV EDI, OFFSET RCT;
      PUSH EDI;
      PUSH EBX;
      CALL GetClientRect;
      PUSH EDI;
      PUSH EBX;
      CALL ClientToScreen;
      LEA EAX, [EDI + 8];
      PUSH EAX;
      PUSH EBX;
      CALL ClientToScreen;
      MOV EBX, ClipHook;
      PUSH 0;
      PUSH EIB;
      PUSH EBX;
      PUSH WH_MOUSE_LL;
      CALL SetWindowsHookExA;
      MOV DWORD PTR [ESI], EAX;
      PUSH EAX;
      PUSH 0;
      PUSH EAX;
      CALL EBX;
      invoke TrayMenuModify, TXT_ACTV, NIM_MODIFY;
      JMP @EXIT;

    @fail:
    invoke TrayMenuModify, TXT_DEAC, NIM_MODIFY;
    PUSH EDI;
    CALL UnhookWindowsHookEx;
    XOR EAX, EAX;
    MOV DWORD PTR [ESI], EAX;
    PUSH EAX;
    PUSH EAX;
    PUSH EAX;
    CALL ClipHook;
    JMP @EXIT;

  @WM_CLOSE:
    MOV wPrm, MNU_SHOW;
  @WM_COMMAND:
    MOV ECX, wPrm;
    CMP CL, IDC_DONE;
    JNE @F;
      PUSH VK_ESCAPE;
      PUSH EAX;
      PUSH IDC_DONE;
      PUSH hWnd;

      invoke ShowOrHide, hWnd;
      PUSH hWnd;
      CALL SetCapture;
      PUSH CUR;
      CALL SetCursor;

      CALL RegisterHotKey;
      JMP @EXIT;
    @@:
    CMP CL, MNU_CLIP;
    JE @WM_HOTKEY;
    CMP CL, MNU_SHOW;
    JNE @F;
      invoke ShowOrHide, hWnd;
      JMP @EXIT;
    @@:
    CMP CL, MNU_QUIT;
    JNE @EXIT;
      PUSH EAX;
      PUSH hWnd;

      PUSH OFFSET NID;
      PUSH NIM_DELETE;
      CALL Shell_NotifyIconA;
      PUSH IDW;
      CALL UnhookWinEvent;
      PUSH IDH;
      CALL UnhookWindowsHookEx;

      CALL EndDialog;
    JMP @EXIT;

WndProc endp;



@main:

  XOR EAX, EAX;  <---------------------------------------- loading APIs [begin]
  LEA ECX, [EAX + TBL_SIZE];
  MOV EDI, OFFSET PRC;
  PUSH EBP;
  PUSH EDI;
  REP STOSD;
  MOV EDI, OFFSET TBL;

  MOV EAX, DWORD PTR FS:[EAX + 48];
  TEST EAX, EAX;
  JS @F;
    MOV EAX, DWORD PTR [EAX + 12];
    MOV ESI, DWORD PTR [EAX + 28];
  @flib:
    LODSD;
    PUSH EAX;
    MOV EAX, DWORD PTR [EAX + 8];
    JMP @flok;
  @@:
    MOV EAX, 0BFF70000h;
    PUSH EAX;

  @flok:
    MOV EDX, (IMAGE_DOS_HEADER PTR [EAX]).e_lfanew;
    MOV EDX, (IMAGE_NT_HEADERS PTR [EAX + EDX]).OptionalHeader.\
    DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
    ADD EDX, EAX;
    MOV ECX, (IMAGE_EXPORT_DIRECTORY PTR [EDX]).NumberOfNames;
    MOV ESI, (IMAGE_EXPORT_DIRECTORY PTR [EDX]).AddressOfNames;
    MOV EBP, (IMAGE_EXPORT_DIRECTORY PTR [EDX]).AddressOfFunctions;
    MOV EBX, (IMAGE_EXPORT_DIRECTORY PTR [EDX]).AddressOfNameOrdinals;
    LEA EBX, [EBX + EAX - 2];
    LEA ESI, [ESI + EAX - 4];
    ADD EBP, EAX;
    SHL ECX, 8;
    PUSH EAX;
    PUSH ESI;
    JMP @load;

    @ldok:
      MOV ESI, DWORD PTR [EAX];
      ADD ESI, DWORD PTR [ESP];
      SHL ECX, 8;
      PUSH EAX;

      XOR EAX, EAX;
      JMP @hash;
      @@:
        IMUL EAX, EAX, API_MULT;
        LEA EAX, [EAX + EDX + API_PLUS];
        ADD ESI, 1;
      @hash:
        MOVZX EDX, BYTE PTR [ESI];
        TEST EDX, EDX;
      JNE @B;

      MOVZX EDX, BYTE PTR [EDI];
      LEA ESI, [EDI - 1];
      JMP @axlt;
      @@:
        SETC CL;
        CMP AX, WORD PTR [ESI + EDX*2];
        JE @axeq;
        JB @axlt;
        LEA ESI, [ESI + EDX*2];
      @axlt:
        ADD DL, CL;
        SHR EDX, 1;
      JNE @B;

      ADD ESI, 2;
      CMP AX, WORD PTR [ESI];
      JNE @load;

      @axeq:
      LEA ESI, [ESI + EDX*2 - 1];
      SUB ESI, EDI;

      MOVZX EAX, WORD PTR [EBX];
      MOV EAX, DWORD PTR [EBP + EAX*4];
      ADD EAX, DWORD PTR [ESP + 4];
      MOV EDX, DWORD PTR [ESP + 12];
      MOV DWORD PTR [EDX + ESI*2], EAX;

    @load:
      POP EAX;
      ADD EBX, 2;
      ADD EAX, 4;
      SHR ECX, 8;
      DEC ECX;
    JGE @ldok;

    POP ESI;
    POP ESI;
    MOV EBX, LoadLibraryExA;
    TEST EBX, EBX;
    JE @flib;

    POP EDX;
    MOVZX EAX, BYTE PTR [EDI];
    LEA EDX, [EDX + EAX*4];
    LEA EDI, [EDI + EAX*2 + 1];
    PUSH EDX;
    PUSH ESI;
    MOV ESI, EDI;
    XOR EAX, EAX;
    REPNE SCASB;

    PUSH EAX;
    PUSH EAX;
    PUSH ESI;
    CALL EBX;
    TEST EAX, EAX;
  JNE @flok;

;  POP EBP;
;  POP EBP;
;  POP EBP;  <---------------------------------------------- loading APIs [end]

  XOR EBX, EBX;
  MOV IDH, EBX;

  MOV ESI, ActivateActCtx;  <-------- enabling XP styles, if applicable [begin]
  TEST ESI, ESI;
  JE @F;
    PUSH EBX;
    PUSH EBX;
    PUSH OFFSET CTL;
    CALL LoadLibraryExA;
    SUB ESP, 256;
    MOV EDX, ESP;
    PUSH EAX;
    PUSH EAX;
    PUSH 124;
    PUSH EDX;
    PUSH EAX;
    PUSH OFFSET SHE;
    PUSH ACTCTX_FLAG_RESOURCE_NAME_VALID or ACTCTX_FLAG_SET_PROCESS_DEFAULT or \
         ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID;
    PUSH 32;

    PUSH 255;
    PUSH EDX;
    CALL GetSystemDirectoryA;
    MOV BYTE PTR [ESP + 32 + EAX], 0;

    PUSH ESP;
    CALL CreateActCtxA;
    PUSH ESP;
    PUSH EAX;
    CALL ESI;  <----------------------- enabling XP styles, if applicable [end]
  @@:

  PUSH EBX;
  CALL GetModuleHandleA;
  MOV EIB, EAX;

  PUSH EBX;        <-- terminating zeroes
  PUSH 0061006Eh;  <-- 'a', 'n'
  PUSH 00610064h;  <-- 'a', 'd'
  PUSH 00720065h;  <-- 'r', 'e'
  PUSH 0056000Ah;  <-- 'V', size=10
  PUSH EBX;        <-- class=0, caption=L""
  PUSH 00000088h;  <-- menu=0, cy
  PUSH 00C80000h;  <-- cx, y=0
  PUSH EBX;        <-- x=0, 0 controls
  PUSH WS_EX_TOOLWINDOW or WS_EX_TOPMOST
  PUSH DS_3DLOOK or DS_ABSALIGN or DS_CENTER or DS_SETFONT or \
       WS_CLIPSIBLINGS or WS_POPUP or WS_VISIBLE or WS_CAPTION or WS_SYSMENU;
  MOV EDX, ESP;  <-- preparing a dialog template for DialogBoxIndirectParamA

  PUSH EBX;
  PUSH WndProc;
  PUSH EBX;
  PUSH EDX;
  PUSH EAX;  <-- preparing arguments for DialogBoxIndirectParamA

  CALL CreatePopupMenu;  <----------------------------- creating a menu [begin]
  MOV EDI, OFFSET MTB;
  MOV ESI, EAX;
  MOV PPM, EAX;
  JMP @menu;
  @@:
    ADD EBX, 3;
    PUSH EDI;
    XOR EAX, EAX;
    LEA ECX, [EAX - 1];
    REPNE SCASB;
    MOVZX ECX, WORD PTR [EDI];
    ADD EDI, 2;
    PUSH EBX;
    PUSH ECX;
    PUSH ESI;
    CALL AppendMenuA;
    TEST BYTE PTR [EDI - 1], MF_DEFAULT / 256;
    JE @menu;
      PUSH 0;
      PUSH EBX;
      PUSH ESI;
      CALL SetMenuDefaultItem;
  @menu:
    CMP BYTE PTR [EDI], 0;
  JNE @B;  <--------------------------------------------- creating a menu [end]

  MOV ECX, 8;  <------------------------------------- creating a cursor [begin]
  PUSH 0;
  @fill:
    MOVZX EAX, WORD PTR [ECX * 2 + OFFSET CRS - 2];
    MOV EDX, EAX;
    MOV ESI, 16;
    @@:
      SHR EDX, 1;
      RCL EAX, 1;
      DEC ESI;
    JG @B;
    PUSH EAX;
    PUSH EAX;
    DEC ECX;
  JG @fill;

  LEA ECX, [EDX + 2];  <-- EDX = 0 here
  @@:
    PUSH [ECX * 4 + ESP];
    PUSH [ESP];
    ADD ECX, 4;
    CMP ECX, 4 * 7;
  JL @B;
  PUSH EDX;
  MOV EBP, ESP;

  DEC EDX;
  PUSH EDX;
  @@:
    PUSH EDX;
    DEC ECX;
  JGE @B;

  MOV EAX, ESP;
  PUSH EBP;
  PUSH EAX;
  PUSH 32;
  PUSH 32;
  PUSH 15;
  PUSH 15;
  PUSH EIB;
  CALL CreateCursor;
  MOV CUR, EAX;
  ADD ESP, 256;  <------------------------------------- creating a cursor [end]

  CALL DialogBoxIndirectParamA;

  PUSH EAX;
  CALL ExitProcess;

end @main;
