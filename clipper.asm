.386;
.model flat, stdcall;
option casemap:none;
assume fs:nothing;

include c:/masm32/include/windows.inc;

  LoadLibraryExA            equ  DWORD PTR [PRC + 4*0000];
  ActivateActCtx            equ  DWORD PTR [PRC + 4*0001];
  CreateActCtxA             equ  DWORD PTR [PRC + 4*0002];
  CloseHandle               equ  DWORD PTR [PRC + 4*0003];
  Process32First            equ  DWORD PTR [PRC + 4*0004];
  ExitProcess               equ  DWORD PTR [PRC + 4*0005];
  GetSystemDirectoryA       equ  DWORD PTR [PRC + 4*0006];
  Process32Next             equ  DWORD PTR [PRC + 4*0007];
  CreateToolhelp32Snapshot  equ  DWORD PTR [PRC + 4*0008];
  GetModuleHandleA          equ  DWORD PTR [PRC + 4*0009];
  ScreenToClient            equ  DWORD PTR [PRC + 4*0010];
  SetCapture                equ  DWORD PTR [PRC + 4*0011];
  CreateWindowExA           equ  DWORD PTR [PRC + 4*0012];
  SetWindowLongA            equ  DWORD PTR [PRC + 4*0013];
  GetWindowRect             equ  DWORD PTR [PRC + 4*0014];
  GetWindowThreadProcessId  equ  DWORD PTR [PRC + 4*0015];
  SendMessageA              equ  DWORD PTR [PRC + 4*0016];
  RegisterHotKey            equ  DWORD PTR [PRC + 4*0017];
  SetWindowPos              equ  DWORD PTR [PRC + 4*0018];
  MapDialogRect             equ  DWORD PTR [PRC + 4*0019];
  MessageBoxIndirectA       equ  DWORD PTR [PRC + 4*0020];
  ModifyMenuA               equ  DWORD PTR [PRC + 4*0021];
  GetClientRect             equ  DWORD PTR [PRC + 4*0022];
  UnhookWindowsHookEx       equ  DWORD PTR [PRC + 4*0023];
  IsWindow                  equ  DWORD PTR [PRC + 4*0024];
  SetForegroundWindow       equ  DWORD PTR [PRC + 4*0025];
  EnableWindow              equ  DWORD PTR [PRC + 4*0026];
  TrackPopupMenuEx          equ  DWORD PTR [PRC + 4*0027];
  ShowWindow                equ  DWORD PTR [PRC + 4*0028];
  SetMenuDefaultItem        equ  DWORD PTR [PRC + 4*0029];
  CallNextHookEx            equ  DWORD PTR [PRC + 4*0030];
  LoadCursorA               equ  DWORD PTR [PRC + 4*0031];
  ClientToScreen            equ  DWORD PTR [PRC + 4*0032];
  GetDlgItem                equ  DWORD PTR [PRC + 4*0033];
  GetCapture                equ  DWORD PTR [PRC + 4*0034];
  SetCursor                 equ  DWORD PTR [PRC + 4*0035];
  SetWinEventHook           equ  DWORD PTR [PRC + 4*0036];
  GetClassNameA             equ  DWORD PTR [PRC + 4*0037];
  ReleaseCapture            equ  DWORD PTR [PRC + 4*0038];
  SendDlgItemMessageA       equ  DWORD PTR [PRC + 4*0039];
  DialogBoxIndirectParamA   equ  DWORD PTR [PRC + 4*0040];
  CreatePopupMenu           equ  DWORD PTR [PRC + 4*0041];
  GetMessagePos             equ  DWORD PTR [PRC + 4*0042];
  UnregisterHotKey          equ  DWORD PTR [PRC + 4*0043];
  GetForegroundWindow       equ  DWORD PTR [PRC + 4*0044];
  GetParent                 equ  DWORD PTR [PRC + 4*0045];
  GetWindowLongA            equ  DWORD PTR [PRC + 4*0046];
  AppendMenuA               equ  DWORD PTR [PRC + 4*0047];
  CreateCursor              equ  DWORD PTR [PRC + 4*0048];
  ClipCursor                equ  DWORD PTR [PRC + 4*0049];
  UnhookWinEvent            equ  DWORD PTR [PRC + 4*0050];
  GetCursorPos              equ  DWORD PTR [PRC + 4*0051];
  LoadIconA                 equ  DWORD PTR [PRC + 4*0052];
  IsWindowVisible           equ  DWORD PTR [PRC + 4*0053];
  CallWindowProcA           equ  DWORD PTR [PRC + 4*0054];
  SetWindowsHookExA         equ  DWORD PTR [PRC + 4*0055];
  EndDialog                 equ  DWORD PTR [PRC + 4*0056];
  WindowFromPoint           equ  DWORD PTR [PRC + 4*0057];
  Shell_NotifyIconA         equ  DWORD PTR [PRC + 4*0058];

  TBL_SIZE equ 60;
  API_MULT equ 07AA1h;
  API_PLUS equ 02408h;

  WMC_TRAY equ (WM_USER + 100);
  ICN_MAIN equ 1;

  TXT_ACTV equ 82;
  TXT_DEAC equ 104;

  IDC_TREE equ 19;
  IDC_DONE equ 20;

  IDC_CLAS equ 21;  <-- these three need to have powers of 2 in the low nibble
  IDC_CAPT equ 22;
  IDC_PROC equ 24;

  IDC_CBME equ 25;
  IDC_BTME equ 26;
  IDC_BTGH equ 27;
  IDC_BTED equ 28;

  TXT_CLAS equ 41;
  TXT_CAPT equ 42;
  TXT_PROC equ 44;

  MNU_SHOW equ 3;   <-- these three depend on menu creation code
  MNU_CLIP equ 6;
  MNU_QUIT equ 12;

