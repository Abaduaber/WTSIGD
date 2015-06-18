{$I-} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Unit LGFiles;
Interface
Uses
    LUtils, LMem, LRF, LInput;

    {*. Убрать проверку на превышение размера RLE-изображения над несжатым.
        Такое вполне допустимо.}
Type
    {Описание всех задействованых для BMP типов}
    TBMPHead = Record
        FSign: Word;
        FSize: LongInt;
        FReserved, FReserved2: Word;
        FOffs, FInfoHeadSize: LongInt;
        FWidth, FHeight: LongInt;
        FPlanes, FBPP: Word;
        FCompression, FImgSize: LongInt;
        FXRes, FYRes: LongInt;
        FColorsUsed, FColorsImp: LongInt;
    End;
    TBMPHeadP = ^TBMPHead;
    TBMPPal = Array [0..255, 0..3] Of Byte;
    TBMPPalP = ^TBMPPal;
    TBMPErr = (
        TBE_OK, TBE_NotABMPFile, TBE_ErrorReading, TBE_WrongPointer,
        TBE_DataTooBigToLoad, TBE_UnsupportedBPP, TBE_RLEUnsupported,
        TBE_WrongWidth, TBE_WrongHeight, TBE_UnableToWriteBMP,
        TBE_FileIsNotExist
    );
    TBMP = Record
        FErr: TBMPErr;
        FFD: File;
        FFName: String;
        FHead: TBMPHead;
        FPalP: TBMPPalP;
    End;
    TBMPP = ^TBMP;

    TLGFType = (
        TLGFT_Img, TLGFT_Spr, TLGFT_RLEImg, TLGFT_RLESpr
    );
    TLGFHead = Record
        FSign: LongInt;           {Сигнатура файла - его идентификатор}
        FVerLow, FVerHigh: Byte;  {Версии - старшая и младшая}
        FType: TLGFType;          {Тип - как описано в TLGFType}
        FBPP: Byte;               {Глубина цвета в битах}
        FWidth, FHeight: Word;    {Ширина и высота в пикселах}
        FWaitVal: Word;           {Значение задержки (для анимации), или ?}
        FIsPalette: Boolean;      {Есть ли палитра, если да, то после заголовка}
        FBackVal: Byte;           {Значение фонового цвета для спрайта}
        FDataSize: Word;          {Размер данных изображения (c учетом сжатия).}
        FRWord: Word;             {Зарезервировано}
    End;
    TLGFHeadP = ^TLGFHead;
    TLGFPal = Array [0..255, 0..2] Of Byte;
    TLGFPalP = ^TLGFPal;
    TLGFErr = (
        TGE_Ok, TGE_LGFNotExist, TGE_UnableToReadLGF, TGE_BadLGFFile,
        TGE_UnknownLGFVer, TGE_LGFOnly8BPP, TGE_WrongLGFWidth,
        TGE_WrongLGFHeight, TGE_BMPToLGFSpr_RLEFail, TGE_LGFNotExistInRes,
        TGE_ResFileNotExist, TGE_BMPToLGF_BMPFail
    );
    TLGF = Record
        FErr: TLGFErr;
        FBMPErr: TBMPErr; {Отображает информацию об ошибке при BMPToLGF}
        FFD: File;
        FFName: String;
        FHead: TLGFHead;
        FPalP: TLGFPalP;
        FDataP: TByteBufP;
    End;
    TLGFP = ^TLGF;

   {Заголовок шрифтового файла}
    TLFFHead = Record
        FSign: LongInt;
        FVerLow, FVerHigh: Byte;
    End;
    TLFFHeadP = ^TLFFHead;
    TLFFErr = (
        TFE_Ok, TFE_NotExist, TFE_UnableToRead, TFE_BadFile,
        TFE_UnknownVer, TFE_WrongCharWidth, TFE_WrongCharHeight,
        TFE_NotExistInRes, TFE_SrcFileNotExist, TFE_BadSrcFile,
        TFE_UnableToWrite, TFE_ResFileNotExist
    );
    TLFF = Record
        FFD: File;
        FIndex: Word;
        FErr: TLFFErr;
        FFName: String;
        FHead: TLFFHead;
        FDataP: TByteBufP;
    End;
    TLFFP = ^TLFF;
    TFontChars = Array [0..255] Of TByteBufP;
    TFontCharsP = ^TFontChars;

    {Описания палитры}
    TLPFErr = (
        TPE_Ok, TPE_LPFNotExist, TPE_NotAnLPFFile, TPE_LPFNotExistInLRF,
        TPE_BadLPF
    );
    TLPF = Record
        FErr: TLPFErr;
        FFName: String;
        FDataP: TLGFPalP;
    End;
    TLPFP = ^TLPF;

    TErrMsg = String[80];
