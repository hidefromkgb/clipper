.386;
.model flat, stdcall;
option casemap:none;
assume fs:nothing;

include \masm32\include\windows.inc;



IPersistFile STRUCT
  QueryInterface         DD ?;  <-- 3 params
  AddRef                 DD ?;  <-- 1 params
  Release                DD ?;  <-- 1 params
  GetClassID             DD ?;  <-- 2 params
  IsDirty                DD ?;  <-- 1 params
  Load                   DD ?;  <-- 3 params
  Save                   DD ?;  <-- 3 params
  SaveCompleted          DD ?;  <-- 2 params
  GetCurFile             DD ?;  <-- 2 params
IPersistFile ENDS;

IShellLink STRUCT
  QueryInterface         DD ?;  <-- 3 params
  AddRef                 DD ?;  <-- 1 params
  Release                DD ?;  <-- 1 params
  GetPath                DD ?;  <-- 4 params
  GetIDList              DD ?;  <-- 1 params
  SetIDList              DD ?;  <-- 1 params
  GetDescription         DD ?;  <-- 2 params
  SetDescription         DD ?;  <-- 1 params
  GetWorkingDirectory    DD ?;  <-- 2 params
  SetWorkingDirectory    DD ?;  <-- 1 params
  GetArguments           DD ?;  <-- 2 params
  SetArguments           DD ?;  <-- 1 params
  GetHotkey              DD ?;  <-- 1 params
  SetHotkey              DD ?;  <-- 1 params
  GetShowCmd             DD ?;  <-- 1 params
  SetShowCmd             DD ?;  <-- 1 params
  GetIconLocation        DD ?;  <-- 3 params
  SetIconLocation        DD ?;  <-- 2 params
  SetRelativePath        DD ?;  <-- 2 params
  Resolve                DD ?;  <-- 2 params
  SetPath                DD ?;  <-- 1 params
IShellLink ENDS;



;const

COMMENT #
  [ FF81 ]  GetEnhMetaFileA / ResizePalette
  [ 24D2 ]  GetCurrentDirectoryA / SwitchToFiber
  [ 3587 ]  GetConsoleProcessList / GetStringScripts
  [ 4FE0 ]  CallNamedPipeW / FreeLibrary
