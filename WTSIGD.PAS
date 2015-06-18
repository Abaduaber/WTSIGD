{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Program WTSIGD;
Uses
	LGLInt, LRF, LGL, LUtils, LMem, LInput, BSound, Objects, Memory, DOS;
Var
    GOldMem, GStartTime, GEndTime: LongInt;
    GScrP: TScreenP;
    ResP: TResP;
    FontP: TFontP;
    FS: TDosStream;
    MS: TEmsStream;
    MouS: TMouseState;
    Mouse: TImageP;
    NGT, ST: LongInt;
    IterC, ScNum: Word;
    IsDeb: Boolean;
    OldPal: TPaletteP;
Const
    CFrameLen = 40;
    CFPS = 25;
    SkipT = 1000 Div CFPS;

    Procedure Init; Forward;
    Procedure Done; Forward;
    Procedure Demo; Forward;
    Function Scene1: Word; Forward;
    Function Scene2(AI: Word): Word; Forward;
    Function Scene3(AI: Word): Word; Forward;
    Function Scene4(AI: Word): Word; Forward;
    Function Scene5(AI: Word): Word; Forward;
    Function Scene6(AI: Word): Word; Forward;
    Function Scene7(AI: Word): Word; Forward;
    Function Scene8(AI: Word): Word; Forward;
    Function Scene9(AI: Word): Word; Forward;

Procedure PrintC(AImgP: TImageP; AStr: String; AX, AY: Integer; AC: Byte);
Var
    OldC: Byte;
Begin
    OldC:= FontP^.GetColor;
    FontP^.SetColor(AC);
    FontP^.PrintXYOn(AImgP, AStr, AX, AY);
    FontP^.SetColor(OldC);
End;

Procedure PrintV(AImgP: TImageP; AStr: String; AX, AY: Integer);
Var
    I: Integer; OldC: Byte;
Begin
    {OldC:= FontP^.GetColor;
    FontP^.SetColor(Random(255));}
    For I:= 1 To Length(AStr) Do Begin
      FontP^.PrintXYOn(AImgP, AStr[I], AX, AY);
      Inc(AY, 6);
    End;
    {FontP^.SetColor(OldC); }
End;

Procedure Demo;
Var
    CI: Word;
Begin
    If (ScNum >= 1) And (ScNum < 10) Then Begin
      Case ScNum Of
        1: CI:= Scene1;
        2: CI:= Scene2(CI);
        3: CI:= Scene3(CI);
        4: CI:= Scene4(CI);
        5: CI:= Scene5(CI);
        6: CI:= Scene6(CI);
        7: CI:= Scene7(CI);
        8: CI:= Scene8(CI);
        9: CI:= Scene9(CI);
      End;
    End
    Else Begin
      CI:= Scene1;
      CI:= Scene2(CI);
      CI:= Scene3(CI);
      CI:= Scene4(CI);
      CI:= Scene5(CI);
      CI:= Scene6(CI);
      CI:= Scene7(CI);
      CI:= Scene8(CI);
      CI:= Scene9(CI);
    End;
    Sleep;
    IterC:= CI;
End;

Function Scene9(AI: Word): Word;
Var
    I, II, FI: Word;
    B1P: TImageP;
    BPP, CPP: TAnimP;
    BPalP: TPaletteP;
Begin
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st9_1b.lgf'));
    New(BPP, LoadFromRes(ResP, 'bpp', '.lgf', 12));
    New(CPP, LoadFromRes(ResP, 'cpp', '.lgf', 32));
    DestroyRes(ResP);

    BPP^.MoveTo(370, 130); BPP^.SetAllFrameDelay(0);
    CPP^.SetAllFrameDelay(1);

    GScrP^.FPalP^.Fill(0, 256, 63, 63, 63);
    GScrP^.FPalP^.Apply;
    FontP^.SetColor(255);
    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    II:= 0; ST:= 0; NGT:= ReadMS;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      If II < 80 Then Begin
        If GScrP^.FPalP^.FadeTo(BPalP, -1) Then;
        GScrP^.FPalP^.Apply;
      End;


      B1P^.Draw;
      If II < 100 Then Begin
        BPP^.Move(-2, 0); BPP^.Draw;
      End;
      If (II >= 100) Then Begin
        CPP^.MoveTo(BPP^.XP, BPP^.YP);
        CPP^.Draw;
      End;

      If II > 140 Then Begin
        If GScrP^.FPalP^.ChangeBr(-2) Then Break;
        GScrP^.FPalP^.Apply;
      End;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        FontP^.PrintXY('Sec = ' + IntToStr(II Div 24), 10, 30);
        FontP^.PrintXY('MEM = ' + IntToStr(MemAvail), 10, 40);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;

      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;


    Dispose(B1P, Destroy); Dispose(BPalP, Destroy);
    Dispose(BPP, Destroy); Dispose(CPP, Destroy);
End;

Function Scene8(AI: Word): Word;
Var
    I, II, FI: Word;
    B1P, F1P, Sky, Sun, Scr1, Scr3, DTOF, DTF, Throne, GSes, Celest: TImageP;
    WH, Scr2, Duck: TImageP;
    OctP, Smoke, FS, Expl: TAnimP;
    LastI, PTI, BDS, TDir, RX, RY: Integer;
    PTA: Array [1..100] Of Integer;
    BPalP: TPaletteP;
   { FD: Text; }
    Temp: String;
Begin
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st8_1b.lgf'));
    New(F1P, LoadFromRes(ResP, 'st8_1f.lgf'));
    New(Sky, LoadFromRes(ResP, 'sky2.lgf'));
    New(Sun, LoadFromRes(ResP, 'sun.lgf'));
    New(OctP, LoadFromRes(ResP, 'octp', '.lgf', 8));
    New(DTF, LoadFromRes(ResP, 'dtf.lgf'));
    New(Throne, LoadFromRes(ResP, 'throne.lgf'));
    New(GSes, LoadFromRes(ResP, 'gses.lgf'));
    New(Celest, LoadFromRes(ResP, 'celest.lgf'));
    New(Smoke, LoadFromRes(ResP, 'smoke', '.lgf', 11));
    New(DTOF, LoadFromRes(ResP, 'dtof.lgf'));
    New(FS, LoadFromRes(ResP, 'fsr', '.lgf', 16));
    New(Expl, LoadFromRes(ResP, 'expl', '.lgf', 25));
    New(WH, LoadFromRes(ResP, 'woohoo.lgf'));
    New(Duck, LoadFromRes(ResP, 'duck.lgf'));
    New(Scr1, Create(OT_Img, 110, 56));
    New(Scr2, Create(OT_Img, 320, 200));
    New(Scr3, Create(OT_Spr, 73, 151));

    OpenSF(ResP, 'TIMING.TXT');
    FI:= 1; BDS:= 0; TDir:= 2;
    While Not IsSFEOF(ResP) Do Begin
      ReadLnSF(ResP, Temp);
      PTA[FI]:= StrToInt(Temp);
      Inc(FI);
    End;
    DestroyRes(ResP);

    B1P^.MoveTo(0, -50); F1P^.MoveTo(0, 0); Sun^.MoveTo(145, 100);
    OctP^.SetAllFrameDelay(1); OctP^.MoveTo(15, 135);
    {DTF^.MoveTo(247, 65);} DTF^.MoveTo(0, 65);
    Throne^.MoveTo(280, 75); GSes^.MoveTo(297, 135);
    Celest^.MoveTo(185, 157);
    Smoke^.Hide; Smoke^.SetAllFrameDelay(1);
    Scr1^.MoveTo(7, 52); Scr3^.MoveTo(247, 0);
    FS^.MoveTo(-50, 145); WH^.MoveTo(50, 150); WH^.SetFlip(True, False);
    Scr3^.SetSpriteIndex(254);
    GScrP^.FPalP^.Fill(0, 256, 63, 63, 63);
    GScrP^.FPalP^.Apply;
    FontP^.SetColor(255);
   { Assign(FD, 'timing.txt');
    ReWrite(FD); }
    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    II:= 0; ST:= 0; NGT:= ReadMS; LastI:= 0; PTI:= 1; RX:= 35; RY:= 28;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      If Not (II >= 225) And (II < 1800) Then Scr1^.Fill(0);
      Scr3^.Fill(254);
      If II < 80 Then Begin
        If Not GScrP^.FPalP^.FadeTo(BPalP, -1) Then
          GScrP^.FPalP^.Apply;
      End;

      If II < 200 Then DTOF^.DrawOn(Scr1);
      If (II > 100) And (II <= 156) Then Begin
          DTOF^.Move(0, -1);
      End;
      If (II >= 175) And (II < 225) Then Begin
        FontP^.PrintXYOn(Scr1, 'SYSTEM REPORTS:', 12, 24);
        FontP^.PrintXYOn(Scr1, 'SOMETHING WENT', 2, 30);
        FontP^.PrintXYOn(Scr1, 'WRONG',18, 36);
      End;

      If (II > 500) And (II < 565) Then Begin
        GSes^.Move(-Integer(II Mod 8 = 0), Integer(II Mod 4 = 0));
      End;

      Sky^.Move(1, 0);
      Sky^.Draw; Sky^.Move(-320, 0); Sky^.Draw; Sky^.Move(320, 0);
      If Sky^.XP = 320 Then Sky^.MoveTo(0, 0);
      Sun^.Draw;
      B1P^.Draw;
      F1P^.Draw;
      Scr1^.Draw;
      DTF^.Move(0, BDS);
      For FI:= 0 To 9 Do Begin
        DTF^.DrawOn(Scr3); DTF^.Move(0, -DTF^.Height);
      End;
      DTF^.Move(0, DTF^.Height * 10);
      Scr3^.Draw;
      Throne^.Draw;
      GSes^.Draw;
      Celest^.Draw;

      If II >= 565 Then Begin
        Smoke^.Trans^.SetAutoCPos(False);
        Smoke^.MoveTo(GSes^.XP - Smoke^.Width Div 2 + 5, GSes^.YP - Smoke^.Height Div 2);
        Smoke^.Draw; If Smoke^.IsResizeDone(50, 50) Then; Smoke^.Trans^.Draw;
      End;

      If II = PTA[PTI] Then OctP^.SetStep(1);
      If II = PTA[PTI] + 3 Then Begin
        OctP^.SetStep(0); Inc(PTI);
      End;

      OctP^.Draw;

      If (II > 210) And (II < 260) Then Begin
        FS^.Move(2, 0); FS^.Draw;
      End;
      If (II > 260) And (II < 288) Then Begin
        WH^.MoveTo(FS^.XP + 7, FS^.YP + 6); WH^.Draw;
      End;
      If (II >= 288) And (II < 358) Then Begin
        FS^.SetStep(-1);
        FS^.Move(-2, 0); FS^.Draw;
      End;

      If II < 20 Then FontP^.PrintXY('GOD BLESS YOU', 140, 98);
      If (II > 600) And (II < 605) Then Begin
        FontP^.PrintXY('DOWNGRADE IT', 2, 193);
      End;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        FontP^.PrintXY('Sec = ' + IntToStr(II Div 24), 10, 30);
        FontP^.PrintXY('MEM = ' + IntToStr(MemAvail), 10, 40);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;

      If (II >= 730) And (II <= 760) Then Begin
        For FI:= 0 To 255 Do GScrP^.FPalP^.SetColor(FI, Random(63), Random(63), Random(63));
        GScrP^.FPalP^.Apply;
      End;
      If (II = 760) Then Begin
        GScrP^.FPalP^.SetRange(0, BPalP, 0, 255);
        GScrP^.FPalP^.Apply;
      End;

      If (II > 962) And (II < 1175) Then Begin
        Scr2^.GetFrom(GScrP, 0, 0, 320, 200, 0, 0);
        Scr2^.Move(TDir Div 2, TDir);
        Scr2^.Draw;
        Expl^.MoveTo(300, 120); Expl^.Draw; Expl^.PrevFrame;
        Expl^.MoveTo(280, 120); Expl^.Draw; Expl^.PrevFrame;
        Expl^.MoveTo(260, 120); Expl^.Draw; Expl^.PrevFrame;
        Expl^.MoveTo(240, 120); Expl^.Draw; Expl^.PrevFrame;
        Expl^.MoveTo(220, 120); Expl^.Draw;
        TDir:= -TDir;
      End;

      If II > 1250 Then Begin
        If II < 1400 Then Sun^.Move(0, -Integer(II Mod 2 = 0));
        If GScrP^.FPalP^.ChangeBr(Integer(II Mod 4 = 0)) Then;
        GScrP^.FPalP^.Apply;
      End;
      If II > 1500 Then Break;

      If (II >= 225) And (II < 1800) Then Begin
        If GScrP^.IsTransE Then Scr1^.Draw;
        If GScrP^.IsResizeDone(RX, RY) Then GScrP^.Trans^.SetAutoPPos(False);
        GScrP^.Trans^.MoveTo(0, 0);
        If II > 800 Then Begin
          If GScrP^.IsRotateDone(II - 800) Then;
          GScrP^.Trans^.MoveTo(-40, -65);
          RX:= 45; RY:= 37;
        End;
        GScrP^.Trans^.DrawOn(Scr1);
        FontP^.SetColor(0);
        If II Mod 48 >= 24 Then FontP^.PrintXYOn(Scr1, 'CAM 074:', 1, 1);
        FontP^.SetColor(255);
        Scr1^.Draw;
      End;

      If (II >= 650) And (II < 660) Then GScrP^.SetFlip(Not GScrP^.IsHorFlip, False);
      If (II >= 660) And (II < 670) Then GScrP^.SetFlip(False, Not GScrP^.IsVertFlip);
      If (II >= 670) And (II < 680) Then GScrP^.SetFlip(Not GScrP^.IsHorFlip, Not GScrP^.IsVertFlip);

      If (II > 820) And (II < 830) Then Begin
        Duck^.SetFlip(True, False);
        Duck^.MoveTo(160, 170); Duck^.Draw;
        FontP^.PrintXY('THE DUCK DOES NOT FORGIVE!!!', 100, 194);
      End;

      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      If (II >= 930) And (II < 962) Then Begin
        If Not GScrP^.FPalP^.ChangeBr(2) Then GScrP^.FPalP^.Apply;
      End;
      If II = 962 Then Begin
        Celest^.Hide; Throne^.Hide; GSes^.Hide; BDS:= 4; Smoke^.Trans^.Hide;
      End;
      If (II >= 962) And (II < 1000) Then Begin
        If GScrP^.FPalP^.FadeTo(BPalP, -2) Then;
        GScrP^.FPalP^.Apply;
      End;

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene8:= I;
    {Close(FD);}

    Dispose(BPalP, Destroy); Dispose(B1P, Destroy); Dispose(Sun, Destroy);
    Dispose(F1P, Destroy); Dispose(OctP, Destroy); Dispose(Sky, Destroy);
    Dispose(DTF, Destroy); Dispose(Celest, Destroy);
    Dispose(Throne, Destroy); Dispose(GSes, Destroy); Dispose(Smoke, Destroy);
    Dispose(Scr1, Destroy); Dispose(DTOF, Destroy); Dispose(Scr3, Destroy);
    Dispose(FS, Destroy); Dispose(WH, Destroy); Dispose(Scr2, Destroy);
    Dispose(Expl, Destroy); Dispose(Duck, Destroy);
End;

Function Scene7(AI: Word): Word;
Var
    I, II, FI: Word;
    B1P, B2P, TrainV, Scr1, Suhov, STN: TImageP;
    ScP: TSceneP;
    MLamp, OctW, Derp, PacMan, LyraS, LyraW, PM: TAnimP;
    BPalP: TPaletteP;
    TSp: Real;
    VI, OctS: Integer;
    AStr: String;
    YRollP: Array [1..5] Of Integer;
Begin
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st7_1b.lgf'));
    New(B2P, LoadFromRes(ResP, 'st7_2b.lgf'));
    New(TrainV, LoadFromRes(ResP, 'trainv.lgf'));
    New(MLamp, LoadFromRes(ResP, 'mlamp', '.lgf', 5));
    New(ScP, Create(8));
    New(OctW, LoadFromRes(ResP, 'octw', '.lgf', 11));
    New(Derp, LoadFromRes(ResP, 'derpy', '.lgf', 13));
    New(PacMan, LoadFromRes(ResP, 'pacman', '.lgf', 6));
    New(LyraS, LoadFromRes(ResP, 'lyras', '.lgf', 13));
    New(LyraW, LoadFromRes(ResP, 'lyraw', '.lgf', 16));
    New(PM, LoadFromRes(ResP, 'swpa', '.lgf', 16));
    New(STN, LoadFromRes(ResP, 'swpb1.lgf'));
    New(Suhov, LoadFromRes(ResP, 'suhov.lgf'));
    New(Scr1, Create(OT_Img, 31, 23));
    DestroyRes(ResP);

    B1P^.MoveTo(0, 0); B2P^.MoveTo(212, 0);
    MLamp^.SetAllFrameDelay(36); MLamp^.MoveTo(186, 61);
    OctW^.MoveTo(-10, 115); OctW^.SetAllFrameDelay(2); OctW^.Hide;
    Derp^.SetAllFrameDelay(2); Derp^.SetFrameDelay(4, 60);
    Derp^.SetFrameDelay(7, 60); Derp^.SetFrameDelay(13, 60);
    TrainV^.MoveTo(-2587, 119); Derp^.MoveTo(-1480, 136);
    Scr1^.MoveTo(355, 59);
    PacMan^.SetAllFrameDelay(2); PacMan^.MoveTo(-10, 8);
    ScP^.Add(B1P); ScP^.Add(B2P); ScP^.Add(MLamp); ScP^.Add(Scr1);
    ScP^.Add(STN); ScP^.Add(LyraS);
    Suhov^.MoveTo(-20, -20);
    STN^.MoveTo(317, 121); LyraS^.MoveTo(367, 90); LyraS^.SetAllFrameDelay(2);
    PM^.MoveTo(50, 115); PM^.SetAllFrameDelay(2); PM^.Hide; PM^.SetFlip(True, False);
    LyraW^.SetAllFrameDelay(2); LyraW^.Hide; LyraS^.Hide; LyraW^.MoveTo(290, 122);

    AStr:= '0123456789ABCDEFGHIJKLMNOPQRST UVWXYZ';
    For FI:= 1 To 5 Do YRollP[FI]:= 2;
    GScrP^.FPalP^.Fill(0, 256, 63, 63, 63);
    GScrP^.FPalP^.Apply;
    FontP^.SetColor(255);
    If STN^.IsResizeDone(60, 60) Then;
    STN^.Trans^.SetAutoCPos(False);
    TSp:= 30; OctS:= 75;

    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    II:= 0; ST:= 0; NGT:= ReadMS;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);

      Scr1^.Fill(0);
      For FI:= 0 To 4 Do Begin
        PrintV(Scr1, AStr, 1 + FI * 6, YRollP[FI + 1]);
      End;

      If II < 80 Then Begin
        If Not GScrP^.FPalP^.FadeTo(BPalP, -1) Then
          GScrP^.FPalP^.Apply;
      End;
      Case II Of
        1..74:
        Begin
          ScP^.Move(-1, 0); OctW^.Move(-1, 0);
        End;
      End;
      If (II > 40) And (II < 95) Then Dec(YRollP[1], 2);
      If (II > 50) And (II < 135) Then Dec(YRollP[2], 2);
      If (II > 70) And (II < 77) Then Dec(YRollP[4], 2);
      If (II > 80) And (II < 99) Then Dec(YRollP[5], 2);

      If (II > 150) And (II < 205) Then For FI:= 1 To 5 Do Dec(YRollP[FI], 7);

      If (II > 205) And (II < 260) Then Begin
        For FI:= 1 To 30 Do If FI Mod 6 = 0 Then
          If PacMan^.XP + PacMan^.Width < FI Then Scr1^.PSet(FI, 11, 255);  {!!!}

        PacMan^.Move(1, 0); PacMan^.DrawOn(Scr1);
      End;

      If (II > 260) And (II < 281) Then Begin
        Suhov^.Move(1, 1);
        Suhov^.DrawOn(Scr1);
      End;
      If II >= 281 Then Begin
        If Suhov^.IsResizeDone(100 - (II - 281) * 2, 100 - (II - 281) * 2) Then Suhov^.Trans^.DrawOn(Scr1);
        Suhov^.Move(-1, -1);
      End;

      If (II > 120) And (II < 145) Then Begin
          OctW^.Move(0, 1);
          Inc(OctS);
      End;
      If II = 145 Then OctW^.SetStep(0);

      OctW^.Draw;
      If II < 145 Then OctW^.Move(1, 0);
      Derp^.Move(Trunc(TSp), 0); TrainV^.Move(Trunc(TSp), 0);
      If OctW^.IsResizeDone(OctS, OctS) Then; {OctW^.Trans^.SetAutoCPos(False);}

      GScrP^.Fill(Random(255));
      ScP^.Draw;
      PM^.Draw;
      If II < 150 Then Begin
        If PM^.IsResizeDone(75, 75) Then PM^.Trans^.Draw;
        PM^.Move(1, 0);
      End
      Else If (II >= 150) And (II < 250) Then Begin
        PM^.SetStep(0);
        PM^.Trans^.Draw;
      End
      Else If (II >= 250) Then Begin
          PM^.SetStep(1); PM^.SetFlip(False, False);
          If PM^.IsResizeDone(75, 75) Then PM^.Trans^.Draw;
          PM^.Move(-1, 0);
      End;

      If II < 250 Then Begin
        If LyraS^.IsResizeDone(75, 75) Then
      End
      Else Begin
        If II = 250 Then LyraS^.Trans^.UnLoad;
        LyraW^.Draw;
        If LyraW^.IsResizeDone(75, 75) Then;
        LyraW^.Move(-1, 0);
        LyraW^.Trans^.SetAutoCPos(False);
        LyraW^.Trans^.Draw;
      End;
      OctW^.Trans^.Draw;
      Derp^.Draw;
      For VI:= 1 To 8 Do Begin
          TrainV^.Draw; TrainV^.Move(320, 0);
      End;
      TrainV^.Move(-8 * 320, 0);


      If II < 150 Then Begin
        TSp:= TSp - 0.27;
        If TSp < 0 Then TSp:= 0;
      End
      Else If II > 160 Then Begin
        TSp:= TSp + 0.27;
        OctW^.Move(Trunc(TSp), 0);
      End;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        FontP^.PrintXY('Sec = ' + IntToStr(II Div 24), 10, 30);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      If II > 325 Then Begin
        If Not GScrP^.FPalP^.ChangeBr(2) Then
          GScrP^.FPalP^.Apply
        Else
          Break;
      End;
      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene7:= I;

    Dispose(ScP, Destroy); Dispose(B1P, Destroy);
    Dispose(B2P, Destroy); Dispose(BPalP, Destroy);
    Dispose(Scr1, Destroy); Dispose(Suhov, Destroy);
    Dispose(MLamp, Destroy); Dispose(OctW, Destroy);
    Dispose(LyraS, Destroy); Dispose(STN, Destroy);
    Dispose(LyraW, Destroy); Dispose(PM, Destroy);
    Dispose(Derp, Destroy); Dispose(TrainV, Destroy); Dispose(PacMan, Destroy);