Const
    CBMPErrMsgs: Array [0..Ord(TBE_FileIsNotExist)] Of TErrMsg = (
        'OK',
        'Specified file is not in BMP format',
        'Error via reading BMP structures. Possible file is broken.',
        'Wrong BMP data loaded in a structure',
        'BMP image data is too big to be loaded to memory',
        'Unsupported color depth (BPP) of BMP image',
        'RLE-compressed bitmaps is unsupported',
        'BMP image width must be in range [1..320]',
        'BMP image height must be in range [1..200]',
        'Unable to write BMP image. Something is gone wrong',
        'Specified file is not exist'
    );
    CLGFErrMsgs: Array [0..Ord(TGE_BMPToLGF_BMPFail)] Of TErrMsg = (
        'OK',
        'Required LGF file is not exist.',
        'Unable to read LGF file. Possibly, file is damaged.',
        'Possibly, LGF file is damaged.',
        'Unknown version of LGF file.',
        'Temporary only LGF-s of 8bit color depth supported',
        'Wrong width of LGF image. Must be in range of [1..320]',
        'Wrong height of LGF image. Must be in range of [1..200]',
        'RLE-compressed image data is bigger than uncompressed',
        'Required LGF file is not exist in LRF.',
        'Required resource file is not exist.',
        'Unable to convert BMP to LGF. Bad BMP file.'
    );
    CLFFErrMsgs: Array [0..Ord(TFE_ResFileNotExist)] Of TErrMsg = (
        'OK',
        'Required LFF file is not exist.',
        'Unable to read LFF file. Possibly, file is damaged.',
        'Possibly, file is damaged',
        'Unknown version of LFF file',
        'Wrong width of a char. Must be in range of [1..15]',
        'Wrong height of a char. Must be in range of [1..15]',
        'Required LFF file is not exist in LRF',
        'Source make-font file is not exist',
        'Possibly source make-font file is damaged',
        'Unable to write created font file.',
        'Required resource file is not exist'
    );
    CLPFErrMsgs: Array [0..Ord(TPE_BadLPF)] Of TErrMsg = (
        'OK',
        'Required LPF file is not exist',
        'Required file is not in LPF format',
        'Required LPF file is not exist in LRF',
        'Possibly, LPF file is damaged'
    );

    Procedure BMP8ToLGF(Var ALGFP: TLGFP; ABMPName, ALGFName: String;
      AType: TLGFType; AIsPal: Boolean);
    Procedure RLECompression(Var ALGFP: TLGFP; ABufP: TByteBufP);

    Procedure MakeLFF(Var ALFFP: TLFFP; ASrcName, ALFFName: String);

    Function ExtractPalFromBMP(ABMPName, ALPFName: String): TBMPErr;
    Procedure WriteDataToBMP(ABMPName: String; ADataP: TByteBufP; APalP: TLGFPalP;
      AWidth, AHeight: Word);
    Function LoadLGFFromFile(Var AImgP: TByteBufP; AHeadSize: Word; ALGFName: String): TLGFP;
    Function LoadLGFFromLRF(Var AResP: TResP; Var AImgP: TByteBufP;
      AHeadSize: Word; ALGFName: TSFName): TLGFP;
    Function DestroyLGF(ALGFP: TLGFP): TLGFP;

    Function LoadLFFFromFile(Var AFChars: TFontChars; AHeadSize: Word; ALFFName: String): TLFFP;
    Function LoadLFFFromLRF(Var AResP: TResP; Var AFChars: TFontChars;
      AHeadSize: Word; ALFFName: TSFName): TLFFP;

    Function LoadLPFFromFile(ALPFName: String): TLPFP;
    Function LoadLPFFromLRF(AResP: TResP; Var ALPFName: TSFName): TLPFP;
    Procedure BMPPalToLGFPal(Var ABMPPalP: TBMPPalP; Var ALGFPalP: TLGFPalP);
    Procedure LGFPalToBMPPal(Var ABMPPalP: TBMPPalP; Var ALGFPalP: TLGFPalP);

    Procedure ReportBMPError(Var ABMPP: TBMPP; AIsHalt: Boolean);
    Procedure ReportLGFError(Var ALGFP: TLGFP; AIsHalt: Boolean);
    Procedure ReportLPFError(Var ALPFP: TLPFP; AIsHalt: Boolean);
    Procedure ReportLFFError(Var ALFFP: TLFFP; AIsHalt: Boolean);

Implementation
Const
    CModuleName = 'LGFiles'; CModuleVer = '2.0';
    CModuleVerIntHigh = Byte(1); CModuleVerIntLow = Byte(0);
    B = 0; G = 1; R = 2; F = 3;
    CBMPSign = $4D42;
    CLGF_Id = $3E46474C;
    CLPF_Id = $3E46504C;
    CLFF_Id = $3E46464C;

    CLFF_CharMaxW = 15;
    CLFF_CharMaxH = 15;
    CLFF_CharF = Char('@');

    Procedure OpenBMP(Var ABMPP: TBMPP; AFName: String); Forward;
    Procedure SetBMPErr(Var ABMPP: TBMPP; ABool: Boolean; AErr: TBMPErr); Forward;
    Procedure SetLGFErr(Var ALGFP: TLGFP; ABool: Boolean; AErr: TLGFErr); Forward;
    Procedure SetLPFErr(Var ALPFP: TLPFP; ABool: Boolean; AErr: TLPFErr); Forward;
    Procedure SetLFFErr(Var ALFFP: TLFFP; ABool: Boolean; AErr: TLFFErr); Forward;
    Procedure CreateLGF(Var ALGFP: TLGFP; ALGFName: String); Forward;
    Procedure CreateLFF(Var ALFFP: TLFFP; ALFFName: String); Forward;
    Function IsBMP8ToLGFFailed(Var ALGFP: TLGFP; Var ABMPP: TBMPP): Boolean; Forward;
    Procedure FillBMPHeader(Var ABMPHeadP: TBMPHeadP; AWidth, AHeight: Word); Forward;
    Function CalcBMPLineSize(AWidth: Word): Word; Forward;


{Создает структуру ALGFP, загружает BMP из ABMPName и переводит его
в LGF-файл с типом, указанным в параметре AType. LGF файл сохраняется,
под именем ALGFName}
Procedure BMP8ToLGF(Var ALGFP: TLGFP; ABMPName, ALGFName: String;
AType: TLGFType; AIsPal: Boolean);
Var
    BMPP: TBMPP;
    I, RealWidth, RSize: Word;
    TempBufP: TByteBufP;