#
  LoadLibraryExA         equ  DWORD PTR [PRC + 4*000];

  ; <-- kernel32
  CreateActCtxA          equ  DWORD PTR [PRC + 4*001];
  GetSystemDirectoryA    equ  DWORD PTR [PRC + 4*002];
  ActivateActCtx         equ  DWORD PTR [PRC + 4*003];
  GetModuleHandleA       equ  DWORD PTR [PRC + 4*004];
  DeactivateActCtx       equ  DWORD PTR [PRC + 4*005];

  ; <-- user32
  DestroyMenu            equ  DWORD PTR [PRC + 4*006];
  SendDlgItemMessageA    equ  DWORD PTR [PRC + 4*007];
  ModifyMenuA            equ  DWORD PTR [PRC + 4*008];
  ClipCursor             equ  DWORD PTR [PRC + 4*009];
  ReleaseCapture         equ  DWORD PTR [PRC + 4*010];
  SetWinEventHook        equ  DWORD PTR [PRC + 4*011];
  MessageBoxIndirectA    equ  DWORD PTR [PRC + 4*012];
  ShowWindow             equ  DWORD PTR [PRC + 4*013];
  SendMessageA           equ  DWORD PTR [PRC + 4*014];
  DialogBoxParamA        equ  DWORD PTR [PRC + 4*015];
  SetWindowsHookExA      equ  DWORD PTR [PRC + 4*016];
  GetParent              equ  DWORD PTR [PRC + 4*017];
  SetForegroundWindow    equ  DWORD PTR [PRC + 4*018];
  RegisterHotKey         equ  DWORD PTR [PRC + 4*019];
  CallNextHookEx         equ  DWORD PTR [PRC + 4*020];
  GetForegroundWindow    equ  DWORD PTR [PRC + 4*021];
  GetClientRect          equ  DWORD PTR [PRC + 4*022];
  CreatePopupMenu        equ  DWORD PTR [PRC + 4*023];
  ClientToScreen         equ  DWORD PTR [PRC + 4*024];
  IsWindow               equ  DWORD PTR [PRC + 4*025];
  AppendMenuA            equ  DWORD PTR [PRC + 4*026];
  UnhookWinEvent         equ  DWORD PTR [PRC + 4*027];
  GetDlgItem             equ  DWORD PTR [PRC + 4*028];
  IsWindowVisible        equ  DWORD PTR [PRC + 4*029];
  TrackPopupMenuEx       equ  DWORD PTR [PRC + 4*030];
  LoadCursorA            equ  DWORD PTR [PRC + 4*031];
  LoadIconA              equ  DWORD PTR [PRC + 4*032];
  SetMenuDefaultItem     equ  DWORD PTR [PRC + 4*033];
  WindowFromPoint        equ  DWORD PTR [PRC + 4*034];
  UnregisterHotKey       equ  DWORD PTR [PRC + 4*035];
  UnhookWindowsHookEx    equ  DWORD PTR [PRC + 4*036];
  SetCursor              equ  DWORD PTR [PRC + 4*037];
  SetCapture             equ  DWORD PTR [PRC + 4*038];
  GetCursorPos           equ  DWORD PTR [PRC + 4*039];
  EndDialog              equ  DWORD PTR [PRC + 4*040];
  GetClassNameA          equ  DWORD PTR [PRC + 4*041];

  ; <-- ole32
  CoInitializeEx         equ  DWORD PTR [PRC + 4*042];
  CoCreateInstance       equ  DWORD PTR [PRC + 4*043];
  CoUninitialize         equ  DWORD PTR [PRC + 4*044];

  ; <-- shell32.dll
  Shell_NotifyIconA      equ  DWORD PTR [PRC + 4*045];



  ICN_MAIN equ 1;
  CUR_CROS equ 2;

  MNU_SHOW equ 1;
  MNU_CLIP equ 2;
  MNU_QUIT equ 4;

  DLG_MAIN equ 10;
  MLB_DONE equ 101;

  MCB_PNWC equ 102;
  MCB_EOWC equ 103;
  MLB_TOGL equ 104;
  MLB_EXIT equ 105;
  MHK_TOGL equ 106;
  MHK_EXIT equ 107;

  MLB_CLAS equ 108;
  MLB_TITL equ 109;
  MID_CLAS equ 110;
  MID_TITL equ 111;
  MCB_CLAS equ 112;
  MCB_TITL equ 113;
  MCB_RMIN equ 114;
  MBT_LINK equ 115;

  MGB_WPTR equ 116;
  MGB_CONF equ 117;
  MGB_ACTW equ 118;

  WMC_TRAY equ (WM_USER + 100);
  TBL_SIZE equ 48;

  API_MULT equ 6353;
  API_PLUS equ -8;

  TXT_ACTV equ 82;
  TXT_DEAC equ 104;


.data?

  PRC DD TBL_SIZE DUP (?);
  NID DB SIZEOF(NOTIFYICONDATA) DUP(?);
  RCT DB SIZEOF(RECT) DUP(?);

  IMB DD ?;    <-- .exe image base
  IDH DD ?;    <-- WH_MOUSE hook
  IDW DD ?;    <-- WinEvent hook

  DLG DD ?;    <-- main dialog
  WND DD ?;    <-- foreground window
  PPM DD ?;    <-- tray context menu

  IDN DD ?;    <-- main control