End;

Function Scene6(AI: Word): Word;
Var
    I, II, FI: Word;
    B1P, B2P, F1P, F2P, F3P, Sky, Fence, SubWay, Damned, Table, Sm, Sm2: TImageP;
    Logo, Bar, L1: TImageP;
    Scr1, Scr2, Scr3, Scr4, Scr5, Scr6: TImageP;
    Scr1C: Byte;

    OctW, DJ, DE, D1, D2, Drunk, Cgr, Smoke, Spire, Spire2: TAnimP;
    BPalP: TPaletteP;
    BScP, FScP: TSceneP;
    AStr: String;
    YRollP: Array [1..30] Of Integer;
    LogoRD, LogoS, LLabYP, LLabXP: Integer;
Begin
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st6_1b.lgf'));
    New(B2P, LoadFromRes(ResP, 'st6_2b.lgf'));
    New(F1P, LoadFromRes(ResP, 'st6_1f.lgf'));
    New(F2P, LoadFromRes(ResP, 'st6_2f.lgf'));
    New(F3P, LoadFromRes(ResP, 'st6_3f.lgf'));
    New(Sky, LoadFromRes(ResP, 'sky1.lgf'));
    New(Fence, LoadFromRes(ResP, 'fence.lgf'));
    New(SubWay, LoadFromRes(ResP, 'subway.lgf'));
    New(Damned, LoadFromRes(ResP, 'damned.lgf'));
    New(Table, LoadFromRes(ResP, 'table.lgf'));
    New(Logo, LoadFromRes(ResP, 'djlogo.lgf'));
    New(Bar, LoadFromRes(ResP, 'bar.lgf'));
    New(OctW, LoadFromRes(ResP, 'octw', '.lgf', 11));
    New(DJ, LoadFromRes(ResP, 'djpon', '.lgf', 8));
    New(DE, LoadFromRes(ResP, 'decks', '.lgf', 8));
    New(D1, LoadFromRes(ResP, 'bdance', '.lgf', 14));
    New(D2, LoadFromRes(ResP, 'sdance', '.lgf', 10));
    New(Drunk, LoadFromRes(ResP, 'dra', '.lgf', 8));
    New(Cgr, LoadFromRes(ResP, 'cgr', '.lgf', 9));
    New(Smoke, LoadFromRes(ResP, 'smoke', '.lgf', 11));
    New(L1, LoadFromRes(ResP, 'light1.lgf'));
    New(Sm, LoadFromRes(ResP, 'drb1.lgf'));
    New(Sm2, LoadFromRes(ResP, 'sma1.lgf'));
    New(Spire, LoadFromRes(ResP, 'spire', '.lgf', 6));
    New(Spire2, LoadFromRes(ResP, 'spire', '.lgf', 6));
    New(BScP, Create(8));
    New(FScP, Create(10));
    DestroyRes(ResP);
    New(Scr1, Create(OT_Img, 95, 16)); New(Scr2, Create(OT_Img, 110, 56));
    New(Scr3, Create(OT_Img, 95, 41)); New(Scr4, Create(OT_Img, 131, 31));
    New(Scr5, Create(OT_Img, 95, 16)); New(Scr6, Create(OT_Img, 135, 28));

    Scr1^.MoveTo(211, 105); Scr2^.MoveTo(376, 37);
    Scr3^.MoveTo(581, 73); Scr4^.MoveTo(583, 121);
    Scr5^.MoveTo(786, 179); Scr6^.MoveTo(194, 125);
    SubWay^.MoveTo(770, 136); Fence^.MoveTo(722, 125);
    Damned^.MoveTo(20, 60);
    OctW^.MoveTo(-OctW^.Width, 150); OctW^.SetAllFrameDelay(2);
    Sm2^.MoveTo(413, 148); Cgr^.MoveTo(Sm2^.XP - 1, Sm2^.YP + 22);
    Smoke^.MoveTo(Sm2^.XP - (Smoke^.Width Div 2) - 2, Cgr^.YP - Smoke^.Height);
    DJ^.SetAllFrameDelay(2); DE^.SetAllFrameDelay(2);
    D1^.SetAllFrameDelay(1); D2^.SetAllFrameDelay(1);
    Smoke^.SetAllFrameDelay(2);
    Cgr^.SetAllFrameDelay(350); Cgr^.SetFrameDelay(9, 2000);
    L1^.MoveTo(0, 120);
    DJ^.MoveTo(100, -6); DJ^.Hide;
    DE^.MoveTo(83, -4); DE^.Hide;
    D1^.MoveTo(50, 5); D1^.Hide; D1^.SetFlip(True, False);
    D2^.MoveTo(20, 7); D2^.Hide; Table^.MoveTo(-5, 10);
    Logo^.Move(-95, 0);

    Drunk^.MoveTo(25, 5);
    Drunk^.SetFlip(True, False); Drunk^.Hide;
    Drunk^.SetAllFrameDelay(2); Sm^.MoveTo(80, 5);

    Spire^.MoveTo(193, 7); Spire2^.MoveTo(355, 9);

    B2P^.MoveTo(B1P^.Width, 0); B1P^.MoveTo(0, 0);
    BScP^.Add(B1P); BScP^.Add(B2P); BScP^.Add(Spire); BScP^.Add(Spire2);
    Spire^.SetAllFrameDelay(3); Spire2^.SetAllFrameDelay(3);
    Spire^.Hide; Spire2^.Hide;

    F2P^.MoveTo(F1P^.Width, 0); F3P^.MoveTo(F1P^.Width * 2, 0);
    FScP^.Add(F1P); FScP^.Add(F2P); FScP^.Add(F3P); FScP^.Add(Scr1);
    FScP^.Add(Scr2); FScP^.Add(Scr3); FScP^.Add(Sm2); FScP^.Add(Cgr);
    FScP^.Add(Smoke);

    GScrP^.FPalP^.Fill(0, 256, 0, 0, 0);
    GScrP^.FPalP^.Apply;
    LogoRD:= 5; LogoS:= 105;
    AStr:= '0123456789ABCDEFGHIJKLMNOPQRST UVWXYZ';
    For II:= 1 To 30 Do YRollP[II]:= 2;
    If Sm^.IsResizeDone(60, 60) Then; Sm^.Trans^.SetAutoCPos(False);
    FontP^.SetColor(255);

    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    II:= 0; ST:= 0; NGT:= ReadMS;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      If II < 80 Then Begin
        If Not GScrP^.FPalP^.FadeTo(BPalP, 1) Then
          GScrP^.FPalP^.Apply;
      End;

      Scr1^.Fill(0); Scr2^.Fill(0); Scr3^.Fill(0); Scr5^.Fill(0); Scr6^.Fill(0); {!!!}
      If II Mod 12 = 0 Then Scr1C:= Random(255);
      PrintC(Scr1, 'BAR "NONAME"', 15, 2, Scr1C);
      PrintC(Scr5, 'SUBWAY', 25, 2, Scr1C);
      PrintC(Scr5, 'FREE MEM: ' + IntToStr(MemAvail), 3, 10, Scr1C);

      If (II >= 230) And (II < 301) Then Dec(YRollP[1]);
      If (II >= 230) And (II < 349) Then Dec(YRollP[2]);
      If (II >= 310) And (II < 363) Then Dec(YRollP[3]);
      If (II >= 250) And (II < 405) Then Dec(YRollP[4]);
      If (II >= 280) And (II < 423) Then Dec(YRollP[5]);
      If (II >= 290) And (II < 349) Then Dec(YRollP[6]);
      If (II >= 270) And (II < 383) Then Dec(YRollP[7]);
      If (II >= 260) And (II < 409) Then Dec(YRollP[8]);
      If (II >= 280) And (II < 435) Then Dec(YRollP[9]);
      If (II >= 290) And (II < 325) Then Dec(YRollP[10]);
      If (II >= 330) And (II < 401) Then Dec(YRollP[11]);
      If (II >= 340) And (II < 477) Then Dec(YRollP[12]);
      If (II >= 370) And (II < 429) Then Dec(YRollP[13]);
      If (II >= 360) And (II < 503) Then Dec(YRollP[14]);
      If (II >= 380) And (II < 523) Then Dec(YRollP[15]);
      If (II >= 400) And (II < 483) Then Dec(YRollP[16]);
      If (II >= 410) And (II < 529) Then Dec(YRollP[17]);
      If (II >= 420) And (II < 533) Then Dec(YRollP[18]);
      If II < 600 Then
        For FI:= 0 To 17 Do PrintV(Scr2, AStr, 2 + FI * 6, YRollP[FI + 1])
      Else If (II >= 600) And (II <= 650) Then Begin
        For FI:= 0 To 17 Do PrintV(Scr2, AStr, 2 + FI * 6, YRollP[FI + 1] - (II - 600) * 8);
        Damned^.Move(0, -1);
        Damned^.DrawOn(Scr2);
      End
      Else If (II > 650) And (II < 725) Then Begin
        FontP^.PrintXYOn(Scr2, 'DAMNED (R)', 755 - II, 2);
        FontP^.PrintXYOn(Scr2, 'PERFECT', 35, 767 - II);
        FontP^.PrintXYOn(Scr2, 'TOBACCO', 35, 773 - II);
        Damned^.DrawOn(Scr2);
      End
      Else Begin
        FontP^.PrintXYOn(Scr2, 'DAMNED (R)', 30, 2);
        FontP^.PrintXYOn(Scr2, 'PERFECT', 35, 42);
        FontP^.PrintXYOn(Scr2, 'TOBACCO', 35, 48);
        Damned^.DrawOn(Scr2);
      End;

      Smoke^.MoveTo(Sm2^.XP - (Smoke^.Width Div 2) + Cgr^.GetCurIndex - 2, Smoke^.YP);

      If II < 750 Then Begin
        Bar^.DrawOn(Scr6);
        Drunk^.Draw;
        If Drunk^.IsResizeDone(60, 60) Then Drunk^.Trans^.DrawOn(Scr6);
        Drunk^.Trans^.SetAutoCPos(False);
        Sm^.Trans^.DrawOn(Scr6);
      End;

      If II > 600 Then Begin
        Scr4^.Fill(Random(255));
        For FI:= 0 To 3 Do Begin
            Table^.DrawOn(Scr4);
            Table^.Move(Table^.Width + 5, 0);
        End;
        Table^.Move(-(Table^.Width * 4 + 20), 0);
        DJ^.DrawOn(Scr4); DE^.DrawOn(Scr4); D1^.DrawOn(Scr4); D2^.DrawOn(Scr4);
        If DJ^.IsResizeDone(66, 66) Then DJ^.Trans^.DrawOn(Scr4);
        If DE^.IsResizeDone(66, 66) Then DE^.Trans^.DrawOn(Scr4);
        If D1^.IsResizeDone(66, 66) Then D1^.Trans^.DrawOn(Scr4);
        If D2^.IsResizeDone(66, 66) Then D2^.Trans^.DrawOn(Scr4);
      End;

      If II > 600 Then Begin
        Logo^.MoveTo(0, 0);
        Inc(LogoS, LogoRD);
        If (LogoS = 100) Or (LogoS = 300) Then LogoRD:= -LogoRD;
        If Logo^.IsResizeDone(LogoS, LogoS) Then Logo^.Trans^.DrawOn(Scr3);
        If (II > 650) And (II < 700) Then LLabYP:= 700 - II;
        If (II >= 700) And (II < 780) Then LLabXP:= 780 - II;
        FontP^.PrintXYOn(Scr3, 'Vinyl Scratch', 2, LLabYP);
        FontP^.PrintXYOn(Scr3, '18.12.2012', LLabXP, 10);
        FontP^.PrintXYOn(Scr3, 'New set presentation', 2, (Scr3^.Height Div 2) - LLabYP);
      End;


      Case II Of
      1..120:
      Begin
          OctW^.Move(Integer(II Mod 2 = 0), 0);
      End;
      121..600:
      Begin
          BScP^.Move(-Integer(II Mod 4 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr4^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr5^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr6^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          FScP^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          SubWay^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          Fence^.Move(-Integer(II Mod 2 = 0) * Integer(F3P^.XP <> 0), 0);
          L1^.Move(-1 * Integer(F3P^.XP <> 0), 0);
          OctW^.Move(Integer(II Mod 2 = 0) * Integer(F3P^.XP = 0), 0);
      End;
      Else Begin
          OctW^.SetAllFrameDelay(1);
          BScP^.Move(-Integer(II Mod 4 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr4^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr5^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          Scr6^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          FScP^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          SubWay^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          Fence^.Move(-Integer(II Mod 1 = 0) * Integer(F3P^.XP <> 0), 0);
          L1^.Move(-2 * Integer(F3P^.XP <> 0), 0);
          OctW^.Move(Integer(II Mod 1 = 0) * Integer(F3P^.XP = 0), 0);
      End;
      End;
      If II > 1130 Then OctW^.Move(0, Integer(II Mod 4 = 0));

      Sky^.Move(1, 0);
      Sky^.Draw; Sky^.Move(-320, 0); Sky^.Draw; Sky^.Move(320, 0);
      If Sky^.XP = 320 Then Sky^.MoveTo(0, 0);
      Drunk^.Draw;
      If (II > 370) And (II < 430) Then Spire2^.Show Else Spire2^.Hide;
      If (II > 435) And (II < 465) Then Spire^.Show Else Spire^.Hide;
      BScP^.Draw;
      Scr4^.Draw; Scr6^.Draw;
      FScP^.Draw;
      For FI:= 0 To 4 Do Begin
          Fence^.Draw;
          Fence^.Move(Fence^.Width, 0);
      End;
      Fence^.Move(-Fence^.Width * 5, 0);

      OctW^.Draw;
      SubWay^.Draw;
      Scr5^.Draw;
      For FI:= 1 To 10 Do Begin
          L1^.Draw; L1^.Move(250, 0);
      End;
      L1^.Move(-250 * 10, 0);

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        FontP^.PrintXY('Sec = ' + IntToStr(II Div 24), 10, 30);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      If II > 1150 Then Begin
        If Not GScrP^.FPalP^.ChangeBr(1) Then
          GScrP^.FPalP^.Apply
        Else
          Break;
      End;

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene6:= I;

    Dispose(BPalP, Destroy); Dispose(Spire, Destroy);
    Dispose(Spire2, Destroy);
    Dispose(Scr1, Destroy); Dispose(Scr2, Destroy);
    Dispose(Scr3, Destroy); Dispose(Scr4, Destroy);
    Dispose(Scr5, Destroy); Dispose(Scr6, Destroy);
    Dispose(Smoke, Destroy); Dispose(L1, Destroy);
    Dispose(B1P, Destroy); Dispose(B2P, Destroy);
    Dispose(F1P, Destroy); Dispose(F2P, Destroy);
    Dispose(F3P, Destroy); Dispose(Sky, Destroy);
    Dispose(OctW, Destroy); Dispose(DE, Destroy);
    Dispose(DJ, Destroy); Dispose(D1, Destroy);
    Dispose(D2, Destroy); Dispose(Drunk, Destroy);
    Dispose(Sm, Destroy); Dispose(Sm2, Destroy);
    Dispose(Cgr, Destroy); Dispose(Fence, Destroy);
    Dispose(SubWay, Destroy); Dispose(Damned, Destroy);
    Dispose(Table, Destroy); Dispose(Logo, Destroy);
    Dispose(Bar, Destroy); Dispose(BScP, Destroy);
    Dispose(FScP, Destroy);
End;


Function Scene5(AI: Word): Word;
Const
    PDA: Array [1..78] Of ShortInt = (
        1, 1, 0, 1, 0, 1, -1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1,
        -1, 1, -1, 1, -1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,
        1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1, -1, 1, -1, 1, -1, 1, -1,
        0, -1, 0, -1, 0, -1, -1, -1, -1, -1, 0, -1, 0, -1, -1, -1, -1, -1,
        -3, 1
    );
Var
    I, II: Word;
    B1P, B2P, F1P, Sky, Pencil, Canv, Lamp, Neuro, Bus: TImageP;
    DFly, Luna: TAnimP;
    BPalP: TPaletteP;
    ScP: TSceneP;
    PDI, GSI, LI: Integer;
    DThX, DThX2, GSY, GSY2, NVD, LSize, FSP: Integer;
    GSOS, GSOS2: String;
Begin
    I:= AI; GSOS:= 'GOD SENT'; GSOS2:= 'OBSESSION';
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st5_1b.lgf'));
    New(B2P, LoadFromRes(ResP, 'st5_2b.lgf'));
    New(F1P, LoadFromRes(ResP, 'st5_1f.lgf'));
    New(Sky, LoadFromRes(ResP, 'sky2.lgf'));
    New(DFly, LoadFromRes(ResP, 'drfly', '.lgf', 3));
    New(Luna, LoadFromRes(ResP, 'lunaf', '.lgf', 16));
    New(Pencil, LoadFromRes(ResP, 'drfly5.lgf'));
    New(Canv, LoadFromRes(ResP, 'drfly4.lgf'));
    New(Lamp, LoadFromRes(ResP, 'lamp.lgf'));
    New(Neuro, LoadFromRes(ResP, 'neuro.lgf'));
    New(Bus, LoadFromRes(ResP, 'bus.lgf'));
    New(ScP, Create(8));
    DestroyRes(ResP);

    B1P^.MoveTo(0, -40); B2P^.MoveTo(320, -40);
    ScP^.Add(B1P); ScP^.Add(B2P);
    Sky^.Move(0, -40);
    DFly^.SetAllFrameDelay(3); Luna^.SetAllFrameDelay(2);
    DFly^.Move(410, 120); Canv^.Move(457, 125); Pencil^.Move(449, 122);
    Lamp^.MoveTo(0, 50); Luna^.MoveTo(1200, 10);
    Neuro^.MoveTo(1220, 10); Bus^.MoveTo(-200, 141);

    II:= 1; PDI:= 1;
    DThX:= -73; DThX2:= 355; GSY:= -70; GSY2:= 220; LSize:= 100;
    FSP:= -2;
    NVD:= 1;
    GScrP^.FPalP^.Fill(0, 256, 63, 63, 63); GScrP^.FPalP^.Apply;

    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    ST:= 0; NGT:= ReadMS;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      If II < 80 Then Begin
        If Not GScrP^.FPalP^.FadeTo(BPalP, -1) Then
          GScrP^.FPalP^.Apply;
      End;
      ScP^.Move(-Integer(II Mod 4 = 0), 0);
      Sky^.Move(-Integer(II Mod 2 = 0), 0);
      Sky^.Draw; Sky^.Move(320, 0); Sky^.Draw; Sky^.Move(-320, 0);
      If Sky^.XP = -320 Then Sky^.MoveTo(0, -40);

      F1P^.Move(FSP, 0);
      DFly^.Move(FSP, 0); Canv^.Move(FSP, 0); Pencil^.Move(FSP, 0);
      Luna^.Move(FSP * 2, 0); Neuro^.Move(FSP * 2, 0);
      If II Mod 15 = 0 Then Begin
          Neuro^.Move(0, NVD);
          NVD:= -NVD;
      End;
      Pencil^.Move(PDA[PDI], PDA[PDI + 1]);
      Inc(PDI, 2); If PDI > 78 Then PDI:= 1;

      If F1P^.XP < -320 Then Begin
        F1P^.MoveTo(-1, 0);
      End;
      Lamp^.Move(-(Abs(FSP) + (II Mod 2)), 0);

      ScP^.Draw;
      F1P^.Draw; F1P^.Move(320, 0); F1P^.Draw; F1P^.Move(-320, 0);
      DFly^.Draw; Canv^.Draw; Pencil^.Draw;

      If (Luna^.XP > -40) And (Luna^.XP < 120) Then Begin
        Dec(LSize, Abs(FSP));
        If Luna^.IsResizeDone(LSize, LSize) Then Begin
          Luna^.Hide; Luna^.Trans^.Draw;
        End;
        If Neuro^.IsResizeDone(LSize, LSize) Then Begin
          Neuro^.Hide; Neuro^.Trans^.Draw;
        End;
      End
      Else Begin
        Luna^.Draw; Neuro^.Draw;
      End;

      If II > 324 Then Begin
          Bus^.Move(8, 0);
          Bus^.Draw;
      End;
      For LI:= 1 To 20 Do Begin
          Lamp^.Draw; Lamp^.Move(250, 0);
      End;
      Lamp^.Move(-5000, 0);

      Case II Of
        75..125: Begin
          Inc(DThX, 2); Dec(DThX2, 2);
          FontP^.SetColor(255);
        End;
        126..145:
          FontP^.SetColor(Random(255));
        146..210: Begin
          Dec(DThX, 2); Inc(DThX2, 2);
          FontP^.SetColor(255);
        End;
        211..287: Begin
          Inc(GSY, 2); Dec(GSY2, 2);
          FontP^.SetColor(0);
        End;
        288..307:
          FontP^.SetColor(255);
        308..500: Begin
          Inc(GSY, 2); Dec(GSY2, 2);
          FontP^.SetColor(0);
        End;
      End;

      FontP^.PrintXY('THANK YOU', DThX, 1);
      FontP^.PrintXY('DRAGONFLY', DThX2, 194);
      For GSI:= 1 To Length(GSOS) Do Begin
          FontP^.PrintXY(GSOS[GSI], 1, GSY + GSI * 7);
      End;
      For GSI:= 1 To Length(GSOS2) Do Begin
          FontP^.PrintXY(GSOS2[GSI], 314, GSY2 + GSI * 7);
      End;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      Case II Of
      {  330..393:
          If Not GScrP^.FPalP^.ChangeBr(1) Then GScrP^.FPalP^.Apply;
        394..457: If Not GScrP^.FPalP^.FadeTo(BPalP, -1) Then GScrP^.FPalP^.Apply;}
        {458..521: If Not GScrP^.FPalP^.ChangeBr(-1) Then GScrP^.FPalP^.Apply;}
        388..451: If Not GScrP^.FPalP^.ChangeBr(-1) Then GScrP^.FPalP^.Apply;
      End;



      If II = 452 Then Break;

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene5:= I;
    Dispose(B1P, Destroy);
    Dispose(B2P, Destroy);
    Dispose(F1P, Destroy);
    Dispose(Sky, Destroy);
    Dispose(ScP, Destroy);
    Dispose(DFly, Destroy);
    Dispose(Luna, Destroy);
    Dispose(Neuro, Destroy);
    Dispose(Bus, Destroy);
    Dispose(Pencil, Destroy);
    Dispose(Canv, Destroy);
    Dispose(Lamp, Destroy);
    Dispose(BPalP, Destroy);
End;

Function Scene4(AI: Word): Word;
Var
    I, II: Word;
    B1P, B2P, F1P, F2P, Sky, RobTab, RobCanv, L1, L2, L3, Light, Job: TImageP;
    Win1_1, Win1_2, Win2_1, Win2_2: TImageP;
    OctW, CinTab, PSPB, PSPR, AJS, Que: TAnimP;
    Thief, CCher: TAnimP;
    BPalP: TPaletteP;
    ScP, FScP: TSceneP;
    LI, PC: Integer;
    FCol, SCol: Byte;
    FXP, FYP, FXP2, FXS: Integer;
    GSStr: String;
Const
    BSpeed = 10;
Begin
    I:= AI;
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(BPalP, LoadFromLPF('pal.lpf'));
    New(B1P, LoadFromRes(ResP, 'st4_1b.lgf'));
    New(B2P, LoadFromRes(ResP, 'st4_2b.lgf'));
    New(F1P, LoadFromRes(ResP, 'st4_1f.lgf'));
    New(F2P, LoadFromRes(ResP, 'st4_2f.lgf'));
    New(Sky, LoadFromRes(ResP, 'sky1.lgf'));
    New(RobTab, LoadFromRes(ResP, 'robtab1.lgf'));
    New(RobCanv, Create(OT_Img, RobTab^.Width, RobTab^.Height));
    New(L1, LoadFromRes(ResP, 'light1.lgf'));
    New(L2, LoadFromRes(ResP, 'light2.lgf'));
    New(L3, LoadFromRes(ResP, 'light3.lgf'));
    New(OctW, LoadFromRes(ResP, 'octw', '.lgf', 11));
    New(CinTab, LoadFromRes(ResP, 'cintab', '.lgf', 5));
    New(PSPB, LoadFromRes(ResP, 'pspb', '.lgf', 4));
    New(PSPR, LoadFromRes(ResP, 'pspr', '.lgf', 4));
    New(Thief, LoadFromRes(ResP, 'thief', '.lgf', 12));
    New(CCher, LoadFromRes(ResP, 'ccher', '.lgf', 16));
    New(AJS, LoadFromRes(ResP, 'ajs', '.lgf', 2));
    New(Que, LoadFromRes(ResP, 'ques', '.lgf', 4));
    New(Win1_1, LoadFromRes(ResP, 'win1_1.lgf'));
    New(Win1_2, LoadFromRes(ResP, 'win1_1.lgf'));
    New(Win2_1, LoadFromRes(ResP, 'win2_1.lgf'));
    New(Win2_2, LoadFromRes(ResP, 'win2_1.lgf'));
    New(Job, LoadFromRes(ResP, 'needjob.lgf'));
    New(ScP, Create(8)); New(FScP, Create(8));
    DestroyRes(ResP);

    Light:= L1; L2^.MoveTo(0, 120); L3^.MoveTo(0, 120);
    B1P^.MoveTo(0, -80); B2P^.MoveTo(320, -80); F1P^.MoveTo(0, 0);
    F2P^.MoveTo(320, 0);
    OctW^.MoveTo(20, 150);
    Thief^.MoveTo(620, 135); CCher^.MoveTo(600, 135);
    AJS^.MoveTo(395, 135); Job^.MoveTo(418, 159);
    RobCanv^.Fill(0); RobTab^.MoveTo(0, RobCanv^.Height + 1);
    Light^.MoveTo(0, 120); Que^.MoveTo(443, 141);
    OctW^.SetAllFrameDelay(2); CinTab^.SetAllFrameDelay(5);
    PSPR^.SetAllFrameDelay(1); PSPB^.SetAllFrameDelay(1);
    Que^.SetAllFrameDelay(2); Que^.SetFrameDelay(1, 100);
    AJS^.SetAllFrameDelay(10);
    PSPR^.MoveTo(170, 115); PSPB^.MoveTo(190, 125);
    Win1_1^.MoveTo(153, 32); Win1_2^.MoveTo(101, 75);
    Win2_1^.MoveTo(250, 25); Win2_2^.MoveTo(370, 69);
    ScP^.Add(B1P); ScP^.Add(B2P);
    FScP^.Add(F1P); FScP^.Add(F2P); FScP^.Add(Win1_1); FScP^.Add(Win1_2);
    FScP^.Add(Win2_1); FScP^.Add(Win2_2); FScP^.Add(AJS);

    Thief^.Hide; CCher^.Hide; AJS^.Hide; PSPR^.Hide; PSPB^.Hide;
    Sky^.MoveTo(0, 0);
    II:= 1; PC:= 1;
    FXP:= 500; FXP2:= -180; FYP:= 190; FXS:= 3;
    GSStr:= 'GODSENTINPIECES';
    GScrP^.FPalP^.Fill(0, 256, 0, 0, 0); GScrP^.FPalP^.Apply;

    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ContinueSound;
    ST:= 0; NGT:= ReadMS;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      ScP^.Move(-Integer(II Mod BSpeed = 0) * Byte(F2P^.XP <> 0), 0);
      FScP^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0), 0);
      RobCanv^.MoveTo(F1P^.XP + 284, F1P^.YP + 97);
      CinTab^.MoveTo(F2P^.XP + 157, F2P^.YP + 82);
      Sky^.Move(-ShortInt(II Mod 3 = 0), 0);
      Sky^.Draw;
      Sky^.Move(320, 0);
      Sky^.Draw;
      Sky^.Move(-320, 0);
      If Sky^.XP = -320 Then Sky^.MoveTo(0, 0);
      ScP^.Draw;
      FScP^.Draw;
      Case II Mod 240 Of
        0..59: Light:= L1;
        60..119: Light:= L2;
        120..179: Light:= L3;
        180..209: Light:= L1;
        210..239: Light:= L2;
        {240..299: Light:= L3; }
      End;
      If II Mod 2 = 0 Then Win1_1^.Show Else Win1_1^.Hide;
      If II Mod 15 < 5 Then Win2_2^.Show Else Win2_2^.Hide;
      If II Mod 4 = 0 Then PC:= -PC;
      PSPR^.Move(-Integer(II Mod 2 = 0) + PC * Byte(II Mod 2 = 0), PC * Byte(II Mod 2 = 0));
      PSPB^.Move(-Integer(II Mod 2 = 0) + PC * Byte(II Mod 2 = 0), PC * Byte(II Mod 2 = 0));
      PSPR^.Draw; PSPB^.Draw;
      If PSPR^.IsResizeDone(50, 50) Then PSPR^.Trans^.Draw;
      If PSPB^.IsResizeDone(50, 50) Then PSPB^.Trans^.Draw;
      If AJS^.IsResizeDone(70, 70) Then AJS^.Trans^.Draw;
      AJS^.Draw;
      Job^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0), 0); Job^.Draw;
      Que^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0), 0); Que^.Draw;

      RobTab^.DrawOn(RobCanv);
      RobCanv^.Draw;
      If (II >= 220) And (II Mod 7 = 0) And (RobTab^.YP <> 0) Then RobTab^.Move(0, -1);
      If II Mod 25 = 0 Then Begin
          FCol:= Random(255); SCol:= Random(255);
      End;
      FontP^.SetColor(FCol);
      If II < 850 Then Begin
          FontP^.PrintXY('Cupcakes the movie', F2P^.XP + 174, F2P^.YP + 89);
          FontP^.PrintXY('tonight', F2P^.XP + 194, F2P^.YP + 96);
      End
      Else Begin
          FontP^.PrintXY('Molestia big porn-set', F2P^.XP + 169, F2P^.YP + 89);
          FontP^.PrintXY('tommorow night', F2P^.XP + 189, F2P^.YP + 96);
      End;

      FontP^.SetColor(SCol);
      FontP^.PrintXY('FREE RAM: ' + IntToStr(MemAvail Div 1024) + 'KB',
        F2P^.XP + 169, F2P^.YP + 105);
      CinTab^.Draw;
      If F2P^.XP = 0 Then OctW^.Move(Integer(II Mod 2 = 0), 0);

      CCher^.Move(-3, 0); CCher^.Draw;
      Thief^.Move(-4, 0); Thief^.Draw;
      If Thief^.IsResizeDone(75, 75) Then Thief^.Trans^.Draw;
      If CCher^.IsResizeDone(75, 75) Then CCher^.Trans^.Draw;
      OctW^.Draw;

      L1^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0) * 2, 0);
      L2^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0) * 2, 0);
      L3^.Move(-Integer(II Mod 2 = 0) * Byte(F2P^.XP <> 0) * 2, 0);
      For LI:= 1 To 10 Do Begin
          Light^.Draw; Light^.Move(160, 0);
      End;
      Light^.Move(-160 * 10, 0);

      FontP^.SetColor(0);
      Dec(FXP, FXS); Inc(FXP2, FXS);
      If (II >= 128) And (II <= 145) Then Begin
        FXS:= 0; FontP^.SetColor(255);
      End Else FXS:= 3;
      If II > 260 Then FontP^.PrintXY(GSStr[(II - 260) Div 40], 314, 194);

      FontP^.PrintXY('GOD SENT', FXP, FYP);
      FontP^.PrintXY('DISEASES', 300 - FXP, FYP);

      FontP^.SetColor(255);
      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I) + '_' + IntToStr(II), 10, 20);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      If II < 90 Then Begin
        If Not GScrP^.FPalP^.FadeTo(BPalP, 1) Then
          GScrP^.FPalP^.Apply;
      End
      Else If II > 900 Then Begin
        If Not GScrP^.FPalP^.ChangeBr(1) Then
          GScrP^.FPalP^.Apply
        Else
          Break;
      End;

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene4:= I;

    Dispose(B1P, Destroy);
    Dispose(B2P, Destroy);
    Dispose(F1P, Destroy);
    Dispose(F2P, Destroy);
    Dispose(Sky, Destroy);
    Dispose(OctW, Destroy);
    Dispose(PSPR, Destroy);
    Dispose(PSPB, Destroy);
    Dispose(Thief, Destroy);
    Dispose(CCher, Destroy);
    Dispose(CinTab, Destroy);
    Dispose(RobTab, Destroy);
    Dispose(RobCanv, Destroy);
    Dispose(L1, Destroy);
    Dispose(L2, Destroy);
    Dispose(L3, Destroy);
    Dispose(BPalP, Destroy);
    Dispose(Win1_1, Destroy);
    Dispose(Win1_2, Destroy);
    Dispose(Win2_1, Destroy);
    Dispose(Win2_2, Destroy);
    Dispose(Que, Destroy);
    Dispose(Job, Destroy);
    Dispose(AJS, Destroy);
    Dispose(ScP, Destroy);
    Dispose(FScP, Destroy);