Begin
    CreateLGF(ALGFP, ALGFName);
    OpenBMP(BMPP, ABMPName);
    If IsBMP8ToLGFFailed(ALGFP, BMPP) Then Exit;
    With BMPP^ Do Begin
        SetBMPErr(BMPP, FHead.FBPP <> 8, TBE_UnsupportedBPP);
        SetBMPErr(BMPP, (FHead.FWidth < 1) Or (FHead.FWidth > 320), TBE_WrongWidth);
        SetBMPErr(BMPP, (FHead.FHeight < 1) Or (FHead.FHeight > 200), TBE_WrongHeight);
        If IsBMP8ToLGFFailed(ALGFP, BMPP) Then Exit;
    End;
    With ALGFP^.FHead Do Begin
        FSign:= CLGF_Id;
        FVerLow:= CModuleVerIntLow;
        FVerHigh:= CModuleVerIntHigh;
        FType:= AType;
        FBPP:= 8;
        FWidth:= BMPP^.FHead.FWidth;
        FHeight:= BMPP^.FHead.FHeight;
        FWaitVal:= 0; {!!! пока не используется}
        FIsPalette:= AIsPal;
        FBackVal:= 0;
        FDataSize:= 0;
        FRWord:= 0;

        Assign(BMPP^.FFD, ABMPName);
        Reset(BMPP^.FFD, 1);
        If FIsPalette Then Begin
            ALGFP^.FPalP:= SafeCreateBuf(SizeOf(ALGFP^.FPalP^));
            BMPP^.FPalP:= SafeCreateBuf(SizeOf(BMPP^.FPalP^));
            Seek(BMPP^.FFD, 54);
            BlockRead(BMPP^.FFD, BMPP^.FPalP^, 1024);
            BMPPalToLGFPal(BMPP^.FPalP, ALGFP^.FPalP);
            BMPP^.FPalP:= SafeDestroyBuf(BMPP^.FPalP);
        End;
    End;
    With ALGFP^ Do Begin
        {Создаем LGF файл.}
        Assign(FFD, ALGFName);
        ReWrite(FFD, 1);
        {Заголовок записывать пока рано - еще не знаем FDataSize}
        Seek(FFD, SizeOf(FHead));
        {Если есть, записываем палитру.}
        If FHead.FIsPalette Then Begin
            BlockWrite(FFD, FPalP^, SizeOf(FPalP^));
            FPalP:= SafeDestroyBuf(FPalP);
        End;

        {Рассчитываем реальную длину строки BMP изображения, с учетом выравнивания}
        RealWidth:= CalcBMPLineSize(FHead.FWidth);
        RSize:= RealWidth * FHead.FHeight;
        {Создаем буфер для данных LGF файла, будем работать через него}
        FDataP:= SafeCreateBuf(RSize);
        {Читаем все данные из BMP-шки за один заход.}
        Seek(BMPP^.FFD, 1078);
        BlockRead(BMPP^.FFD, FDataP^, RSize, I);
        {Проверяем, удалось ли прочитать нужное количество байт?}
        If IOResult <> 0 Then;
        SetBMPErr(BMPP, I <> RSize, TBE_ErrorReading);
        {Если нет - то выходим, установив статус ошибки}
        If IsBMP8ToLGFFailed(ALGFP, BMPP) Then Exit;
        Close(BMPP^.FFD);
        BMPP:= SafeDestroyBuf(BMPP);
        {Если все ОК, то перевернем порядок строк на прямой, чтобы
        потом сразу записать их в LGF. Перед этим выделим для временного
        буфера достаточное количество памяти}
        TempBufP:= SafeCreateBuf(FHead.FWidth * FHead.FHeight);
        For I:= 0 To FHead.FHeight - 1 Do
            MoveMem(@TempBufP^[(FHead.FHeight - I - 1) * FHead.FWidth + 1],
            @FDataP^[RealWidth * I + 1], FHead.FWidth);

        If AType In [TLGFT_Spr, TLGFT_RLESpr] Then
            {Если LGF будет спрайтом, то установим значение фона равное верхнему
            левому пикселу}
            FHead.FBackVal:= TempBufP^[1];

        If AType In [TLGFT_Img, TLGFT_Spr] Then Begin
            {Сжатие не требуется, просто запишем данные в файл}
            BlockWrite(FFD, TempBufP^, SizeOfBuf(TempBufP));
            {И не забудем обновить FDataSize в заголовке}
            FHead.FDataSize:= FHead.FWidth * FHead.FHeight;
        End
        Else Begin
            {Сожмем данные с помощью RLE алгоритма}
            RLECompression(ALGFP, TempBufP);
            {Запишем сжатое в файл}
            BlockWrite(FFD, FDataP^, FHead.FDataSize);
            FFName:= '[compress ratio: ' + IntToStr(SizeOfBuf(TempBufP)) + ' > ' +
              IntToStr(FHead.FDataSize) + ' bytes]';
        End;
        {А теперь запишем заголовок и закроем файл}
        Seek(FFD, 0);
        BlockWrite(FFD, FHead, SizeOf(FHead));
        Close(FFD);
        {Освобождаем память}
        FDataP:= SafeDestroyBuf(FDataP);
        TempBufP:= SafeDestroyBuf(TempBufP);
    End;
End;

Procedure RLECompression(Var ALGFP: TLGFP; ABufP: TByteBufP);
Var
    XI, YI, DI, TDI: Word;
    C: ShortInt;
Begin
    {Negitive C - Background, positive - image data}
    With ALGFP^.FHead Do Begin
        If FType = TLGFT_RLESpr Then Begin
            DI:= 1;
            For YI:= 1 To FHeight Do Begin
                XI:= 1;
                While XI <= FWidth Do Begin
                    C:= 0;
                    If ABufP^[(YI - 1) * FWidth + XI] = FBackVal Then Begin
                        While (XI <= FWidth) And
                        (ABufP^[(YI - 1) * FWidth + XI] = FBackVal) Do Begin
                            Dec(C); Inc(XI);
                            If C = -128 Then Begin
                                ALGFP^.FDataP^[DI]:= C; Inc(DI);
                                C:= 0;
                            End;
                        End;
                        ALGFP^.FDataP^[DI]:= C;
                        If DI + FWidth > FWidth * FHeight Then Begin
                            ALGFP^.FErr:= TGE_BMPToLGFSpr_RLEFail;
                            Exit;
                        End;
                    End
                    Else Begin
                        TDI:= DI;
                        Inc(DI);
                        While (XI <= FWidth) And
                        (ABufP^[(YI - 1) * FWidth + XI] <> FBackVal) Do Begin
                            Inc(C);
                            ALGFP^.FDataP^[DI]:= ABufP^[(YI - 1) * FWidth + XI];
                            Inc(XI); Inc(DI);
                            If C = 127 Then Begin
                                ALGFP^.FDataP^[TDI]:= C; TDI:= DI; Inc(DI);
                                C:= 0;
                            End;
                        End;
                        ALGFP^.FDataP^[TDI]:= C;
                        If DI + FWidth > FWidth * FHeight Then Begin
                            ALGFP^.FErr:= TGE_BMPToLGFSpr_RLEFail;
                            Exit;
                        End;
                        Dec(DI);
                    End;
                    Inc(DI);
                End;
            End;
            Dec(DI);
            FDataSize:= DI;
        End
        Else Begin
        End;
    End;