.data?

  PRC DD TBL_SIZE DUP(?);  <-- main function table
  BUF DB SIZEOF(PROCESSENTRY32) DUP(?);  <-- 256++ byte buffer for everything
  NID DB SIZEOF(NOTIFYICONDATA) DUP(?);  <-- tray icon data
  RCT DB SIZEOF(RECT) DUP(?);  <-- clip rectangle
  EIB DD ?;  <-- executable image base
  MTC DD ?;  <-- tray context menu
  CUR DD ?;  <-- crosshair cursor
  STA DD ?;  <-- checkbox status
  WCL DD ?;  <-- clipped window
  WFG DD ?;  <-- foreground window
  WMD DD ?;  <-- main dialog window
  HWE DD ?;  <-- window event hook handle
  HLM DD ?;  <-- low-level mouse hook handle

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
      DW 00CA8h, 00D04h, 05EFAh, 0619Ch, 06C11h, 09093h, 0A2EBh, 0AC50h,
         0D5D3h;
  @@:
      DB "USER32", 0, (@F - $)/2;
      DW 001F2h, 01610h, 01682h, 01A45h, 01C4Eh, 0241Ch, 025D0h, 02A49h,
         02AF6h, 02EE4h, 03219h, 043B6h, 051F5h, 05445h, 05F14h, 060B7h,
         062DFh, 0631Bh, 06729h, 06885h, 06F79h, 07AF7h, 07CF2h, 08DF6h,
         09A84h, 09A92h, 09C45h, 0A740h, 0A865h, 0AA6Eh, 0AC55h, 0AE15h,
         0B33Fh, 0B99Ch, 0B9ABh, 0BAF2h, 0C0B9h, 0C526h, 0C872h, 0CA56h,
         0CDB4h, 0D170h, 0D912h, 0DF9Ah, 0EE81h, 0FD6Eh, 0FE2Fh, 0FF4Eh;
  @@:
  SHE DB "shell32.dll", 0, (@F - $)/2;
      DW 05A02h;
  @@:
      DB 0;
  CTL DB "COMCTL32", 0;

  treeview DB "SysTreeView32", 0;
  static   DB "STATIC", 0;
  button   DB "BUTTON", 0;

  texthelp DB "This is a program that allows you to lock the cursor", 10;
           DB "in any window you like. Useful for restricting cursor", 10;
           DB "movement while playing games in windowed mode.", 10, 10;
           DB "Key features:", 10;
           DB "  -  Drag & drop the crosshair or click Memorize to lock", 10;
           DB "  -  The lock is removed while the target is inactive", 10;
           DB "  -  [WIN] + [ESC] toggles the lock on and off", 10;
           DB "  -  All memorized windows lock automatically if active", 10;
           DB "  -  In Edit mode: [ ] = rename, [ENTER] = on / off,", 10;
           DB "     [BACKSPACE] / [DEL] = remove the window", 10;
           DB "  -  System tray menu for easier access", 10;
           DB "  -  The main icon is a broken paperclip =)", 10, 10;
           DB "© hidefromkgb, 2021   |   ";
  version  DB "clipper, v0.6", 0;
  pointer  DB "Pick a window", 0;
  active   DB "Current active window", 0;
  escape   DB "[Esc] to cancel", 0;
  memorize DB "Memorize!", 0;
  gethelp  DB "Help", 0;
  editall  DB "Edit...", 0;
  class    DB "Class:", 0;
  caption  DB "Caption:", 0;
  process  DB "Process:", 0;



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



