{$I+} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N-} {$D+} {$L-} {$Y-} {$X-}
Unit LMem;
Interface
Uses
    LUtils, LInput;
Const
    CMaxBufSize = 65520;
    CMaxByte = High(Byte);
    CMinByte = Low(Byte);
    CMaxShort = High(ShortInt);
    CMinShort = Low(ShortInt);
    CMaxInt = High(Integer);
    CMinInt = Low(Integer);
    CMaxWord = High(Word);
    CMinWord = Low(Word);
    CMaxLong = High(LongInt);
    CMinLong = Low(LongInt);
Type
    TByteBuf = Array [1..65520] Of Byte;
    TCharBuf = Array [1..65520] Of Char;
    TWordBuf = Array [1..32760] Of Word;
    TIntBuf = Array [1..32760] Of Integer;
    TLongBuf = Array [1..16380] Of LongInt;
    TStrBuf = Array [1..255] Of String;
    TBoolBuf = Array [1..65520] Of Boolean;

    TByteBufP = ^TByteBuf;
    TWordBufP = ^TWordBuf;
    TIntBufP = ^TIntBuf;
    TLongBufP = ^TLongBuf;
    TCharBufP = ^TCharBuf;
    TStrBufP = ^TStrBuf;
    TBoolBufP = ^TBoolBuf;

    TMoveMemProc = Procedure(AFrom, ATo: Pointer; ASize: Word);
    TFillMemProc = Procedure(ADst: Pointer; AValue: Byte; ASize: Word);

    Function SafeCreateBuf(ASize: Word): Pointer;
    Function CreateBuf(ASize: Word): Pointer;
    Function SizeOfBuf(ABuf: Pointer): Word;
    Function ResizeBuf(ABuf: Pointer; ANewSize: Word): Pointer;
    Function ChangeReportSizeBuf(ABuf: Pointer; ANewSize: Word): Pointer;
    Function DestroyBuf(ABuf: Pointer): Pointer;
    Function SafeDestroyBuf(ABuf: Pointer): Pointer;
    Function BytesToKB(Bytes: LongInt): LongInt;
    Function KBToBytes(KBs: LongInt): LongInt;
    Procedure MoveMem16(ATo, AFrom: Pointer; ASize: Word); Far;
    Procedure MoveMem32(ATo, AFrom: Pointer; ASize: Word); Far;
    Procedure FillMem16(ADst: Pointer; AValue: Byte; ASize: Word);
    Procedure FillMem32(ADst: Pointer; AValue: Byte; ASize: Word);

Var
    MoveMem: TMoveMemProc;
    FillMem: TFillMemProc;

Implementation
Const
    ErrMsg_Bytes = ' bytes';

Function SafeCreateBuf(ASize: Word): Pointer;
Var
    TempP: Pointer;
Begin
    TempP:= CreateBuf(ASize);
    If TempP = Nil Then Begin
        RestoreOldGM;
        LInput.RestoreOldKeybHandler;
        WriteLn('LMem: Unable to create memory buffer');
        WriteLn('Need: ', ASize, ErrMsg_Bytes);
        WriteLn('Free memory left: ', MemAvail, ErrMsg_Bytes);
        WriteLn('Max free memory block: ', MaxAvail, ErrMsg_Bytes);
        Halt;
    End;
    SafeCreateBuf:= TempP;
End;

Function CreateBuf(ASize: Word): Pointer;
Var
    TempP: Pointer;
Begin
    If (ASize = 0) Or (ASize > CMaxBufSize) Or (MaxAvail < ASize + 2) Then Begin
        CreateBuf:= Nil;
        Exit;
    End;
    Inc(ASize, 2);
    GetMem(TempP, ASize);
    Word(TempP^):= ASize;
    TempP:= Pointer(LongInt(TempP) + 2);
    CreateBuf:= TempP;
End;

Function ResizeBuf(ABuf: Pointer; ANewSize: Word): Pointer;
Var
    TempP: Pointer;