End;

{Создает LFF-файл с шрифтом из файла, описывающего шрифт}
Procedure MakeLFF(Var ALFFP: TLFFP; ASrcName, ALFFName: String);
Var
    SrcF: Text;
    CurWidth, CurHeight, CurNum: Byte;
    CurStr, FontName: String;
    I, II, C, DI: Word;
    TempL: LongInt;
Begin
    CreateLFF(ALFFP, ALFFName);
    SetLFFErr(ALFFP, Not IsFileExist(ASrcName), TFE_SrcFileNotExist);
    ReportLFFError(ALFFP, True);
    ALFFP^.FDataP:= SafeCreateBuf(CMaxBufSize);
    Assign(SrcF, ASrcName);
    Reset(SrcF);
    ReadLn(SrcF, FontName);
    DI:= 1;
    For C:= 0 To 255 Do With ALFFP^ Do Begin
        Read(SrcF, CurNum);
        Read(SrcF, CurWidth);
        ReadLn(SrcF, CurHeight);
        SetLFFErr(ALFFP, (IOResult <> 0) Or EOF(SrcF), TFE_BadSrcFile);
        SetLFFErr(ALFFP, (CurWidth < 1) Or (CurWidth > CLFF_CharMaxW), TFE_WrongCharWidth);
        SetLFFErr(ALFFP, (CurHeight < 1) Or (CurHeight > CLFF_CharMaxH), TFE_WrongCharHeight);
        ReportLFFError(ALFFP, True);
        FDataP^[DI]:= CurWidth; Inc(DI);
        FDataP^[DI]:= CurHeight; Inc(DI);
        For I:= 1 To CurHeight Do Begin
            ReadLn(SrcF, CurStr);
            SetLFFErr(ALFFP, (IOResult <> 0) Or EOF(SrcF), TFE_BadSrcFile);
            ReportLFFError(ALFFP, True);
            For II:= 1 To CurWidth Do Begin
                If CurStr[II] = CLFF_CharF Then
                    FDataP^[DI]:= 0
                Else
                    FDataP^[DI]:= 255;
                Inc(DI);
            End;
        End;
        Inc(FIndex);
    End;
    Close(SrcF);
    With ALFFP^ Do Begin
        FDataP:= ResizeBuf(FDataP, DI - 1);
        Assign(FFD, FFName);
        ReWrite(FFD, 1);
        TempL:= CLFF_Id;
        CurWidth:= CModuleVerIntLow;
        CurHeight:= CModuleVerIntHigh;
        BlockWrite(FFD, TempL, SizeOf(TempL));
        BlockWrite(FFD, CurWidth, SizeOf(CurWidth));
        BlockWrite(FFD, CurHeight, SizeOf(CurHeight));
        BlockWrite(FFD, FontName[0], Length(FontName) + 1);
        BlockWrite(FFD, FDataP^, SizeOfBuf(FDataP));
        FDataP:= SafeDestroyBuf(FDataP);
        Close(FFD);
        SetLFFErr(ALFFP, (IOResult <> 0), TFE_UnableToWrite);
    End;
End;

{Записывает на диск файл с именем ABMPName. Данные и палитру берет из ADataP
и APalP соответственно, длину и ширину - из параметров AWidth и AHeight}
Procedure WriteDataToBMP(ABMPName: String; ADataP: TByteBufP; APalP: TLGFPalP; AWidth, AHeight: Word);
Var
    HeadP: TBMPHeadP;
    FFD: File;
    BMPPalP: TBMPPalP;
    TempW, I: Word;
Begin
    HeadP:= SafeCreateBuf(SizeOf(HeadP^));
    BMPPalP:= SafeCreateBuf(SizeOf(BMPPalP^));
    FillBMPHeader(HeadP, AWidth, AHeight);
    LGFPalToBMPPal(BMPPalP, APalP);
    TempW:= CalcBMPLineSize(AWidth) - AWidth;
    Assign(FFD, ABMPName);
    ReWrite(FFD, 1);
    BlockWrite(FFD, HeadP^, SizeOf(HeadP^));
    BlockWrite(FFD, BMPPalP^, SizeOf(BMPPalP^));
    For I:= AHeight - 1 DownTo 0 Do Begin
        BlockWrite(FFD, ADataP^[AWidth * I + 1], AWidth);
        Seek(FFD, FileSize(FFD) + TempW);
    End;
    Close(FFD);
    BMPPalP:= SafeDestroyBuf(BMPPalP);
    HeadP:= SafeDestroyBuf(HeadP);
    If IOResult <> 0 Then Begin
        RestoreOldGM;
        LInput.RestoreOldKeybHandler;
        WriteLn(CModuleName, ': file ', ABMPName + ' - ', CBMPErrMsgs[Byte(TBE_UnableToWriteBMP)]);
        Halt;
    End;
End;

{Создает в памяти структуру, инкапсулирующую LGF. Загружает в нее содержимое
файла ALGFName, проверяет на ошибки чтения, и возвращает указатель на
структуру, с полем FErr, несущим статус ошибки. Если AImgP - nil, тогда
данные образа изображения не загружаются.}
Function LoadLGFFromFile(Var AImgP: TByteBufP; AHeadSize: Word; ALGFName: String): TLGFP;
Var
    LGFP: TLGFP;
    TempW: Word;
