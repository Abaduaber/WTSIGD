{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$D-} {$L-} {$Y-} {$X-}
Unit LUtils;
Interface
Type
    TRegs = Record
        Case Integer Of
          0:
            (AX, BX, CX, DX, ES, DS, SI, DI, BP, Flags: Word);
          1:
        (AL, AH, BL, BH, CL, CH, DL, DH: Byte);
    End;
    TDTARec = Record
        FDiskType: Byte;
        FSearchMask: Array [1..11] Of Char;
        FSearchAttr: Byte;
        FFileNum: Word;
        FDirClasterStart: Word;
        FReserved: LongInt;
        FFileAttr: Byte;
        FFileCreateTime: Word;
        FFileCreateData: Word;
        FFileSize: LongInt;
        FFileName: Array [1..13] Of Char;
        FErrCode: Byte;
    End;
    TDTARecP = ^TDTARec;

    {CP866}
    Function UpperCase(AStr: String): String;
    Function DownCase(AStr: String): String;
    Function IntToStr(AInt: LongInt): String;
    Function StrToInt(AStr: String): LongInt;  {0 �᫨ �訡��}
    Function GetPasStrFromASCIZ(AFrom: Pointer): String;
    {Files}
    Function ExtractFullNameFromPath(AFilePath: String): String;
    Function ExtractNameFromPath(AFilePath: String): String;
    Function ExtractExtFromPath(AFilePath: String): String;
    Function IsFileExist(AFileName: String): Boolean;
    Function IsDeleteFile(AFileName: String): Boolean;
    Procedure FindFirstFile(Var ADTARecP: TDTARecP; AFileMask: String);
    Procedure FindNextFile(Var ADTARecP: TDTARecP);
    Function GetDTAName(ADTARecP: TDTARecP): String;
    {Timer}
    Function ReadTimer: LongInt;
    Function ReadTimerChip: Word;
    Function ReadOsc: LongInt;
    Function ReadMS: LongInt;
    Procedure DelayTicks(Ticks: LongInt);
    Procedure Delay(MS: Word);
    {Other}
    Function IsCAPSEnabled: Boolean;
    Function IntPower(X, I: LongInt): LongInt;
    Procedure CallInt(IntNum: Byte; Var Regs: TRegs);
    Procedure SetIntVec(ANum: Byte; ANewHandlerP: Pointer);
    Function GetIntVec(ANum: Byte): Pointer;
    Function IsBitSet(AVal: LongInt; ABit: Byte): Boolean;
    Function SetBit(AVal: LongInt; ABit: Byte): LongInt;
    Function ClearBit(AVal: LongInt; ABit: Byte): LongInt;
    Function ToggleBit(AVal: LongInt; ABit: Byte): LongInt;
    Function CheckCPUType: Word;
    Procedure SwapInt(Var AFirst: Integer; Var ASec: Integer);
    {Screen}
    Procedure SetGM(ANum: Byte);
    Function GetCurGM: Byte;
    Procedure RestoreOldGM;
Const
    CEOLSign = $0A0D;

Implementation
Uses
    LMem;
Var
    GTimer: LongInt Absolute $40:$6C;
    GOldVMode: Byte;

    Procedure SetDTAArea(ANewDTAP: TDTARecP); Forward;

Function IsCAPSEnabled: Boolean;
Begin
    IsCAPSEnabled:= (Mem[0:$417] And $40) <> 0;
End;

{�����頥� True, �᫨ 䠩� �� ��� AFileName �������}
Function IsFileExist(AFileName: String): Boolean;
Var
    FD: File;
    FExist: Boolean;
Begin
    Assign(FD, AFileName);
    Reset(FD);
    FExist:= IOResult = 0;
    If FExist Then Close(FD);
    IsFileExist:= FExist;
End;

{�����頥� True, �᫨ 㤠���� 㤠���� 䠩� �� ��� AFileName}
Function IsDeleteFile(AFileName: String): Boolean;
Var
    FD: File;
Begin
    If IsFileExist(AFileName) Then Begin
        Assign(FD, AFileName);
        Erase(FD);
        IsDeleteFile:= IOResult = 0;
    End
    Else
        IsDeleteFile:= False;