.code

  COMMENT #
  TXT DB MCB_PNWC, "Захват свежесозданного окна", 0;
      DB MCB_EOWC, "Выходить при закрытии окна", 0;
      DB MLB_TOGL, "Вкл./выкл.:", 0;
      DB MLB_EXIT, "Выход:", 0;

      DB MLB_CLAS, "Класс:", 0;
      DB MLB_TITL, "Текст:", 0;
      DB MCB_CLAS, "Класс", 0;
      DB MCB_TITL, "Текст", 0;
      DB MCB_RMIN, "Запуск в фоне", 0;
      DB MBT_LINK, "Ярлык на рабстол с", 0Ah, "этими параметрами", 0;

      DB MGB_WPTR, "[ Указатель ]", 0;
      DB MGB_CONF, "Настройки", 0;
      DB MGB_ACTW, "Текущее активное окно", 0;
      DB 0, "Clipper, v0.6", 0;
  #

  TXT DB MCB_PNWC, "Pick the next window created", 0;
      DB MCB_EOWC, "Exit on window closure", 0;
      DB MLB_TOGL, "On/off key:", 0;
      DB MLB_EXIT, "Exit key:", 0;

      DB MLB_CLAS, "Class:", 0;
      DB MLB_TITL, "Title:", 0;
      DB MCB_CLAS, "Use class", 0;
      DB MCB_TITL, "Use title", 0;
      DB MCB_RMIN, "Run minimized", 0;
      DB MBT_LINK, "Create a desktop", 0Ah, "icon for this config", 0;

      DB MGB_WPTR, "[ Pointer ]", 0;
      DB MGB_CONF, "Settings", 0;
      DB MGB_ACTW, "Current active window", 0;
      DB 0, "Clipper, v0.6", 0;

  UND DB "<undefined>", 0;

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
      DW 04153h;
  @@:
      DB "kernel32", 0, (@F - $)/2;
      DW 02954h, 045B3h, 04B68h, 05433h, 0AE41h;
  @@:
      DB "user32", 0, (@F - $)/2;
      DW 00017h, 0046Eh, 022F6h, 023B6h, 027D5h, 02AE5h, 03659h, 03729h;
      DW 03D20h, 043F3h, 0523Eh, 06052h, 063D7h, 06749h, 06849h, 0684Bh;
      DW 068E5h, 06ED5h, 06F92h, 08844h, 08BA6h, 08D84h, 094E6h, 0969Ah;
      DW 09FFBh, 0A397h, 0A9C2h, 0AD75h, 0B2FEh, 0B3CCh, 0B415h, 0C632h;
      DW 0C890h, 0D090h, 0D55Fh, 0F070h;
  @@:
      DB "ole32", 0, (@F - $)/2;
      DW 04521h, 07AEBh, 0DC67h;
  @@:
  @shel:
      DB "shell32.dll", 0, (@F - $)/2;
      DW 03302h;
  @@:
      DB 0;


@main:

  XOR EAX, EAX;
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

  POP EBP;
  POP EBP;
  POP EBP;

  PUSH EAX;
  CALL GetModuleHandleA;
  MOV IMB, EAX;

  CALL CreatePopupMenu;
  MOV EDI, OFFSET MTB;
  MOV ESI, EAX;
  MOV PPM, EAX;
  XOR EBX, EBX;
  JMP @menu;

  @@:
    INC EBX;
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
    TEST BYTE PTR [EDI - 1], MF_DEFAULT/256;
    JE @menu;
      PUSH 0;
      PUSH EBX;
      PUSH ESI;
      CALL SetMenuDefaultItem;
  @menu:
    CMP BYTE PTR [EDI], 0;
  JNE @B;

  XOR EBX, EBX;
  MOV IDH, EBX;
  MOV WND, EBX;

  PUSH EBX;
  PUSH EBX;
  CALL CoInitializeEx;

  MOV ESI, ActivateActCtx;
  TEST ESI, ESI;
  JE @F;
    SUB ESP, 256;
    MOV EDX, ESP;
    PUSH EAX;
    PUSH EAX;
    PUSH 124;
    PUSH EDX;
    PUSH EAX;
    PUSH @shel;
    PUSH ACTCTX_FLAG_RESOURCE_NAME_VALID or \
         ACTCTX_FLAG_SET_PROCESS_DEFAULT or \
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
    CALL ESI;
  @@:

  PUSH ICN_MAIN;
  PUSH IMB;
  CALL LoadIconA;
  PUSH EAX;
  PUSH OFFSET MainProc;
  PUSH EBX;
  PUSH DLG_MAIN;
  PUSH IMB;
  CALL DialogBoxParamA;

  TEST ESI, ESI;
  JE @F;
    PUSH 0;
    CALL DeactivateActCtx;
    ADD ESP, 256 + 32 - 4;
  @@:

  CALL CoUninitialize;
  XOR EAX, EAX;
  RET;



