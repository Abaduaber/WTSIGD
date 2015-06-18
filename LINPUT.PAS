{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N-} {$D+} {$L-} {$Y-} {$X-}
Unit LInput;
Interface
Uses
    LUtils;
Type
    TMB = (TMB_None, TMB_L, TMB_R, TMB_LR, TMB_M, TMB_LM, TMB_RM, TMB_LRM);
    TMouseState = Record
        FButtons: TMB;
        FReserved: Byte;
        FXPos, FYPos: Word;
    End;

    TKeybButtons = (
        TKB_No, TKB_Esc, TKB_1, TKB_2, TKB_3, TKB_4, TKB_5, TKB_6, TKB_7, TKB_8, TKB_9,
        TKB_0, TKB_Minus, TKB_Equal, TKB_BackSpace, TKB_Tab, TKB_Q, TKB_W,
        TKB_E, TKB_R, TKB_T, TKB_Y, TKB_U, TKB_I, TKB_O, TKB_P, TKB_LBracket,
        TKB_RBracket, TKB_Enter, TKB_Ctrl, TKB_A, TKB_S, TKB_D, TKB_F, TKB_G,
        TKB_H, TKB_J, TKB_K, TKB_L, TKB_Semicolon, TKB_Quote, TKB_Apostrophe,
        TKB_LShift, TKB_Slash, TKB_Z, TKB_X, TKB_C, TKB_V, TKB_B, TKB_N,
        TKB_M, TKB_Comma, TKB_Point, TKB_BackSlash, TKB_RShift, TKB_Asteriks,
        TKB_Alt, TKB_Space, TKB_CapsLock, TKB_F1, TKB_F2, TKB_F3, TKB_F4,
        TKB_F5, TKB_F6, TKB_F7, TKB_F8, TKB_F9, TKB_F10, TKB_NumLock,
        TKB_ScrollLock, TKB_Home, TKB_Up, TKB_PgUp, TKB_KPMinus, TKB_Left,
        TKB_KP5, TKB_Right, TKB_KPPlus, TKB_End, TKB_Down, TKB_PgDown, TKB_Insert,
        TKB_Delete, TKB_None1, TKB_None2, TKB_None3, TKB_F11, TKB_F12, TKB_Last
    );
Var
    IsMouseVisible: Boolean;

    Function InitMouse: Boolean;
    Procedure ShowMouse;
    Procedure HideMouse;
    Procedure GetMouseState(Var AMouseState: TMouseState);
    Procedure SetMouseXY(AXPos, AYPos: Word);
    Procedure SetMouseHor(AMin, AMax: Word);
    Procedure SetMouseVert(AMin, AMax: Word);

    Procedure SetNewKeybHandler;
    Procedure RestoreOldKeybHandler;
    Procedure SetInpMode(AIsInputStr: Boolean);
    Procedure SetInpLang(AIsEng: Boolean);
    Function IsInpEngLang: Boolean;
    Procedure SetInpStrDelay(ANewDelay: Word);
    Procedure SetChangeLangKey(ANewKey: TKeybButtons);
    Function GetInpStr: String;
    Function IsInputIsDone: Boolean;
    Procedure SetInpStr(AStr: String);
    Procedure SetMaxInpStrLen(ALen: Byte);
    Function WhatKeyPressed: TKeybButtons;
    Function IsAnyKeyPressedCRT: Boolean;
    Function IsKeyPressed(AKey: TKeybButtons): Boolean;
    Function WaitCode: Byte;
    Function WaitChar: Char;
    Procedure ClearKeybBuf;

    Procedure Sleep;
    Function GetKey: Word;
    Procedure NewExitProc;

Implementation
Uses
    LMem;
Type
    TCharsArr = Array [Ord(TKB_Esc)..Ord(TKB_Space)] Of Char;
    TCharsArrP = ^TCharsArr;
Const
    CKeyChars: TCharsArr =
      #27'1234567890-='#8#9'qwertyuiop[]'#13#0'asdfghjkl;''`'#0'\' +
      'zxcvbnm,./'#0'*'#0' ';
    CShiftKeyChars: TCharsArr =
      #27'!@#$%^&*()_+'#8#9'QWERTYUIOP{}'#13#0'ASDFGHJKL:"~'#0'|' +
      'ZXCVBNM<>?'#0'*'#0' ';
    CRusKeyChars: TCharsArr =
      #27'1234567890-='#8#9'йцукенгшщзхъ'#13#0'фывапролджэё'#0'\' +
      'ячсмитьбю.'#0'*'#0' ';
    CShiftRusKeyChars: TCharsArr =
      #27'!"№;%:?*()_+'#8#9'ЙЦУКЕНГШЩЗХЪ'#13#0'ФЫВАПРОЛДЖЭЁ'#0'/' +
      'ЯЧСМИТЬБЮ,'#0'*'#0' ';

    CKeyBufSize = 16;