Begin
    {Создадим буфер в памяти для записи LGF и сразу вернем его, как результат}
    CreateLGF(LGFP, ALGFName);
    LoadLGFFromFile:= LGFP;
    {Проверка на присутствие файла, и выход, если файл не обнаружен}
    SetLGFErr(LGFP, Not IsFileExist(ALGFName), TGE_LGFNotExist);
    If LGFP^.FErr <> TGE_Ok Then Exit;
    {Откроем файл и прочитаем заголовок}
    Assign(LGFP^.FFD, ALGFName);
    Reset(LGFP^.FFD, 1);
    BlockRead(LGFP^.FFD, LGFP^.FHead, SizeOf(LGFP^.FHead), TempW);
  Repeat {Цикл-костыль, чтобы делать Break из него, в нужный момент =)}
    SetLGFErr(LGFP, TempW <> SizeOf(LGFP^.FHead), TGE_UnableToReadLGF);
    {Проверим на ошибки в заголовке}
    With LGFP^.FHead Do Begin
        SetLGFErr(LGFP, (FSign <> CLGF_Id) Or (Not (FType In [TLGFT_Img..TLGFT_RLESpr])), TGE_BadLGFFile);
        SetLGFErr(LGFP, FVerHigh > CModuleVerIntHigh, TGE_UnknownLGFVer);
        SetLGFErr(LGFP, FVerLow > CModuleVerIntLow, TGE_UnknownLGFVer);
        SetLGFErr(LGFP, FBPP <> 8, TGE_LGFOnly8BPP); {!!!}
        SetLGFErr(LGFP, (FWidth < 0) Or (FWidth > 320), TGE_WrongLGFWidth);
        SetLGFErr(LGFP, (FHeight < 0) Or (FHeight > 200), TGE_WrongLGFHeight);
        SetLGFErr(LGFP, (FDataSize < 1) Or (FDataSize > 320 * 200), TGE_BadLGFFile);
        If LGFP^.FErr <> TGE_Ok Then Break;
    End;
    With LGFP^ Do Begin
        {Если необходимо, прочитаем из файла палитру}
        If FHead.FIsPalette Then Begin
            FPalP:= SafeCreateBuf(SizeOf(FPalP^));
            BlockRead(FFD, FPalP^, SizeOf(FPalP^), TempW);
            SetLGFErr(LGFP, TempW <> SizeOf(FPalP^), TGE_BadLGFFile);
            If FErr <> TGE_Ok Then Break;
        End;
        If AImgP <> Nil Then Begin
            {Создадим буфер для данных самого изображения, и прочитаем их в него}
            AImgP:= SafeCreateBuf(AHeadSize + FHead.FDataSize);
            BlockRead(FFD, Pointer(LongInt(AImgP) + AHeadSize)^, FHead.FDataSize, TempW);
            SetLGFErr(LGFP, TempW <> FHead.FDataSize, TGE_BadLGFFile);
            If FErr <> TGE_Ok Then Break;
        End;
    End;
  Until True;
    Close(LGFP^.FFD);
End;

{Тоже, что и предыдущая функция, но файл грузится из ресурсного псевдоархива.
Псевдоархив должен быть открыт.}
Function LoadLGFFromLRF(Var AResP: TResP; Var AImgP: TByteBufP;
AHeadSize: Word; ALGFName: TSFName): TLGFP;
Var
    LGFP: TLGFP;
    TempW: Word;
Begin
    {Создадим буфер в памяти для записи LGF и сразу вернем его, как результат}
    CreateLGF(LGFP, ALGFName);
    LoadLGFFromLRF:= LGFP;
    {Проверка на присутствие файла, и выход, если файл не обнаружен}
    SetLGFErr(LGFP, FindSF(AResP, ALGFName) = 0, TGE_LGFNotExistInRes);
    If LGFP^.FErr <> TGE_Ok Then Exit;
    {Откроем файл и прочитаем заголовок}
    OpenSF(AResP, ALGFName);
    ReadSF(AResP, LGFP^.FHead, SizeOf(LGFP^.FHead));
    {Проверим на ошибки в заголовке}
    With LGFP^.FHead Do Begin
        SetLGFErr(LGFP, (FSign <> CLGF_Id) Or (Not (FType In [TLGFT_Img..TLGFT_RLESpr])), TGE_BadLGFFile);
        SetLGFErr(LGFP, FVerHigh > CModuleVerIntHigh, TGE_UnknownLGFVer);
        SetLGFErr(LGFP, FVerLow > CModuleVerIntLow, TGE_UnknownLGFVer);
        SetLGFErr(LGFP, FBPP <> 8, TGE_LGFOnly8BPP); {!!!}
        SetLGFErr(LGFP, (FWidth < 0) Or (FWidth > 320), TGE_WrongLGFWidth);
        SetLGFErr(LGFP, (FHeight < 0) Or (FHeight > 200), TGE_WrongLGFHeight);
        SetLGFErr(LGFP, (FDataSize < 1) Or (FDataSize > 320 * 200), TGE_BadLGFFile);
        If LGFP^.FErr <> TGE_Ok Then Exit;
    End;
    With LGFP^ Do Begin
        {Если необходимо, прочитаем из файла палитру}
        If FHead.FIsPalette Then Begin
            FPalP:= SafeCreateBuf(SizeOf(FPalP^));
            ReadSF(AResP, FPalP^, SizeOf(FPalP^));
            If FErr <> TGE_Ok Then Exit;
        End;
        If AImgP <> Nil Then Begin
            {Создадим буфер для данных самого изображения, и прочитаем их в него}
            AImgP:= SafeCreateBuf(AHeadSize + FHead.FDataSize);
            ReadSF(AResP, Pointer(LongInt(AImgP) + AHeadSize)^, FHead.FDataSize);
            If FErr <> TGE_Ok Then Exit;
        End;
    End;
End;

{Загружает шрифт из файла LFF}
Function LoadLFFFromFile(Var AFChars: TFontChars; AHeadSize: Word; ALFFName: String): TLFFP;
Var
    LFFP: TLFFP;
    TempW, I, II: Word;
    CurWidth, CurHeight: Byte;