Begin
    TempP:= CreateBuf(ANewSize);
    If TempP = Nil Then Begin
        ResizeBuf:= Nil;
        Exit;
    End;
    If ANewSize >= SizeOfBuf(ABuf) Then
        MoveMem(TempP, ABuf, SizeOfBuf(ABuf))
    Else
        MoveMem(TempP, ABuf, ANewSize);
    ABuf:= DestroyBuf(ABuf);
    ResizeBuf:= TempP;
End;

Function ChangeReportSizeBuf(ABuf: Pointer; ANewSize: Word): Pointer;
Begin
    Word(Pointer(LongInt(ABuf) - 2)^):= ANewSize;
    ChangeReportSizeBuf:= ABuf;
End;

Function SizeOfBuf(ABuf: Pointer): Word;
Begin
    SizeOfBuf:= Word(Pointer(LongInt(ABuf) - 2)^) - 2;
End;

Function DestroyBuf(ABuf: Pointer): Pointer;
Begin
    ABuf:= TByteBufP(LongInt(ABuf) - 2);
    FreeMem(ABuf, Word(Pointer(ABuf)^));
    DestroyBuf:= Nil;
End;

Function SafeDestroyBuf(ABuf: Pointer): Pointer;
Begin
    If ABuf <> Nil Then ABuf:= DestroyBuf(ABuf);
    SafeDestroyBuf:= Nil;
End;

Procedure MoveMem16(ATo, AFrom: Pointer; ASize: Word); Assembler;
Asm
    push ds
    mov dx,ASize
    test dx,dx
    jz @End
    lds si,AFrom
    les di,ATo
    cld
    cmp dx,1
    je @CopyLastByte
    mov cx,dx
    shr cx,1
    rep movsw
    and dx,1
    test dx,dx
    jz @End
   @CopyLastByte:
    movsb
   @End:
    pop ds
End;

Procedure MoveMem32(ATo, AFrom: Pointer; ASize: Word); Assembler;
Asm
    push ds
    mov dx,ASize
    test dx,dx
    jz @End
    lds si,AFrom
    les di,ATo
    cld

    cmp dx,1
    je @CopyLastByte
    cmp dx,2
    je @CopyLastWord
    cmp dx,3
    je @CopyLastTriple

    mov cx,dx
    shr cx,2
    db 66h
    rep movsw

    and dx,3
    test dx,dx
    jz @End
    cmp dx,1
    je @CopyLastByte
    cmp dx,2
    je @CopyLastWord
   @CopyLastTriple:
    movsb
   @CopyLastWord:
    movsb
   @CopyLastByte:
    movsb
   @End:
    pop ds
End;

Procedure FillMem16(ADst: Pointer; AValue: Byte; ASize: Word); Assembler;
Asm
    mov cx,ASize
    test cx,cx
    jz @End
    les di,ADst
    cld
    mov al,AValue
    mov ah,al
    cmp cx,1
    je @FillLastByte
    mov dx,cx
    and dx,1
    shr cx,1
    rep stosw
    test dx,dx
    jz @End
   @FillLastByte:
    stosb
   @End:
End;

Procedure FillMem32(ADst: Pointer; AValue: Byte; ASize: Word); Assembler;
Asm
    mov cx,ASize
    test cx,cx
    jz @End
    les di,ADst
    cld
    mov al,AValue
    mov ah,al
    push ax
    push ax
    db 66h
    pop ax

    mov dx,cx
    cmp dx,1
    je @FillLastByte
    cmp dx,2
    je @FillLastWord
    cmp dx,3
    je @FillLastTriple

    shr cx,2
    db 66h
    rep stosw

    and dx,3
    cmp dx,1
    je @FillLastByte
    cmp dx,2
    je @FillLastWord
   @FillLastTriple:
    stosb
   @FillLastWord:
    stosb
   @FillLastByte:
    stosb
   @End:
End;

Function BytesToKB(Bytes: LongInt): LongInt;
Begin
    BytesToKB:= Bytes Div 1024 + LongInt((Bytes Mod 1024) > 0);
End;

Function KBToBytes(KBs: LongInt): LongInt;
Begin
    KBToBytes:= KBs Shl 10;
End;

Begin
    MoveMem:= MoveMem16;
    FillMem:= FillMem16;
End.