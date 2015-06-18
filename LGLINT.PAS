{$I+} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Unit LGLInt;
Interface
Uses
    LMem, LUtils, LXMS, LGL, LGFiles, LRF;
{!Возможно, отображение анимации изначально начинается не с первого кадра,
а со второго.
Разобраться со свойствами AutoCPos для Trans}
Type
    TIObjType = (IOT_Image, IOT_ImageTrans, IOT_Screen, IOT_Anim, IOT_Copy);
    TImageP = ^TImage;
    TImageTransP = ^TImageTrans;
    TImage = Object
        Public
            Constructor Create(AObjType: TObjType; AXSize, AYSize: Word);
            Constructor LoadFromLGF(ALGFName: String);
            Constructor LoadFromRes(AResP: TResP; ALGFName: TSFName);
            Constructor CreateEq(AImageP: TImageP; AIsCopyState: Boolean);
            Destructor Destroy;
            Procedure UnLoadToXMS;
            Procedure RestoreFromXMS;
            Procedure UnLoad;

            Function IsTransE: Boolean;
            Function Trans: TImageTransP;
            Function GetTransObj: TImageP;
            Function IsResizeDone(AWPer, AHPer: Word): Boolean;
            Function IsRotateDone(Alpha: Integer): Boolean;
            Function IsRotResDone(Alpha: Integer; AWPer, AHPer: Word): Boolean;

            Function GetDataP: LGL.TImgP;
            Function GetSize: Word; Virtual;
            Procedure Move(AXStep, AYStep: Integer);
            Procedure MoveTo(AXPos, AYPos: Integer);
            Function CloseIn(DstImageP: TImageP; AXStep, AYStep: Word): Boolean;
            Function XP: Integer;
            Function YP: Integer;
            Function Width: Integer;
            Function Height: Integer;
            Procedure Fill(AColor: Byte);
            Procedure Draw;
            Procedure DrawOn(AImageP: TImageP);
            Procedure PSet(AXPos, AYPos: Word; AC: Byte);
            Procedure Line(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
            Procedure Box(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
            Procedure FillBox(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
            Procedure Crop(AXLMod, AXRMod: Integer; AYMod: Word; AXStart,
              AYStart, AXLen, AYLen: Integer);
            Procedure CropOn(ADstImageP: TImageP; AXLMod, AXRMod: Integer;
              AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);
            Procedure GetFrom(ASrcImgP: TImageP; ASrcXPos, ASrcYPos,
              ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer);
            Procedure SaveBMP(ABMPName: String);
            Procedure Show;
            Procedure Hide;
            Procedure SetFlip(AIsHorFlip, AIsVertFlip: Boolean);
            Function IsHorFlip: Boolean;
            Function IsVertFlip: Boolean;
            Procedure SetSpriteIndex(ANewIndex: Byte);
            Procedure SetSpriteIndexXY(AX, AY: Word);
            Function GetPixel(AX, AY: Word): Byte;
            Procedure SetImgType(AObjType: TObjType);
            Function GetObjType: TIObjType;
        Private
            FTrans: TImageTransP;
            FImgP: LGL.TImgP;
            FXMSId, FImgSize: Word;
            FXPos, FYPos, FManCount: Integer;
            FIsVisible: Boolean;
            FIObjType: TIObjType;
    End;

    TImageTrans = Object(TImage)
        Public
            Procedure UnLoad; Virtual;
            Procedure UnLoadToXMS; Virtual;
            Procedure RestoreFromXMS; Virtual;
            Function GetXC: Integer;
            Function GetYC: Integer;
            Procedure SetAutoPPos(AIsAuto: Boolean);
            Procedure SetAutoCPos(AIsAuto: Boolean);
            Constructor Create(AObjType: TObjType; AXSize, AYSize: Word);
            Constructor LoadFromLGF(ALGFName: String);
            Constructor LoadFromRes(AResP: TResP; ALGFName: TSFName);
            Function IsResizeDone(AWPer, AHPer: Word): Boolean; Virtual;
            Function IsRotateDone(Alpha: Integer): Boolean; Virtual;
            Function IsRotResDone(Alpha: Integer; AWPer, AHPer: Word): Boolean; Virtual;
        Private
            FIsAutoPPos, FIsAutoCPos: Boolean;
            FParent: TImageP;
            FXC, FYC: Integer;
    End;

    TAnimFrRec = Record
        FImgP: LGL.TImgP;
        FWaitVal, FImgSize: Word;
    End;
    TAnimArr = Array [1..255] Of TAnimFrRec;
    TAnimArrP = ^TAnimArr;
    TAnimP = ^TAnim;
    TAnim = Object(TImage)
        Public
            Constructor LoadFromRes(AResP: TResP; AName, AExt: TSFName; ACount: Word);
            Constructor LoadFromLGFS(AName, AExt: TSFName; ACount: Word);
            Destructor Destroy; Virtual;
            Procedure UnLoadToXMS; Virtual;
            Procedure RestoreFromXMS; Virtual;

            Function GetCurIndex: Integer;
            Function GetSize: Word; Virtual;
            Procedure SetFlip(AIsHorFlip, AIsVertFlip: Boolean); Virtual;
            Procedure SetCurFrame(AFrameNum: Word);
            Procedure PrevFrame;
            Procedure NextFrame;
            Procedure SetLoopIndex(ANewIndex: Word);
            Procedure SetFrameDelay(AFrameNum, ADelay: Word);
            Procedure SetAllFrameDelay(ADelay: Word);
            Procedure SetStep(AStep: Integer);
            Procedure Draw; Virtual;
            Procedure DrawOn(AImageP: TImageP); Virtual;
        Private
            FFrs: TAnimArrP;
            FCount, FCurFWait, FLoopIndex: Word;
            FIndex, FStep: Integer;
            FIsLoop: Boolean;
            Procedure CorrectFrameIndex;
    End;

    TPaletteP = ^TPalette;
    TPalette = Object
        Public
            Constructor Create;
            Constructor LoadFromLPF(ALPFName: String);
            Constructor LoadFromLGF(ALGFName: String);
            Constructor LoadFromRes(AResP: TResP; ALRFName: TSFName);
            Constructor LoadFromLGFInRes(AResP: TResP; ALGFName: TSFName);

            Function ChangeBr(AStep: ShortInt): Boolean;
            Function FadeTo(ASrcPalP: TPaletteP; AStep: ShortInt): Boolean;
            Function Gray(AStep: ShortInt): Boolean;
            Procedure SetRange(ADstFrom: Byte; ASrcPalP: TPaletteP; ASrcFrom, ACount: Byte);
            Procedure SetColor(AI, AR, AG, AB: Byte);
            Procedure ChangeBrC(AI: Byte; AR, AG, AB: ShortInt);
            Procedure Fill(AFrom: Byte; ACount: Word; AR, AG, AB: Byte);
            Procedure ReadFromVGA;
            Procedure Apply;
            Procedure UnLoad;
            Function GetDataP: TPalP;
            Destructor Destroy;
        Private
            FPalDataP: LGL.TPalP;
    End;

    TScreen = Object(TImage)
        Public
            FPalP: TPaletteP;

            Constructor Create(AIsAutoWaitR: Boolean);
            Destructor Destroy; Virtual;
            Procedure InitGM;
            Procedure CloseGM;
            Procedure Refresh;
            Function GetFPS: Word;
        Private
            FIsAutoWaitR, FIsInGM: Boolean;
    End;
    TScreenP = ^TScreen;

    TFont = Object
        Public
            Procedure Locate(AXP, AYP: Integer);
            Procedure SetHorInterval(AHI: Byte);
            Procedure SetVertInterval(AVI: Byte);
            Procedure SetColor(AColor: Byte);
            Function GetColor: Byte;
            Procedure PrintXY(AStr: String; AXPos, AYPos: Integer);
            Procedure PrintXYOn(ADstImgP: TImageP; AStr: String;
              AXPos, AYPos: Integer);
            Procedure Print(AStr: String);
            Procedure PrintLn(AStr: String);

            Constructor LoadFromLFF(ALFFName: String);
            Constructor LoadFromRes(AResP: TResP; ALFFName: TSFName);
            Destructor Destroy;
        Private
            FFontP: LGL.TFntP;
            FColor, FVI: Byte;
            FXP, FYP: Integer;
    End;
    TFontP = ^TFont;

    TSceneImArr = Array [1..CMaxBufSize Div SizeOf(TImageP)] Of TImageP;
    TSceneImArrP = ^TSceneImArr;
    TScene = Object
        Public
            Constructor Create(ASize: Integer);
            Procedure Add(AImageP: TImageP);
            Procedure Move(AXPos, AYPos: Integer);
            Procedure Draw;
            Procedure Del(AImageP: TImageP);
            Procedure ClearAll;
            Destructor Destroy;
        Private
            FSize, FI: Integer;
            FXSize, FYSize: Integer;
            FIAP: TSceneImArrP;
    End;
    TSceneP = ^TScene;

    Procedure SetCurrentScreen(AScrP: TScreenP);
    Procedure Set32BitDrawMode(AIs32Bit: Boolean);
    Procedure Set32BitRefreshMode(AIs32Bit: Boolean);

Implementation
Const
    CRotateCost = 1; CResizeCost = 2; CRotateSInc = 130;
Var
    GCurScrP: TScreenP;

Procedure SetCurrentScreen(AScrP: TScreenP);
Begin
    GCurScrP:= AScrP;
End;

Procedure Set32BitDrawMode(AIs32Bit: Boolean);
Begin
    LGL.Set32BitDraw(AIs32Bit);
End;

Procedure Set32BitRefreshMode(AIs32Bit: Boolean);
Begin
    LGL.Set32BitRefresh(AIs32Bit);
End;

Constructor TFont.LoadFromLFF(ALFFName: String);
Begin
    FFontP:= LGL.LoadFromLFF(ALFFName); FXP:= 0; FYP:= 0; FVI:= 1;
    SetHorInterval(1); SetVertInterval(1); SetColor(255);
End;

Constructor TFont.LoadFromRes(AResP: TResP; ALFFName: TSFName);
Begin
    FFontP:= LGL.LoadFontFromRes(AResP, ALFFName); FXP:= 0; FYP:= 0; FVI:= 1;
    SetHorInterval(1); SetVertInterval(1); SetColor(255);
End;

Destructor TFont.Destroy;
Begin
    FFontP:= LGL.DestroyFont(FFontP);
End;

Procedure TFont.Locate(AXP, AYP: Integer);
Begin
    FXP:= AXP; FYP:= AYP;
End;

Procedure TFont.SetHorInterval(AHI: Byte);
Begin
    FFontP^.FCharInterval:= AHI;
End;

Procedure TFont.SetVertInterval(AVI: Byte);
Begin
    FVI:= AVI;
End;

Procedure TFont.Print(AStr: String);
Var
    I, WinR, WinD, ChW: Integer;
Begin
    For I:= 1 To Length(AStr) Do Begin
        ChW:= TImgP(FFontP^.FChars[Byte(AStr[I])])^.FWidth;
        TImgP(FFontP^.FChars[Byte(AStr[I])])^.FReserved:= FColor;
        LGL.DrawOn(GCurScrP^.GetDataP,
        TImgP(FFontP^.FChars[Byte(AStr[I])]), FXP, FYP);
        Inc(FXP, ChW + FFontP^.FCharInterval);
    End;
End;

Procedure TFont.PrintLn(AStr: String);
Var
    XLen, YLen: Integer;
Begin
    CalcFontStrSize(FFontP, AStr, XLen, YLen);
    Print(AStr); FXP:= 0; Inc(FYP, YLen + FVI);
End;

Procedure TFont.SetColor(AColor: Byte);
Begin
    FColor:= AColor;
End;

Function TFont.GetColor: Byte;
Begin
    GetColor:= FColor;
End;

Procedure TFont.PrintXY(AStr: String; AXPos, AYPos: Integer);
Begin
    LGL.PrintXYOn(GCurScrP^.GetDataP, FFontP, AXPos, AYPos, FColor, AStr);
End;

Procedure TFont.PrintXYOn(ADstImgP: TImageP; AStr: String; AXPos, AYPos: Integer);
Begin
    LGL.PrintXYOn(ADstImgP^.GetDataP, FFontP, AXPos, AYPos, FColor, AStr);
End;

Constructor TAnim.LoadFromRes(AResP: TResP; AName, AExt: TSFName; ACount: Word);
Var
    I: Word;
Begin
    FXPos:= 0; FYPos:= 0;
    FIsVisible:= True;
    FCount:= ACount; FCurFWait:= 0; FXMSId:= 0;
    FLoopIndex:= FCount; FIsLoop:= True;
    FIndex:= 1; FStep:= 1; FManCount:= 0;
    FFrs:= SafeCreateBuf(SizeOf(FFrs^[1]) * ACount);
    For I:= 1 To ACount Do Begin
        FFrs^[I].FImgP:= LGL.LoadFromRes(AResP, AName + IntToStr(I) + AExt);
        FFrs^[I].FImgSize:= SizeOfBuf(FFrs^[I].FImgP);
    End;
    FImgP:= FFrs^[1].FImgP;
    SetAllFrameDelay(0); SetFlip(False, False);
    FIObjType:= IOT_Anim;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Constructor TAnim.LoadFromLGFS(AName, AExt: TSFName; ACount: Word);
Var
    I: Word;
Begin
    FXPos:= 0; FYPos:= 0;
    FIsVisible:= True;
    FCount:= ACount; FCurFWait:= 0; FXMSId:= 0;
    FLoopIndex:= FCount; FIsLoop:= True;
    FIndex:= 1; FStep:= 1; FManCount:= 0;
    FFrs:= SafeCreateBuf(SizeOf(FFrs^[1]) * ACount);
    For I:= 1 To ACount Do Begin
        FFrs^[I].FImgP:= LGL.LoadFromLGF(AName + IntToStr(I) + AExt);
        FFrs^[I].FImgSize:= SizeOfBuf(FFrs^[I].FImgP);
    End;
    FImgP:= FFrs^[1].FImgP;
    SetAllFrameDelay(0); SetFlip(False, False);
    FIObjType:= IOT_Anim;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Procedure TAnim.UnLoadToXMS;
Var
    I: Word;
    AllAniSize: LongInt;
Begin
    AllAniSize:= 0;
    For I:= 1 To FCount Do Inc(AllAniSize, FFrs^[I].FImgSize);
    FXMSId:= LXMS.GetMem(BytesToKB(AllAniSize));
    AllAniSize:= 0;
    For I:= 1 To FCount Do Begin
        MemToXMS(FXMSId, FFrs^[I].FImgP, SizeOfBuf(FFrs^[I].FImgP), AllAniSize);
        Inc(AllAniSize, SizeOfBuf(FFrs^[I].FImgP));
        FFrs^[I].FImgP:= SafeDestroyBuf(FFrs^[I].FImgP);
    End;
End;

Procedure TAnim.RestoreFromXMS;
Var
    LIndex: LongInt;
    I: Word;
Begin
    LIndex:= 0;
    For I:= 1 To FCount Do Begin
        FFrs^[I].FImgP:= SafeCreateBuf(FFrs^[I].FImgSize);
        XMSToMem(FXMSId, FFrs^[I].FImgP, FFrs^[I].FImgSize, LIndex);
        Inc(LIndex, FFrs^[I].FImgSize);
    End;
    FXMSId:= LXMS.FreeMem(FXMSId);
End;

Procedure TAnim.Draw;
Begin
    DrawOn(GCurScrP);
End;

Procedure TAnim.DrawOn(AImageP: TImageP);
Begin
    Inherited DrawOn(AImageP);
    If FCurFWait = 0 Then Begin
        Inc(FIndex, FStep);
        CorrectFrameIndex;
        FImgP:= FFrs^[FIndex].FImgP;  {!!! before inherited}
    End
    Else
        Dec(FCurFWait);
End;

Function TAnim.GetCurIndex: Integer;
Begin
    GetCurIndex:= FIndex;
End;

Procedure TAnim.SetFlip(AIsHorFlip, AIsVertFlip: Boolean);
Var
    I: Integer;
Begin
    For I:= 1 To FCount Do LGL.SetImgFlip(FFrs^[I].FImgP, AIsHorFlip, AIsVertFlip);
End;

Procedure TAnim.SetLoopIndex(ANewIndex: Word);
Begin
    If (ANewIndex < 0) Or (ANewIndex > FCount) Then Exit;
    If ANewIndex = 0 Then
        FLoopIndex:= FCount
    Else
        FLoopIndex:= ANewIndex;
End;

Procedure TAnim.SetCurFrame(AFrameNum: Word);
Begin
    If (AFrameNum < 1) Or (AFrameNum > FLoopIndex) Then Exit;
    FIndex:= AFrameNum;
End;

Procedure TAnim.PrevFrame;
Begin
    Dec(FIndex);
    CorrectFrameIndex;
End;

Procedure TAnim.NextFrame;
Begin
    Inc(FIndex);
    CorrectFrameIndex;
End;

Procedure TAnim.SetFrameDelay(AFrameNum, ADelay: Word);
Begin
    FFrs^[AFrameNum].FWaitVal:= ADelay;
End;

Procedure TAnim.SetAllFrameDelay(ADelay: Word);
Var
    I: Word;
Begin
    For I:= 1 To FCount Do FFrs^[I].FWaitVal:= ADelay;
End;

Procedure TAnim.SetStep(AStep: Integer);
Begin
    If AStep < 0 Then
        FStep:= -1
    Else If AStep > 0 Then
        FStep:= 1
    Else
        FStep:= 0;
End;

Procedure TAnim.CorrectFrameIndex;
Begin
    If (FIndex In [1..FLoopIndex]) Then
    Else If FIsLoop Then Begin
        If FIndex < 1 Then
            FIndex:= FLoopIndex
        Else If FIndex > FLoopIndex Then
            FIndex:= 1;
    End
    Else If FIndex > FLoopIndex Then
        FIndex:= FLoopIndex
    Else If FIndex < 1 Then
        FIndex:= 1;
    FCurFWait:= FFrs^[FIndex].FWaitVal;
End;

Function TAnim.GetSize: Word;
Var
    I, Size: Word;
Begin
    Size:= 0;
    For I:= 1 To FCount Do Inc(Size, SizeOfBuf(FFrs^[I].FImgP));
    Inc(Size, SizeOfBuf(FFrs));
    GetSize:= Size + SizeOf(Self);
End;

Destructor TAnim.Destroy;
Var
    I: Word;
Begin
    If FXMSId <> 0 Then RestoreFromXMS;
    FImgP:= Nil;
    For I:= 1 To FCount Do FFrs^[I].FImgP:= SafeDestroyBuf(FFrs^[I].FImgP);
    FFrs:= SafeDestroyBuf(FFrs);
    Inherited Destroy;
End;

Constructor TPalette.Create;
Begin
    FPalDataP:= SafeCreateBuf(SizeOf(FPalDataP^));
End;

Constructor TPalette.LoadFromLPF(ALPFName: String);
Begin
    FPalDataP:= LGL.LoadPalFromLPF(ALPFName);
End;

Constructor TPalette.LoadFromLGF(ALGFName: String);
Begin
    FPalDataP:= LGL.LoadPalFromLGF(ALGFName);
End;

Constructor TPalette.LoadFromRes(AResP: TResP; ALRFName: TSFName);
Begin
    FPalDataP:= LGL.LoadPalFromRes(AResP, ALRFName);
End;

Constructor TPalette.LoadFromLGFInRes(AResP: TResP; ALGFName: TSFName);
Begin
    FPalDataP:= LGL.LoadPalFromLGFInRes(AResP, ALGFName);
End;

Procedure TPalette.SetColor(AI, AR, AG, AB: Byte);
Begin
    LGL.SetColorInPal(FPalDataP, AI, AR, AG, AB);
End;

Procedure TPalette.SetRange(ADstFrom: Byte; ASrcPalP: TPaletteP;
ASrcFrom, ACount: Byte);
Begin
    LGL.SetRangeInPal(FPalDataP, ADstFrom, ASrcPalP^.GetDataP, ASrcFrom, ACount);
End;

Procedure TPalette.Fill(AFrom: Byte; ACount: Word; AR, AG, AB: Byte);
Var
    I: Integer;
Begin
    For I:= AFrom To AFrom + ACount Do Begin
        LGL.SetColorInPal(FPalDataP, I, AR, AG, AB);
    End;
End;

Function TPalette.ChangeBr(AStep: ShortInt): Boolean;
Begin
    ChangeBr:= LGL.ChangePalBr(FPalDataP, AStep);
End;

Function TPalette.Gray(AStep: ShortInt): Boolean;
Begin
    Gray:= LGL.GrayPal(FPalDataP, AStep);
End;

Procedure TPalette.ChangeBrC(AI: Byte; AR, AG, AB: ShortInt);
Begin
    Inc(FPalDataP^[AI][0], AB); Inc(FPalDataP^[AI][1], AG);
    Inc(FPalDataP^[AI][2], AR);
End;

Function TPalette.FadeTo(ASrcPalP: TPaletteP; AStep: ShortInt): Boolean;
Begin
    FadeTo:= LGL.FadePal(FPalDataP, ASrcPalP^.GetDataP, AStep);
End;

Procedure TPalette.ReadFromVGA;
Begin
    FPalDataP:= LGL.ReadVGAPal;
End;

Procedure TPalette.Apply;
Begin
    LGL.ApplyPal(FPalDataP);
End;

Function TPalette.GetDataP: TPalP;
Begin
    GetDataP:= FPalDataP;
End;

Procedure TPalette.UnLoad;
Begin
    FPalDataP:= SafeDestroyBuf(FPalDataP);
End;

Destructor TPalette.Destroy;
Begin
    FPalDataP:= SafeDestroyBuf(FPalDataP);
End;

Constructor TScreen.Create(AIsAutoWaitR: Boolean);
Begin
    FIsAutoWaitR:= AIsAutoWaitR;
    FImgP:= LGL.InitScr;
    FPalP:= Nil; FIsInGM:= False;
    If GCurScrP = Nil Then GCurScrP:= @Self;
    FXPos:= 0; FYPos:= 0; FManCount:= 0; FIsVisible:= True;
    FIObjType:= IOT_Screen; FXMSId:= 0;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Procedure TScreen.Refresh;
Begin
    If FIsAutoWaitR Then LGL.WaitR;
    LGL.RefreshScr(FImgP);
End;

Function TScreen.GetFPS: Word;
Begin
    GetFPS:= LGL.GetFPS;
End;

Procedure TScreen.InitGM;
Begin
    LGL.InitGM;
    FIsInGM:= True;
    If FPalP <> Nil Then FPalP^.Apply;
End;

Procedure TScreen.CloseGM;
Begin
    LGL.CloseGM;
    FIsInGM:= False;
End;

Destructor TScreen.Destroy;
Begin
    If FXMSId <> 0 Then RestoreFromXMS;
    If GCurScrP = @Self Then If FIsInGM Then LGL.CloseGM;
    If FPalP <> Nil Then Dispose(FPalP, Destroy);
    Inherited Destroy;
End;

Constructor TImage.Create(AObjType: TObjType; AXSize, AYSize: Word);
Begin
    FImgP:= LGL.Create(AObjType, AXSize, AYSize);
    FXPos:= 0; FYPos:= 0; FManCount:= 0; FImgSize:= SizeOfBuf(FImgP);
    FIsVisible:= True; SetFlip(False, False);
    FIObjType:= IOT_Image; FXMSId:= 0;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Constructor TImage.CreateEq(AImageP: TImageP; AIsCopyState: Boolean);
Begin
    FImgP:= AImageP^.FImgP; FIObjType:= IOT_Copy; FXMSId:= 0;
    FImgSize:= SizeOfBuf(FImgP);
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
    If AIsCopyState Then Begin
        FXPos:= AImageP^.FXPos; FYPos:= AImageP^.FYPos;
        FManCount:= AImageP^.FManCount; FIsVisible:= AImageP^.FIsVisible;
    End
    Else Begin
        FXPos:= 0; FYPos:= 0; FManCount:= 0; FIsVisible:= True;
    End;
End;

Constructor TImage.LoadFromLGF(ALGFName: String);
Begin
    FImgP:= LGL.LoadFromLGF(ALGFName);
    FXPos:= 0; FYPos:= 0; FManCount:= 0; FImgSize:= SizeOfBuf(FImgP);
    FIsVisible:= True; SetFlip(False, False);
    FIObjType:= IOT_Image; FXMSId:= 0;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Constructor TImage.LoadFromRes(AResP: TResP; ALGFName: TSFName);
Begin
    FImgP:= LGL.LoadFromRes(AResP, ALGFName);
    FXPos:= 0; FYPos:= 0; FManCount:= 0; FImgSize:= SizeOfBuf(FImgP);
    FIsVisible:= True; SetFlip(False, False);
    FIObjType:= IOT_Image; FXMSId:= 0;
    New(FTrans, Create(OT_Spr, 0, 0)); FTrans^.FParent:= @Self;
End;

Destructor TImage.Destroy;
Begin
    If FXMSId <> 0 Then RestoreFromXMS;
    If FIObjType <> IOT_Copy Then FImgP:= SafeDestroyBuf(FImgP); FImgSize:= 0;
    If FTrans <> Nil Then Dispose(FTrans, Destroy);
End;

Procedure TImage.UnLoad;
Begin
    If FIObjType <> IOT_Copy Then FImgP:= SafeDestroyBuf(FImgP); FImgSize:= 0;
    If FTrans <> Nil Then Dispose(FTrans, Destroy);
End;

Procedure TImage.UnLoadToXMS;
Begin
    If FIObjType = IOT_Copy Then Exit;
    FXMSId:= LXMS.GetMem(BytesToKB(SizeOfBuf(FImgP)));
    MemToXMS(FXMSId, FImgP, SizeOfBuf(FImgP), 0);
    FImgP:= DestroyBuf(FImgP);
End;

Procedure TImage.RestoreFromXMS;
Begin
    If FIObjType = IOT_Copy Then Exit;
    FImgP:= SafeCreateBuf(FImgSize);
    XMSToMem(FXMSId, FImgP, FImgSize, 0);
    FXMSId:= LXMS.FreeMem(FXMSId);
End;

Function TImage.GetDataP: LGL.TImgP;
Begin
    GetDataP:= FImgP;
End;

Function TImage.GetTransObj: TImageP;
Var
    ImgP: TImageP;
Begin
    If Not IsTransE Then Begin
        GetTransObj:= Nil;
        Exit;
    End;
    With FTrans^ Do Begin
        New(ImgP, Create(FImgP^.FObjType, Width, Height));
        MoveMem(ImgP^.GetDataP, FImgP, SizeOfBuf(FImgP));
    End;
    GetTransObj:= ImgP;
End;

Function TImage.Trans: TImageTransP;
Begin
    Trans:= FTrans;
    If FTrans^.FIsAutoPPos Then Begin
        If FTrans^.FIsAutoCPos Then
            FTrans^.MoveTo(XP + FTrans^.FXC, YP + FTrans^.FYC)
        Else
            FTrans^.MoveTo(XP, YP);
    End;
End;

Function TImage.IsTransE: Boolean;
Begin
    IsTransE:= FTrans^.FImgP <> Nil;
End;

Function TImage.IsResizeDone(AWPer, AHPer: Word): Boolean;
Var
    NewW, NewH: Word;
    NewType: TObjType;
    DstP, SrcP: TImgP;
    IsSrcC: Boolean;
Begin
    IsSrcC:= False;
    If (FManCount = CResizeCost) Or (FManCount = CResizeCost + CRotateCost) Then Begin
        FManCount:= 0; FTrans^.FXC:= 0; FTrans^.FYC:= 0;
        FTrans^.FImgP:= SafeDestroyBuf(FTrans^.FImgP); SrcP:= FImgP;
    End
    Else If FManCount = CRotateCost Then
        SrcP:= FTrans^.FImgP
    Else If FManCount = 0 Then
        SrcP:= FImgP;

    If (AWPer < 2) Or (AHPer < 2) Or (AWPer > 800) Or (AHPer > 800) Then Begin
        If FManCount <> 0 Then Dec(FManCount, CRotateCost);
        FTrans^.FXC:= 0; FTrans^.FYC:= 0; IsResizeDone:= False; Exit;
    End;
    NewW:= (LongInt(SrcP^.FWidth) * AWPer) Div 100;
    NewH:= (LongInt(SrcP^.FHeight) * AHPer) Div 100;
    If (NewW < 2) Or (NewH < 2) Or (NewW > 320) Or (NewH > 200) Then Begin
        If FManCount <> 0 Then Dec(FManCount, CRotateCost);
        FTrans^.FXC:= 0; FTrans^.FYC:= 0; IsResizeDone:= False; Exit;
    End;
    If Byte(SrcP^.FObjType) <= Byte(OT_Img) Then
        NewType:= OT_Img
    Else
        NewType:= OT_Spr;
    If FTrans^.FImgP = Nil Then Begin
        FTrans^.FImgP:= LGL.Create(NewType, NewW, NewH);
        DstP:= FTrans^.GetDataP; SrcP:= FImgP;
    End
    Else Begin
        SrcP:= LGL.Create(NewType, FTrans^.Width, FTrans^.Height);
        MoveMem(SrcP, FTrans^.GetDataP, SizeOfBuf(FTrans^.GetDataP));
        FTrans^.Unload;
        FTrans^.FImgP:= LGL.Create(NewType, NewW, NewH);
        DstP:= FTrans^.GetDataP;
        IsSrcC:= True;
    End;
    FTrans^.FXC:= FTrans^.FXC + (Integer(SrcP^.FWidth) - FTrans^.Width) Div 2;
    FTrans^.FYC:= FTrans^.FYC + (Integer(SrcP^.FHeight) - FTrans^.Height) Div 2;
    DstP^.FReserved:= SrcP^.FReserved;
    LGL.ResizeImg(DstP, SrcP);
    If IsSrcC Then SrcP:= SafeDestroyBuf(SrcP);
    Inc(FManCount, CResizeCost);
    IsResizeDone:= True;
End;

Function TImage.IsRotateDone(Alpha: Integer): Boolean;
Var
    NewW, NewH: Integer;
    SrcP, DstP: TImgP;
    IsSrcC: Boolean;
    NewType: TObjType;
Begin
    IsSrcC:= False;
    If (FManCount = CRotateCost) Or (FManCount = CRotateCost + CResizeCost) Then Begin
        FManCount:= 0; FTrans^.FXC:= 0; FTrans^.FYC:= 0;
        FTrans^.FImgP:= SafeDestroyBuf(FTrans^.FImgP);
        SrcP:= FImgP;
    End
    Else If FManCount = CResizeCost Then
        SrcP:= FTrans^.FImgP
    Else If FManCount = 0 Then
        SrcP:= FImgP;

    NewW:= SrcP^.FWidth * CRotateSInc Div 100;
    NewH:= SrcP^.FHeight * CRotateSInc Div 100;
    If NewW > NewH Then NewH:= NewW Else NewW:= NewH;
    If (NewW > 200) Or (LongInt(NewW) * NewH + SizeOf(TImg) > MaxAvail) Then Begin
        If FManCount <> 0 Then Dec(FManCount, CResizeCost);
        FTrans^.FXC:= 0; FTrans^.FYC:= 0; IsRotateDone:= False; Exit;
    End;
    If Byte(SrcP^.FObjType) <= Byte(OT_Img) Then
        NewType:= OT_Img
    Else
        NewType:= OT_Spr;
    If FTrans^.FImgP = Nil Then Begin
        FTrans^.FImgP:= LGL.Create(NewType, NewW, NewH);
        DstP:= FTrans^.GetDataP; SrcP:= FImgP;
    End
    Else Begin
        SrcP:= LGL.Create(NewType, FTrans^.Width, FTrans^.Height);
        MoveMem(SrcP, FTrans^.GetDataP, SizeOfBuf(FTrans^.GetDataP));
        FTrans^.Unload;
        FTrans^.FImgP:= LGL.Create(NewType, NewW, NewH);
        DstP:= FTrans^.GetDataP;
        IsSrcC:= True;
    End;
    FTrans^.FXC:= FTrans^.FXC + (Integer(SrcP^.FWidth) - FTrans^.Width) Div 2;
    FTrans^.FYC:= FTrans^.FYC + (Integer(SrcP^.FHeight) - FTrans^.Height) Div 2;
    LGL.FillImg(DstP, SrcP^.FReserved);
    DstP^.FReserved:= SrcP^.FReserved;
    LGL.RotateImg(DstP, SrcP, Alpha);
    If IsSrcC Then SrcP:= SafeDestroyBuf(SrcP);
    Inc(FManCount, CRotateCost);
    IsRotateDone:= True;
End;

Function TImage.IsRotResDone(Alpha: Integer; AWPer, AHPer: Word): Boolean;
Var
    NewW, NewH: Word;
Begin
    IsRotResDone:= False;
    NewW:= (LongInt(Width) * AWPer) Div 100;
    NewH:= (LongInt(Height) * AHPer) Div 100;
    If (NewW * NewH) > (Word(Width) * Height) Then Begin
        If Not IsRotateDone(Alpha) Then Exit;
        If Not IsResizeDone(AWPer, AHPer) Then Exit;
    End
    Else Begin
        If Not IsResizeDone(AWPer, AHPer) Then Exit;
        If Not IsRotateDone(Alpha) Then Exit;
    End;
    IsRotResDone:= FTrans^.FImgP <> Nil;
End;

Procedure TImage.Move(AXStep, AYStep: Integer);
Begin
    FXPos:= FXPos + AXStep; FYPos:= FYPos + AYStep;
End;

Procedure TImage.MoveTo(AXPos, AYPos: Integer);
Begin
    FXPos:= AXPos; FYPos:= AYPos;
End;

Function TImage.CloseIn(DstImageP: TImageP; AXStep, AYStep: Word): Boolean;
Var
    DstX, DstY: Integer;
Begin
    CloseIn:= False; DstX:= DstImageP^.XP; DstY:= DstImageP^.YP;
    If FXPos < DstX Then Begin
        Inc(FXPos, AXStep); CloseIn:= True;
        If FXPos > DstX Then FXPos:= DstX;
    End;
    If FXPos > DstX Then Begin
        Dec(FXPos, AXStep); CloseIn:= True;
        If FXPos < DstX Then FXPos:= DstX;
    End;
    If FYPos < DstY Then Begin
        Inc(FYPos, AYStep); CloseIn:= True;
        If FYPos > DstY Then FYPos:= DstY;
    End;
    If FYPos > DstY Then Begin
        Dec(FYPos, AYStep); CloseIn:= True;
        If FYPos < DstY Then FYPos:= DstY;
    End;
End;

Procedure TImage.Fill(AColor: Byte);
Begin
    LGL.FillImg(FImgP, AColor);
End;

Procedure TImage.Draw;
Begin
    DrawOn(GCurScrP);
End;

Procedure TImage.DrawOn(AImageP: TImageP);
Begin
    If Not FIsVisible Then Exit;
    LGL.DrawOn(AImageP^.GetDataP, FImgP, FXPos, FYPos);
End;

Procedure TImage.PSet(AXPos, AYPos: Word; AC: Byte);
Begin
    LGL.PSet(FImgP, AXPos, AYPos, AC);
End;

Procedure TImage.Line(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    LGL.Line(FImgP, AXPos, AYPos, AEXPos, AEYPos, AC);
End;

Procedure TImage.Box(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    LGL.Box(FImgP, AXPos, AYPos, AEXPos, AEYPos, AC);
End;

Procedure TImage.FillBox(AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    LGL.FillBox(FImgP, AXPos, AYPos, AEXPos, AEYPos, AC);
End;

Procedure TImage.Crop(AXLMod, AXRMod: Integer; AYMod: Word; AXStart,
AYStart, AXLen, AYLen: Integer);
Begin
    If Not FIsVisible Then Exit;
    LGL.DrawCropOn(GCurScrP^.GetDataP, FImgP, AXLMod, AYMod, AYMod,
      AXStart, AYStart, AXLen, AYLen);
End;

Procedure TImage.CropOn(ADstImageP: TImageP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);
Begin
    If Not FIsVisible Then Exit;
    LGL.DrawCropOn(ADstImageP^.GetDataP, FImgP, AXLMod, AYMod, AYMod,
      AXStart, AYStart, AXLen, AYLen);
End;

Procedure TImage.GetFrom(ASrcImgP: TImageP; ASrcXPos, ASrcYPos,
ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer);
Begin
    LGL.CopyImg(FImgP, ASrcImgP^.GetDataP, ASrcXPos, ASrcYPos, ASrcXLen,
    ASrcYLen, ADstXPos, ADstYPos);
End;

Procedure TImage.SaveBMP(ABMPName: String);
Begin
    LGL.SaveAsBMP(FImgP, ABMPName);
End;

Procedure TImage.SetFlip(AIsHorFlip, AIsVertFlip: Boolean);
Begin
    LGL.SetImgFlip(FImgP, AIsHorFlip, AIsVertFlip);
End;

Function TImage.IsHorFlip: Boolean;
Begin
    IsHorFlip:= FImgP^.FIsHorFlip;
End;

Function TImage.IsVertFlip: Boolean;
Begin
    IsVertFlip:= FImgP^.FIsVertFlip;
End;

Procedure TImage.Show;
Begin
    FIsVisible:= True;
End;

Procedure TImage.Hide;
Begin
    FIsVisible:= False;
End;

Function TImage.Width: Integer;
Begin
    Width:= FImgP^.FWidth;
End;

Function TImage.Height: Integer;
Begin
    Height:= FImgP^.FHeight;
End;

Function TImage.XP: Integer;
Begin
    XP:= FXPos;
End;

Function TImage.YP: Integer;
Begin
    YP:= FYPos;
End;

Function TImage.GetSize: Word;
Begin
    GetSize:= SizeOfBuf(FImgP) + SizeOf(Self);
End;

Procedure TImage.SetImgType(AObjType: TObjType);
Begin
    If (AObjType = OT_FontSpr) Or (AObjType = OT_RLESpr) Then Exit;
    FImgP^.FObjType:= AObjType;
    If AObjType = OT_Spr Then SetSpriteIndexXY(0, 0);
End;

Function TImage.GetObjType: TIObjType;
Begin
    GetObjType:= FIObjType;
End;

Function TImage.GetPixel(AX, AY: Word): Byte;
Begin
    GetPixel:= TByteBufP(FImgP)^[CImgHeadSize + FImgP^.FWidth * AY + AX + 1];
End;

Procedure TImage.SetSpriteIndex(ANewIndex: Byte);
Begin
    FImgP^.FReserved:= ANewIndex;
End;

Procedure TImage.SetSpriteIndexXY(AX, AY: Word);
Begin
    FImgP^.FReserved:= TByteBufP(FImgP)^
      [CImgHeadSize + FImgP^.FWidth * AY + AX + 1];
End;

Constructor TImageTrans.Create(AObjType: TObjType; AXSize, AYSize: Word);
Begin
    If (AXSize = 0) And (AYSize = 0) Then Begin
        FImgP:= Nil; FImgSize:= 0;
    End
    Else Begin
        FImgP:= LGL.Create(AObjType, AXSize, AYSize);
        FImgSize:= SizeOfBuf(FImgP); SetFlip(False, False);
    End;
    FXPos:= 0; FYPos:= 0; FManCount:= 0; FXMSId:= 0;
    FIsVisible:= True; FTrans:= Nil; FIObjType:= IOT_ImageTrans;
    FParent:= Nil; FIsAutoPPos:= True; FIsAutoCPos:= True;
End;

Constructor TImageTrans.LoadFromLGF(ALGFName: String);
Begin
    Fail;
End;

Constructor TImageTrans.LoadFromRes(AResP: TResP; ALGFName: TSFName);
Begin
    Fail;
End;

Procedure TImageTrans.SetAutoPPos(AIsAuto: Boolean);
Begin
    FIsAutoPPos:= AIsAuto;
End;

Procedure TImageTrans.SetAutoCPos(AIsAuto: Boolean);
Begin
    FIsAutoCPos:= AIsAuto;
End;

Function TImageTrans.GetXC: Integer;
Begin
    GetXC:= FXC;
End;

Function TImageTrans.GetYC: Integer;
Begin
    GetYC:= FYC;
End;

Procedure TImageTrans.Unload;
Begin
    FImgP:= SafeDestroyBuf(FImgP); FImgSize:= 0;
    FManCount:= 0;
End;

Procedure TImageTrans.UnLoadToXMS;
Begin
    If FImgP = Nil Then Exit;
    FImgSize:= SizeOfBuf(FImgP);
    FXMSId:= LXMS.GetMem(BytesToKB(FImgSize));
    MemToXMS(FXMSId, FImgP, FImgSize, 0);
    FImgP:= DestroyBuf(FImgP);
End;

Procedure TImageTrans.RestoreFromXMS;
Begin
    If FXMSId = 0 Then Exit;
    FImgP:= SafeCreateBuf(FImgSize);
    XMSToMem(FXMSId, FImgP, FImgSize, 0);
    FXMSId:= LXMS.FreeMem(FXMSId);
End;

Function TImageTrans.IsResizeDone(AWPer, AHPer: Word): Boolean;
Begin
    IsResizeDone:= False;
End;

Function TImageTrans.IsRotateDone(Alpha: Integer): Boolean;
Begin
    IsRotateDone:= False;
End;

Function TImageTrans.IsRotResDone(Alpha: Integer; AWPer, AHPer: Word): Boolean;
Begin
    IsRotResDone:= False;
End;

Constructor TScene.Create(ASize: Integer);
Begin
    FSize:= ASize; FI:= 1;
    FIAP:= SafeCreateBuf(FSize * SizeOf(TImageP));
End;

Procedure TScene.Add(AImageP: TImageP);
Begin
    If FI > FSize Then Exit;
    FIAP^[FI]:= AImageP;
    Inc(FI);
End;

Procedure TScene.Move(AXPos, AYPos: Integer);
Var
    I: Integer;
Begin
    For I:= 1 To FI - 1 Do Begin
        If FIAP^[I] = Nil Then Continue;
        FIAP^[I]^.Move(AXPos, AYPos);
    End;
End;

Procedure TScene.Del(AImageP: TImageP);
Var
    I: Integer;
Begin
    For I:= 1 To FI - 1 Do If FIAP^[I] = AImageP Then Begin
        FIAP^[I]:= Nil; Exit;
    End;
End;

Procedure TScene.ClearAll;
Var
    I: Integer;
Begin
    For I:= 1 To FI - 1 Do FIAP^[I]:= Nil; FI:= 1;
End;

Procedure TScene.Draw;
Var
    I: Integer;
Begin
    For I:= 1 To FI - 1 Do Begin
        If FIAP^[I] = Nil Then Continue;
        If FIAP^[I]^.IsTransE Then Begin
            If FIAP^[I]^.GetObjType = IOT_Anim Then
                TAnimP(FIAP^[I])^.Trans^.Draw
            Else
                FIAP^[I]^.Trans^.Draw
        End
        Else Begin
            If FIAP^[I]^.GetObjType = IOT_Anim Then
                TAnimP(FIAP^[I])^.Draw
            Else
                FIAP^[I]^.Draw;
        End;
    End;
End;

Destructor TScene.Destroy;
Begin
    FIAP:= SafeDestroyBuf(FIAP);
End;

Begin
    GCurScrP:= Nil;
End.