End;

Function ExtractFullNameFromPath(AFilePath: String): String;
Var
    I: Word;
Begin
    For I:= Length(AFilePath) DownTo 1 Do Begin
        If AFilePath[I] = '\' Then Begin
            Inc(I);
            Break;
        End;
    End;
    ExtractFullNameFromPath:= Copy(AFilePath, I, Length(AFilePath) - I + 1);
End;

Function ExtractNameFromPath(AFilePath: String): String;
Var
    I: Word;
Begin
    AFilePath:= ExtractFullNameFromPath(AFilePath);
    For I:= 1 To Length(AFilePath) Do Begin
        If AFilePath[I] = '.' Then Begin
            Dec(I);
            Break;
        End;
    End;
    ExtractNameFromPath:= Copy(AFilePath, 1, I);
End;

Function ExtractExtFromPath(AFilePath: String): String;
Var
    I: Word;
Begin
    For I:= Length(AFilePath) DownTo 1 Do
        If AFilePath[I] = '.' Then Break;
    If I <> 1 Then
        ExtractExtFromPath:= Copy(AFilePath, I, Length(AFilePath) - I)
    Else
        ExtractExtFromPath:= '';
End;

Procedure SetDTAArea(ANewDTAP: TDTARecP); Assembler;
Asm
    push ds
    lds dx,ANewDTAP
    mov ah,1ah
    int 21h
    pop ds
End;

Procedure FindFirstFile(Var ADTARecP: TDTARecP; AFileMask: String);
Var
    AFileMaskP: Pointer;
    ErrCode: Byte;
Begin
    ADTARecP:= SafeCreateBuf(SizeOf(ADTARecP^));
    SetDTAArea(ADTARecP);
    AFileMask:= AFileMask + Chr(0);
    AFileMaskP:= @AFileMask;
    Asm
        push ds
        mov ax,4e00h
        xor cx,cx
        lds dx,AFileMaskP
        inc dx
        int 21h
        jc @Err
        xor ax,ax
        mov ErrCode,al
        jmp @End
       @Err:
        mov ErrCode,al
       @End:
        pop ds
    End;
    ADTARecP^.FErrCode:= ErrCode;
End;

Procedure FindNextFile(Var ADTARecP: TDTARecP);
Var
    ErrCode: Byte;
Begin
    Asm
        push ds
        mov ax,4f00h
        int 21h
        jc @Err
        xor ax,ax
        mov ErrCode,al
        jmp @End
       @Err:
        mov ErrCode,al
       @End:
        pop ds
    End;
    ADTARecP^.FErrCode:= ErrCode;
End;

Function GetDTAName(ADTARecP: TDTARecP): String;
Var
    FName: String;
    I: Word;
Begin
    MoveMem(@FName[1], @ADTARecP^.FFileName[1], SizeOf(ADTARecP^.FFileName));
    For I:= 1 To SizeOf(ADTARecP^.FFileName) Do
      If ADTARecP^.FFileName[I] = Chr(0) Then Break;
    FName[0]:= Chr(I - 1);
    GetDTAName:= FName;
End;

{�����頥� ��ப� AStr, � ���ன �� ᨬ���� �८�ࠧ����� � ���孨�
ॣ����. �����⠭� �� ࠡ��� � ����஢��� CP866}
Function UpperCase(AStr: String): String;
Var
    I: Word;
Begin
    For I:= 1 To Length(AStr) Do Begin
        If Byte(AStr[I]) >= 128 Then Begin
            Case Byte(AStr[I]) Of
              160..175:
                AStr[I]:= Char(Byte(AStr[I]) - 32);
              224..239:
                AStr[I]:= Char(Byte(AStr[I]) - 80);
            End;
        End
        Else
            AStr[I]:= UpCase(AStr[I]);
    End;
    UpperCase:= AStr;
End;

{�����頥� ��ப� AStr, � ���ன �� ᨬ���� �८�ࠧ����� � ������
ॣ����. �����⠭� �� ࠡ��� � ����஢��� CP866}
Function DownCase(AStr: String): String;
Var
    I: Word;