Begin
    {Выделим для шрифта память}
    CreateLFF(LFFP, ALFFName);
    LoadLFFFromFile:= LFFP;
    With LFFP^ Do Begin
        {Проверка на присутствие файла, и выход, если файл не обнаружен}
        SetLFFErr(LFFP, Not IsFileExist(ALFFName), TFE_NotExist);
        If FErr <> TFE_Ok Then Exit;
        {Откроем файл и прочитаем заголовок}
      Repeat
        Assign(FFD, ALFFName);
        Reset(FFD, 1);
        BlockRead(FFD, FHead, SizeOf(FHead), TempW);
        BlockRead(FFD, FFName[0], 1);
        BlockRead(FFD, FFName[1], Byte(FFName[0]), TempW);
        SetLFFErr(LFFP, (TempW <> Byte(FFName[0])) Or (IOResult <> 0), TFE_BadFile);
        SetLFFErr(LFFP, (FHead.FSign <> CLFF_Id), TFE_BadFile);
        SetLFFErr(LFFP, FHead.FVerHigh > CModuleVerIntHigh, TFE_UnknownVer);
        SetLFFErr(LFFP, FHead.FVerLow > CModuleVerIntLow, TFE_UnknownVer);
        If LFFP^.FErr <> TFE_Ok Then Break;
        For I:= 0 To 255 Do Begin
            BlockRead(FFD, CurWidth, SizeOf(CurWidth));
            BlockRead(FFD, CurHeight, SizeOf(CurHeight));
            SetLFFErr(LFFP, (CurWidth < 1) Or (CurWidth > CLFF_CharMaxW), TFE_WrongCharWidth);
            SetLFFErr(LFFP, (CurHeight < 1) Or (CurHeight > CLFF_CharMaxH), TFE_WrongCharHeight);
            If LFFP^.FErr <> TFE_Ok Then Break;
            TempW:= Word(CurWidth) * CurHeight;
            AFChars[I]:= SafeCreateBuf(TempW + AHeadSize);
            AFChars[I]^[1]:= CurWidth; AFChars[I]^[2]:= CurHeight;
            BlockRead(FFD, AFChars[I]^[AHeadSize + 1], TempW);
            SetLFFErr(LFFP, FHead.FVerLow > CModuleVerIntLow, TFE_UnknownVer);
            If LFFP^.FErr <> TFE_Ok Then Break;
        End;
      Until True;
    End;
    Close(LFFP^.FFD);
    If IOResult <> 0 Then;
End;

{Загружает шрифт из ресурсного псевдоархива}
Function LoadLFFFromLRF(Var AResP: TResP; Var AFChars: TFontChars;
AHeadSize: Word; ALFFName: TSFName): TLFFP;
Var
    LFFP: TLFFP;
    TempW, I: Word;
    CurWidth, CurHeight: Byte;
Begin
    {Выделим для шрифта память}
    CreateLFF(LFFP, ALFFName);
    LoadLFFFromLRF:= LFFP;
    With LFFP^ Do Begin
        LFFP^.FFName:= ALFFName;
        {Проверка на присутствие файла, и выход, если файл не обнаружен}
        SetLFFErr(LFFP, FindSF(AResP, ALFFName) = 0, TFE_NotExistInRes);
        If FErr <> TFE_Ok Then Exit;
        {Откроем файл и прочитаем заголовок}
        OpenSF(AResP, ALFFName);
        ReadSF(AResP, FHead, SizeOf(FHead));
        ReadSF(AResP, FFName[0], 1);
        ReadSF(AResP, FFName[1], Byte(FFName[0]));
        SetLFFErr(LFFP, (FHead.FSign <> CLFF_Id), TFE_BadFile);
        SetLFFErr(LFFP, FHead.FVerHigh > CModuleVerIntHigh, TFE_UnknownVer);
        SetLFFErr(LFFP, FHead.FVerLow > CModuleVerIntLow, TFE_UnknownVer);
        If LFFP^.FErr <> TFE_Ok Then Exit;
        For I:= 0 To 255 Do Begin
            ReadSF(AResP, CurWidth, SizeOf(CurWidth));
            ReadSF(AResP, CurHeight, SizeOf(CurHeight));
            SetLFFErr(LFFP, (CurWidth < 1) Or (CurWidth > CLFF_CharMaxW), TFE_WrongCharWidth);
            SetLFFErr(LFFP, (CurHeight < 1) Or (CurHeight > CLFF_CharMaxH), TFE_WrongCharHeight);
            If LFFP^.FErr <> TFE_Ok Then Exit;
            TempW:= Word(CurWidth) * CurHeight;
            AFChars[I]:= SafeCreateBuf(TempW + AHeadSize);
            AFChars[I]^[1]:= CurWidth; AFChars[I]^[2]:= CurHeight;
            ReadSF(AResP, AFChars[I]^[AHeadSize + 1], TempW);
            SetLFFErr(LFFP, FHead.FVerLow > CModuleVerIntLow, TFE_UnknownVer);
            If LFFP^.FErr <> TFE_Ok Then Exit;
        End;
    End;
End;

Function LoadLPFFromFile(ALPFName: String): TLPFP;
Var
    LPFP: TLPFP;
    FD: File;
    TempL: LongInt;
Begin
    LPFP:= SafeCreateBuf(SizeOf(LPFP^));
    LoadLPFFromFile:= LPFP;
    While True Do With LPFP^ Do Begin
        FErr:= TPE_Ok;
        FFName:= ALPFName;
        FDataP:= SafeCreateBuf(SizeOf(FDataP^));
          SetLPFErr(LPFP, Not IsFileExist(ALPFName), TPE_LPFNotExist);
          If LPFP^.FErr <> TPE_Ok Then Break;
        Assign(FD, ALPFName);
        Reset(FD, 1);
          SetLPFErr(LPFP, (IOResult <> 0) Or (FileSize(FD) < SizeOf(FDataP^) + 4), TPE_BadLPF);
          If LPFP^.FErr <> TPE_Ok Then Break;
        BlockRead(FD, TempL, 4);
          SetLPFErr(LPFP, TempL <> CLPF_Id, TPE_NotAnLPFFile);
          If LPFP^.FErr <> TPE_Ok Then Break;
        BlockRead(FD, FDataP^, SizeOf(FDataP^));
        Break;
    End;
    Close(FD);
    If IOResult <> 0 Then;
End;

Function LoadLPFFromLRF(AResP: TResP; Var ALPFName: TSFName): TLPFP;
Var
    LPFP: TLPFP;
    TempL: LongInt;
