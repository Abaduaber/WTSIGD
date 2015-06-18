{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Unit LRF;
Interface
Uses
    LUtils, LMem, LXMS;
Type
    TSFName = String[12];
    TFileName = String[255];

    TResErr = (
        TRE_Ok, TRE_UnableToCreate, TRE_UnableToOpen, TRE_DamagedLRF,
        TRE_NotOpened, TRE_SubFileNotExist, TRE_UnableToAddSelfInSelf,
        TRE_AlreadyExistInRF, TRE_SrcFileNotExist, TRE_SrcFileEmpty,
        TRE_MaxFilesReached, TRE_UnknownLRFVer, TRE_UnableToSeek,
        TRE_SFNotOpened, TRE_RFIsEmpty, TRE_ReadBeyondEOSF,
        TRE_UnableToCreateDstF, TRE_UnableToExtract, TRE_NotAResFile
    );
    TResErrMsg = String[80];

    TResHead = Record
        FResId: LongInt;
        FVer, FCrypt, FCompressed, FFileCount: Word;
    End;
    TSFHead = Record
        FId: Word;
        FName: TSFName;
        FReserved: Byte;
        FOffs, FSize: LongInt;
    End;
    TRes = Record
        FHead: TResHead;
        FCurFile: TSFHead;
        FErr: TResErr;
        FFD: File;
        FFName: String;
        FIsOpened, FIsSFOpened: Boolean;
    End;
    TResP = ^TRes;

    Procedure CreateRes(Var AResP: TResP);
    Procedure CreateRF(Var AResP: TResP; AFileName: TFileName);
    Procedure OpenRF(Var AResP: TResP; AFileName: TFileName);
    Procedure CloseRF(Var AResP: TResP);
    Function FindSF(Var AResP: TResP; ASubFName: TSFName): LongInt;
    Procedure OpenSF(Var AResP: TResP; ASubFName: TSFName);
    Procedure OpenFirstSF(Var AResP: TResP);
    Function OpenNextSF(Var AResP: TResP): LongInt;
    Procedure ReadSF(Var AResP: TResP; Var ABuf; ASize: Word);
    Procedure ReadLnSF(Var AResP: TResP; Var AStr: String);
    Procedure SeekSF(Var AResP: TResP; ANewPos: LongInt);
    Function SFSize(Var AResP: TResP): LongInt;
    Function SFPos(Var AResP: TResP): LongInt;
    Function SFOffs(Var AResP: TResP): LongInt;
    Function SFName(Var AResP: TResP): TSFName;
    Function IsSFEOF(Var AResP: TResP): Boolean;

    Procedure AddFileToRF(Var AResP: TResP; AFileName: TFileName);
    Procedure ExtractFromRF(Var AResP: TResP; ASFName: TSFName);
    Procedure DeleteFromRF(Var AResP: TResP; ASFName: TSFName);

    Function GetErr(Var AResP: TResP): TResErr;
    Procedure ClearErr(Var AResP: TResP);
    Procedure ReportError(Var AResP: TResP; AIsHalt: Boolean);
    Procedure DestroyRes(Var AResP: TResP);


Const
    CLRFErrMsgs: Array [0..Ord(TRE_NotAResFile)] Of TResErrMsg = (
        'Ok',
        'Unable to create LRF-file',
        'Unable to open LRF-file',
        'LRF file is damaged',
        'LRF file is not opened',
        'Sub file with required name not exist in LRF',
        'Unable to add self LRF file to self',
        'Subfile with this name already exist in LRF',
        'Source file to add is not exist',
        'Source file to add is empty',
        'Max amout of subfiles reached - unable to add more',
        'Unknown LRF version',
        'Unable to seek in file',
        'Subfile not opened',
        'Resource file is empty',
        'Unable to read beyond end of subfile',
        'Unable to create destination file',
        'Unable to extract file',
        'Specified file is not in LRF-format'
    );

Implementation
Const
    CResId = $3E46524C;
    CResFId = $3E46;
    CResMaxFiles = 1000;

    CModuleName = 'LRes'; CModuleVer = '1.0';
    CLRFVer = $0001;

    Procedure ReadSFHead(Var AResP: TResP); Forward;
    Procedure SetErr(Var AResP: TResP; ABool: Boolean; AErr: TResErr); Forward;

Procedure CreateRes(Var AResP: TResP);
Begin
    AResP:= SafeCreateBuf(SizeOf(AResP^));
    With AResP^ Do Begin
        FHead.FResId:= 0;
        FIsOpened:= False;
        FErr:= TRE_Ok;
    End;
End;

Procedure CreateRF(Var AResP: TResP; AFileName: TFileName);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        If FIsOpened Then CloseRF(AResP);
        FFName:= DownCase(AFileName);
        Assign(FFD, FFName);
        ReWrite(FFD, 1);
        FHead.FResId:= CResId;
        FHead.FFileCount:= 0;
        FHead.FVer:= CLRFVer;
        FHead.FCrypt:= 0;
        FHead.FCompressed:= 0;
        BlockWrite(FFD, FHead, SizeOf(FHead));
        If IOResult <> 0 Then Begin
            FErr:= TRE_UnableToCreate;
            Exit;
        End;
        FIsOpened:= True;
    End;
End;

Procedure OpenRF(Var AResP: TResP; AFileName: TFileName);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        If FIsOpened Then CloseRF(AResP);
        FFName:= DownCase(AFileName);
        Assign(FFD, FFName);
        Reset(FFD, 1);
        SetErr(AResP, IOResult <> 0, TRE_UnableToOpen);
        BlockRead(FFD, FHead, SizeOf(FHead));
        SetErr(AResP, IOResult <> 0, TRE_DamagedLRF);
        SetErr(AResP, FHead.FResId <> CResId, TRE_NotAResFile);
        SetErr(AResP, FHead.FVer > CLRFVer, TRE_UnknownLRFVer);
        FIsOpened:= True;
    End;
End;

Function FindSF(Var AResP: TResP; ASubFName: TSFName): LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        If Not FIsOpened Then Begin
            FErr:= TRE_NotOpened;
            Exit;
        End;
        ASubFName:= DownCase(ASubFName);
        Seek(FFD, SizeOf(FHead));
        While Not EOF(FFD) Do Begin
            ReadSFHead(AResP);
            If FErr <> TRE_Ok Then Break;
            If FCurFile.FName = ASubFName Then Begin
                FindSF:= FilePos(FFD);
                FIsSFOpened:= True;
                Exit;
            End
            Else Begin
                If FilePos(FFD) + FCurFile.FSize > FileSize(FFD) Then Begin
                    FErr:= TRE_DamagedLRF;
                    Break;
                End;
                Seek(FFD, FilePos(FFD) + FCurFile.FSize);
            End;
        End;
        FindSF:= 0;
    End;
End;

Procedure OpenSF(Var AResP: TResP; ASubFName: TSFName);
Begin
    If AResP^.FErr <> TRE_Ok Then ReportError(AResP, True);
    SetErr(AResP, FindSF(AResP, ASubFName) = 0, TRE_SubFileNotExist);
End;

Procedure OpenFirstSF(Var AResP: TResP);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        Seek(FFD, SizeOf(FHead));
        SetErr(AResP, EOF(FFD), TRE_RFIsEmpty);
        ReadSFHead(AResP);
        FIsSFOpened:= True;
    End;
End;

Function OpenNextSF(Var AResP: TResP): LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        Seek(FFD, FCurFile.FOffs + FCurFile.FSize);
        If EOF(FFD) Then Begin
            OpenNextSF:= 0;
            FIsSFOpened:= False;
        End
        Else Begin
            ReadSFHead(AResP);
            FIsSFOpened:= True;
            OpenNextSF:= FCurFile.FOffs;
        End;
    End;
End;

Procedure ReadSF(Var AResP: TResP; Var ABuf; ASize: Word);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SetErr(AResP, IsSFEOF(AResP) Or (SFPos(AResP)
          + ASize > FCurFile.FOffs + FCurFile.FSize), TRE_ReadBeyondEOSF);
        If FErr = TRE_Ok Then BlockRead(FFD, ABuf, ASize);
    End;
End;

Procedure ReadLnSF(Var AResP: TResP; Var AStr: String);
Var
    I, FS, EOLExist: Word;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SetErr(AResP, IsSFEOF(AResP), TRE_ReadBeyondEOSF);
        FS:= 255;
        If SFSize(AResP) - SFPos(AResP) < FS Then
          FS:= SFSize(AResP) - SFPos(AResP);   {FSize!!!}
        ReadSF(AResP, AStr[1], FS);
        EOLExist:= 0;
        For I:= 1 To FS Do
        If Word((Pointer(PChar(@AStr[I])))^) = CEOLSign Then Begin
            Dec(I);
            EOLExist:= 2;
            Break;
        End;
        AStr[0]:= Chr(I);
        SeekSF(AResP, SFPos(AResP) - (FS - I - EOLExist));
    End;
End;

Function SFSize(Var AResP: TResP): LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SFSize:= FCurFile.FSize;
    End;
End;

Function SFPos(Var AResP: TResP): LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SFPos:= FilePos(FFD) - FCurFile.FOffs;
    End;
End;

Function SFOffs(Var AResP: TResP): LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SFOffs:= FCurFile.FOffs;
    End;
End;

Function SFName(Var AResP: TResP): TSFName;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SFName:= FCurFile.FName;
    End;
End;

Function IsSFEOF(Var AResP: TResP): Boolean;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        IsSFEOF:= FilePos(FFD) >= (FCurFile.FOffs + FCurFile.FSize);
    End;
End;

Procedure SeekSF(Var AResP: TResP; ANewPos: LongInt);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        SetErr(AResP, Not FIsSFOpened, TRE_SFNotOpened);
        SetErr(AResP, (ANewPos > FCurFile.FSize) Or (ANewPos < 0), TRE_UnableToSeek);
        If FErr = TRE_Ok Then Seek(FFD, FCurFile.FOffs + ANewPos);
    End;
End;

Procedure ReadSFHead(Var AResP: TResP);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        BlockRead(FFD, FCurFile, SizeOf(FCurFile));
        SetErr(AResP, (IOResult <> 0) Or (FCurFile.FId <> CResFId), TRE_DamagedLRF);
    End;
End;

Procedure AddFileToRF(Var AResP: TResP; AFileName: TFileName);
Var
    SrcFD: File;
    BufP: TByteBufP;
    TempW: LongInt;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        AFileName:= DownCase(AFileName);
        SetErr(AResP, FFName = AFileName, TRE_UnableToAddSelfInSelf);
        SetErr(AResP, FindSF(AResP, AFileName) <> 0, TRE_AlreadyExistInRF);
        Assign(SrcFD, AFileName);
        Reset(SrcFD, 1);
        SetErr(AResP, IOResult <> 0, TRE_SrcFileNotExist);
        SetErr(AResP, FileSize(SrcFD) = 0, TRE_SrcFileEmpty);
        Inc(FHead.FFileCount);
        SetErr(AResP, FHead.FFileCount > CResMaxFiles, TRE_MaxFilesReached);
        If FErr <> TRE_Ok Then Begin
            Close(SrcFD);
            If IOResult <> 0 Then;
            Exit;
        End;

        With FCurFile Do Begin
            FId:= CResFId;
            FName:= ExtractFullNameFromPath(AFileName);
            FReserved:= 0;
            FSize:= FileSize(SrcFD);
            FOffs:= FileSize(FFD) + SizeOf(FCurFile);
        End;
        Seek(FFD, 0);
        BlockWrite(FFD, FHead, SizeOf(FHead));
        Seek(FFD, FileSize(FFD));
        BlockWrite(FFD, FCurFile, SizeOf(FCurFile));

        If FileSize(SrcFD) > SizeOf(BufP^) Then
          BufP:= SafeCreateBuf(SizeOf(BufP^))
        Else
          BufP:= SafeCreateBuf(FileSize(SrcFD));

        While Not EOF(SrcFD) Do Begin
            If FileSize(SrcFD) - FilePos(SrcFD) > SizeOfBuf(BufP) Then Begin
                BlockRead(SrcFD, BufP^, SizeOfBuf(BufP));
                BlockWrite(FFD, BufP^, SizeOfBuf(BufP));
            End
            Else Begin
                TempW:= FileSize(SrcFD) - FilePos(SrcFD);
                BlockRead(SrcFD, BufP^, TempW);
                BlockWrite(FFD, BufP^, TempW);
            End;
        End;
        OpenSF(AResP, FCurFile.FName);
        SeekSF(AResP, 0);
        FIsSFOpened:= True;
        BufP:= DestroyBuf(BufP);
        Close(SrcFD);
        If IOResult <> 0 Then;
    End;
End;

Procedure ExtractFromRF(Var AResP: TResP; ASFName: TSFName);
Var
    DstFD: File;
    BufP: TByteBufP;
    TempW: Word;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        ASFName:= DownCase(ASFName);
        OpenSF(AResP, ASFName);
        If FErr <> TRE_Ok Then Exit;
        Assign(DstFD, ASFName);
        ReWrite(DstFD, 1);
        SetErr(AResP, IOResult <> 0, TRE_UnableToCreateDstF);

        If SFSize(AResP) >= SizeOf(BufP^) Then
            BufP:= SafeCreateBuf(SizeOf(BufP^))
        Else
            BufP:= SafeCreateBuf(SFSize(AResP));

        While Not IsSFEOF(AResP) Do Begin
            If SFSize(AResP) - SFPos(AResP) > SizeOfBuf(BufP) Then Begin
                ReadSF(AResP, BufP^, SizeOfBuf(BufP));
                BlockWrite(DstFD, BufP^, SizeOfBuf(BufP));
            End
            Else Begin
                TempW:= SFSize(AResP) - SFPos(AResP);
                ReadSF(AResP, BufP^, TempW);
                BlockWrite(DstFD, BufP^, TempW);
            End;
        End;
        SetErr(AResP, IOResult <> 0, TRE_UnableToExtract);
        SeekSF(AResP, 0);
        BufP:= DestroyBuf(BufP);
        Close(DstFD);
    End;
End;

Procedure DeleteFromRF(Var AResP: TResP; ASFName: TSFName);
Var
    BufP: TByteBufP;
    LResP: TResP;
    ModifyOffs: LongInt;
    OldName, TempName: TFileName;
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        SetErr(AResP, Not FIsOpened, TRE_NotOpened);
        ASFName:= DownCase(ASFName);
        SetErr(AResP, FindSF(AResP, ASFName) = 0, TRE_SubFileNotExist);
        If GetErr(AResP) <> TRE_Ok Then Exit;
        OldName:= AResP^.FFName;
        TempName:= Copy(OldName, 1, Length(OldName) - 1) + '_';
        ModifyOffs:= 0;
        CreateRes(LResP);
        CreateRF(LResP, TempName);
        LResP^.FHead.FFileCount:= FHead.FFileCount - 1;
        Seek(LResP^.FFD, 0);
        BlockWrite(LResP^.FFD, LResP^.FHead, SizeOf(LResP^.FHead));

        OpenFirstSF(AResP);
        While Not EOF(FFD) And (FErr = TRE_Ok) Do Begin
            If FCurFile.FName = ASFName Then
                ModifyOffs:= FCurFile.FSize
            Else Begin
                If SFSize(AResP) >= SizeOf(BufP^) Then
                    BufP:= SafeCreateBuf(SizeOf(BufP^))
                Else
                    BufP:= SafeCreateBuf(SFSize(AResP));

                If ModifyOffs > 0 Then Begin
                    Dec(FCurFile.FOffs, ModifyOffs + SizeOf(FCurFile));
                    BlockWrite(LResP^.FFD, FCurFile, SizeOf(FCurFile));
                    Inc(FCurFile.FOffs, ModifyOffs + SizeOf(FCurFile));
                End
                Else
                    BlockWrite(LResP^.FFD, FCurFile, SizeOf(FCurFile));

                While Not IsSFEOF(AResP) And (FErr = TRE_Ok) Do Begin
                    If SFSize(AResP) - SFPos(AResP) > SizeOfBuf(BufP) Then Begin
                        ReadSF(AResP, BufP^, SizeOfBuf(BufP));
                        BlockWrite(LResP^.FFD, BufP^, SizeOfBuf(BufP));
                    End
                    Else Begin
                        BufP:= ResizeBuf(BufP, SFSize(AResP) - SFPos(AResP));
                        ReadSF(AResP, BufP^, SizeOfBuf(BufP));
                        BlockWrite(LResP^.FFD, BufP^, SizeOfBuf(BufP));
                    End;
                End;
                BufP:= DestroyBuf(BufP);
            End;
            If OpenNextSF(AResP) = 0 Then Break;
        End;
        DestroyRes(LResP);
        CloseRF(AResP);
        If IsDeleteFile(OldName) Then;
        Assign(FFD, TempName);
        Rename(FFD, OldName);
        OpenRF(AResP, OldName);
    End;
End;

Procedure CloseRF(Var AResP: TResP);
Begin
    With AResP^ Do Begin
        If FErr <> TRE_Ok Then ReportError(AResP, True);
        If Not FIsOpened Then Exit;
        FHead.FResId:= 0; FHead.FFileCount:= 0;
        FIsOpened:= False; FIsSFOpened:= False;
        Close(FFD);
        If IOResult <> 0 Then;
    End;
End;

Procedure DestroyRes(Var AResP: TResP);
Begin
    If AResP^.FIsOpened Then CloseRF(AResP);
    AResP:= DestroyBuf(AResP);
End;

Function GetErr(Var AResP: TResP): TResErr;
Begin
    GetErr:= AResP^.FErr;
End;

Procedure ClearErr(Var AResP: TResP);
Begin
    AResP^.FErr:= TRE_Ok;
End;

Procedure SetErr(Var AResP: TResP; ABool: Boolean; AErr: TResErr);
Begin
    If ABool And (AResP^.FErr = TRE_Ok) Then AResP^.FErr:= AErr;
End;

Procedure ReportError(Var AResP: TResP; AIsHalt: Boolean);
Begin
    If AResP^.FErr = TRE_Ok Then Exit;
    WriteLn(CModuleName, ', file - ', AResP^.FFName, ': ', CLRFErrMsgs[Byte(AResP^.FErr)]);
    If AIsHalt Then Begin
        ReadLn;
        Halt(Byte(AResP^.FErr));
    End;
End;

End.