MakeIcon proc;

;  CLSID_ShellLinkA GUID {000021401h, 00000h, 00000h,
;                        {0C0h, 000h, 000h, 000h, 000h, 000h, 000h, 046h}};
;  CLSID_ShellLinkW GUID {0000214F9h, 00000h, 00000h,
;                        {0C0h, 000h, 000h, 000h, 000h, 000h, 000h, 046h}};
;  IID_IShellLink   GUID {0000214EEh, 00000h, 00000h,
;                        {0C0h, 000h, 000h, 000h, 000h, 000h, 000h, 046h}};
;  IID_IPersistFile GUID {00000010Bh, 00000h, 00000h,
;                        {0C0h, 000h, 000h, 000h, 000h, 000h, 000h, 046h}};

  PUSHAD;

  XOR EAX, EAX;
  MOV EDX, 46000000h;
  MOV ECX, 000000C0h;

  PUSH EDX;
  PUSH ECX;
  PUSH EAX;
  PUSH 00021401h;  <-- CLSID_ShellLink
  MOV EDI, ESP;

  PUSH EDX;
  PUSH ECX;
  PUSH EAX;
  PUSH 000214EEh;  <-- IID_IShellLink
  MOV ESI, ESP;

  PUSH EAX;
  PUSH ESP;
  PUSH ESI;
  PUSH 1;          <-- CLSCTX_INPROC_SERVER
  PUSH EAX;
  PUSH EDI;
  CALL CoCreateInstance;
  POP ESI;

  ADD ESP, 20;
  PUSH 0000010Bh;  <-- IID_IPersistFile

  PUSH EAX;
  PUSH ESP;
  PUSH EDI;
  PUSH ESI;
  MOV EAX, DWORD PTR [ESI];
  CALL (IShellLink PTR [EAX]).QueryInterface;
  POP EDI;

  PUSH EDI;
  MOV EAX, DWORD PTR [EDI];
  CALL (IPersistFile PTR [EAX]).Release;

  PUSH ESI;
  MOV EAX, DWORD PTR [ESI];
  CALL (IShellLink PTR [EAX]).Release;

  ADD ESP, 16;
  POPAD;
  RET;

MakeIcon endp;



TranslateDlg proc hWnd: DWORD, text: DWORD;

  PUSH EDI;
  MOV EDI, text;
  JMP @F;

  @elem:
    PUSH EDI;
    PUSH EAX;
    PUSH WM_SETTEXT;
    PUSH EAX;
    PUSH hWnd;
    CALL SendDlgItemMessageA;
    XOR EAX, EAX;
    LEA ECX, [EAX - 1];
    REPNE SCASB;
  @@:
    MOVZX EAX, BYTE PTR [EDI];
    INC EDI;
    TEST EAX, EAX;
  JNE @elem;

  PUSH EDI;
  PUSH EAX;
  PUSH WM_SETTEXT;
  PUSH hWnd;
  CALL SendMessageA;

  POP EDI;
  RET;

TranslateDlg endp;