EnableControl proc uuid: DWORD, what: DWORD;

  PUSH uuid;
  PUSH WMD;
  CALL GetDlgItem;
  PUSH what;
  PUSH EAX;
  CALL EnableWindow;
  RET;

EnableControl endp;



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
    CMP EAX, WCL;
    JNE @F;
    CMP EDX, HLM;
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
  CMP HLM, 0;
  JE @nohk;
  CMP H, 0;
  JE @nohk;
  MOV EBX, W;
  MOV EDX, E;
  CMP EDX, EVENT_OBJECT_LOCATIONCHANGE;
  JE @F;
  CMP EDX, EVENT_SYSTEM_MINIMIZEEND;
  JE @F;
  CMP EDX, EVENT_SYSTEM_FOREGROUND;
  @@:
  JNE @F;
    CMP EBX, WCL;
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
  MOV EBX, OFFSET WCL;
  CMP DWORD PTR [EBX], 0;
  JE @nohk;
    PUSH DWORD PTR [EBX];
    CALL IsWindow;
    TEST EAX, EAX;
  JNE @nohk;
    MOV DWORD PTR [EBX], EAX;
    CALL GetForegroundWindow;
    PUSH EAX;
    PUSH -1;
    PUSH WM_LBUTTONUP;
    PUSH WMD;
    CALL SendMessageA;
  @nohk:
  MOV EDX, E;
  CMP EDX, EVENT_SYSTEM_FOREGROUND;
  JE @F;
  CMP EDX, EVENT_SYSTEM_MINIMIZEEND;
  JNE @quit;
  @@:
    MOV EBX, W;
    MOV WFG, EBX;
    TEST EBX, EBX;
  JE @quit;
    CMP H, 0;
    JE @F;
    PUSH WMD;
    CALL IsWindowVisible;
    TEST EAX, EAX;
  JE @quit;
  @@:
    PUSH EDI;
    MOV EDI, OFFSET BUF;

    PUSH SIZEOF(PROCESSENTRY32);
    PUSH EDI;
    PUSH EBX;
    CALL GetClassNameA;
    PUSH EDI;
    PUSH 0;
    PUSH WM_SETTEXT;
    PUSH TXT_CLAS;
    PUSH WMD;
    CALL SendDlgItemMessageA;

    PUSH EDI;
    PUSH SIZEOF(PROCESSENTRY32);
    PUSH WM_GETTEXT;
    PUSH EBX;
    CALL SendMessageA;
    PUSH EDI;
    PUSH 0;
    PUSH WM_SETTEXT;
    PUSH TXT_CAPT;
    PUSH WMD;
    CALL SendDlgItemMessageA;

    PUSH EBX;
    PUSH ESP;
    PUSH EBX;
    CALL GetWindowThreadProcessId;
    POP EBX;

    PUSH 0;
    PUSH TH32CS_SNAPPROCESS;
    CALL CreateToolhelp32Snapshot;
    PUSH EDI;
    PUSH EAX;
    MOV EDI, EAX;
    CALL Process32First;
    JMP @loop;
    @@:
      CMP EBX, (PROCESSENTRY32 PTR [BUF]).th32ProcessID;
      JE @F;
      PUSH OFFSET BUF;
      PUSH EDI;
      CALL Process32Next;
    @loop:
      TEST EAX, EAX;
      JNE @B;
    @@:

    PUSH EDI;
    CALL CloseHandle;

    MOV EDI, OFFSET (PROCESSENTRY32 PTR [BUF]).szExeFile;  <-- discard all dirs
    MOV ECX, EDI;
    XOR EAX, EAX;
    REPNE SCASB;
    ADD EAX, '\';
    SUB EDI, 2;
    NEG ECX;
    ADD ECX, EDI;
    SHR ECX, 1;
    STD;
    REPNE SCASB;
    CLD;
    TEST ECX, ECX;
    SETNE CL;
    MOVZX ECX, CL;
    LEA EDI, [EDI + ECX + 1];

    PUSH EDI;
    PUSH 0;
    PUSH WM_SETTEXT;
    PUSH TXT_PROC;
    PUSH WMD;
    CALL SendDlgItemMessageA;

    POP EDI;
  @quit:
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
  PUSH WCL;
  CALL IsWindow;
  TEST EAX, EAX;
  JNE @F;
    OR EBX, MF_GRAYED;
  @@:
  PUSH OFFSET MED;
  PUSH MNU_CLIP;
  PUSH EBX;
  PUSH MNU_CLIP;
  PUSH MTC;
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
    invoke WCBTHook, 0, EVENT_SYSTEM_FOREGROUND, WFG, EAX, EAX, EAX, EAX;
  @@:
  PUSH hWnd;
  CALL ShowWindow;
  RET;

