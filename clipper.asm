.386;
.model flat, stdcall;
option casemap:none;
assume fs:nothing;

include \masm32\include\windows.inc;


;const
  LoadLibraryExA         equ  DWORD PTR [PRC + 000];
  GetModuleHandleA       equ  DWORD PTR [PRC + 004];

  ; <-- user32.dll
  ReleaseCapture         equ  DWORD PTR [PRC + 008];
  GetCursorPos           equ  DWORD PTR [PRC + 012];
  SetCursor              equ  DWORD PTR [PRC + 016];
  SetForegroundWindow    equ  DWORD PTR [PRC + 020];
  UnhookWinEvent         equ  DWORD PTR [PRC + 024];
  IsWindowVisible        equ  DWORD PTR [PRC + 028];
  RegisterHotKey         equ  DWORD PTR [PRC + 032];
  ModifyMenuA            equ  DWORD PTR [PRC + 036];
  EndDialog              equ  DWORD PTR [PRC + 040];
  SetCapture             equ  DWORD PTR [PRC + 044];
  MessageBoxIndirectA    equ  DWORD PTR [PRC + 048];
  GetClientRect          equ  DWORD PTR [PRC + 052];
  UnregisterHotKey       equ  DWORD PTR [PRC + 056];
  LoadIconA              equ  DWORD PTR [PRC + 060];
  ShowWindow             equ  DWORD PTR [PRC + 064];
  UnhookWindowsHookEx    equ  DWORD PTR [PRC + 068];
  CreatePopupMenu        equ  DWORD PTR [PRC + 072];
  SetMenuDefaultItem     equ  DWORD PTR [PRC + 076];
  AppendMenuA            equ  DWORD PTR [PRC + 080];
  SendMessageA           equ  DWORD PTR [PRC + 084];
  DialogBoxParamA        equ  DWORD PTR [PRC + 088];
  IsWindow               equ  DWORD PTR [PRC + 092];
  SetWinEventHook        equ  DWORD PTR [PRC + 096];
  ClientToScreen         equ  DWORD PTR [PRC + 100];
  GetForegroundWindow    equ  DWORD PTR [PRC + 104];
  SetWindowsHookExA      equ  DWORD PTR [PRC + 108];
  ClipCursor             equ  DWORD PTR [PRC + 112];
  DestroyMenu            equ  DWORD PTR [PRC + 116];
  GetParent              equ  DWORD PTR [PRC + 120];
  LoadCursorA            equ  DWORD PTR [PRC + 124];
  WindowFromPoint        equ  DWORD PTR [PRC + 128];
  GetDlgItem             equ  DWORD PTR [PRC + 132];
  CallNextHookEx         equ  DWORD PTR [PRC + 136];
  TrackPopupMenuEx       equ  DWORD PTR [PRC + 140];

  ; <-- comctl32.dll
  InitCommonControlsEx   equ  DWORD PTR [PRC + 144];

  ; <-- shell32.dll
  Shell_NotifyIconA      equ  DWORD PTR [PRC + 148];

  ICN_MAIN equ 1;
  CUR_CROS equ 2;

  MNU_SHOW equ 1;
  MNU_CLIP equ 2;
  MNU_QUIT equ 4;

  DLG_MAIN equ 10;
  IDC_DONE equ 101;
  IDC_INFO equ 102;
  IDC_EXIT equ 103;

  RCT_SIZE equ (4 + (SIZEOF(RECT) and -4));
  NID_SIZE equ (4 + (SIZEOF(NOTIFYICONDATA) and -4));

  WMC_TRAY equ (WM_USER + 100);
  TBL_SIZE equ 48;

  API_MULT equ 0FBC5h;
  API_PLUS equ -1;

  TXT_ACTV equ 82;
  TXT_DEAC equ 104;


.data?

  PRC DD TBL_SIZE DUP (?);
  NID DB SIZEOF(NOTIFYICONDATA) DUP(?);
  RCT DB SIZEOF(RECT) DUP(?);

  IMB DD ?;
  IDH DD ?;
  IDW DD ?;

  WND DD ?;
  DLG DD ?;
  PPM DD ?;

  IDN DD ?;
  IIN DD ?;
  IEX DD ?;