Begin
    LPFP:= SafeCreateBuf(SizeOf(LPFP^));
    LoadLPFFromLRF:= LPFP;
    With LPFP^ Do Begin
        FErr:= TPE_Ok;
        FFName:= ALPFName;
        FDataP:= SafeCreateBuf(SizeOf(FDataP^));
          SetLPFErr(LPFP, FindSF(AResP, ALPFName) = 0, TPE_LPFNotExistInLRF);
          If LPFP^.FErr <> TPE_Ok Then Exit;
        OpenSF(AResP, ALPFName);
          SetLPFErr(LPFP, (LRF.GetErr(AResP) <> TRE_Ok) Or
            (SFSize(AResP) < SizeOf(FDataP^) + 4), TPE_BadLPF);
          If LPFP^.FErr <> TPE_Ok Then Exit;
        ReadSF(AResP, TempL, 4);
          SetLPFErr(LPFP, TempL <> CLPF_Id, TPE_NotAnLPFFile);
          If LPFP^.FErr <> TPE_Ok Then Exit;
        ReadSF(AResP, FDataP^, SizeOf(FDataP^));
    End;
End;

Function ExtractPalFromBMP(ABMPName, ALPFName: String): TBMPErr;
Var
    BMPP: TBMPP;
    LPFFD: File;
    LPFPalP: TLGFPalP;
    TempW: Word;
    TempL: LongInt;
Begin
    OpenBMP(BMPP, ABMPName);
    With BMPP^ Do While True Do Begin
          SetBMPErr(BMPP, FHead.FBPP <> 8, TBE_UnsupportedBPP);
          If BMPP^.FErr <> TBE_Ok Then Break;
        Assign(FFD, FFName);
        Reset(FFD, 1);
          SetBMPErr(BMPP, FileSize(FFD) < 1078, TBE_ErrorReading);
          If BMPP^.FErr <> TBE_Ok Then Break;
        FPalP:= SafeCreateBuf(SizeOf(FPalP^));
        LPFPalP:= SafeCreateBuf(SizeOf(LPFPalP^));
        Seek(FFD, 54);
        BlockRead(FFD, FPalP^, SizeOf(FPalP^), TempW);
          SetBMPErr(BMPP, TempW <> SizeOf(FPalP^), TBE_ErrorReading);
          If BMPP^.FErr <> TBE_Ok Then Break;
        BMPPalToLGFPal(FPalP, LPFPalP);
        Assign(LPFFD, ALPFName);
        ReWrite(LPFFD, 1);
        TempL:= CLPF_Id;
        BlockWrite(LPFFD, TempL, 4);
        BlockWrite(LPFFD, LPFPalP^, SizeOf(LPFPalP^));
        Close(LPFFD);
        FPalP:= SafeDestroyBuf(FPalP);
        LPFPalP:= SafeDestroyBuf(LPFPalP);
        Break;
    End;
    Close(BMPP^.FFD);
    If IOResult <> 0 Then;
    ExtractPalFromBMP:= BMPP^.FErr;
    BMPP:= SafeDestroyBuf(BMPP);
End;

Function DestroyLGF(ALGFP: TLGFP): TLGFP;
Begin
    ALGFP^.FPalP:= SafeDestroyBuf(ALGFP^.FPalP);
    ALGFP^.FDataP:= SafeDestroyBuf(ALGFP^.FDataP);
    DestroyLGF:= SafeDestroyBuf(ALGFP);
End;

{Создает в памяти структуру, инкапсулирующую LGF. Файл не создает.}
Procedure CreateLGF(Var ALGFP: TLGFP; ALGFName: String);
Begin
    ALGFP:= SafeCreateBuf(SizeOf(ALGFP^));
    With ALGFP^ Do Begin
        FErr:= TGE_Ok;
        FBMPErr:= TBE_Ok;
        FPalP:= Nil;
        FDataP:= Nil;
        FFName:= ALGFName;
    End;
End;

Procedure CreateLFF(Var ALFFP: TLFFP; ALFFName: String);
Begin
    ALFFP:= SafeCreateBuf(SizeOf(ALFFP^));
    With ALFFP^ Do Begin
        FErr:= TFE_Ok;
        FDataP:= Nil;
        FFName:= ALFFName;
        FIndex:= 0;
    End;
End;

{Выделяет память для ABMPP, открывает BMP файл с именем AFName
и читает его заголовок, сразу устанавливая код ошибки.}
Procedure OpenBMP(Var ABMPP: TBMPP; AFName: String);
Var
    RBytes: Word;
Begin
    ABMPP:= SafeCreateBuf(SizeOf(ABMPP^));
    With ABMPP^ Do Begin
        FErr:= TBE_Ok;
        FPalP:= Nil;
        SetBMPErr(ABMPP, Not IsFileExist(AFName), TBE_FileIsNotExist);
        If FErr <> TBE_Ok Then Exit;
        FFName:= AFName;
        Assign(FFD, FFName);
        Reset(FFD, 1);
        BlockRead(FFD, FHead, SizeOf(FHead), RBytes);
        If IOResult <> 0 Then;
        Close(FFD);
        SetBMPErr(ABMPP, (RBytes <> SizeOf(FHead)) Or (IOResult <> 0), TBE_ErrorReading);
        SetBMPErr(ABMPP, FHead.FSign <> CBMPSign, TBE_NotABMPFile);
        SetBMPErr(ABMPP, FHead.FCompression <> 0, TBE_RLEUnsupported);
    End;
End;

{Заполняет заголовок BMP-Файла}
Procedure FillBMPHeader(Var ABMPHeadP: TBMPHeadP; AWidth, AHeight: Word);
Var
    TempW: Word;
Begin
    TempW:= CalcBMPLineSize(AWidth);
    With ABMPHeadP^ Do Begin
        FSign:= CBMPSign;
        FSize:= 1024 + SizeOf(TBMPHead) + TempW * AHeight;
        FReserved:= 0; FReserved2:= 0;
        FOffs:= SizeOf(TBMPHead) + 1024;
        FInfoHeadSize:= 40;
        FWidth:= AWidth; FHeight:= AHeight;
        FPlanes:= 1; FBPP:= 8;
        FCompression:= 0; FImgSize:= 0;
        FXRes:= 0; FYRes:= 0;
        FColorsUsed:= 256; FColorsImp:= 0;
    End;