End;

Function Scene3(AI: Word): Word;
Var
    I, II: Word;
    B1P, B2P, P1, P2, P3, P4: TImageP;
    DW, AJD: TAnimP;
    BPalP: TPaletteP;
    ScP: TSceneP;
Begin
    I:= AI;
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(B1P, LoadFromRes(ResP, 'st3_01.lgf'));
    New(B2P, LoadFromRes(ResP, 'st3_02.lgf'));
    New(DW, LoadFromRes(ResP, 'discw', '.lgf', 10));
    New(AJD, LoadFromRes(ResP, 'ajd', '.lgf', 17));
    New(P1, Create(OT_Img, 160, 100));
    New(P2, Create(OT_Img, 160, 100));
    New(P3, Create(OT_Img, 160, 100));
    New(P4, Create(OT_Img, 160, 100));
    New(ScP, Create(4));
    New(BPalP, LoadFromLPF('pal.lpf'));
    DestroyRes(ResP);
    B1P^.MoveTo(-160, 0); B2P^.MoveTo(80, 0);
    P1^.GetFrom(B1P, 0, 0, 160, 100, 0, 0);
    P2^.GetFrom(B1P, 160, 0, 80, 100, 0, 0);
    P2^.GetFrom(B2P, 0, 0, 80, 100, 80, 0);
    P3^.GetFrom(B1P, 0, 100, 160, 100, 0, 0);
    P4^.GetFrom(B1P, 160, 100, 80, 100, 0, 0);
    P4^.GetFrom(B2P, 0, 100, 80, 100, 80, 0);
    P1^.MoveTo(0, 0); P2^.MoveTo(160, 0);
    P3^.MoveTo(0, 100); P4^.MoveTo(160, 100);
    AJD^.MoveTo(80, 120); AJD^.SetAllFrameDelay(3);
    AJD^.SetFrameDelay(17, 1000);
    ScP^.Add(B1P); ScP^.Add(B2P); ScP^.Add(AJD);
    DW^.MoveTo(-80, 35); DW^.SetAllFrameDelay(1);

    II:= 1; GScrP^.FPalP^.Fill(0, 256, 0, 0, 0); GScrP^.FPalP^.Apply;

    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ST:= 0; NGT:= ReadMS;
    ContinueSound;
    While True Do Begin
      GetMouseState(MouS);
      Inc(II);
      GScrP^.Fill(0);
      If II <= 40 Then Begin
        ScP^.Move(4, 0);
        ScP^.Draw;
      End
      Else Begin
        P1^.Draw; P2^.Draw; P3^.Draw; P4^.Draw;
        AJD^.Draw;
        P1^.Move(-1, -1); P2^.Move(1, -1);
        P3^.Move(-1, 1); P4^.Move(1, 1);
      End;

      DW^.Move(4, 0);
      DW^.Draw;
      If DW^.XP >= 320 Then Begin
        If GScrP^.FPalP^.ChangeBr(-2) Then
          Break
        Else
          GScrP^.FPalP^.Apply;
      End
      Else
        If Not GScrP^.FPalP^.FadeTo(BPalP, 2) Then
          GScrP^.FPalP^.Apply;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I), 10, 20);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Scene3:= I;
    Dispose(B1P, Destroy);
    Dispose(B2P, Destroy);
    Dispose(P1, Destroy);
    Dispose(P2, Destroy);
    Dispose(P3, Destroy);
    Dispose(P4, Destroy);
    Dispose(AJD, Destroy);
    Dispose(ScP, Destroy);
    Dispose(DW, Destroy);
    Dispose(BPalP, Destroy);
