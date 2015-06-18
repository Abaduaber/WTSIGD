{$I+} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Unit LXMS;
Interface
Uses
    LUtils;
Type
    TXMSId = Word;

    Function Init: Boolean;
    Function GetVersion: Word;
    Function XMemAvail: Word;
    Function XMaxAvail: Word;
    Function GetMem(AMemSize: Word): Word;
    Function FreeMem(AId: Word): Word;
    Procedure MemToXMS(AXMSId: Word; AFrom: Pointer; ASize, AOffs: LongInt);
    Procedure XMSToMem(AXMSId: Word; ATo: Pointer; ASize, AOffs: LongInt);
    Procedure XMSToXMS(ADstXMS, ASrcXMS: Word; ADstOffs, ASrcSize, ASrcOffs: LongInt);

Implementation
Type
    TXMSDataRec = Record
        FMoveBytesCount: LongInt;
        FSrcId: Word;
        FSrcOffs: LongInt;
        FDstId: Word;
        FDstOffs: LongInt;
    End;
    TXMSErr = (
        TE_Ok, TE_NotEnoughMem, TE_WrongEMB, TE_EMBBlocked,
        TE_Uninitialized, TE_Unknown
    );
Const
    {Константы имени и версии модуля}
    CModuleName = 'LXMS'; CModuleVer = '1.0';
    {Текстовые константы сообщений об ошибках}
    CErrMsgs: Array [0..Ord(TE_Unknown)] Of String[40] = (
        'OK',
        'Not enough XMS memory.',
        'Wrong EMB block identifier',
        'EMB field is blocked',
        'XMS is not initialized',
        'Unknown XMS error'
    );
Var
    EntryPoint: Pointer;
    MoveRec: TXMSDataRec;
    IsInitialized: Boolean;

    Procedure ReportError(AErr: Word); Forward;
    Procedure Copy; Forward;

Function Init: Boolean; Assembler;
Asm
    mov ax,4300h
    int 2fh
    cmp al,80h
    jne @Exit
    mov ax,1
    mov [IsInitialized],al
    mov ax,4310h
    int 2fh
    mov word ptr [EntryPoint],bx
    mov word ptr [EntryPoint+2],es
   @Exit:
End;

Function GetVersion: Word; Assembler;
Asm
    cmp [IsInitialized],0
    jne @Next
    push 0
    call ReportError
   @Next:
    xor ah,ah
    call dword ptr EntryPoint
End;

Function XMemAvail: Word; Assembler;
Asm
    cmp [IsInitialized],0
    jne @Next
    push 0
    call ReportError
   @Next:
    mov ah,08h
    xor bl,bl
    call dword ptr EntryPoint
    xor bh,bh
    test bl,bl
    jz @NotErr
    push bx
    call ReportError
   @NotErr:
End;

Function XMaxAvail: Word; Assembler;
Asm
    cmp [IsInitialized],0
    jne @Next
    push 0
    call ReportError
   @Next:
    mov ah,08h
    xor bl,bl
    call dword ptr EntryPoint
    xor bh,bh
    test bl,bl
    jz @NotErr
    push bx
    call ReportError
   @NotErr:
    mov ax,dx
End;

Function GetMem(AMemSize: Word): Word; Assembler;
Asm
    cmp [IsInitialized],0
    jne @Next
    push 0
    call ReportError
   @Next:
    mov ah,09h
    mov dx,AMemSize
    call dword ptr EntryPoint
    test ax,ax
    jnz @End
    xor bh,bh
    push bx
    call ReportError
   @End:
    mov ax,dx
End;

Function FreeMem(AId: Word): Word; Assembler;
Asm
    cmp [IsInitialized],0
    jne @Next
    push 0
    call ReportError
   @Next:
    mov dx,AId
    mov ah,0ah
    call dword ptr EntryPoint
    test ax,ax
    jnz @End
    xor bh,bh
    push bx
    call ReportError
   @End:
    xor ax,ax
End;

Procedure Copy; Assembler;
Asm
    mov ah,0bh
    mov si,offset MoveRec
    call dword ptr EntryPoint
    test ax,ax
    jnz @End
    xor bh,bh
    push bx
    call ReportError
   @End:
End;

Procedure MemToXMS(AXMSId: Word; AFrom: Pointer; ASize, AOffs: LongInt);
Begin
    If Not IsInitialized Then ReportError(0);
    Inc(ASize, ASize And 1);
    With MoveRec Do Begin
        FMoveBytesCount:= ASize;
        FSrcId:= 0;
        FSrcOffs:= LongInt(AFrom);
        FDstId:= AXMSId;
        FDstOffs:= AOffs;
    End;
    Copy;
End;

Procedure XMSToMem(AXMSId: Word; ATo: Pointer; ASize, AOffs: LongInt);
Begin
    If Not IsInitialized Then ReportError(0);
    Inc(ASize, ASize And 1);
    With MoveRec Do Begin
        FMoveBytesCount:= ASize;
        FSrcId:= AXMSId;
        FSrcOffs:= AOffs;
        FDstId:= 0;
        FDstOffs:= LongInt(ATo);
    End;
    Copy;
End;

Procedure XMSToXMS(ADstXMS, ASrcXMS: Word; ADstOffs, ASrcSize, ASrcOffs: LongInt);
Begin
    If Not IsInitialized Then ReportError(0);
    Inc(ASrcSize, ASrcSize And 1);
    With MoveRec Do Begin
        FMoveBytesCount:= ASrcSize;
        FSrcId:= ASrcXMS;
        FSrcOffs:= ASrcOffs;
        FDstId:= ADstXMS;
        FDstOffs:= ADstOffs;
    End;
    Copy;
End;

Procedure ReportError(AErr: Word);
Begin
    RestoreOldGM;
    Write(CModuleName, ': ');
    Case AErr Of
      $0A0:
        WriteLn(CErrMsgs[Ord(TE_NotEnoughMem)]);
      $0A2:
        WriteLn(CErrMsgs[Ord(TE_WrongEMB)]);
      $0AB:
        WriteLn(CErrMsgs[Ord(TE_EMBBlocked)]);
      0:
        WriteLn(CErrMsgs[Ord(TE_Uninitialized)]);
      Else
        WriteLn(CErrMsgs[Ord(TE_Unknown)]);
    End;
    ReadLn;
    Halt(AErr);
End;

Begin
    IsInitialized:= False;
End.