ShowOrHide endp;



CreateControl proc sCls: DWORD, sCap: DWORD, dims: DWORD, dDID: DWORD,
                   dSty: DWORD;

  PUSH EBX;
  MOV EBX, WMD;
  PUSH 0;
  PUSH 0;
  PUSH WM_GETFONT;
  PUSH EBX;
  CALL SendMessageA;
  PUSH EAX;

  PUSH 0;
  PUSH EIB;
  PUSH dDID;
  PUSH EBX;

  MOV EAX, dims;
  MOVZX EDX, AL;
  PUSH EDX;
  MOVZX EDX, AH;
  PUSH EDX;
  SHR EAX, 16;
  MOVZX EDX, AL;
  PUSH EDX;
  MOVZX EDX, AH;
  PUSH EDX;

  PUSH ESP;
  PUSH EBX;
  CALL MapDialogRect;

  PUSH dSty;
  PUSH sCap;

  PUSH OFFSET static;
  PUSH 0; or WS_EX_STATICEDGE;
  CMP sCls, 0;
  JE @F;
    MOV DWORD PTR [ESP + 4], OFFSET button;
  JG @F;
    MOV DWORD PTR [ESP + 4], OFFSET treeview;
    OR DWORD PTR [ESP], WS_EX_CLIENTEDGE;
  @@:
  CALL CreateWindowExA;

  POP EDX;
  PUSH EAX;

  PUSH 1;
  PUSH EDX;
  PUSH WM_SETFONT;
  PUSH EAX;
  CALL SendMessageA;

  POP EAX;
  POP EBX;
  RET;

CreateControl endp;

control macro ctrl: REQ, sCls: REQ, sCap: REQ, dims: REQ, dDID: REQ, dSty: REQ;

  PUSH dSty or WS_CHILD;
  PUSH dDID;
  PUSH dims;
  PUSH sCap;
  PUSH sCls;
  CALL ctrl;

endm;



AddItemToTree proc prev: DWORD, text: DWORD, flag: DWORD;

  PUSH ESI;
  PUSH EDI;
  PUSH EBX;
  MOV EDI, WMD;
  MOV ESI, SendDlgItemMessageA;
  XOR EBX, EBX;
  LEA EAX, [EBX + 2];
  CMP prev, EBX;
  JNE @F;
    DEC EAX;
  @@:
  PUSH EAX;                      <-- item.lParam
  PUSH EBX;                      <-- item.cChildren
  PUSH EBX;                      <-- item.iSelectedImage
  PUSH EBX;                      <-- item.iImage
  PUSH EBX;                      <-- item.cchTextMax
  PUSH OFFSET BUF;               <-- item.pszText

  PUSH DWORD PTR [ESP];
  PUSH SIZEOF(PROCESSENTRY32);
  PUSH WM_GETTEXT;
  PUSH text;
  PUSH EDI;
  CALL ESI;

  MOV EAX, EBX;
  CMP prev, EBX;
  JE @F;
    PUSH EBX;
    PUSH EBX;
    PUSH BM_GETCHECK;
    PUSH flag;
    PUSH EDI;
    CALL ESI;
    SHL EAX, 12;
  @@:
  LEA ECX, [EAX + 1000h];

  PUSH TVIS_STATEIMAGEMASK;      <-- item.stateMask
  PUSH ECX;                      <-- item.state
  PUSH EBX;                      <-- item.hItem
  PUSH TVIF_TEXT or TVIF_STATE;  <-- item.mask
  PUSH TVI_LAST;                 <-- hInsertAfter
  PUSH prev;                     <-- hParent

  PUSH ESP;
  PUSH EBX;
  PUSH TVM_INSERTITEM;
  PUSH IDC_TREE;
  PUSH EDI;
  CALL ESI;
  POP EBX;
  POP EDI;
  POP ESI;
  RET;