End;

Function Scene2(AI: Word): Word;
Var
    B1P, B2P, B3P, B4P: TImageP;
    GTS, Spike, Lyra, BnBn, Octs: TAnimP;
    ScP: TSceneP;
    I, II: Word;
    LBS, LBD: Integer;
    BPalP: TPaletteP;
Begin
    I:= AI;
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(B1P, LoadFromRes(ResP, 'st2_01.lgf'));
    New(B2P, LoadFromRes(ResP, 'st2_02.lgf'));
    New(B3P, LoadFromRes(ResP, 'st2_03.lgf'));
    New(B4P, LoadFromRes(ResP, 'st2_04.lgf'));
    New(GTS, LoadFromRes(ResP, 'gts', '.lgf', 18));
    New(Lyra, LoadFromRes(ResP, 'lyraw', '.lgf', 16));
    New(BnBn, LoadFromRes(ResP, 'bnbnw', '.lgf', 16));
    New(Octs, LoadFromRes(ResP, 'octs', '.lgf', 2));
    New(Spike, LoadFromRes(ResP, 'sspike', '.lgf', 8));
    New(BPalP, LoadFromLPF('pal.lpf'));
    DestroyRes(ResP);
    GTS^.SetAllFrameDelay(3); Spike^.SetAllFrameDelay(4);
    Spike^.SetFrameDelay(8, 100); Octs^.SetAllFrameDelay(20);
    Lyra^.SetFlip(True, False); BnBn^.SetFlip(True, False);
    Spike^.SetFlip(True, False); Octs^.SetFlip(True, False);
    New(ScP, Create(8));
    FontP^.SetColor(0);
    B1P^.MoveTo(0, 0); B2P^.MoveTo(260, 0);
    B3P^.MoveTo(0, 0); B4P^.MoveTo(0, 180);
    GTS^.MoveTo(260, 130); Lyra^.MoveTo(-50, 270); BnBn^.MoveTo(-65, 270);
    Spike^.MoveTo(230, 160); Octs^.MoveTo(155, 235);
    GScrP^.FPalP^.Fill(0, 256, 0, 0, 0); GScrP^.FPalP^.Apply;
    ScP^.Add(B1P); ScP^.Add(B2P); ScP^.Add(GTS); ScP^.Add(Spike);

    II:= 1;
    If (ScNum >= 1) And (ScNum < 10) Then Sleep;
    ST:= 0; NGT:= ReadMS;
    ContinueSound;
    While True Do Begin
      GetMouseState(MouS);
      Case II Of
      1..90:
      Begin
        ScP^.Move(-2, 0);
        ScP^.Draw;
        If GTS^.GetCurIndex > 17 Then GTS^.PrevFrame;
        If (II < 50) And Not GScrP^.FPalP^.FadeTo(BPalP, 2) Then;
        If II >= 50 Then If GScrP^.FPalP^.ChangeBr(2) Then Begin
          ScP^.ClearAll;
          ScP^.Add(B3P); ScP^.Add(B4P);
          II:= 90; LBD:= -1; LBS:= 180; Lyra^.Hide; BnBn^.Hide;
        End;
      End;
      91..310:
      Begin
        Inc(LBS, LBD * 2);
        If II < 170 Then Begin
            ScP^.Move(0, -2);
            Lyra^.Move(0, -2); BnBn^.Move(0, -2); Octs^.Move(0, -2);
        End;
        ScP^.Draw;
        If II Mod 5 = 0 Then LBD:= -1 Else LBD:= 0;
        Lyra^.Move(2, LBD); BnBn^.Move(2, LBD);
        Lyra^.Draw; BnBn^.Draw; Octs^.Draw;
        If Lyra^.IsResizeDone(LBS, LBS) Then;
        If BnBn^.IsResizeDone(LBS, LBS) Then;
        Lyra^.Trans^.Draw; BnBn^.Trans^.Draw;
        If (II < 150) And Not GScrP^.FPalP^.FadeTo(BPalP, -1) Then;
        If II >= 201 Then If GScrP^.FPalP^.Gray(1) Then;
        If II >=241 Then If GScrP^.FPalP^.ChangeBr(-1) Then Break;
      End
      Else
        Break;
      End;
      Inc(II);
      GScrP^.FPalP^.Apply;

      If IsDeb Then Begin
        FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
        FontP^.PrintXY('IT = ' + IntToStr(I), 10, 20);
        Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
        Mouse^.Draw;
      End;
      GScrP^.Refresh;
      If MouS.FButtons = TMB_L Then
        Break
      Else If MouS.FButtons = TMB_R Then
        GScrP^.SaveBMP(IntToStr(I) + '.bmp');

      Inc(NGT, SkipT);
      ST:= NGT - ReadMS;
      If ST >= 0 Then Delay(ST);
      Inc(I);
    End;
    Dispose(B1P, Destroy);
    Dispose(B2P, Destroy);
    Dispose(B3P, Destroy);
    Dispose(B4P, Destroy);
    Dispose(GTS, Destroy);
    Dispose(Lyra, Destroy);
    Dispose(BnBn, Destroy);
    Dispose(Octs, Destroy);
    Dispose(Spike, Destroy);
    Dispose(BPalP, Destroy);
    Dispose(ScP, Destroy);
    Scene2:= I;
