{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Program LGFC;
Uses
    LMem, LUtils, LGFiles;
Const
    CProgName = 'LGFC v2.0:';
    CUsageText = 'Usage: lgfc.exe ep bmpfilename' + Chr(13) + Chr(10) +
        'Or lgfc.exe cm <img, spr, rleimg, rlespr> <p, np> mask';
    CConvText = 'converted';
    CExtractPalText = 'palette extracted';
    COverwrite = 'file is already exist. Overwrite? [Y/N]?: ';
    CSkipped = 'file skipped';
    CWrongMask = 'There is no files matching mask';
    CConvertingDone = 'file(s) converted';
Var
    ConvCount: Word;

Function OverwritePrompt(AFName: String): Boolean;
Var
    Tex: String;
Begin
    Write(AFName, ' - ', COverwrite);
    ReadLn(Tex);
    If UpperCase(Tex) = 'Y' Then
        OverwritePrompt:= True
    Else Begin
        WriteLn(AFName, ' - ', CSkipped);
        Dec(ConvCount);
        OverwritePrompt:= False;
    End;
End;

Procedure ReportBMPError(AFName: String; ABMPErr: TBMPErr);
Begin
    If ABMPErr = TBE_Ok Then Exit;
    WriteLn(AFName + ' - ', CBMPErrMsgs[Byte(ABMPErr)]);
End;

Procedure WrongParams;
Begin
    WriteLn(CUsageText);
    ReadLn;
    Halt;
End;

Procedure Glitch_Mob_Drive_It_Like_You_Stole_It;
Var
    DTAP: TDTARecP;
    Par1, Par2, Par3, Par4, Tex: String;
    BMPErr: TBMPErr;
    LGFP: TLGFP;
    PalBool, TempBool, OverwriteBool, IsExistOne: Boolean;
    LGFType: TLGFType;
Begin
    Par1:= UpperCase(ParamStr(1)); Par2:= UpperCase(ParamStr(2));
    Par3:= UpperCase(ParamStr(3)); Par4:= UpperCase(ParamStr(4));
    ConvCount:= 0; IsExistOne:= False;
    If Par1 = 'EP' Then Begin
        If ParamCount <> 2 Then WrongParams;
        Tex:= ExtractNameFromPath(Par2) + '.LPF';

        TempBool:= False; OverwriteBool:= False;
        If IsFileExist(Tex) Then Begin
            TempBool:= True;
            OverwriteBool:= OverwritePrompt(Tex);
        End;
        If Not TempBool Or OverWriteBool Then Begin
            BMPErr:= ExtractPalFromBMP(Par2, Tex);
            If BMPErr <> TBE_Ok Then
                ReportBMPError(Par2, BMPErr)
            Else
                WriteLn(Par2, ' - ', CExtractPalText);
        End;
    End
    Else If Par1 = 'CM' Then Begin
        If ParamCount <> 4 Then WrongParams;
        FindFirstFile(DTAP, Par4);
        {cm <img, spr, rleimg, rlespr> <p, np> mask}
        While DTAP^.FErrCode = 0 Do Begin
            Inc(ConvCount); IsExistOne:= True;
            Tex:= ExtractNameFromPath(GetDTAName(DTAP)) + '.LGF';
            If Par2 = 'IMG' Then
                LGFType:= TLGFT_Img
            Else If Par2 = 'RLEIMG' Then
                LGFType:= TLGFT_RLEImg
            Else If Par2 = 'SPR' Then
                LGFType:= TLGFT_Spr
            Else If Par2 = 'RLESPR' Then
                LGFType:= TLGFT_RLESpr
            Else
                WrongParams;

            If Par3 = 'P' Then
                PalBool:= True
            Else If Par3 = 'NP' Then
                PalBool:= False
            Else
                WrongParams;

            TempBool:= False; OverwriteBool:= False;
            If IsFileExist(Tex) Then Begin
                TempBool:= True;
                OverwriteBool:= OverwritePrompt(Tex);
            End;
            If Not TempBool Or OverWriteBool Then Begin
                BMP8ToLGF(LGFP, GetDTAName(DTAP), Tex, LGFType, PalBool);
                If LGFP^.FErr <> TGE_Ok Then Begin
                    WriteLn(GetDTAName(DTAP), ' - ', CLGFErrMsgs[Byte(LGFP^.FErr)]);
                    If LGFP^.FErr = TGE_BMPToLGF_BMPFail Then
                        WriteLn(GetDTAName(DTAP), ' - ', CBMPErrMsgs[Byte(LGFP^.FBMPErr)]);
                End
                Else Begin
                    Write(GetDTAName(DTAP), ' - ', 'converted to ', Tex);
                    If LGFType In [TLGFT_RLEImg, TLGFT_RLESpr] Then
                        WriteLn('. ', LGFP^.FFName)
                    Else
                        WriteLn;
                End;
                LGFP:= DestroyLGF(LGFP);
            End;
            FindNextFile(DTAP);
        End;
        DTAP:= DestroyBuf(DTAP);
        If Not IsExistOne Then
            WriteLn(CWrongMask)
        Else
            WriteLn(ConvCount, ' ', CConvertingDone);
    End
    Else
        WrongParams;
End;

Begin
    WriteLn(CProgName);
    Glitch_Mob_Drive_It_Like_You_Stole_It;
End.