GetWindowTitle proc hWnd: DWORD;

  PUSHAD;
  MOV EDI, OFFSET UND;
  MOV ESI, EDI;
  MOV EBX, hWnd;
  TEST EBX, EBX;
  JE @F;
    SUB ESP, 124;
    MOV EDI, ESP;
    PUSH 123;
    PUSH EDI;
    PUSH EBX;
    CALL GetClassNameA;

    MOV ESI, SendMessageA;
    XOR EAX, EAX;
    PUSH EAX;
    PUSH EAX;
    PUSH WM_GETTEXTLENGTH;
    PUSH EBX;
    CALL ESI;

    AND EAX, -4;
    ADD EAX, 4;
    SUB ESP, EAX;

    PUSH ESP;
    PUSH EAX;
    PUSH WM_GETTEXT;
    PUSH EBX;
    CALL ESI;
    MOV ESI, ESP;
  @@:
  MOV EDX, DLG;

  PUSH ESI;
  PUSH EAX;
  PUSH WM_SETTEXT;
  PUSH MID_TITL;
  PUSH EDX;

  PUSH EDI;
  PUSH EAX;
  PUSH WM_SETTEXT;
  PUSH MID_CLAS;
  PUSH EDX;

  MOV EBX, SendDlgItemMessageA;
  CALL EBX;
  CALL EBX;
  LEA ESP, [EBP - 32];
  POPAD;
  RET;

GetWindowTitle endp;



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



WCBTHook proc H: DWORD, E: DWORD, W: DWORD, \
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
  ADD EDI, IMB;
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