End;

{Конвертирует палитру BMP файла в палитру, применяемую в LGF:
на каждый цвет из палитры уходит 3 байта, сдвинутые влево}
Procedure BMPPalToLGFPal(Var ABMPPalP: TBMPPalP; Var ALGFPalP: TLGFPalP);
Var
    I: Integer;
Begin
    For I:= 0 To 255 Do Begin
        ALGFPalP^[I, R]:= ABMPPalP^[I, B] Shr 2;
        ALGFPalP^[I, G]:= ABMPPalP^[I, G] Shr 2;
        ALGFPalP^[I, B]:= ABMPPalP^[I, R] Shr 2;
    End;
End;

{Конвертирует палитру LGF файда в палитру, применяемую в BMP}
Procedure LGFPalToBMPPal(Var ABMPPalP: TBMPPalP; Var ALGFPalP: TLGFPalP);
Var
    I: Integer;
Begin
    For I:= 0 To 255 Do Begin
        ABMPPalP^[I, R]:= ALGFPalP^[I, B] Shl 2;
        ABMPPalP^[I, G]:= ALGFPalP^[I, G] Shl 2;
        ABMPPalP^[I, B]:= ALGFPalP^[I, R] Shl 2;
        ABMPPalP^[I, F]:= 0;
    End;
End;

{Возвращает реальную длину скан-линии BMP файла в байтах, с учетом выравн.}
Function CalcBMPLineSize(AWidth: Word): Word;
Var
    TempW: Word;
Begin
    TempW:= 4 - (AWidth Mod 4);
    If TempW = 4 Then TempW:= 0;
    Inc(TempW, AWidth);
    CalcBMPLineSize:= TempW;
End;

{Делает проверки, и записывает статус ошибки BMP в ALGFP}
Function IsBMP8ToLGFFailed(Var ALGFP: TLGFP; Var ABMPP: TBMPP): Boolean;
Begin
    If ABMPP^.FErr <> TBE_Ok Then Begin
        ALGFP^.FBMPErr:= ABMPP^.FErr;
        ALGFP^.FErr:= TGE_BMPToLGF_BMPFail;
        Close(ABMPP^.FFD);
        If IOResult <> 0 Then;
        ABMPP^.FPalP:= SafeDestroyBuf(ABMPP^.FPalP);
        ALGFP^.FDataP:= SafeDestroyBuf(ALGFP^.FDataP);
        ALGFP^.FPalP:= SafeDestroyBuf(ALGFP^.FPalP);
        ABMPP:= SafeDestroyBuf(ABMPP);
        IsBMP8ToLGFFailed:= True;
    End
    Else
        IsBMP8ToLGFFailed:= False;
End;

Procedure SetBMPErr(Var ABMPP: TBMPP; ABool: Boolean; AErr: TBMPErr);
Begin
    If ABool And (ABMPP^.FErr = TBE_Ok) Then ABMPP^.FErr:= AErr;
End;

Procedure SetLGFErr(Var ALGFP: TLGFP; ABool: Boolean; AErr: TLGFErr);
Begin
    If IOResult <> 0 Then;
    If ABool And (ALGFP^.FErr = TGE_Ok) Then ALGFP^.FErr:= AErr;
End;

Procedure SetLFFErr(Var ALFFP: TLFFP; ABool: Boolean; AErr: TLFFErr);
Begin
    If IOResult <> 0 Then;
    If ABool And (ALFFP^.FErr = TFE_Ok) Then ALFFP^.FErr:= AErr;
End;

Procedure SetLPFErr(Var ALPFP: TLPFP; ABool: Boolean; AErr: TLPFErr);
Begin
    If ABool And (ALPFP^.FErr = TPE_Ok) Then ALPFP^.FErr:= AErr;
End;

Procedure ReportBMPError(Var ABMPP: TBMPP; AIsHalt: Boolean);
Begin
    If ABMPP^.FErr = TBE_Ok Then Exit;
    RestoreOldGM;
    LInput.RestoreOldKeybHandler;
    WriteLn(CModuleName, ': file ', ABMPP^.FFName + ' - ', CBMPErrMsgs[Byte(ABMPP^.FErr)]);
    If AIsHalt Then Begin
        ReadLn;
        Halt(Byte(ABMPP^.FErr));
    End;
End;

Procedure ReportLGFError(Var ALGFP: TLGFP; AIsHalt: Boolean);
Begin
    If ALGFP^.FErr = TGE_Ok Then Exit;
    RestoreOldGM;
    LInput.RestoreOldKeybHandler;
    WriteLn(CModuleName, ': file ', ALGFP^.FFName + ' - ', CLGFErrMsgs[Byte(ALGFP^.FErr)]);
    If AIsHalt Then Begin
        ReadLn;
        Halt(Byte(ALGFP^.FErr));
    End;
End;

Procedure ReportLFFError(Var ALFFP: TLFFP; AIsHalt: Boolean);
Begin
    If ALFFP^.FErr = TFE_Ok Then Exit;
    RestoreOldGM;
    LInput.RestoreOldKeybHandler;
    WriteLn(CModuleName, ': file ', ALFFP^.FFName + ' - ', CLFFErrMsgs[Byte(ALFFP^.FErr)]);
    If ALFFP^.FErr = TFE_BadSrcFile Then WriteLn('Char index: ', ALFFP^.FIndex);
    If AIsHalt Then Begin
        ReadLn;
        Halt(Byte(ALFFP^.FErr));
    End;
End;

Procedure ReportLPFError(Var ALPFP: TLPFP; AIsHalt: Boolean);
Begin
    If ALPFP^.FErr = TPE_Ok Then Exit;
    RestoreOldGM;
    LInput.RestoreOldKeybHandler;
    WriteLn(CModuleName, ': file ', ALPFP^.FFName + ' - ', CLPFErrMsgs[Byte(ALPFP^.FErr)]);
    If AIsHalt Then Begin
        ReadLn;
        Halt(Byte(ALPFP^.FErr));
    End;
End;

End.