AddItemToTree endp;



EditProc proc hWnd: DWORD, uMsg: DWORD, wPrm: DWORD, lPrm: DWORD;

  PUSH GWLP_USERDATA;
  PUSH hWnd;
  CALL GetWindowLongA;

  PUSH lPrm;
  PUSH wPrm;
  PUSH uMsg;
  PUSH hWnd;
  PUSH EAX;
  CALL CallWindowProcA;

  CMP uMsg, WM_GETDLGCODE;
  JNE @F;
    OR EAX, DLGC_WANTALLKEYS;
  @@:
  RET;

EditProc endp;



DlgProc proc hWnd: DWORD, uMsg: DWORD, wPrm: DWORD, lPrm: DWORD;

  XOR EBX, EBX;  <-- for some weird reason on all versions of Windows and WINE
              ;      the dialog proc preserves EBX; let`s take advantage of it
  MOV ECX, uMsg;
  CMP ECX, WM_CLOSE;
  JE @WM_CLOSE;
  CMP ECX, WM_NOTIFY;
  JE @WM_NOTIFY;
  CMP ECX, WM_COMMAND;
  JE @WM_COMMAND;
  CMP ECX, WM_LBUTTONUP;
  JE @WM_LBUTTONUP;
  CMP ECX, WM_HOTKEY;
  JE @WM_HOTKEY;
  CMP ECX, WMC_TRAY;
  JE @WMC_TRAY;
  CMP ECX, WM_INITDIALOG;
  JE @WM_INITDIALOG;
  @EXIT_FALSE:
    XOR EAX, EAX;
    RET;
  @EXIT_TRUE:
    XOR EAX, EAX;
    INC EAX;
    RET;

  @WM_INITDIALOG:
    MOV ECX, hWnd;
    MOV WMD, ECX;

    PUSH OFFSET version;
    PUSH EBX;
    PUSH WM_SETTEXT;
    PUSH hWnd;
    CALL SendMessageA;

    PUSH WINEVENT_OUTOFCONTEXT or WINEVENT_SKIPOWNTHREAD;
    PUSH EBX;
    PUSH EBX;
    PUSH OFFSET WCBTHook;
    PUSH EIB;
    PUSH EVENT_OBJECT_LOCATIONCHANGE;
    PUSH EVENT_SYSTEM_FOREGROUND;
    CALL SetWinEventHook;
    MOV HWE, EAX;

    PUSH ICN_MAIN;
    PUSH EIB;
    CALL LoadIconA;

    MOV EDX, hWnd;
    MOV ECX, OFFSET NID;

    MOV (NOTIFYICONDATA PTR [ECX]).cbSize, SIZEOF(NOTIFYICONDATA);
    MOV (NOTIFYICONDATA PTR [ECX]).hwnd,   EDX;
    MOV (NOTIFYICONDATA PTR [ECX]).uID,    1;
    MOV (NOTIFYICONDATA PTR [ECX]).uFlags, NIF_MESSAGE or NIF_ICON or NIF_TIP;
    MOV (NOTIFYICONDATA PTR [ECX]).hIcon,  EAX;
    MOV (NOTIFYICONDATA PTR [ECX]).uCallbackMessage, WMC_TRAY;

    PUSH EAX;
    PUSH ICON_BIG;
    PUSH WM_SETICON;
    PUSH EDX;
    CALL SendMessageA;

    invoke TrayMenuModify, TXT_DEAC, NIM_ADD;

    PUSH ESI;
    MOV ESI, CreateControl;

    control ESI, 1, OFFSET pointer,  04023C3Bh, EBX, \
        BS_GROUPBOX or WS_VISIBLE or BS_CENTER;
    control ESI, 1, OFFSET active,   4402983Bh, EBX, BS_GROUPBOX or WS_VISIBLE;
    control ESI, -1, EBX, 44429838h, IDC_TREE, TVS_INFOTIP or TVS_LINESATROOT \
        or TVS_HASLINES or TVS_NOHSCROLL or TVS_EDITLABELS or TVS_HASBUTTONS;
    PUSH WS_CHILD or TVS_CHECKBOXES or TVS_INFOTIP or TVS_LINESATROOT \
         or TVS_HASLINES or TVS_NOHSCROLL or TVS_EDITLABELS or TVS_HASBUTTONS;
    PUSH GWL_STYLE;
    PUSH EAX;
    CALL SetWindowLongA;

    control ESI, 1, OFFSET memorize, 080B360Ah, IDC_CBME, BS_AUTOCHECKBOX \
        or BS_VCENTER or BS_FLAT or WS_VISIBLE or WS_TABSTOP or WS_DISABLED;
    control ESI, EBX, OFFSET escape, 06313809h, IDC_DONE, \
        WS_VISIBLE or SS_NOTIFY or SS_CENTERIMAGE or SS_CENTER;
    control ESI, EBX, EBX,           0615381Ch, IDC_DONE, \
        WS_VISIBLE or SS_NOTIFY or SS_CENTERIMAGE or SS_ICON;

    PUSH EBX;
    PUSH CUR;
    PUSH STM_SETICON;
    PUSH EAX;
    CALL SendMessageA;

    control ESI, 1, OFFSET class,    480B320Ah, IDC_CLAS, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_AUTOCHECKBOX;
    control ESI, 1, OFFSET caption,  4815320Ah, IDC_CAPT, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_AUTOCHECKBOX;
    control ESI, 1, OFFSET process,  481F320Ah, IDC_PROC, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_AUTOCHECKBOX;
    control ESI, 1, OFFSET memorize, 482B300Eh, IDC_BTME, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_PUSHBUTTON \
        or WS_DISABLED;
    control ESI, 1, OFFSET gethelp,  782B300Eh, IDC_BTGH, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_PUSHBUTTON;
    control ESI, 1, OFFSET editall, 0A82B300Eh, IDC_BTED, \
        WS_VISIBLE or WS_TABSTOP or BS_VCENTER or BS_FLAT or BS_AUTOCHECKBOX \
        or BS_PUSHLIKE;

    control ESI, EBX, EBX, 7A0B5E0Ah, TXT_CLAS, \
        WS_VISIBLE or SS_CENTERIMAGE or SS_ENDELLIPSIS;
    control ESI, EBX, EBX, 7A155E0Ah, TXT_CAPT, \
        WS_VISIBLE or SS_CENTERIMAGE or SS_ENDELLIPSIS;
    control ESI, EBX, EBX, 7A1F5E0Ah, TXT_PROC, \
        WS_VISIBLE or SS_CENTERIMAGE or SS_PATHELLIPSIS;

    PUSH VK_ESCAPE;
    PUSH MOD_WIN;
    PUSH MNU_CLIP;
    PUSH hWnd;
    CALL RegisterHotKey;
    invoke WCBTHook, EBX, EVENT_SYSTEM_FOREGROUND, hWnd, EBX, EBX, EBX, EBX;
    POP ESI;
    JMP @EXIT_FALSE;

  @WMC_TRAY:
    MOV ECX, lPrm;
    CMP CX, WM_RBUTTONDOWN;
    JE @F;
    CMP CX, WM_LBUTTONDOWN;
    JNE @EXIT_FALSE;
    @@:
    PUSH EBX;
    MOV EAX, hWnd;
    PUSH EAX;
    PUSH EAX;
    CALL SetForegroundWindow;
    PUSH EBX;
    PUSH EBX;
    PUSH ESP;
    CALL GetCursorPos;
    PUSH TPM_CENTERALIGN or TPM_RIGHTBUTTON;
    PUSH MTC;
    CALL TrackPopupMenuEx;
    JMP @EXIT_FALSE;

  @WM_NOTIFY:
    CMP wPrm, IDC_TREE;
    JNE @EXIT_FALSE;
    MOV EBX, lPrm;
    CMP (NMHDR PTR [EBX]).code, TVN_ENDLABELEDIT;
    JNE @F;
      PUSH 1;
      PUSH DWLP_MSGRESULT;
      PUSH hWnd;
      CALL SetWindowLongA;
      JMP @EXIT_TRUE;
    @@:
    CMP (NMHDR PTR [EBX]).code, TVN_BEGINLABELEDIT;
    JNE @F;
      PUSH 0;
      PUSH 0;
      PUSH TVM_GETEDITCONTROL;
      PUSH IDC_TREE;
      PUSH hWnd;
      CALL SendDlgItemMessageA;
      MOV EBX, EAX;
      PUSH GWL_WNDPROC;
      PUSH EBX;
      CALL GetWindowLongA;
      PUSH EAX;
      PUSH GWLP_USERDATA
      PUSH EBX;
      CALL SetWindowLongA;
      PUSH EditProc;
      PUSH GWL_WNDPROC;
      PUSH EBX;
      CALL SetWindowLongA;
      JMP @EXIT_TRUE;
    @@:
    CMP (NMHDR PTR [EBX]).code, NM_CLICK;
    JNE @EXIT_FALSE;
      CALL GetMessagePos;
      PUSH 0;
      PUSH 0;
      MOVZX EDX, AX;
      SHR EAX, 16;
      PUSH EAX;
      PUSH EDX;

      PUSH ESP;
      PUSH (NMHDR PTR [EBX]).hwndFrom;
      CALL ScreenToClient;

      PUSH ESP;
      PUSH 0;
      PUSH TVM_HITTEST;
      PUSH (NMHDR PTR [EBX]).hwndFrom;
      CALL SendMessageA;

      TEST (TVHITTESTINFO PTR [ESP]).flags, TVHT_ONITEMSTATEICON;
      JE @EXIT_FALSE;
      PUSH (TVHITTESTINFO PTR [ESP]).hItem;
      PUSH TVGN_CARET;
      PUSH TVM_SELECTITEM;
      PUSH (NMHDR PTR [EBX]).hwndFrom;
      CALL SendMessageA;
    JMP @EXIT_TRUE;

  @WM_HOTKEY:
    MOV ECX, wPrm;
    CMP CL, IDC_DONE;
    JNE @F;
      invoke Uncapture, hWnd;
      invoke ShowOrHide, hWnd;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, MNU_CLIP;
    JNE @EXIT_FALSE;
      CMP EBX, WCL;
    JE @EXIT_FALSE;
      MOV ESI, OFFSET HLM;
      MOV EDI, DWORD PTR [ESI];
      TEST EDI, EDI;
      JNE @fail;
      DEC EBX;
      MOV wPrm, EBX;
      MOV EBX, WCL;
      MOV lPrm, EBX;

  @WM_LBUTTONUP:
    MOV EAX, lPrm;
    CMP wPrm, -1;
    JE @F;
      CALL GetCapture;
      CMP EAX, hWnd;
      JNE @EXIT_FALSE;
      invoke Uncapture, hWnd;
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
    MOV ESI, OFFSET HLM;
    MOV EDI, DWORD PTR [ESI];
    TEST EDI, EDI;
    JNE @fail;
    CMP EBX, hWnd;
    JE @EXIT_FALSE;

      MOV WCL, EBX;
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
      JMP @EXIT_FALSE;

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
    JMP @EXIT_FALSE;

  @WM_CLOSE:
    MOV wPrm, MNU_SHOW;
  @WM_COMMAND:
    MOV ECX, wPrm;
    CMP CL, IDC_BTME;
    JNE @F;
      invoke AddItemToTree, EBX, TXT_PROC, IDC_PROC;
      MOV EBX, EAX;
      invoke AddItemToTree, EBX, TXT_CLAS, IDC_CLAS;
      invoke AddItemToTree, EBX, TXT_CAPT, IDC_CAPT;
      invoke AddItemToTree, EBX, TXT_PROC, IDC_PROC;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, IDC_BTGH;
    JNE @F;
      PUSH LANG_NEUTRAL;
      PUSH EBX;
      PUSH EBX;
      PUSH ICN_MAIN;
      PUSH MB_OK or MB_USERICON;
      PUSH OFFSET gethelp;
      PUSH OFFSET texthelp;
      PUSH EIB;
      PUSH hWnd;
      PUSH SIZEOF(MSGBOXPARAMSA);
      PUSH ESP;
      CALL MessageBoxIndirectA;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, IDC_CLAS;
    JE @F;
    CMP CL, IDC_CAPT;
    JE @F;
    CMP CL, IDC_PROC;
    @@:
    JNE @F;
      PUSH EBX;
      PUSH EBX;
      PUSH BM_GETCHECK;
      MOVZX EBX, CL;
      PUSH EBX;
      AND EBX, 0Fh;
      PUSH hWnd;
      CALL SendDlgItemMessageA;
      TEST EAX, EAX;
      JE @zero;
      OR STA, EBX;
      JMP @btre;
      @zero:
      NOT EBX;
      AND STA, EBX;
      @btre:
      MOV EBX, STA;
      invoke EnableControl, IDC_CBME, EBX;
      invoke EnableControl, IDC_BTME, EBX;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, IDC_BTED;
    JNE @F;
      PUSH IDC_TREE;
      PUSH hWnd;
      CALL GetDlgItem;
      PUSH EAX;

      PUSH SWP_SHOWWINDOW;
      PUSH 3Dh;
      PUSH EBX;
      PUSH EBX;
      PUSH EBX;

      PUSH EAX;
      CALL IsWindowVisible;
      LEA EBX, [EAX * 2 - 1];

      PUSH ESP;
      PUSH hWnd;
      CALL MapDialogRect;

      IMUL EBX, DWORD PTR [ESP + 12];

      PUSH ESP;
      PUSH hWnd;
      CALL GetWindowRect;

      MOV EAX, DWORD PTR [ESP + 0];
      SUB DWORD PTR [ESP + 8], EAX;
      ADD EBX, DWORD PTR [ESP + 4];
      SUB DWORD PTR [ESP + 12], EBX;

      PUSH HWND_TOPMOST;
      PUSH hWnd;
      CALL SetWindowPos;

      CALL ShowOrHide;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, IDC_DONE;
    JNE @F;
      invoke ShowOrHide, hWnd;
      PUSH hWnd;
      CALL SetCapture;
      PUSH CUR;
      CALL SetCursor;
      PUSH VK_ESCAPE;
      PUSH EBX;
      PUSH IDC_DONE;
      PUSH hWnd;
      CALL RegisterHotKey;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, MNU_CLIP;
    JE @WM_HOTKEY;
    CMP CL, MNU_SHOW;
    JNE @F;
      invoke ShowOrHide, hWnd;
      JMP @EXIT_FALSE;
    @@:
    CMP CL, MNU_QUIT;
    JNE @EXIT_FALSE;
      invoke TrayMenuModify, TXT_DEAC, NIM_DELETE;
      PUSH HWE;
      CALL UnhookWinEvent;
      PUSH HLM;
      CALL UnhookWindowsHookEx;
      PUSH EBX;
      PUSH hWnd;
      CALL EndDialog;
    JMP @EXIT_FALSE;

DlgProc endp;



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
  MOV STA, EBX;
  MOV HLM, EBX;
  MOV WFG, EBX;

  MOV ESI, ActivateActCtx;  <-------- enabling XP styles, if applicable [begin]
  TEST ESI, ESI;
  JE @F;
    PUSH EBX;
    PUSH EBX;
    PUSH OFFSET CTL;
    CALL LoadLibraryExA;
    MOV EDX, OFFSET BUF;
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
    MOV BYTE PTR [EAX + OFFSET BUF], 0;

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
  PUSH 00000041h;  <-- menu=0, cy
  PUSH 00E00000h;  <-- cx, y=0
  PUSH EBX;        <-- x=0, 0 controls
  PUSH WS_EX_TOOLWINDOW or WS_EX_TOPMOST
  PUSH DS_3DLOOK or DS_ABSALIGN or DS_CENTER or DS_SETFONT or \
       WS_CLIPSIBLINGS or WS_POPUP or WS_VISIBLE or WS_CAPTION or WS_SYSMENU;
  MOV EDX, ESP;  <-- preparing a dialog template for DialogBoxIndirectParamA

  PUSH EBX;
  PUSH DlgProc;
  PUSH EBX;
  PUSH EDX;
  PUSH EAX;  <-- preparing arguments for DialogBoxIndirectParamA

  CALL CreatePopupMenu;  <----------------------------- creating a menu [begin]
  MOV EDI, OFFSET MTB;
  MOV ESI, EAX;
  MOV MTC, EAX;
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
