{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Program LFFM;
Uses
    LMem, LUtils, LGFiles;
Const
    CProgName = 'LFFM v2.0:';
    CUsageText = 'Usage: lffm.exe srcfilename lfffilename';
    CFontCreated = 'font created';
    COverwrite = 'file is already exist. Overwrite? [Y/N]?: ';
    CSkipped = 'file skipped';

Procedure Motley_Crue_Looks_That_Kill;
Var
    Par1, Par2, Tex: String;
    LFFP: TLFFP;
Begin
    If ParamCount <> 2 Then Begin
        WriteLn(CUsageText);
        Halt;
    End;
    Par1:= UpperCase(ParamStr(1)); Par2:= UpperCase(ParamStr(2));
    MakeLFF(LFFP, Par1, Par2);
    If LFFP^.FErr <> TFE_Ok Then
        ReportLFFError(LFFP, True)
    Else
        WriteLn(Par2, ' - ', CFontCreated);
    LFFP:= DestroyBuf(LFFP);
End;

Begin
    Motley_Crue_Looks_That_Kill;
End.