.code

  HCP DB "Help & some extra info", 0;
  HTX DB "Clipper v0.5-RC1", 0Ah, 0Ah;
      DB "This is a program that allows you to lock the cursor", 0Ah;
      DB "in any window you like. Useful for restricting cursor", 0Ah;
      DB "movement while playing a game in windowed mode.", 0Ah, 0Ah;
      DB "Key features:", 0Ah;
      DB "  -  Drag the crosshair & drop it on the target to lock", 0Ah;
      DB "  -  The lock is removed while the target is inactive", 0Ah;
      DB "  -  [WIN] + [ENTER] toggles the lock on and off", 0Ah;
      DB "  -  System tray menu for easier access", 0Ah, 0Ah;
      DB "© WASM.RU Forum, 2012.", 0;

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
      DW 0CD35h, 0EB2Bh;
  @@:
      DB "user32", 0, (@F - $)/2;
      DW 00357h, 00D14h, 01535h, 017DCh, 02D2Eh, 031F3h, 033E7h, 03F0Bh;
      DW 04C0Eh, 0567Ah, 05D46h, 072B8h, 07A80h, 07CE1h, 07E53h, 07E7Eh;
      DW 099CEh, 0B15Bh, 0BF8Bh, 0C5A8h, 0C808h, 0C8A0h, 0CC46h, 0CD28h;
      DW 0CFB0h, 0D05Dh, 0D548h, 0D934h, 0DE25h, 0E834h, 0EF1Bh, 0F484h;
      DW 0F513h, 0FAC3h;
  @@:
      DB "comctl32", 0, (@F - $)/2;
      DW 0458Eh;
  @@:
      DB "shell32", 0, (@F - $)/2;
      DW 046E5h;
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

  PUSH ICC_STANDARD_CLASSES;
  PUSH SIZEOF(INITCOMMONCONTROLSEX);
  PUSH ESP;
  CALL InitCommonControlsEx;
  ADD ESP, 8;

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

  PUSH ICN_MAIN;
  PUSH IMB;
  CALL LoadIconA;
  PUSH EAX;
  PUSH OFFSET MainProc;
  PUSH EBX;
  PUSH DLG_MAIN;
  PUSH IMB;
  CALL DialogBoxParamA;

  XOR EAX, EAX;
  RET;



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
    MOV EDI, GetDlgItem;

    PUSH IDC_DONE;
    PUSH ESI;
    CALL EDI;
    MOV IDN, EAX;

    PUSH IDC_INFO;
    PUSH ESI;
    CALL EDI;
    MOV IIN, EAX;
    PUSH EAX;

    PUSH IDC_EXIT;
    PUSH ESI;
    CALL EDI;
    MOV IEX, EAX;
    MOV EDI, EAX;

    PUSH VK_RETURN;
    PUSH MOD_WIN;
    PUSH DLG_MAIN;
    PUSH hWnd;
    CALL RegisterHotKey;

    MOV ESI, SendMessageA;
    MOV EBX, LoadIconA;
    PUSH lPrm;
    PUSH 1;
    PUSH WM_SETICON;
    PUSH hWnd;
    CALL ESI;

    PUSH IDI_QUESTION;
    PUSH 0;
    CALL EBX;
    POP EDX;
    PUSH EAX;
    PUSH IMAGE_ICON;
    PUSH STM_SETIMAGE;
    PUSH EDX;
    CALL ESI;

    PUSH IDI_HAND;
    PUSH 0;
    CALL EBX;
    PUSH EAX;
    PUSH IMAGE_ICON;
    PUSH STM_SETIMAGE;
    PUSH EDI;
    CALL ESI;

    MOV EAX, OFFSET NID;
    MOV (NOTIFYICONDATA PTR [EAX]).cbSize, SIZEOF(NOTIFYICONDATA);
    MOV EDX, hWnd;
    MOV (NOTIFYICONDATA PTR [EAX]).hwnd,   EDX;
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
    XOR EAX, EAX;
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
      PUSH WH_MOUSE_LL;
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
    XOR EAX, EAX;
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
    XOR EAX, EAX;
    RET;


  @WMC_TRAY:
    MOV EAX, lPrm;
    CMP AX, WM_RBUTTONDOWN;
    JNE @B;

    SUB ESP, 8;
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

    XOR EAX, EAX;
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
      CMP AL, MNU_QUIT;
    JE @WM_CLOSE;
      CMP AL, IDC_DONE;
    JNE @F;
      PUSH 0;
      PUSH IMAGE_ICON;
      PUSH STM_SETIMAGE;
      PUSH IDN;
      CALL SendMessageA;
      PUSH CUR_CROS;
      PUSH IMB;
      CALL LoadCursorA;
      PUSH EAX;
      CALL SetCursor;
      PUSH hWnd;
      CALL SetCapture;
      XOR EAX, EAX;
    @@:
      CMP AL, IDC_INFO;
    JNE @F;
      PUSH LANG_NEUTRAL;
      PUSH 0;
      PUSH 0;
      PUSH ICN_MAIN;
      PUSH MB_OK or MB_USERICON;
      PUSH OFFSET HCP;
      PUSH OFFSET HTX;
      PUSH IMB;
      PUSH hWnd;
      PUSH SIZEOF(MSGBOXPARAMSA);
      PUSH ESP;
      CALL MessageBoxIndirectA;
      XOR EAX, EAX;
    @@:
      CMP AL, IDC_EXIT;
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
    XOR EAX, EAX;
    RET;

MainProc endp;



end @main;
