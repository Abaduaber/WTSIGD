{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Program LRFP;
Uses
    LMem, LUtils, LRF;
Const
    CUsageText = 'Usage: lrfp.exe am resfilename mask' + Chr(13) + Chr(10) +
    'Or lrfp.exe al resfilename listfilename' + Chr(13) + Chr(10) +
    'Or lrfp.exe e resfilename subfilename' + Chr(13) + Chr(10) +
    'Or lrfp.exe ea resfilename' + Chr(13) + Chr(10) +
    'Or lrfp.exe d resfilename subfilename';
    CAddText = 'added';
    CDeleteText = 'deleted';
    CExtractText = 'extracted';
    COverwrite = 'file is already exist. Overwrite? [Y/N]?: ';
    CSkipped = 'file skipped';

Procedure AddFileByMask(Var AResP: TResP; Var ADTAP: TDTARecP; AMask: String);
Begin
    FindFirstFile(ADTAP, AMask);
    While ADTAP^.FErrCode = 0 Do Begin
        AddFileToRF(AResP, GetDTAName(ADTAP));
        If GetErr(AResP) <> TRE_Ok Then Begin
            WriteLn(GetDTAName(ADTAP) + ' - ' + LRF.CLRFErrMsgs[Byte(GetErr(AResP))]);
            ClearErr(AResP);
        End
        Else
            WriteLn(GetDTAName(ADTAP) + ' - ' + CAddText);
        FindNextFile(ADTAP);
    End;
    ADTAP:= DestroyBuf(ADTAP);
End;

Procedure Check_N_CreateRes(Var AResP: TResP; Var AFName: String);
Begin
    CreateRes(AResP);
    OpenRF(AResP, AFName);
    If GetErr(AResP) <> TRE_OK Then Begin
        ClearErr(AResP);
        CreateRF(AResP, AFName);
    End;
End;

Procedure ReportResError(Var AResP: TResP; ABool: Boolean);
Begin
    If Not ABool Or (GetErr(AResP) = TRE_Ok) Then Exit;
    WriteLn(LRF.CLRFErrMsgs[Byte(GetErr(AResP))]);
    Halt(Byte(GetErr(AResP)));
End;

Procedure ExtractPromptOverwrite(Var AResP: TResP; AFName: String);
Var
    Tex: String;
Begin
    Write(AFName, ' - ', COverwrite);
    ReadLn(Tex);
    If UpperCase(Tex) = 'Y' Then Begin
        ExtractFromRF(AResP, AFName);
        ReportResError(AResP, True);
        WriteLn(AFName, ' - ', CExtractText);
    End
    Else
        WriteLn(AFName, ' - ', CSkipped);
End;

Procedure G_n_R_Sex_Drugs_n_Rock_n_Roll;
Var
    DTAP: TDTARecP;
    Par1, Par2, Par3, Tex: String;
    FD: Text;
    ResP: TResP;
Begin
    Par1:= UpperCase(ParamStr(1));
    Par2:= UpperCase(ParamStr(2));
    Par3:= UpperCase(ParamStr(3));
    If Par1 = 'AL' Then Begin
        If Not IsFileExist(Par3) Then Begin
            WriteLn('>list file ' + Par3 + ' not exist');
            Halt(2);
        End;
        Assign(FD, Par3);
        Reset(FD);
        Check_N_CreateRes(ResP, Par2);
        While Not EOF(FD) Do Begin
            ReadLn(FD, Tex);
            AddFileByMask(ResP, DTAP, Tex);
        End;
        Close(FD);
        DestroyRes(ResP);
    End
    Else If Par1 = 'AM' Then Begin
        Check_N_CreateRes(ResP, Par2);
        AddFileByMask(ResP, DTAP, Par3);
        DestroyRes(ResP);
    End
    Else If Par1 = 'E' Then Begin
        CreateRes(ResP);
        OpenRF(ResP, Par2);
        ReportResError(ResP, True);

        If IsFileExist(Par3) Then
            ExtractPromptOverwrite(ResP, Par3)
        Else Begin
            ExtractFromRF(ResP, Par3);
            ReportResError(ResP, True);
            WriteLn(Par3, ' - ', CExtractText);
        End;
        DestroyRes(ResP);
    End
    Else If Par1 = 'EA' Then Begin
        CreateRes(ResP);
        OpenRF(ResP, Par2);
        ReportResError(ResP, True);
        OpenFirstSF(ResP);
        ReportResError(ResP, True);
        If IsFileExist(SFName(ResP)) Then
            ExtractPromptOverwrite(ResP, SFName(ResP))
        Else Begin
            ExtractFromRF(ResP, SFName(ResP));
            ReportResError(ResP, True);
            WriteLn(SFName(ResP), ' - ', CExtractText);
        End;
        While OpenNextSF(ResP) <> 0 Do Begin
            If IsFileExist(SFName(ResP)) Then
                ExtractPromptOverwrite(ResP, SFName(ResP))
            Else Begin
                ExtractFromRF(ResP, SFName(ResP));
                ReportResError(ResP, True);
                WriteLn(SFName(ResP), ' - ', CExtractText);
            End;
        End;
        DestroyRes(ResP);
    End
    Else If Par1 = 'D' Then Begin
        CreateRes(ResP);
        OpenRF(ResP, Par2);
        ReportResError(ResP, True);
        DeleteFromRF(ResP, Par3);
        ReportResError(ResP, True);
        WriteLn(Par3, ' - ', CDeleteText);
        DestroyRes(ResP);
    End
    Else Begin
        WriteLn(CUsageText);
        ReadLn;
    End;
End;

Begin
    G_n_R_Sex_Drugs_n_Rock_n_Roll;
End.