End;

Function Scene1: Word;
Var
    B1P, B2P, B3P, B4P, Flower, C1P, C2P, C3P, Duck: TImageP;
    BPP, FPP, RDS, SPP, Disc: TAnimP;
    ScP: TSceneP;
    I, RI, ResC: Word;
    DR, DD: Integer;
    BPalP: TPaletteP;
Const
    ClSpeed = 8;
Begin
    PauseSound;
    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(B1P, LoadFromRes(ResP, 'st1_01.lgf'));
    New(B2P, LoadFromRes(ResP, 'st1_02.lgf'));
    New(B3P, LoadFromRes(ResP, 'st1_03.lgf'));
    New(B4P, LoadFromRes(ResP, 'st1_04.lgf'));
    New(BPP, LoadFromRes(ResP, 'bpp', '.lgf', 12));
    New(FPP, LoadFromRes(ResP, 'fpp', '.lgf', 25));
    New(RDS, LoadFromRes(ResP, 'rds', '.lgf', 4));
    New(Disc, LoadFromRes(ResP, 'disc', '.lgf', 9));
    New(SPP, LoadFromRes(ResP, 'spp', '.lgf', 5));
    New(Flower, LoadFromRes(ResP, 'flower.lgf'));
    New(C1P, LoadFromRes(ResP, 'cloud_1.lgf'));
    New(C2P, LoadFromRes(ResP, 'cloud_2.lgf'));
    New(C3P, LoadFromRes(ResP, 'cloud_3.lgf'));
    New(Duck, LoadFromRes(ResP, 'duck.lgf'));
    New(BPalP, Create);
    DestroyRes(ResP);

    New(ScP, Create(16));
    FontP^.SetColor(0);
    B1P^.MoveTo(-80, 0);
    B2P^.MoveTo(120, 0);
    B3P^.MoveTo(-80, 150);
    B4P^.MoveTo(120, 150);
    BPP^.MoveTo(330, 80);
    Duck^.MoveTo(B3P^.XP + 25, B3P^.YP + 100);
    Duck^.SetFlip(True, False);
    C1P^.MoveTo(B1P^.XP + 30, B1P^.YP + 100);
    C2P^.MoveTo(B1P^.XP + 130, B1P^.YP + 105);
    C3P^.MoveTo(B2P^.XP + 70, B2P^.YP + 110);
    If Flower^.IsResizeDone(60, 60) Then;
    Flower^.MoveTo(B3P^.XP + 115, B3P^.YP + 20);
    Flower^.Trans^.SetAutoCPos(False);

    RDS^.MoveTo(B2P^.XP + 135, B2P^.YP + 100);
    Disc^.MoveTo(180, -60);
    Disc^.SetAllFrameDelay(1);
    RDS^.SetAllFrameDelay(10);
    BPP^.SetAllFrameDelay(0);
    FPP^.SetAllFrameDelay(1);
    SPP^.SetAllFrameDelay(2);
    SPP^.SetFrameDelay(5, 1000);
    SPP^.SetFlip(True, False);


    ScP^.Add(B1P); ScP^.Add(B2P); ScP^.Add(B3P); ScP^.Add(B4P);
    ScP^.Add(C1P); ScP^.Add(C2P); ScP^.Add(C3P);
    ScP^.Add(Flower); ScP^.Add(Duck); ScP^.Add(RDS);

    BPalP^.Fill(0, 256, 0, 0, 0);
    BPalP^.Apply;
    I:= 1; ResC:= 100;
    If (ScNum >= 1) And (ScNum < 10) Then Sleep;

    ContinueSound;
    ST:= 0; NGT:= ReadMS;
    While True Do Begin
    GetMouseState(MouS);
    Case I Of
    1..100:
    Begin
        ScP^.Move(0, -1);
        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        ScP^.Draw;
        If Not BPalP^.FadeTo(GScrP^.FPalP, 1) Then BPalP^.Apply;
        If I = 100 Then Begin
           StartSound;
           DR:= -10; DD:= 1;
        End;
    End;
    101..175:
    Begin
        RI:= I - 100;

        BPP^.Move(-2, 0);
        ScP^.Move(ShortInt(RI >= 38), 0);
        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);

        ScP^.Draw;
        BPP^.Draw;
    End;
    176..206:
    Begin
        RI:= I - 175; ResC:= 100 - RI * 2 + 20;
        BPP^.Hide;
        BPP^.Draw;
        If BPP^.IsResizeDone(ResC, ResC) Then;
        If Duck^.IsRotateDone(DR) Then;

        ScP^.Move(0, RI Mod 2);
        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        BPP^.Move(-1, -1);

        ScP^.Draw;
        BPP^.Trans^.Draw;
    End;
    207..265:
    Begin
        RI:= I - 206;
        BPP^.Hide;
        BPP^.Draw;
        If BPP^.IsResizeDone(ResC, ResC) Then;
        If Duck^.IsRotateDone(DR) Then;

        ScP^.Move(RI Mod 2, 0);
        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        BPP^.Move(-1, 0);

        ScP^.Draw;
        BPP^.Trans^.Draw;
        If I = 265 Then Begin
            FPP^.MoveTo(BPP^.XP, BPP^.YP);
            ScP^.Del(Flower);
        End;
    End;
    266..312:
    Begin
        RI:= I - 265;
        FPP^.Hide;
        FPP^.Draw;
        If FPP^.IsResizeDone(ResC, ResC) Then;
        If Duck^.IsRotateDone(DR) Then;

        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        ScP^.Draw;
        FPP^.Trans^.Draw;
        If I > 286 Then Begin
            If (FPP^.GetCurIndex < 9) Or (FPP^.GetCurIndex > 19) Then
                FPP^.SetCurFrame(9);
        End;
    End;
    313..340:
    Begin
        RI:= I - 312;
        FPP^.Hide;
        FPP^.Draw;
        If FPP^.IsResizeDone(ResC, ResC) Then;
        If Duck^.IsRotateDone(DR) Then;

        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        Disc^.Move(0, 2);
        ScP^.Draw;
        FPP^.Trans^.Draw;
        Disc^.Draw;

        If (FPP^.GetCurIndex < 9) Or (FPP^.GetCurIndex > 19) Then
            FPP^.SetCurFrame(9);
        If I = 340 Then SPP^.MoveTo(FPP^.XP, FPP^.YP);
    End;
    341..373:
    Begin
        RI:= I - 340;
        SPP^.Hide;
        SPP^.Draw;
        If SPP^.IsResizeDone(ResC, ResC) Then;
        If Duck^.IsRotateDone(DR) Then;

        C1P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C2P^.Move(Byte(I Mod ClSpeed = 0), 0);
        C3P^.Move(Byte(I Mod ClSpeed = 0), 0);
        ScP^.Draw;
        SPP^.Trans^.Draw;
        Flower^.Trans^.Draw;
        Disc^.Draw;
        If GScrP^.FPalP^.ChangeBr(-2) Then;
        GScrP^.FPalP^.Apply;
    End;
    Else
        Break;
    End;
    Inc(DR, DD);
    If (DR > 9) Or (DR < -9) Then DD:= -DD;
    If IsDeb Then Begin
      FontP^.PrintXY('FPS = ' + IntToStr(GScrP^.GetFPS), 10, 10);
      FontP^.PrintXY('IT = ' + IntToStr(I), 10, 20);
      Mouse^.MoveTo(MouS.FXPos, MouS.FYPos);
      Mouse^.Draw;
    End;
    GScrP^.Refresh;
    If MouS.FButtons = TMB_L Then
      Break
    Else If MouS.FButtons = TMB_R Then
      GScrP^.SaveBMP(IntToStr(I) + '.bmp');

    Inc(NGT, SkipT);
    ST:= NGT - ReadMS;
    If ST >= 0 Then Delay(ST);
    Inc(I);
    End;

    Dispose(BPP, Destroy);
    Dispose(B1P, Destroy);
    Dispose(B2P, Destroy);
    Dispose(B3P, Destroy);
    Dispose(B4P, Destroy);
    Dispose(BPalP, Destroy);
    Dispose(Flower, Destroy);
    Dispose(FPP, Destroy);
    Dispose(SPP, Destroy);
    Dispose(RDS, Destroy);
    Dispose(Disc, Destroy);
    Dispose(C1P, Destroy);
    Dispose(C2P, Destroy);
    Dispose(C3P, Destroy);
    Dispose(Duck, Destroy);
    Dispose(ScP, Destroy);
    Scene1:= I;