Var
    OldKeybHandler, OldExitProc: Pointer;
    CharsArrP: TCharsArrP;
    KeyMap: Array [0..127] Of Boolean;
    CharMap: Array [0..127] Of Char;
    KeyBuf: Array [0..CKeyBufSize] Of Byte;
    BufHead, BufTail: Word;
    KeyCount, I: Byte;
    LastInpKey, ChangeLangKey: TKeybButtons;

    IsEngLang, IsInpStrMode: Boolean;
    CurInpStr: String; MaxInpStrLen: Byte;
    NextInpTime: LongInt;
    DelayMSLen: Word;

    Procedure InitKeyb; Forward;
    Procedure ControlInputStr; Forward;
    Procedure InverseCharsArrCase; Forward;
    Procedure AppendCharToStr(Var AStr: String; ACh: Char); Forward;

Procedure NewKeybHandler; Interrupt; Assembler;
Asm
    in al,60h
    mov ah,al
    and al,7Fh
    lea bx,KeyMap
    add bl,al
    adc bh,0
    test ah,80h
    jnz @Released
    mov byte ptr [bx],True
    cmp KeyCount,CKeyBufSize
    je @Done
    lea bx,KeyBuf
    add bx,BufTail
    mov [bx],al
    inc KeyCount
    inc BufTail
    cmp BufTail,CKeyBufSize
    jne @Done
    mov BufTail,0
    jmp @done
   @Released:
    mov byte ptr [bx],False
   @Done:
    mov al,20h
    out 20h,al
    cmp IsInpStrMode,True
    jne @End
    call ControlInputStr
   @End:
End;

Procedure InitKeyb;
Begin
    FillMem(@CharMap, SizeOf(CharMap), 0);
    For I:= Ord(TKB_Esc) To Ord(TKB_Space) Do
        CharMap[I]:= CKeyChars[I];
    CharMap[Ord(TKB_KPMinus)]:= '-';
    CharMap[Ord(TKB_KPPlus)]:= '+';
End;

Procedure SetNewKeybHandler;
Begin
    If OldKeybHandler <> Nil Then Exit;
    OldExitProc:= @ExitProc;
    ExitProc:= @NewExitProc;
    InitKeyb;
    FillMem(@KeyMap, SizeOf(KeyMap), Byte(False));
    KeyCount:= 0; BufHead:= 0; BufTail:= 0;
    OldKeybHandler:= LUtils.GetIntVec(9);
    LUtils.SetIntVec(9, @NewKeybHandler);
End;

Procedure RestoreOldKeybHandler;
Begin
    If OldKeybHandler = Nil Then Exit;
    LUtils.SetIntVec(9, OldKeybHandler);
    OldKeybHandler:= Nil;
End;

Function WhatKeyPressed: TKeybButtons; Assembler;
Asm
    mov ax,ds
    mov es,ax
    lea di,KeyMap+1
    mov cx,58h
    cld
   @ContinueScan:
    mov al,False
    repe scasb
    je @End
    mov al,58h
    sub al,cl

    cmp al,Byte(TKB_NumLock)
    je @ContinueScan
    cmp al,Byte(TKB_CapsLock)
    je @ContinueScan
    cmp al,Byte(TKB_LShift)
    je @ContinueScan
    cmp al,Byte(TKB_RShift)
    je @ContinueScan
   @End:
End;

Procedure ControlInputStr;
Var
    CurKey: TKeybButtons;
    CurMS: LongInt;
Begin
    CurMS:= ReadMS;
    If (NextInpTime Shr 1) > CurMS Then NextInpTime:= CurMS;
    If CurMS < NextInpTime Then Exit;
    CurKey:= WhatKeyPressed;
    If (LastInpKey = CurKey) Then Begin
        LastInpKey:= TKB_No;
        Exit;
    End;
    LastInpKey:= CurKey;
    If CurKey = ChangeLangKey Then SetInpLang(Not IsInpEngLang);

    If IsEngLang Then Begin
        If (IsKeyPressed(TKB_LShift) Or IsKeyPressed(TKB_RShift)) Then
            CharsArrP:= @CShiftKeyChars
        Else
            CharsArrP:= @CKeyChars;
        If IsKeyPressed(TKB_CapsLock) Then InverseCharsArrCase;
    End
    Else Begin
        If IsKeyPressed(TKB_LShift) Or IsKeyPressed(TKB_RShift) Then
            CharsArrP:= @CShiftRusKeyChars
        Else
            CharsArrP:= @CRusKeyChars;
        If IsKeyPressed(TKB_CapsLock) Then InverseCharsArrCase;
    End;
    Case CurKey Of
      TKB_1..TKB_Equal, TKB_Q..TKB_RBracket:
        AppendCharToStr(CurInpStr, CharsArrP^[Byte(CurKey)]);
      TKB_Enter:
        Begin
            SetInpMode(False);
            Exit;
        End;
      TKB_A..TKB_Apostrophe, TKB_Slash..TKB_BackSlash, TKB_Asteriks, TKB_Space:
        AppendCharToStr(CurInpStr, CharsArrP^[Byte(CurKey)]);
      TKB_BackSpace:
        Dec(Byte(CurInpStr[0]), Byte(Byte(CurInpStr[0]) > 0));
      Else
          Exit;
    End;
    NextInpTime:= CurMS + DelayMSLen;