MainProc proc hWnd: DWORD, uMsg: DWORD, wPrm: DWORD, lPrm: DWORD;

  XOR EAX, EAX;
  MOV EDX, uMsg;
  PUSHAD;
  CMP EDX, WMC_TRAY;
  JE @WMC_TRAY;
  CMP EDX, WM_CLOSE;
  JE @WM_CLOSE;
  CMP EDX, WM_HOTKEY;
  JE @WM_HOTKEY;
  CMP EDX, WM_COMMAND;
  JE @WM_COMMAND;
  CMP EDX, WM_LBUTTONUP;
  JE @WM_LBUTTONUP;
  CMP EDX, WM_INITDIALOG;
  JNE @F;

    CALL MakeIcon;

    PUSH WINEVENT_OUTOFCONTEXT or WINEVENT_SKIPOWNTHREAD;
    PUSH EAX;
    PUSH EAX;
    PUSH OFFSET WCBTHook;
    PUSH IMB;
    PUSH EVENT_OBJECT_LOCATIONCHANGE;
    PUSH EVENT_SYSTEM_FOREGROUND;
    CALL SetWinEventHook;
    MOV IDW, EAX;

    MOV ESI, hWnd;
    MOV DLG, ESI;

    PUSH 0;
    CALL GetWindowTitle;

    PUSH VK_RETURN;
    PUSH MOD_WIN;
    PUSH DLG_MAIN;
    PUSH ESI;
    CALL RegisterHotKey;

    PUSH MLB_DONE;
    PUSH ESI;
    CALL GetDlgItem;
    MOV IDN, EAX;

    PUSH OFFSET TXT;
    PUSH ESI;
    CALL TranslateDlg;

    MOV EBX, SendMessageA;
    PUSH lPrm;
    PUSH ICON_BIG;
    PUSH WM_SETICON;
    PUSH ESI;
    CALL EBX;

    PUSH ESI;
    PUSH -1;
    PUSH WM_LBUTTONUP;
    PUSH ESI;
    CALL EBX;

    MOV EAX, OFFSET NID;
    MOV (NOTIFYICONDATA PTR [EAX]).cbSize, SIZEOF(NOTIFYICONDATA);
    MOV (NOTIFYICONDATA PTR [EAX]).hwnd,   ESI;
    MOV (NOTIFYICONDATA PTR [EAX]).uID,    1;
    MOV (NOTIFYICONDATA PTR [EAX]).uFlags, NIF_MESSAGE or \
                                           NIF_ICON or \
                                           NIF_TIP;
    MOV EDX, lPrm;
    MOV (NOTIFYICONDATA PTR [EAX]).hIcon,  EDX;
    MOV (NOTIFYICONDATA PTR [EAX]).uCallbackMessage, WMC_TRAY;

    PUSH NIM_ADD;
    PUSH TXT_DEAC;
    CALL TrayMenuModify;

  @@:
    POPAD;
    RET;


  @WM_HOTKEY:
    INC wPrm;
    JLE @B;
    XOR EAX, EAX;
    CMP EAX, WND;
    JE @B;
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
    PUSH IDC_ARROW;
    PUSH EAX;
    CALL LoadCursorA;
    PUSH EAX;
    CALL SetCursor;
    CALL ReleaseCapture;

    PUSH CUR_CROS;
    PUSH IMB;
    CALL LoadCursorA;
    PUSH EAX;
    PUSH IMAGE_ICON;
    PUSH STM_SETIMAGE;
    PUSH IDN;
    CALL SendMessageA;

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
    JE @F;

      MOV WND, EBX;
      PUSH SW_HIDE;
      PUSH hWnd;
      CALL ShowWindow;

      PUSH EBX;
      CALL GetWindowTitle;

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
      PUSH IMB;
      PUSH EBX;
      PUSH WH_MOUSE;
      CALL SetWindowsHookExA;

      MOV DWORD PTR [ESI], EAX;
      PUSH EAX;
      PUSH 0;
      PUSH EAX;
      CALL EBX;

      PUSH NIM_MODIFY;
      PUSH TXT_ACTV;
      CALL TrayMenuModify;

    @@:
    POPAD;
    RET;

    @fail:
    PUSH NIM_MODIFY;
    PUSH TXT_DEAC;
    CALL TrayMenuModify;
    PUSH EDI;
    CALL UnhookWindowsHookEx;
    XOR EAX, EAX;
    MOV DWORD PTR [ESI], EAX;
    PUSH EAX;
    PUSH EAX;
    PUSH EAX;
    CALL ClipHook;
    POPAD;
    RET;


  @WMC_TRAY:
    MOV EAX, lPrm;
    CMP AX, WM_RBUTTONDOWN;
    JNE @B;

    PUSH EAX;
    PUSH EAX;
    PUSH ESP;
    CALL GetCursorPos;

    PUSH hWnd;
    CALL SetForegroundWindow;

    PUSH 0;
    PUSH hWnd;
    PUSH DWORD PTR [ESP + 12];
    PUSH DWORD PTR [ESP + 12];
    PUSH TPM_CENTERALIGN or TPM_RIGHTBUTTON;
    PUSH PPM;
    CALL TrackPopupMenuEx;

    POP EAX;
    POP EAX;
    POPAD;
    RET;


  @WM_COMMAND:
    LEA EBX, [EAX + SW_HIDE];
    MOV EAX, wPrm;
    CMP AL, MNU_SHOW;
    JNE @F;
      PUSH hWnd;
      CALL IsWindowVisible;
      TEST EAX, EAX;
      JNE @hide;
        PUSH hWnd;
        CALL SetForegroundWindow;
        ADD EBX, SW_SHOWNORMAL - SW_HIDE;
      @hide:
      PUSH EBX;
      PUSH hWnd;
      CALL ShowWindow;
      XOR EAX, EAX;
    @@:
      CMP AL, MNU_CLIP;
    JE @WM_HOTKEY;
      CMP AL, MLB_DONE;
    JNE @F;
      PUSH CUR_CROS;
      PUSH IMB;
      CALL LoadCursorA;
      PUSH EAX;
      CALL SetCursor;
      PUSH 0;
      PUSH IMAGE_ICON;
      PUSH STM_SETIMAGE;
      PUSH IDN;
      CALL SendMessageA;
      PUSH hWnd;
      CALL SetCapture;
      XOR EAX, EAX;
    @@:
      CMP AL, MNU_QUIT;
    JNE @F;


  @WM_CLOSE:
    PUSH EAX;
    PUSH hWnd;
    CALL EndDialog;
    PUSH OFFSET NID;
    PUSH NIM_DELETE;
    CALL Shell_NotifyIconA;
    PUSH DLG_MAIN;
    PUSH hWnd;
    CALL UnregisterHotKey;
    PUSH IDW;
    CALL UnhookWinEvent;
    PUSH IDH;
    CALL UnhookWindowsHookEx;
    PUSH PPM;
    CALL DestroyMenu;
  @@:
    POPAD;
    RET;

MainProc endp;



end @main;