Begin
    For I:= 1 To Length(AStr) Do Begin
        If Byte(AStr[I]) >= 128 Then Begin
            Case Byte(AStr[I]) Of
              128..143:
                AStr[I]:= Char(Byte(AStr[I]) + 32);
              144..159:
                AStr[I]:= Char(Byte(AStr[I]) + 80);
            End;
        End
        Else Begin
            Case Byte(AStr[I]) Of
              65..90:
                AStr[I]:= Char(Byte(AStr[I]) + 32);
            End;
        End;
    End;
    DownCase:= AStr;
End;

{�८�ࠧ�� �᫮ AInt � ��ப� � �����頥� ���}
Function IntToStr(AInt: LongInt): String;
Var
    S: String[11];
Begin
    Str(AInt, S);
    IntToStr:= S;
End;

{��������� �᫮ �� ��ப� AStr � �����頥� ��� ��� LongInt
!!! - �᫨ ��ப� ����஥�� �訡�筮, �����頥� 0}
Function StrToInt(AStr: String): LongInt;
Var
    I: LongInt;
    Code: Integer;
Begin
    Val(AStr, I, Code);
    If Code = 0 Then
        StrToInt:= I
    Else
        StrToInt:= 0; {!!!}
End;

{��������� ⥪�� �� ASCIZ ��ப� �� ����� AFrom � �����頥�
��� ��� ������ ��ப� Pascal-�ଠ�}
Function GetPasStrFromASCIZ(AFrom: Pointer): String;
Var
    Tex: String;
    I: Word;
Begin
    For I:= 1 To 255 Do If TByteBufP(AFrom)^[I] = 0 Then Break;
    MoveMem(@Tex[1], AFrom, I);
    Tex[0]:= Char(I);
    GetPasStrFromASCIZ:= Tex;
End;

{�������� X � �⥯��� I � �����頥� १����}
Function IntPower(X, I: LongInt): LongInt;
Var
    Res: LongInt;
Begin
    Res:= 1;
    While I > 0 Do Begin
        If (I And 1 = 1) Then Res:= Res * X;
        X:= X * X;
        I:= I Shr 1;
    End;
    IntPower:= Res;
End;

{��뢠�� ���뢠��� ��� ����஬ IntNum, ����㦠� ॣ����� ���祭�ﬨ
�� ����� Regs}
Procedure CallInt(IntNum: Byte; Var Regs: TRegs); Assembler;
Asm
    jmp @OverRegs
   @RegsLivesHereXDD:
    dd 0
   @OverRegs:
    mov al,IntNum
    mov byte ptr cs:[@CallInt+1],al

    push bp
    push ds

    les di,Regs
    mov ax,es
    mov word ptr cs:[@RegsLivesHereXDD],ax
    mov word ptr cs:[@RegsLivesHereXDD + 2],di

    mov al,es:[di]
    mov ah,es:[di+1]
    mov bl,es:[di+2]
    mov bh,es:[di+3]
    mov cl,es:[di+4]
    mov ch,es:[di+5]
    mov dl,es:[di+6]
    mov dh,es:[di+7]    {!!!}

    push word ptr es:[di+8]
    push word ptr es:[di+10]
    push word ptr es:[di+12]
    push word ptr es:[di+14]
    push word ptr es:[di+16]
    push word ptr es:[di+18]

    popf
    pop bp
    pop di
    pop si
    pop ds
    pop es

@CallInt:
    dw 0CDh

    push ax
    push bx
    push cx
    push dx
    push es
    push ds
    push di
    push si
    push bp

    mov ax,word ptr cs:[@RegsLivesHereXDD]
    mov es,ax
    mov di,word ptr cs:[@RegsLivesHereXDD+2]

    pop word ptr es:[di+16]
    pop word ptr es:[di+14]
    pop word ptr es:[di+12]
    pop word ptr es:[di+10]
    pop word ptr es:[di+8]
    pop word ptr es:[di+6]
    pop word ptr es:[di+4]
    pop word ptr es:[di+2]
    pop word ptr es:[di]

    pop ds
    pop bp