End;

Function IsAnyKeyPressedCRT: Boolean;
Begin
    IsAnyKeyPressedCRT:= KeyCount <> 0;
End;

Function IsKeyPressed(AKey: TKeybButtons): Boolean;
Begin
    IsKeyPressed:= KeyMap[Byte(AKey)];
End;

Function WaitCode: Byte;
Begin
    While KeyCount = 0 Do;
    WaitCode:= KeyBuf[BufHead];
    Inc(BufHead);
    If BufHead = CKeyBufSize Then BufHead:= 0;
    Dec(KeyCount);
End;

Function WaitChar: Char;
Begin
    WaitChar:= CKeyChars[WaitCode];
End;

Procedure SetInpMode(AIsInputStr: Boolean);
Begin
    IsInpStrMode:= AIsInputStr;
    If AIsInputStr Then
        NextInpTime:= ReadMS + DelayMSLen;
End;

Procedure SetInpLang(AIsEng: Boolean);
Begin
    IsEngLang:= AIsEng;
End;

Function IsInpEngLang: Boolean;
Begin
    IsInpEngLang:= IsEngLang;
End;

Procedure SetInpStrDelay(ANewDelay: Word);
Begin
    DelayMSLen:= ANewDelay;
End;

Procedure SetInpStr(AStr: String);
Begin
    CurInpStr:= Copy(AStr, 1, MaxInpStrLen);
End;

Procedure SetMaxInpStrLen(ALen: Byte);
Begin
    MaxInpStrLen:= ALen; CurInpStr:= Copy(CurInpStr, 1, ALen);
End;

Function GetInpStr: String;
Begin
    GetInpStr:= CurInpStr;
End;

Function IsInputIsDone: Boolean;
Begin
    IsInputIsDone:= Not IsInpStrMode;
End;

Procedure SetChangeLangKey(ANewKey: TKeybButtons);
Begin
    ChangeLangKey:= ANewKey;
End;

Procedure InverseCharsArrCase;
Begin
    If CharsArrP = @CShiftKeyChars Then
        CharsArrP:= @CKeyChars
    Else
        CharsArrP:= @CShiftKeyChars;
End;

Procedure AppendCharToStr(Var AStr: String; ACh: Char);
Begin
    If Length(AStr) < MaxInpStrLen Then AStr:= AStr + ACh;
End;

Procedure ClearKeybBuf;
Begin
    Asm
        pushf
        cli
    End;
    BufHead:= BufTail;
    KeyCount:= 0;
    Asm
        popf
    End;
End;

{Простейшая задержка до нажатия любой клавиши}
Procedure Sleep;
Begin
    If OldKeybHandler <> Nil Then Begin
        While WhatKeyPressed = TKB_No Do;
    End
    Else Asm
        xor ax,ax
        int 16h
    End;
End;

{Получает код клавиши из буфера клавиатуры}
Function GetKey: Word;
Begin
    If OldKeybHandler <> Nil Then Begin
        Exit
    End
    Else Asm
        xor bx,bx
        mov ah,1
        int 16h
        xchg ah,al
        xor ah,ah
    End;
End;

Function InitMouse: Boolean; Assembler;
Asm
    xor ax,ax
    int 33h
    test ax,ax
    jz @Exit
    mov ax,1
   @Exit:
End;

Procedure ShowMouse; Assembler;
Asm
    mov ax,1
    int 33h
    mov al,1
    mov [IsMouseVisible],al
End;

Procedure HideMouse; Assembler;
Asm
    mov ax,2
    int 33h
    xor al,al
    mov [IsMouseVisible],al
End;

Procedure GetMouseState(Var AMouseState: TMouseState); Assembler;
Asm
    les di,AMouseState
    mov ax,3
    int 33h
    mov es:[di],bx
    mov es:[di+2],cx
    mov es:[di+4],dx
End;

Procedure SetMouseXY(AXPos, AYPos: Word); Assembler;
Asm
    mov ax,4
    mov cx,AXpos
    mov dx,AYPos
    int 33h
End;

Procedure SetMouseHor(AMin, AMax: Word); Assembler;
Asm
    mov ax,7
    mov cx,AMin
    mov dx,AMax
    int 33h
End;

Procedure SetMouseVert(AMin, AMax: Word); Assembler;
Asm
    mov ax,8
    mov cx,AMin
    mov dx,AMax
    int 33h
End;

Procedure NewExitProc;
Begin
    If OldKeybHandler <> Nil Then Begin
        ExitProc:= @OldExitProc;
        RestoreOldKeybHandler;
    End;
End;

Begin
    IsMouseVisible:= False; IsEngLang:= True; IsInpStrMode:= False;
    CurInpStr:= ''; DelayMSLen:= 10; ChangeLangKey:= TKB_F12;
    MaxInpStrLen:= 255;
    OldKeybHandler:= Nil;
End.