End;

Procedure Init;
Begin
    IsDeb:= ParamStr(1) = 'deb';
    If StrToInt(ParamStr(2)) <> 0 Then ScNum:= StrToInt(ParamStr(2));
    GOldMem:= MemAvail;
    Set32BitDrawMode(True);
    Set32BitRefreshMode(True);
    New(GScrP, Create(False));
    New(GScrP^.FPalP, LoadFromLPF('pal.lpf'));
    New(FontP, LoadFromLFF('font5.lff'));

    CreateRes(ResP);
    OpenRF(ResP, 'ST1.LRF');
    New(Mouse, LoadFromRes(ResP, 'mouse.lgf'));
    DestroyRes(ResP);

    GScrP^.InitGM;
    New(OldPal, Create);
    OldPal^.ReadFromVGA;
    If InitMouse Then;
    SetMouseHor(0, 319);
    SetMouseVert(0, 199);
    InitMemory;
    SoundRepeat:= False;
    FS.Init('thankyou.wav', StOpenRead);
    MS.Init(FS.GetSize, FS.GetSize);
    MS.CopyFrom(FS, FS.GetSize);
    FS.Done;
    MS.Seek(0);
    If ScNum = 0 Then If InitSound(@MS) <> BSOk Then {Halt}; {!!!}
    GStartTime:= ReadMS;
    Randomize;
End;

Procedure Done;
Begin
    GScrP^.FPalP^.SetRange(0, OldPal, 0, 255);
    GScrP^.FPalP^.Apply;
    Dispose(GScrP, Destroy);
    Dispose(FontP, Destroy);
    Dispose(Mouse, Destroy);
    Dispose(OldPal, Destroy);
    GEndTime:= ReadMS;
    StopSound;
    DoneDosMem;
    InitDosMem;
    MS.Done;
    DoneMemory;
    WriteLn('Took time: ', GEndTime - GStartTime);
    WriteLn('Frames: ', IterC, '; Sec: ', IterC Div 24);
    If MemAvail <> GOldMem Then Begin
        WriteLn('Was: ', GOldMem);
        WriteLn('Now: ', MemAvail);
        WriteLn('Lost: ', GOldMem - MemAvail);
    End
    Else
        WriteLn('OK');
    ReadLn;
End;

Begin
    Init;
    Demo;
    Done;
End.