End;

{��⠭�������� ���� ����� ���뢠��� ANum �� ANewHandlerP}
Procedure SetIntVec(ANum: Byte; ANewHandlerP: Pointer); Assembler;
Asm
    push ds
    mov ax,word ptr ANewHandlerP+2
    mov ds,ax
    mov dx,word ptr ANewHandlerP
    mov ah,25h
    mov al,ANum
    int 21h
    pop ds
End;

{�����頥� ����� ���뢠��� � ����஬ ANum}
Function GetIntVec(ANum: Byte): Pointer; Assembler;
Asm
    mov al,ANum
    mov ah,35h
    int 21h
    mov dx,es
    mov ax,bx
End;

{�����頥� True, �᫨ � AVal ��⠭����� ��� ��� ����஬ ABit}
Function IsBitSet(AVal: LongInt; ABit: Byte): Boolean;
Begin
    IsBitSet:= (AVal And (1 Shl ABit)) <> 0;
End;

{�����頥� AVal, � ���஬ ��� ABit ��⠭����� � 1}
Function SetBit(AVal: LongInt; ABit: Byte): LongInt;
Begin
    SetBit:= AVal Or (1 Shl ABit);
End;

{�����頥� AVal, � ���஬ ��� ABit ��⠭����� � 0}
Function ClearBit(AVal: LongInt; ABit: Byte): LongInt;
Begin
    ClearBit:= AVal And (( 1 Shl ABit) Xor $FFFFFFFF);
End;

{�����頥� AVal, � ���஬ ��� ABit ������஢��}
Function ToggleBit(AVal: LongInt; ABit: Byte): LongInt;
Begin
    ToggleBit:= AVal Xor (1 Shl ABit);
End;

{�����頥� 0, �᫨ 8086, 1 - 286, 2 - 386 � ���}
Function CheckCPUType: Word; Assembler;
Asm
    pushf
    xor ax,ax
    push ax
    popf
    pushf
    pop ax
    and ax,0f000h
    cmp ax,0f000h
    je @CPU86
    mov ax,0f000h
    push ax
    popf
    pushf
    pop ax
    and ax,0f000h
    jz @CPU286
    mov ax,2
    jmp @End
   @CPU286:
    mov ax,1
    jmp @End
   @CPU86:
    xor ax,ax
   @End:
    popf
End;

{Timer}
Function ReadTimer: LongInt;
Begin
    ReadTimer:= GTimer;
End;

Function ReadTimerChip: Word;
Var
    Frec: Word;
Begin
    Frec:= Port[$40];
    Frec:= Frec Or (Port[$40] Shl 8);
    ReadTimerChip:= Frec;
End;

Function ReadOsc: LongInt;
Begin
    ReadOsc:= ((ReadTimer And $7FFF) * $10000)
    Or (65535 - ReadTimerChip);
End;

Function ReadMS: LongInt;
Const
    K = 1193180 / 1000;
Begin
    ReadMS:= Trunc(ReadOsc / K);
End;

Procedure DelayTicks(Ticks: LongInt);
Var
    FinishTime: LongInt;
Begin
    FinishTime:= ReadTimer + Ticks;
    Repeat Until ReadTimer >= FinishTime;
End;

Procedure Delay(MS: Word);
Const
    K = 1193180 / 1000;
Var
    FinishTime: LongInt;
Begin
    FinishTime:= ReadOsc + Trunc(MS * K);
    Repeat Until FinishTime <= ReadOsc;
End;

Procedure SwapInt(Var AFirst: Integer; Var ASec: Integer);
Var
    Temp: Integer;
Begin
    Temp:= ASec; ASec:= AFirst; AFirst:= Temp;
End;

Procedure SetGM(ANum: Byte); Assembler;
Asm
   mov ah,0
   mov al,ANum
   int 10h
End;

Function GetCurGM: Byte;
Begin
    GetCurGM:= Byte(Ptr($40, $49)^);
End;

Procedure RestoreOldGM;
Begin
    If GOldVMode <> GetCurGM Then SetGM(GOldVMode);
End;

Begin
    GOldVMode:= GetCurGM;
End.