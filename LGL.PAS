{$I+} {$A+} {$R-} {$S-} {$Q-} {$G+} {$N+} {$E-} {$D+} {$L-} {$Y-} {$X-}
Unit LGL;
Interface
Uses
    LMem, LUtils, LGFiles, LRF, LInput;
Type
    {Tips:
        * Не забывать в процедурах, которые используют цепочные команды пересылки
          вбивать команды CLD
        * При финальных билдах выпилить ключи $D+ и любые другие
        * Выравнивание данных по границе хотя-бы слова таки имеет смысл
        * Можно подумать о создании общего служебного буфера TImg с размером
          в 64Кб
        * Перед релизом вбить поиск по символу {, чтобы отловить все оставшиеся
          комментарии, и выпилить из кода говно.
        * Переписать GrayPal или просто убрать ее из релиза;

        Шрифтам добавить возможность выводить строку с переносами. Тогда просто
        строка выводится начиная с указанных координат, до тех пор, пока есть
        возможность вместить хотя-бы еще один символ. как только символов
        в строку больше не влазит, идет переход на новую строку, и символы
        снова выводятся до упора. Если эта функция, то будет разумно вернуть
        количество реально выведенных символов.

        Добавить поддержку независимого указателя мыши. Он может рисоваться
        напрямую в видеопамять с помощью специальной процедуры и очень часто.
    }

    {TObjType отображает тип объекта}
    TObjType = (OT_ScrBuf, OT_Img, OT_Spr, OT_RLEImg, OT_RLESpr, OT_FontSpr);
    {TImg служит для хранения информации о изображении. После данных записи
    идут данные самого изображения}
    TImg = Record
        FObjType: TObjType;
        FReserved: Byte;
        FImgSize: Word;
        FWidth, FHeight: Word;
        FIsHorFlip, FIsVertFlip: Boolean;
    End;
    TImgP = ^TImg;

    {TFont служит для хранения информации о шрифте}
    TFnt = Record
        FFP: TLFFP;
        FFontName: String;
        FChars: TFontChars;
        FCharInterval: Byte;
    End;
    TFntP = ^TFnt;

    {Указатели на палитру, только-то}
    TPal = TLGFPal;
    TPalP = TLGFPalP;

    {Процедурные типы для вспомогательных процедур}
    TRefreshScrProc = Procedure(AImgP: TImgP);
    TFillImgProc = Procedure(AImgP: TImgP; AColor: Byte);
    TVertFlipImgProc = Procedure(AImgP: TImgP);
    TCopyImgProc = Procedure(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
       ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer);
    TDrawImgCropProc = Procedure(ADstImgP, ASrcImgP: TImgP; AXLMod,
        AXRMod: Integer; AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);

    {------Процедуры для работы с палитрой--------}
    {Выделяет память для палитры, и загружает ее из файла LPF}
    Function LoadPalFromLPF(ALPFName: String): TPalP;
    {Выделяет память для палитры, и загружает ее из ресурсного псевдоархива}
    Function LoadPalFromRes(Var AResP: TResP; ALPFName: TSFName): TPalP;
    {Выделяет память для палитры, и грузить ее из LGF-файла, лежащего в псевдоархиве}
    Function LoadPalFromLGFInRes(Var AResP: TResP; ALGFName: TSFName): TPalP;
    {Выделяет память для палитры, и загружает ее из LGF-файла}
    Function LoadPalFromLGF(ALGFName: String): TPalP;
    {Устанавливает палитру APalP}
    Procedure ApplyPal(APalP: TPalP);
    {Выделяет память для палитры и загружает ее из регистров VGA адаптера}
    Function ReadVGAPal: TPalP;
    {Устанавливает в палитре APalP цвет AI}
    Procedure SetColorInPal(APalP: TPalP; AI, AR, AG, AB: Byte);
    {Начиная с цвета AFrom, устанавливает в ADstPalP количество цветов
    ACount + 1, делая их аналогичными цветам в ASrcPalP}
    Procedure SetRangeInPal(ADstPalP: TPalP; ADstFrom: Byte; ASrcPalP: TPalP;
      ASrcFrom, ACount: Byte);
    {Изменяет яркость палитры на указанный в AStep шаг, возвращает True,
    если все палитра уже установлена на максимальную\минимальную яркость}
    Function ChangePalBr(APalP: TPalP; AStep: ShortInt): Boolean;
    {Приводит палитру ADstPal к палитре ASrcPal, используя шаг AStep.
    Возвращает True, если палитра после отработки функции уже идентичны}
    Function FadePal(ADstPalP, ASrcPalP: TPalP; AStep: ShortInt): Boolean;
    {Приводит палитру APalP к черно-белому (Grayscale) виду, с шагом AStep}
    Function GrayPal(APalP: TPalP; AStep: ShortInt): Boolean;

    {------Простая графика------}
    {Устаналивает на изображении ADstImgP по координатам AX и AY точку}
    Procedure PSet(ADstImgP: TImgP; AXPos, AYPos: Word; AC: Byte);
    {Выводит на изображении ADstImgP линию проходящую с позиции AXPos, AYPos
     по AEXPos, AEYPos с цветом AC}
    Procedure Line(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
    {Выводит прямоугольник}
    Procedure Box(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
    {Выводит закрашенный цветом AC прямоугольник}
    Procedure FillBox(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);

    {------Трансформации------}
    {Масштабирует изображение ASrcImgP до размеров ADstImgP}
    Procedure ResizeImg(ADstImgP, ASrcImgP: TImgP);
    {Поворачивает изображение ASrcImgP на угол Alpha, и сохраняет в ADstImgP}
    Procedure RotateImg(ADstImgP, ASrcImgP: TImgP; Alpha: Integer);

    {------Прочие процедуры--------}
    {Устанавливает режим работы функций библиотеки (16-32 bit)}
    Procedure Set32BitDraw(AIs32Bit: Boolean);
    {Устанавливает режим вывода буфера в видеопамять (16-32 bit)}
    Procedure Set32BitRefresh(AIs32Bit: Boolean);

    {Вызывает DrawOn(GCurBufP, AImgP, AXPos, AYPos)}
    Procedure Draw(AImgP: TImgP; AXPos, AYPos: Integer);
    {Выполняет проверки, и выбирает подходящую процедуру для вывода изображения}
    Procedure DrawOn(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer);
    {Вызывает DrawCropOn(GCurBufP, ASrcImgP, AXLMod...)}
    Procedure DrawCrop(ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);
    {Выполняет проверки, и выбирает подходящую процедуру для вывода
    изображения с отсечением}
    Procedure DrawCropOn(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);

    {Делает проверки, и в зависимости от входных параметров, вызывает
    нужную функцию копирования части изображения}
    Procedure CopyImg(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
       ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer);

    {Устанавливает флаги флипа, и делает физический флип при необходимости}
    Procedure SetImgFlip(Var AImgP: TImgP; AIsHorFlip, AIsVertFlip: Boolean);

    {Печатает текст AStr используя шрифт AFontP цветом AC по координатам AXPos, AYPos}
    Procedure PrintXY(AFontP: TFntP; AXPos, AYPos: Integer; AC: Byte; AStr: String);
    {Печатает текст AStr на изображении ADstImgP}
    Procedure PrintXYOn(ADstImgP: TImgP; AFontP: TFntP; AXPos, AYPos: Integer;
      AC: Byte; AStr: String);
    {Считает, сколько пикселей в длину и высоту будет занимать печать
     строки AStr и возвращает длину в AWidth и высоту в AHeight}
    Procedure CalcFontStrSize(AFontP: TFntP; AStr: String;
      Var AWidth: Integer; Var AHeight: Integer);

    {Создает в памяти экранный буфер и возвращает указатель на него}
    Function InitScr: TImgP;
    {Перезначает текущий экранный буфер на AImgP}
    Procedure SetScr(AImgP: TImgP);
    {Сохраняет содержимое текущего объекта в BMP-формат. В качестве
    палитры записывается текущая установленная палитра
    RLE-объекты не сохраняет}
    Procedure SaveAsBMP(Var AImgP: TImgP; ABMPName: String);
    {Создает в памяти объект с указанным типом}
    Function Create(AObjType: TObjType; AXSize, AYSize: Word): TImgP;
    {Выделяет память для структур объекта и загружает их из LGF-файла}
    Function LoadFromLGF(ALGFName: String): TImgP;
    {Загружает объект из ресурсного псевдоархива}
    Function LoadFromRes(Var AResP: TResP; ALGFName: TSFName): TImgP;
    {Выделяет память для структуры шрифта и загружает его из LFF}
    Function LoadFromLFF(ALFFName: String): TFntP;
    {Загружает шрифт из LRF-файла}
    Function LoadFontFromRes(Var AResP: TResP; ALFFName: TSFName): TFntP;
    {Уничтожает объект}
    Function Destroy(AImgP: TImgP): TImgP;
    {Уничтожает шрифт}
    Function DestroyFont(AFontP: TFntP): TFntP;
    {Возвращает указатель на данные AImgP}
    Function GetImgDataP(AImgP: TImgP): Pointer;

    {Ожидает обратного вертикального хода луча}
    Procedure WaitR;
    {Устанавливает экранный режим 320x200x256}
    Procedure InitGM;
    {Обновляет видеопамять содержимым из текущего экранного буфера}
    Procedure RefreshScr(AImgP: TImgP);
    {Восстанавливает старый экранный режим, номер которого сохранен в GOldGMNum}
    Procedure CloseGM;
    {Возвращает текущий FPS (значение обновляется раз в секунду)}
    Function GetFPS: Word;

Const
    CImgHeadSize = SizeOf(TImg);
    CMaxImgXSize = 320; CMaxImgYSize = 200;
Var
    {Указатель на процедуру обновления экрана}
    RefreshScrProc: TRefreshScrProc;
    {Указатель на процедуры заполнения изображения}
    FillImg: TFillImgProc;

Implementation
Type
    {Тип сообщения об ошибке}
    TErrMsg = String[80];
    {Типы ошибок}
    TErr = (
        TE_OK, TE_UnableToCreateImg, TE_WrongPaletteRange, TE_WrongDrawDest,
        TE_WrongCopySrc, TE_WrongCopyPos, TE_UnknownDrawDest,
        TE_LGFWithoutPal, TE_DestIsNil, TE_SrcIsNil, TE_VGAIsNotPresent
    );

    TDrawImgProc = Procedure(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer);
    TVertFlipProc = Procedure(AImgP: TImgP);
Const
    {Константы имени и версии модуля}
    CModuleName = 'LGL'; CModuleVer = '2.0';
    {Текстовые константы сообщений об ошибках}
    CErrMsgs: Array [0..Ord(TE_VGAIsNotPresent)] Of TErrMsg = (
        'OK',
        'Unable to create new image',
        'Wrong palette range specified',
        'Wrong draw destination object (must be OT_Img or OT_ScrBuf)',
        'Wrong copy source object',
        'Wrong copy position',
        'Unknown draw source/destination object',
        'There is no palette in specified LGF file',
        'Destination object is NIL',
        'Source object is NIL',
        'VGA-compatible adaptor is not present'
    );

    CDrawOnProc_Text = 'DrawOn proc';
    CPrintXYOnProc_Text = 'PrintXYOn proc';
    CDrawOnCropProc_Text = 'DrawOnCrop proc';
    CCopyImgProc_Text = 'CopyImg proc';
    CLineProc_Text = 'Line proc';
    CFillBoxProc_Text = 'FillBox proc';

    CVMemSeg = $0A000; CVMemOffs = 0;
Var
    {Указатель на процедуру вывода изображения без отсечения}
    DrawImg: TDrawImgProc;
    {Указатель на процедуру отрисовки изображения с отсечением}
    DrawImgCrop: TDrawImgCropProc;
    {Указатель на процедуру копирования части изображения}
    CopyImgProc: TCopyImgProc;
    {Указатель на процедуру вертикального флипа}
    VertFlipProc: TVertFlipProc;
    {Служит для хранения номера старого экранного режима}
    GOldGMNum: Byte;
    {Указатель на текущий экранный буфер}
    GCurScrBufP: TImgP;
    {Используется ли 32-битный режим для генерации изображения?}
    GIs32BitModeDraw: Boolean;
    {Используется ли 32-битный режим для обновления видеобуфера?}
    GIs32BitModeRefresh: Boolean;
    {Переменные для отслеживания FPS}
    G_FPS_LastMS, G_FPS_Frame, G_FPS: LongInt;

    {Восстанавливает старый экранный режим, и сообщает об ошибке}
    Procedure ReportError(AErr: TErr; ADescrStr: String); Forward;

    {Увеличивает\уменьшает яркость палитры на AStep, возвращает True,
    если палитра была установлена на максимальную\минимальную яркость}
    Function IncPalBr(APalP: TPalP; AStep: Byte): Boolean; Forward;
    Function DecPalBr(APalP: TPalP; AStep: Byte): Boolean; Forward;
    {Приводят палитру ADstPalP к ASrcPalP с шагом AStep, в первом
    случае уменьшая, во втором - увеличивая. True - если приведено полностью}
    Function FadePalInc(ADstPalP, ASrcPalP: TPalP; AStep: Byte): Boolean; Forward;
    Function FadePalDec(ADstPalP, ASrcPalP: TPalP; AStep: Byte): Boolean; Forward;

    {Сбрасывают содержимое буфера в видеопамять - обновляют экран}
    Procedure RefreshScr16(AImgP: TImgP); Far; Forward;
    Procedure RefreshScr32(AImgP: TImgP); Far; Forward;

    {Заполняют все изображение цветом AColor}
    Procedure FillImg16(AImgP: TImgP; AColor: Byte); Far; Forward;
    Procedure FillImg32(AImgP: TImgP; AColor: Byte); Far; Forward;

    {Рисуют изображение ASrcImgP на изображении ADstImgP по координатам AXPos и AYPos }
    Procedure DrawImg8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;
    Procedure DrawImg16(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;
    Procedure DrawImg32(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;

    {Рисуют изображение ASrcImgP на изображении ADstImgP применяя отсечение}
    Procedure DrawImgCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Far; Forward;
    Procedure DrawImgCrop16(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Far; Forward;
    Procedure DrawImgCrop32(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Far; Forward;

    {Рисует спрайт ASrcImgP на изображении ADstImgP по координатам AXPos и AYPos}
    Procedure DrawSpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;

    {Рисуют спрайт ASrcImgP на изображении ADstImgP применяя отсечение}
    Procedure DrawSprCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Far; Forward;

    {Рисует спрайт символа шрифта, используя в качестве цвета значение AC}
    Procedure DrawFontSpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer; AC: Byte); Far; Forward;
    {Рисует спрайт символа шрифта c отсечением, используя в качестве цвета значение AC}
    Procedure DrawFontSprCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
        AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer; AC: Byte); Far; Forward;

    {Рисует RLE-спрайт ASrcImgP на изображении ADstImgP по координатам AXPos и AYPos}
    Procedure DrawRLESpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;
    {Рисует RLE-спрайт ASrcImgP отзеркаленным по X}
    Procedure DrawRLESpr8HorFlip(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;
    {Рисует RLE-спрайт ASrcImgP отзеркаленным по Y}
    Procedure DrawRLESpr8VertFlip(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;
    {Рисует RLE-спрайт ASrcImgP отзеркаленным по обоим осям}
    Procedure DrawRLESpr8FullFlip(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Far; Forward;

    {Копируют участок изображения ASrcImgP по координатам ASrcXPos - ASrcYPos,
    с шириной ASrcWidth и высотой ASrcHeight, сохраняя его в изображении
    ADstImgP по координатам ADstXPos - ADstYPos. Выходит, если изображение
    не помещается на приемнике}
    Procedure CopyImg8(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
       ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Far; Forward;
    Procedure CopyImg16(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
       ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Far; Forward;
    Procedure CopyImg32(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
       ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Far; Forward;

    {Отражает изображение по горизонтали}
    Procedure HorFlip(AImgP: TImgP); Forward;
    {Отражает изображение по вертикали}
    Procedure VertFlip16(AImgP: TImgP); Far; Forward;
    Procedure VertFlip32(AImgP: TImgP); Far; Forward;

    {Выводят прямые линии на ADstImgP с позиции AXPos, AYPos длиной ALen цветом AC}
    Procedure HorLine(ADstImgP: TImgP; AXPos, AYPos, ALen: Integer; AC: Byte); Forward;
    Procedure VertLine(ADstImgP: TImgP; AXPos, AYPos, ALen: Integer; AC: Byte); Forward;
    {Выводит непрямую линию, используя алгоритм Брезенхама}
    Procedure BrezLine(ADstImgP: TImgP; AX1, AY1, AX2, AY2: Integer; AC: Byte); Forward;
    {Выводит закрашенный прямоугольник}
    Procedure DrawFillBox(ADstImgP: TImgP; AXPos, AYPos, AXLen, AYLen: Integer; AC: Byte); Forward;
    {____________________________________________________________}

{Выделяет память для палитры, и загружает ее из файла LPF}
Function LoadPalFromLPF(ALPFName: String): TPalP;
Var
    PalP: TPalP;
    LPFP: TLPFP;
Begin
    LPFP:= LoadLPFFromFile(ALPFName);
    If LPFP^.FErr <> TPE_Ok Then ReportLPFError(LPFP, True);
    PalP:= SafeCreateBuf(SizeOf(PalP^));
    MoveMem(PalP, LPFP^.FDataP, SizeOf(PalP^));
    LPFP^.FDataP:= SafeDestroyBuf(LPFP^.FDataP);
    LPFP:= SafeDestroyBuf(LPFP);
    LoadPalFromLPF:= PalP;
End;

{Выделяет память для палитры, и загружает ее из ресурсного псевдоархива}
Function LoadPalFromRes(Var AResP: TResP; ALPFName: TSFName): TPalP;
Var
    PalP: TPalP;
    LPFP: TLPFP;
Begin
    LPFP:= LoadLPFFromLRF(AResP, ALPFName);
    If LPFP^.FErr <> TPE_Ok Then ReportLPFError(LPFP, True);
    PalP:= SafeCreateBuf(SizeOf(PalP^));
    MoveMem(PalP, LPFP^.FDataP, SizeOf(PalP^));
    LPFP^.FDataP:= SafeDestroyBuf(LPFP^.FDataP);
    LPFP:= SafeDestroyBuf(LPFP);
    LoadPalFromRes:= PalP;
End;

{Выделяет память для палитры, и грузит ее из LGF-файла,
лежащего в псевдоархиве}
Function LoadPalFromLGFInRes(Var AResP: TResP; ALGFName: TSFName): TPalP;
Var
    PalP: TPalP;
    LGFP: TLGFP;
    ImgP: TImgP;
Begin
    PalP:= SafeCreateBuf(SizeOf(PalP^));
    LoadPalFromLGFInRes:= PalP;
    ImgP:= Nil; {Чтобы не загружать данные, а только заголовки и палитру}
    LGFP:= LoadLGFFromLRF(AResP, TByteBufP(ImgP), CImgHeadSize, ALGFName);
    If LGFP^.FErr <> TGE_Ok Then ReportLGFError(LGFP, True);
    If LGFP^.FPalP = Nil Then
        ReportError(TE_LGFWithoutPal, ALGFName)
    Else
         MoveMem(@PalP^, @LGFP^.FPalP^, SizeOf(PalP^));
    LGFP:= DestroyLGF(LGFP);
    ImgP:= SafeDestroyBuf(ImgP);
End;

{Выделяет память для палитры, и загружает ее из LGF-файла}
Function LoadPalFromLGF(ALGFName: String): TPalP;
Var
    PalP: TPalP;
    LGFP: TLGFP;
    ImgP: TImgP;
Begin
    PalP:= SafeCreateBuf(SizeOf(PalP^));
    LoadPalFromLGF:= PalP;
    ImgP:= Nil; {Чтобы не загружать данные, только заголовки и палитру}
    LGFP:= LoadLGFFromFile(TByteBufP(ImgP), CImgHeadSize, ALGFName);
    If LGFP^.FErr <> TGE_Ok Then ReportLGFError(LGFP, True);
    If LGFP^.FPalP = Nil Then
        ReportError(TE_LGFWithoutPal, ALGFName)
    Else
         MoveMem(@PalP^, @LGFP^.FPalP^, SizeOf(PalP^));
    LGFP:= DestroyLGF(LGFP);
    ImgP:= SafeDestroyBuf(ImgP);
End;

{Устанавливает палитру APalP}
Procedure ApplyPal(APalP: TPalP); Assembler;
Asm
    push ds
    lds si,APalP
    mov dx,03C8h
    xor ax,ax
    out dx,al
    inc dx
    mov cx,768
    rep outsb
    pop ds
End;

{Выделяет память для палитры и загружает ее из регистров VGA адаптера}
Function ReadVGAPal: TPalP;
Var
    PalP: TPalP;
Begin
    PalP:= SafeCreateBuf(SizeOf(PalP^));
    Asm
        les di,PalP
        mov dx,03C7h
        xor ax,ax
        out dx,al
        inc dx
        inc dx
        mov cx,768
        rep insb
    End;
    ReadVGAPal:= PalP;
End;

{Устанавливает в палитре APalP цвет AI}
Procedure SetColorInPal(APalP: TPalP; AI, AR, AG, AB: Byte);
Begin
    APalP^[AI][0]:= AB;
    APalP^[AI][1]:= AG;
    APalP^[AI][2]:= AR;
End;

{Начиная с цвета AFrom, устанавливает в ADstPalP количество цветов
ACount + 1, делая их аналогичными цветам в ASrcPalP}
Procedure SetRangeInPal(ADstPalP: TPalP; ADstFrom: Byte; ASrcPalP: TPalP; ASrcFrom, ACount: Byte);
Begin
    If (Word(ADstFrom) + ACount > 255) Or (Word(ASrcFrom) + ACount > 255) Then
        ReportError(TE_WrongPaletteRange, '');
    MoveMem(@ADstPalP^[ADstFrom][0], @ASrcPalP^[ASrcFrom][0], Succ(Word(ACount)) * 3);
End;

{Изменяет яркость палитры на указанный в AStep шаг, возвращает True,
если все палитра уже установлена на максимальную\минимальную яркость}
Function ChangePalBr(APalP: TPalP; AStep: ShortInt): Boolean;
Begin
    If AStep > 0 Then
        ChangePalBr:= IncPalBr(APalP, AStep)
    Else If AStep < 0 Then
        ChangePalBr:= DecPalBr(APalP, -AStep);
End;

{Приводит палитру ADstPal к палитре ASrcPal, используя шаг AStep.
Возвращает True, если палитра после отработки функции уже идентичны}
Function FadePal(ADstPalP, ASrcPalP: TPalP; AStep: ShortInt): Boolean;
Begin
    If AStep > 0 Then
        FadePal:= FadePalInc(ADstPalP, ASrcPalP, AStep)
    Else If AStep < 0 Then
        FadePal:= FadePalDec(ADstPalP, ASrcPalP, -AStep);
End;

{Приводит палитру APalP к черно-белому (Grayscale) виду, с шагом AStep}
Function GrayPal(APalP: TPalP; AStep: ShortInt): Boolean;
Var
    I: Integer;
    CMax: Byte;
Begin
    GrayPal:= False;
    For I:= 0 To 255 Do Begin
        If (APalP^[I][0] >= APalP^[I][1]) And (APalP^[I][0] >= APalP^[I][2]) Then Begin
            Inc(APalP^[I][1], AStep * Byte(APalP^[I][1] <> APalP^[I][0]));
            Inc(APalP^[I][2], AStep * Byte(APalP^[I][2] <> APalP^[I][0]));
            GrayPal:= True;
        End
        Else If (APalP^[I][1] >= APalP^[I][0]) And (APalP^[I][1] >= APalP^[I][2]) Then Begin
            Inc(APalP^[I][0], AStep * Byte(APalP^[I][0] <> APalP^[I][1]));
            Inc(APalP^[I][2], AStep * Byte(APalP^[I][2] <> APalP^[I][1]));
            GrayPal:= True;
        End
        Else If (APalP^[I][2] >= APalP^[I][0]) And (APalP^[I][2] >= APalP^[I][1]) Then Begin
            Inc(APalP^[I][0], AStep * Byte(APalP^[I][0] <> APalP^[I][2]));
            Inc(APalP^[I][1], AStep * Byte(APalP^[I][1] <> APalP^[I][2]));
            GrayPal:= True;
        End
    End;
End;

{Увеличивает\уменьшает яркость палитры на AStep}
Function IncPalBr(APalP: TPalP; AStep: Byte): Boolean; Assembler;
Asm
    push ds
    les di,APalP
    lds si,APalP
    cld
    mov bl,AStep
    mov bh,bl
    mov cx,384
    mov dl,63
    mov dh,1
   @IncLoop:
    lodsw
    add ax,bx
    cmp al,dl
    jbe @RaiseResult1
    mov al,dl
    jmp @TestSecondByte
   @RaiseResult1:
    mov dh,0
   @TestSecondByte:
    cmp ah,dl
    jbe @RaiseResult2
    mov ah,dl
    jmp @Next
   @RaiseResult2:
    mov dh,0
   @Next:
    stosw
    dec cx
    jnz @IncLoop
    pop ds
    xor ax,ax
    mov al,dh
End;

Function DecPalBr(APalP: TPalP; AStep: Byte): Boolean; Assembler;
Asm
    push ds
    les di,APalP
    lds si,APalP
    cld
    mov bl,AStep
    mov bh,bl
    mov cx,384
    mov dl,0
    mov dh,1
   @IncLoop:
    lodsw
    sub ax,bx
    cmp al,dl
    jg @RaiseResult1
    mov al,dl
    jmp @TestSecondByte
   @RaiseResult1:
    mov dh,0
   @TestSecondByte:
    cmp ah,dl
    jg @RaiseResult2
    mov ah,dl
    jmp @Next
   @RaiseResult2:
    mov dh,0
   @Next:
    stosw
    dec cx
    jnz @IncLoop
    pop ds
    xor ax,ax
    mov al,dh
End;

{Приводят палитру ADstPalP к ASrcPalP с шагом AStep, в первом
случае уменьшая, во втором - увеличивая. True - если приведено полностью}
Function FadePalInc(ADstPalP, ASrcPalP: TPalP; AStep: Byte): Boolean; Assembler;
Asm
    push ds
    les di,ADstPalP
    lds si,ASrcPalP
    cld
    mov bl,AStep
    mov bh,bl
    mov cx,384
    mov dh,1
   @FadeLoop:
    mov ax,es:[di]
    add ax,bx
    cmp al,ds:[si]
    jbe @RaiseResult1
    mov al,ds:[si]
    jmp @TestSecondByte
   @RaiseResult1:
    mov dh,0
   @TestSecondByte:
    inc si
    cmp ah,ds:[si]
    jbe @RaiseResult2
    mov ah,ds:[si]
    jmp @Next
   @RaiseResult2:
    mov dh,0
   @Next:
    inc si
    stosw
    dec cx
    jnz @FadeLoop
    pop ds
    xor ax,ax
    mov al,dh
End;

Function FadePalDec(ADstPalP, ASrcPalP: TPalP; AStep: Byte): Boolean; Assembler;
Asm
    push ds
    les di,ADstPalP
    lds si,ASrcPalP
    cld
    mov bl,AStep
    mov bh,bl
    mov cx,384
    mov dh,1
   @FadeLoop:
    mov ax,es:[di]
    sub ax,bx
    cmp al,ds:[si]
    jg @RaiseResult1
    mov al,ds:[si]
    jmp @TestSecondByte
   @RaiseResult1:
    mov dh,0
   @TestSecondByte:
    inc si
    cmp ah,ds:[si]
    jg @RaiseResult2
    mov ah,ds:[si]
    jmp @Next
   @RaiseResult2:
    mov dh,0
   @Next:
    inc si
    stosw
    dec cx
    jnz @FadeLoop
    pop ds
    xor ax,ax
    mov al,dh
End;

{Устаналивает на изображении ADstImgP по координатам AX и AY точку}
Procedure PSet(ADstImgP: TImgP; AXPos, AYPos: Word; AC: Byte); Assembler;
Asm
    les di,ADstImgP
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    cmp ax,[es:di+2]
    jae @End
    add ax,CImgHeadSize
    add di,ax
    mov cl,AC
    mov [es:di],cl
   @End:
End;

{Выводит на изображении ADstImgP линию проходящую с позиции AXPos, AYPos
по AEXPos, AEYPos с цветом AC}
Procedure Line(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CLineProc_Text);
    With ADstImgP^ Do Begin
        If FObjType > OT_Spr Then ReportError(TE_WrongDrawDest, CLineProc_Text);;
        {Если линия больше похожа на точку - да будет так}
        If (AXPos = AEXPos) And (AYPos = AEYPos) And (AXPos = AYPos) Then Begin
            PSet(ADstImgP, AXPos, AYPos, AC);
            Exit;
        End;
        If AXPos = AEXPos Then Begin
            If AYPos > AEYPos Then SwapInt(AYPos, AEYPos);
            If (AXPos < 0) Or (AXPos >= FWidth) Then Exit;
            If AYPos < 0 Then AYPos:= 0;
            If AEYPos >= FHeight Then AEYPos:= FHeight - 1;
            VertLine(ADstImgP, AXPos, AYPos, AEYPos - AYPos + 1, AC)
        End
        Else If AYPos = AEYPos Then Begin
            If AXPos > AEXPos Then SwapInt(AXPos, AEXPos);
            If (AYPos < 0) Or (AYPos >= FHeight) Then Exit;
            If AXPos < 0 Then AXPos:= 0;
            If AEXPos >= FWidth Then AEXPos:= FWidth - 1;
            HorLine(ADstImgP, AXPos, AYPos, AEXPos - AXPos + 1, AC);
        End;
        BrezLine(ADstImgP, AXPos, AYPos, AEXPos, AEYPos, AC);
    End;
End;

{Выводит непрямую линию, используя алгоритм Брезенхама}
Procedure BrezLine(ADstImgP: TImgP; AX1, AY1, AX2, AY2: Integer; AC: Byte); Assembler;
Var
    DXInc, DYInc, ShortDistance, SXInc, SYInc, SCount, DCount: Word;
Asm
    mov cx,1
    mov dx,cx

    mov di,AY2
    sub di,AY1
    jge @Keep_Y
    neg dx
    neg di
   @Keep_Y:
    mov DYInc,dx
    mov si,AX2
    sub si,AX1
    jge @Keep_X
    neg cx
    neg si
   @Keep_X:
    mov DXInc,cx

    cmp si,di
    jge @HorSeg
    xor cx,cx
    xchg si,di
    jmp @SaveVal
   @HorSeg:
    xor dx,dx
   @SaveVal:
    mov ShortDistance,di
    mov SXInc,cx
    mov SYInc,dx

    mov ax,ShortDistance
    shl ax,1
    mov SCount,ax
    sub ax,si
    mov bx,ax
    sub ax,si
    mov DCount,ax

    mov cx,AX1
    mov dx,AY1
    inc si
    mov al,AC
    les di,ADstImgP
   @DrawLoop:
    dec si
    jz @Finish
    test dx,dx
    js @SkipDot
    test cx,cx
    js @SkipDot
    cmp cx,[es:di+4]
    jge @SkipDot
    cmp dx,[es:di+6]
    jge @SkipDot
   @DrawDot:
    push di
    push dx
    mov ax,[es:di+4]
    mul dx
    add ax,cx
    add di,CImgHeadSize
    add di,ax
    mov al,AC
    mov [es:di],al
    pop dx
    pop di
   @SkipDot:
    cmp bx,0
    jge @DLine
    add cx,SXInc
    add dx,SYInc
    add bx,SCount
    jmp @DrawLoop
   @DLine:
    add cx,DXInc
    add dx,DYInc
    add bx,DCount
    jmp @DrawLoop
   @Finish:
End;

{Выводит прямоугольник}
Procedure Box(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    Line(ADstImgP, AXPos, AYPos, AEXPos, AYPos, AC);
    Line(ADstImgP, AXPos, AYPos, AXPos, AEYPos, AC);
    Line(ADstImgP, AXPos, AEYPos, AEXPos, AEYPos, AC);
    Line(ADstImgP, AEXPos, AYPos, AEXPos, AEYPos, AC);
End;

{Выводят прямые линии на ADstImgP с позиции AXPos, AYPos длиной ALen цветом AC}
Procedure HorLine(ADstImgP: TImgP; AXPos, AYPos, ALen: Integer; AC: Byte); Assembler;
Asm
    les di,ADstImgP
    mov ax,[es:di+4]
    mov bx,AYPos
    mul bx
    add ax,AXPos
    add di,ax
    add di,CImgHeadSize
    mov cx,ALen
    mov al,AC
    rep stosb
End;

Procedure VertLine(ADstImgP: TImgP; AXPos, AYPos, ALen: Integer; AC: Byte); Assembler;
Asm
    les di,ADstImgP
    mov ax,[es:di+4]
    mov bx,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    dec dx
    add di,ax
    add di,CImgHeadSize
    mov cx,ALen
    mov al,AC
   @DrawDot:
    stosb
    add di,dx
    dec cx
    jnz @DrawDot
End;

{Выводит закрашенный цветом AC прямоугольник}
Procedure FillBox(ADstImgP: TImgP; AXPos, AYPos, AEXPos, AEYPos: Integer; AC: Byte);
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CFillBoxProc_Text);
    With ADstImgP^ Do Begin
        If FObjType > OT_Spr Then ReportError(TE_WrongDrawDest, CFillBoxProc_Text);
        {Если прямоугольник больше похож на точку - да будет так}
        If (AXPos = AEXPos) And (AYPos = AEYPos) And (AXPos = AYPos) Then Begin
            PSet(ADstImgP, AXPos, AYPos, AC);
            Exit;
        End;
        If AYPos > AEYPos Then SwapInt(AYPos, AEYPos);
        If AXPos > AEXPos Then SwapInt(AXPos, AEXPos);
        {Если за пределами холста, то не рисуем вообще}
        If ((AEXPos < 0) Or (AXPos >= FWidth)) Or
          ((AEYPos < 0) Or (AYPos >= FHeight)) Then Exit;
        {Если размер не вкладывается в холст, то приводим его к нормальному}
        If AXPos < 0 Then AXPos:= 0;
        If AEXPos >= FWidth Then AEXPos:= FWidth - 1;
        If AYPos < 0 Then AYPos:= 0;
        If AEYPos >= FHeight Then AEYPos:= FHeight - 1;
        DrawFillBox(ADstImgP, AXPos, AYPos, AEXPos - AXPos + 1,
          AEYPos - AYPos + 1, AC);
    End;
End;

{Выводит закрашенный цветом AC прямоугольник.}
Procedure DrawFillBox(ADstImgP: TImgP; AXPos, AYPos, AXLen, AYLen: Integer; AC: Byte); Assembler;
Asm
    push bp
    les di,ADstImgP
    mov bx,AYPos
    mov ax,[es:di+4]
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    mov al,AC
    mov ah,al
    mov si,AXLen
    mov bx,AYLen
    mov bp,si
    and bp,1
    sub dx,si
    shr si,1
   @DrawLoop:
    mov cx,si
    rep stosw
    test bp,bp
    jz @NextCheck
    stosb
   @NextCheck:
    add di,dx
    dec bx
    jnz @DrawLoop
    pop bp
End;

{Масштабирует изображение ASrcImgP до размеров ADstImgP}
Procedure ResizeImg(ADstImgP, ASrcImgP: TImgP);
Var
    SrcP: TImgP;
    XRatio, YRatio, I, J, X2, Y2, W1, W2, H1, H2, M: Word;
Begin
    If ASrcImgP^.FObjType = OT_RLESpr Then Begin
        SrcP:= Create(OT_Spr, ASrcImgP^.FWidth, ASrcImgP^.FHeight);
        FillImg(SrcP, ASrcImgP^.FReserved);
        DrawOn(SrcP, ASrcImgP, 0, 0);
    End
    Else
        SrcP:= ASrcImgP;
    W1:= SrcP^.FWidth; H1:= SrcP^.FHeight;
    W2:= ADstImgP^.FWidth; H2:= ADstImgP^.FHeight;
    XRatio:=(W1 Shl 7) Div W2;
    YRatio:= (H1 Shl 7) Div H2;
    Y2:= 1;
    Asm
        push ds
        les di,ADstImgP
        lds si,SrcP
        cld
        add di,CImgHeadSize
        add si,CImgHeadSize
        mov ch,byte ptr [H2]
        xor dx,dx
        mov cl,7
       @YLoop:
        mov ax,[Y2]
        shr ax,cl
        mul [W1]
        mov [M],ax
        add si,ax
        mov dx,[W2]
        mov ax,1
       @XLoop:
        mov bx,ax
        shr bx,cl
        add si,bx
        movsb
        sub si,bx
        dec si
        add ax,[XRatio]
        dec dx
        jnz @XLoop
       @AfterXLoop:
        sub si,[M]
        mov ax,[YRatio]
        add [Y2],ax
        dec ch
        jnz @YLoop
        pop ds
    End;
    If ASrcImgP^.FObjType = OT_RLESpr Then SrcP:= SafeDestroyBuf(SrcP);
End;

{Поворачивает изображение ASrcImgP на угол Alpha, и сохраняет в ADstImgP}
Procedure RotateImg(ADstImgP, ASrcImgP: TImgP; Alpha: Integer);
Var
    SrcP: TImgP;
    DstOffs, SrcOffs: Word;
    X0, Y0, X1, Y1, NewW, NewH, OldW, OldH: Integer;
    ISn, ICs, XC, YC, NXC, NYC, ICsXDelta, ISnXDelta, XSum, YSum: Integer;
Begin
    OldW:= ASrcImgP^.FWidth; OldH:= ASrcImgP^.FHeight;
    If ASrcImgP^.FObjType = OT_RLESpr Then Begin
        SrcP:= LGL.Create(OT_Spr, OldW, OldH);
        FillImg(SrcP, ASrcImgP^.FReserved);
        LGL.DrawOn(SrcP, ASrcImgP, 0, 0);
    End
    Else
        SrcP:= ASrcImgP;

    ISn:= Trunc(Sin(Alpha * Pi / 180) * 256);
    ICs:= Trunc(Cos(Alpha * Pi / 180) * 256);
    DstOffs:= CImgHeadSize + 1; SrcOffs:= DstOffs;

    NewW:= ADstImgP^.FWidth;
    NewH:= ADstImgP^.FHeight;
    If NewW > NewH Then NewH:= NewW Else NewW:= NewH;
    XC:= (OldW Div 2); YC:= (OldH Div 2);
    NXC:= (NewW Div 2); NYC:= (NewH Div 2);

    ICsXDelta:= ICs * (NewW); ISnXDelta:= ISn * (NewW);
    XSum:= ISn * -NYC + (ICs * -NYC) + XC * 256;
    YSum:= ICs * -NYC + (-ISn * -NYC) + YC * 256;
    Asm
        push ds
        les di,ADstImgP
        lds si,SrcP
        cld
        add si,CImgHeadSize
        add di,CImgHeadSize

        mov bx,[XSum]
        mov dx,[YSum]
        mov ch,byte ptr [NewH]
       @YLoop:
        mov cl,byte ptr [NewW]
       @XLoop:
        xor ax,ax
        mov al,bh
        test bx,bx
        js @AfterSecC
        cmp ax,[OldW]
        jae @AfterSecC
       @AfterFirstC:
        mov [X0],ax
        mov al,dh
        test dx,dx
        js @AfterSecC
        cmp ax,[OldH]
        jae @AfterSecC
        push dx
        mul [OldW]
        mov dx,si
        add si,ax
        add si,[X0]
        movsb
        mov si,dx
        pop dx
        dec di
       @AfterSecC:
        sub dx,[ISn]
        add bx,[ICs]
        inc di
        dec cl
        jnz @XLoop
        add bx,[ISn]
        add dx,[ICs]
        add dx,[ISnXDelta]
        sub bx,[ICsXDelta]
        dec ch
        jnz @YLoop
        pop ds
    End;
    If ASrcImgP^.FObjType = OT_RLESpr Then SrcP:= SafeDestroyBuf(SrcP);
End;

{Вызывает DrawOn(GCurBufP, AImgP, AXPos, AYPos) - вывод в текущий буфер}
Procedure Draw(AImgP: TImgP; AXPos, AYPos: Integer);
Begin
    DrawOn(GCurScrBufP, AImgP, AXPos, AYPos);
End;

{Выполняет проверки, и выбирает подходящую процедуру для вывода изображения}
Procedure DrawOn(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer);
Var
    DstWidth, DstHeight, XRight, YDown: Integer;
    ImgP: TImgP;
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CDrawOnProc_Text);
    If ASrcImgP = Nil Then ReportError(TE_SrcIsNil, CDrawOnProc_Text);
    If ADstImgP^.FObjType > OT_Spr Then ReportError(TE_WrongDrawDest, CDrawOnProc_Text);
    With ASrcImgP^ Do Begin
        XRight:= AXPos + FWidth; YDown:= AYPos + FHeight;
        DstWidth:= ADstImgP^.FWidth; DstHeight:= ADstImgP^.FHeight;
        {Если за пределами холста, то не рисуем вообще}
        If ((XRight <= 0) Or (AXPos >= DstWidth)) Or
          ((YDown <= 0) Or (AYPos >= DstHeight)) Then Exit;
        {Если ASrcImgP полностью помещается в ADstImgP по указанным
        координатам то просто выводим обычной процедурой для вывода}
        If (AXPos >= 0) And (XRight < DStWidth) And (AYPos >= 0)
        And (YDown < DstHeight) Then Begin
            Case FObjType Of
              OT_ScrBuf, OT_Img:
                If FWidth >= 4 Then
                    DrawImg(ADstImgP, ASrcImgP, AXPos, AYPos)
                Else
                    DrawImg8(ADstImgP, ASrcImgP, AXPos, AYPos);
              OT_Spr:
                DrawSpr8(ADstImgP, ASrcImgP, AXPos, AYPos);
              OT_RLEImg:;
              OT_RLESpr:
                If ASrcImgP^.FIsHorFlip Then Begin
                    If ASrcImgP^.FIsVertFlip Then
                        DrawRLESpr8FullFlip(ADstImgP, ASrcImgP, AXPos, AYPos)
                    Else
                        DrawRLESpr8HorFlip(ADstImgP, ASrcImgP, AXPos, AYPos);
                End
                Else Begin
                    If ASrcImgP^.FIsVertFlip Then
                        DrawRLESpr8VertFlip(ADstImgP, ASrcImgP, AXPos, AYPos)
                    Else
                        DrawRLESpr8(ADstImgP, ASrcImgP, AXPos, AYPos);
                End;
              OT_FontSpr: {Цвет символа передается в ASrcImgP в поле FReserved}
                DrawFontSpr8(ADstImgP, ASrcImgP, AXPos, AYPos,
                  ASrcImgP^.FReserved);
              Else
                ReportError(TE_UnknownDrawDest, CDrawOnProc_Text);
            End;
            Exit;
        End;
        {Иначе используем процедуру вывода с отсечением}
        DrawCropOn(ADstImgP, ASrcImgP, -(AXPos * Byte(AXPos < 0)),
          (XRight - DstWidth) * Byte(XRight - DstWidth > 0),
          -(AYPos * Byte(AYPos < 0) * FWidth),
          AXPos * Byte(AXPos > 0), AYPos * Byte(AYPos > 0),
          (FWidth + (AXPos * Byte(AXPos < 0))) +
          ((DstWidth - XRight) * Byte(DstWidth < XRight)),
          FHeight + (AYPos * Byte(AYPos < 0)) +
          ((DstHeight - YDown) * Byte(DstHeight < YDown))
        );
    End;
End;

{Печатает текст AStr используя шрифт AFontP цветом AC по координатам AXPos, AYPos}
Procedure PrintXY(AFontP: TFntP; AXPos, AYPos: Integer; AC: Byte; AStr: String);
Var
    I, XPos: Integer;
Begin
    PrintXYOn(GCurScrBufP, AFontP, AXPos, AYPos, AC, AStr);
End;

{Печатает текст AStr на изображении ADstImgP}
Procedure PrintXYOn(ADstImgP: TImgP; AFontP: TFntP; AXPos, AYPos: Integer;
AC: Byte; AStr: String);
Var
    I, XPos: Integer;
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CPrintXYOnProc_Text);
    If AFontP = Nil Then ReportError(TE_SrcIsNil, CPrintXYOnProc_Text);
    XPos:= AXPos;
    For I:= 1 To Length(AStr) Do Begin
        If XPos > ADstImgP^.FWidth Then Break;
        TImgP(AFontP^.FChars[Byte(AStr[I])])^.FReserved:= AC;
        DrawOn(ADstImgP, TImgP(AFontP^.FChars[Byte(AStr[I])]),
          XPos, AYPos);
        Inc(XPos, TImgP(AFontP^.FChars[Byte(AStr[I])])^.FWidth +
          AFontP^.FCharInterval);
    End;
End;

{Считает, сколько пикселей в длину и высоту будет занимать печать
строки AStr и возвращает длину в AWidth и высоту в AHeight}
Procedure CalcFontStrSize(AFontP: TFntP; AStr: String;
Var AWidth: Integer; Var AHeight: Integer);
Var
    I: Integer;
Begin
    AWidth:= 0; AHeight:= 0;
    For I:= 1 To Length(AStr) Do Begin
        Inc(AWidth, TImgP(AFontP^.FChars[Byte(AStr[I])])^.FWidth +
          AFontP^.FCharInterval);
        If AHeight < TImgP(AFontP^.FChars[Byte(AStr[I])])^.FHeight Then
            AHeight:= TImgP(AFontP^.FChars[Byte(AStr[I])])^.FHeight;
    End;
End;

{Вызывает DrawCropOn(GCurBufP, ASrcImgP, AXLMod...)}
Procedure DrawCrop(ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);
Begin
    DrawCropOn(GCurScrBufP, ASrcImgP, AXLMod, AXRMod, AYMod, AXStart,
      AYStart, AXLen, AYLen);
End;

{Выполняет проверки, и выбирает подходящую процедуру для вывода
изображения с отсечением}
Procedure DrawCropOn(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer);
Var
    ImgP: TImgP;
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CDrawOnCropProc_Text);
    If ASrcImgP = Nil Then ReportError(TE_SrcIsNil, CDrawOnCropProc_Text);
    If ADstImgP^.FObjType > OT_Spr Then
        ReportError(TE_WrongDrawDest, CDrawOnCropProc_Text);
    With ASrcImgP^ Do Begin
        {Если за границами холста, то не рисовать вообще}
        If ((AXStart + AXLen <= 0) Or (AXStart >= ADstImgP^.FWidth)) Or
          ((AYStart + AYLen <= 0) Or (AYStart >= ADstImgP^.FHeight)) Then Exit;
        Case FObjType Of
          OT_ScrBuf, OT_Img:
            If FWidth >= 4 Then
                DrawImgCrop(ADstImgP, ASrcImgP, AXLMod, AXRMod, AYMod,
                AXStart, AYStart, AXLen, AYLen)
            Else
                DrawImgCrop8(ADstImgP, ASrcImgP, AXLMod, AXRMod, AYMod,
                AXStart, AYStart, AXLen, AYLen);
          OT_Spr:
            DrawSprCrop8(ADstImgP, ASrcImgP, AXLMod, AXRMod,
            AYMod, AXStart, AYStart, AXLen, AYLen);
          OT_RLEImg:;
          OT_RLESpr:
            Begin
                ImgP:= Create(OT_Img, FWidth, FHeight);
                CopyImg(ImgP, ADstImgP, AXStart, AYStart, AXLen, AYLen,
                  Byte(AXStart = 0) * AXLMod, Byte(AYStart = 0) * (AYMod Div ImgP^.FWidth));
                If ASrcImgP^.FIsHorFlip Then Begin
                    If ASrcImgP^.FIsVertFlip Then
                        DrawRLESpr8FullFlip(ImgP, ASrcImgP, 0, 0)
                    Else
                        DrawRLESpr8HorFlip(ImgP, ASrcImgP, 0, 0);
                End
                Else Begin
                    If ASrcImgP^.FIsVertFlip Then
                        DrawRLESpr8VertFlip(ImgP, ASrcImgP, 0, 0)
                    Else
                        DrawRLESpr8(ImgP, ASrcImgP, 0, 0);
                End;
                DrawCropOn(ADstImgP, ImgP, AXLMod, AXRMod, AYMod, AXStart,
                  AYStart, AXLen, AYLen);
                ImgP:= Destroy(ImgP);
            End;
          OT_FontSpr:
            DrawFontSprCrop8(ADstImgP, ASrcImgP, AXLMod, AXRMod,
              AYMod, AXStart, AYStart, AXLen, AYLen, ASrcImgP^.FReserved);
          Else
            ReportError(TE_UnknownDrawDest, CDrawOnCropProc_Text);
        End;
    End;
End;

{Делает проверки, и в зависимости от входных параметров, вызывает
нужную функцию копирования части изображения}
Procedure CopyImg(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer);
Begin
    If ADstImgP = Nil Then ReportError(TE_DestIsNil, CCopyImgProc_Text);
    If ASrcImgP = Nil Then ReportError(TE_SrcIsNil, CCopyImgProc_Text);
    If ADstImgP^.FObjType > OT_Spr Then ReportError(TE_WrongDrawDest, CCopyImgProc_Text);
    If ASrcImgP^.FObjType > OT_Spr Then ReportError(TE_WrongCopySrc, CCopyImgProc_Text);
    With ASrcImgP^ Do Begin
        If (ASrcXLen < 1) Or (ASrcXPos < 0) Or (ASrcXPos + ASrcXLen > FWidth) Or
          (ASrcYLen < 1) Or (ASrcYPos < 0) Or (ASrcYPos + ASrcYLen > FHeight) Or
          (ADstXPos < 0) Or (ADstXPos + ASrcXLen > ADstImgP^.FWidth) Or
          (ADstYPos < 0) Or (ADstYPos + ASrcYLen > ADstImgP^.FHeight) Then
            ReportError(TE_WrongCopyPos, CCopyImgProc_Text);
        CopyImgProc(ADstImgP, ASrcImgP, ASrcXPos, ASrcYPos,
          ASrcXLen, ASrcYLen, ADstXPos, ADstYPos);
    End;
End;

{Рисуют изображение ASrcImgP на изображении ADstImgP применяя отсечение}
Procedure DrawImgCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,[AYStart]
    mul bx
    mov dx,bx
    add ax,[AXStart]
    add di,ax
    add di,CImgHeadSize
    add si,[AYMod]
    add si,CImgHeadSize
    mov bx,[AYLen]
    sub dx,[AXLen]
    mov ax,[AXLen]
   @DrawLoop:
    add si,[AXLMod]
    mov cx,ax
    rep movsb
    add di,dx
    add si,[AXRMod]
    dec bx
    jnz @DrawLoop
    pop ds
End;

Procedure DrawImgCrop16(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,[AYStart]
    mul bx
    mov dx,bx
    add ax,[AXStart]
    add di,ax
    add di,CImgHeadSize
    add si,[AYMod]
    add si,CImgHeadSize
    mov bx,[AYLen]
    sub dx,[AXLen]
    mov ax,[AXLen]
    and ax,1
   @DrawLoop:
    add si,[AXLMod]
    mov cx,[AXLen]
    shr cx,1
    rep movsw
    test ax,ax
    jz @NextCheck
    movsb
   @NextCheck:
    add di,dx
    add si,[AXRMod]
    dec bx
    jnz @DrawLoop
    pop ds
End;

Procedure DrawImgCrop32(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,[AYStart]
    mul bx
    mov dx,bx
    add ax,[AXStart]
    add di,ax
    add di,CImgHeadSize
    add si,[AYMod]
    add si,CImgHeadSize
    mov bx,[AYLen]
    sub dx,[AXLen]
    mov ax,[AXLen]
    and ax,3
   @DrawLoop:
    add si,[AXLMod]
    mov cx,[AXLen]
    shr cx,2
    db 66h
    rep movsw
    test ax,ax
    jz @AfterCmp
    cmp ax,1
    je @CopyLastByte
    cmp ax,2
    je @CopyLastWord
   @CopyLastTriple:
    movsb
   @CopyLastWord:
    movsb
   @CopyLastByte:
    movsb
   @AfterCmp:
    add di,dx
    add si,[AXRMod]
    dec bx
    jnz @DrawLoop
    pop ds
End;

{Рисуют изображение ASrcImgP на изображении ADstImgP по координатам AXPos и AYPos }
Procedure DrawImg8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    mov ax,[si+4]
    sub dx,ax
    mov bx,[si+6]
    add si,CImgHeadSize
   @DrawLoop:
    mov cx,ax
    rep movsb
    add di,dx
    dec bx
    jnz @DrawLoop
    pop ds
End;

Procedure DrawImg16(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    push bp
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    mov ax,[si+4]
    mov bp,ax
    and bp,1
    sub dx,ax
    shr ax,1
    mov bx,[si+6]
    add si,CImgHeadSize
   @DrawLoop:
    mov cx,ax
    rep movsw
    test bp,bp
    jz @NextCheck
    movsb
   @NextCheck:
    add di,dx
    dec bx
    jnz @DrawLoop
    pop bp
    pop ds
End;

Procedure DrawImg32(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    push bp
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    mov ax,[si+4]
    mov bp,ax
    and bp,3
    sub dx,ax
    shr ax,2
    mov bx,[si+6]
    add si,CImgHeadSize
   @DrawLoop:
    mov cx,ax
    db 66h
    rep movsw
    test bp,bp
    jz @AfterCmp
    cmp bp,1
    je @CopyLastByte
    cmp bp,2
    je @CopyLastWord
   @CopyLastTriple:
    movsb
   @CopyLastWord:
    movsb
   @CopyLastByte:
    movsb
   @AfterCmp:
    add di,dx
    dec bx
    jnz @DrawLoop
    pop bp
    pop ds
End;

{Рисует спрайт ASrcImgP на изображении ADstImgP по координатам AXPos и AYPos}
Procedure DrawSpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    push bp
    mov ah,[si+1]
    mov bp,[si+4]
    sub dx,bp
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    mov cx,bp
   @DrawLoop:
    lodsb
    cmp al,ah
    je @SkipDot
    mov es:[di],al
   @SkipDot:
    inc di
   @AfterSetDot:
    dec cx
    jnz @DrawLoop
    add di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Рисует спрайт ASrcImgP на изображении ADstImgP применяя отсечение}
Procedure DrawSprCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,[AYStart]
    mul bx
    mov dx,bx
    add ax,[AXStart]
    add di,ax
    add di,CImgHeadSize
    mov ah,[si+1]
    add si,[AYMod]
    add si,CImgHeadSize
    mov bx,[AYLen]
    sub dx,[AXLen]
   @PrepareDraw:
    mov cx,[AXLen]
    add si,[AXLMod]
   @DrawLoop:
    lodsb
    cmp al,ah
    je @SkipDot
    mov es:[di],al
   @SkipDot:
    inc di
   @AfterSetDot:
    dec cx
    jnz @DrawLoop
    add di,dx
    add si,[AXRMod]
    dec bx
    jnz @PrepareDraw
    pop ds
End;

{Рисует спрайт символа шрифта, используя в качестве цвета значение AC}
Procedure DrawFontSpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer; AC: Byte);
Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    push bp
    mov ah,AC
    mov bp,[si+4]
    sub dx,bp
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    mov cx,bp
   @DrawLoop:
    lodsb
    test al,al
    jnz @SkipDot
    mov es:[di],ah
   @SkipDot:
    inc di
   @AfterSetDot:
    dec cx
    jnz @DrawLoop
    add di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Рисует спрайт символа шрифта c отсечением, используя в качестве цвета значение AC}
Procedure DrawFontSprCrop8(ADstImgP, ASrcImgP: TImgP; AXLMod, AXRMod: Integer;
AYMod: Word; AXStart, AYStart, AXLen, AYLen: Integer; AC: Byte); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,[AYStart]
    mul bx
    mov dx,bx
    add ax,[AXStart]
    add di,ax
    add di,CImgHeadSize
    mov ah,AC
    add si,[AYMod]
    add si,CImgHeadSize
    mov bx,[AYLen]
    sub dx,[AXLen]
   @PrepareDraw:
    mov cx,[AXLen]
    add si,[AXLMod]
   @DrawLoop:
    lodsb
    test al,al
    jnz @SkipDot
    mov es:[di],ah
   @SkipDot:
    inc di
   @AfterSetDot:
    dec cx
    jnz @DrawLoop
    add di,dx
    add si,[AXRMod]
    dec bx
    jnz @PrepareDraw
    pop ds
End;

Procedure DrawRLESpr8(ADstImgP, ASrcImgP: TImgP; AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    push bp
    mov bp,[si+4]
    sub dx,bp
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    mov cx,bp
   @DrawLoop:
    xor ax,ax
    lodsb
    test al,al
    js @SkipBackground
   @DrawPixels:
    sub cx,ax
    push cx
    xor cx,cx
    mov cl,al
    rep movsb
    pop cx
    jmp @NextLine
   @SkipBackground:
    neg al
    add di,ax
    sub cx,ax
   @NextLine:
    test cx,cx
    jnz @DrawLoop
    add di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Рисует RLE-спрайт ASrcImgP отзеркаленным по X}
Procedure DrawRLESpr8HorFlip(ADstImgP, ASrcImgP: TImgP; AXPos,
AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov dx,[es:di+4]
    add di,ax
    add di,CImgHeadSize
    dec di
    push bp
    mov bp,[si+4]
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    mov cx,bp
    add di,bp
   @DrawLoop:
    xor ax,ax
    lodsb
    test al,al
    js @SkipBackground
   @DrawPixels:
    sub cx,ax
    push cx
    mov cl,al
   @DrawNextPixel:
    mov al,ds:[si]
    mov es:[di],al
    inc si
    dec di
    dec cl
    jnz @DrawNextPixel
    pop cx
    jmp @NextLine
   @SkipBackground:
    neg al
    sub di,ax
    sub cx,ax
   @NextLine:
    test cx,cx
    jnz @DrawLoop
    add di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Рисует RLE-спрайт ASrcImgP отзеркаленным по Y}
Procedure DrawRLESpr8VertFlip(ADstImgP, ASrcImgP: TImgP; AXPos,
AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov cx,ax
    xor dx,dx
    mov bx,[es:di+4]
    mov ax,[ds:si+6]
    dec ax
    mul bx
    add cx,ax
    add cx,[ds:si+4]
    mov dx,[es:di+4]
    add di,cx
    add di,CImgHeadSize
    push bp
    mov bp,[si+4]
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    sub di,bp
    mov cx,bp
   @DrawLoop:
    xor ax,ax
    lodsb
    test al,al
    js @SkipBackground
   @DrawPixels:
    sub cx,ax
    push cx
    mov cl,al
    rep movsb
    pop cx
    jmp @NextLine
   @SkipBackground:
    neg al
    add di,ax
    sub cx,ax
   @NextLine:
    test cx,cx
    jnz @DrawLoop
    sub di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Рисует RLE-спрайт ASrcImgP отзеркаленным по обоим осям}
Procedure DrawRLESpr8FullFlip(ADstImgP, ASrcImgP: TImgP;
AXPos, AYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov bx,[es:di+4]
    mov ax,AYPos
    mul bx
    add ax,AXPos
    mov cx,ax
    xor dx,dx
    mov bx,[es:di+4]
    mov ax,[ds:si+6]
    dec ax
    mul bx
    add cx,ax
    add cx,[ds:si+4]
    mov dx,[es:di+4]
    add di,cx
    add di,CImgHeadSize
    dec di
    push bp
    mov bp,[si+4]
    sub dx,bp
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareDraw:
    mov cx,bp
   @DrawLoop:
    xor ax,ax
    lodsb
    test al,al
    js @SkipBackground
   @DrawPixels:
    sub cx,ax
    push cx
    xor cx,cx
    mov cl,al
   @DrawNextPixel:
    mov al,ds:[si]
    mov es:[di],al
    inc si
    dec di
    dec cl
    jnz @DrawNextPixel
    pop cx
    jmp @NextLine
   @SkipBackground:
    neg al
    sub di,ax
    sub cx,ax
   @NextLine:
    test cx,cx
    jnz @DrawLoop
    sub di,dx
    dec bx
    jnz @PrepareDraw
    pop bp
    pop ds
End;

{Копируют участок изображения ASrcImgP по координатам ASrcXPos - ASrcYPos,
с шириной ASrcWidth и высотой ASrcHeight, сохраняя его в изображении
ADstImgP по координатам ADstXPos - ADstYPos.}
Procedure CopyImg8(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov cx,[es:di+4]
    mov ax,[ADstYPos]
    mul cx
    add ax,[ADstXPos]
    add di,ax
    add di,CImgHeadSize
    mov bx,[ds:si+4]
    mov ax,[ASrcYPos]
    mul bx
    add ax,[ASrcXPos]
    add si,ax
    add si,CImgHeadSize
    mov dx,bx
    mov ax,[ASrcXLen]
    mov bx,[ASrcYLen]
    sub cx,ax
    sub dx,ax
    push bp
    mov bp,cx
   @CopyLoop:
    mov cx,ax
    rep movsb
    add di,bp
    add si,dx
    dec bx
    jnz @CopyLoop
    pop bp
    pop ds
End;

Procedure CopyImg16(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov cx,[es:di+4]
    mov ax,[ADstYPos]
    mul cx
    add ax,[ADstXPos]
    add di,ax
    add di,CImgHeadSize
    mov bx,[ds:si+4]
    mov ax,[ASrcYPos]
    mul bx
    add ax,[ASrcXPos]
    add si,ax
    add si,CImgHeadSize
    mov dx,bx
    mov ax,[ASrcXLen]
    sub cx,ax
    sub dx,ax
    mov bx,ax
    and bx,1
    shr ax,1
    mov bh,byte ptr [ASrcYLen]
    push bp
    mov bp,cx
   @CopyLoop:
    mov cx,ax
    rep movsw
    test bl,bl
    jz @NextCheck
    movsb
   @NextCheck:
    add di,bp
    add si,dx
    dec bh
    jnz @CopyLoop
    pop bp
    pop ds
End;

Procedure CopyImg32(ADstImgP, ASrcImgP: TImgP; ASrcXPos, ASrcYPos,
ASrcXLen, ASrcYLen, ADstXPos, ADstYPos: Integer); Assembler;
Asm
    push ds
    les di,ADstImgP
    lds si,ASrcImgP
    cld
    mov cx,[es:di+4]
    mov ax,[ADstYPos]
    mul cx
    add ax,[ADstXPos]
    add di,ax
    add di,CImgHeadSize
    mov bx,[ds:si+4]
    mov ax,[ASrcYPos]
    mul bx
    add ax,[ASrcXPos]
    add si,ax
    add si,CImgHeadSize
    mov dx,bx
    mov ax,[ASrcXLen]
    sub cx,ax
    sub dx,ax
    mov bx,ax
    and bx,3
    shr ax,2
    mov bh,byte ptr [ASrcYLen]
    push bp
    mov bp,cx
   @CopyLoop:
    mov cx,ax
    db 66h
    rep movsw
    test bl,bl
    jz @NextCheck
    cmp bl,1
    je @CopyLastByte
    cmp bl,2
    je @CopyLastWord
   @CopyLastTriple:
    movsb
   @CopyLastWord:
    movsb
   @CopyLastByte:
    movsb
   @NextCheck:
    add di,bp
    add si,dx
    dec bh
    jnz @CopyLoop
    pop bp
    pop ds
End;

{Устанавливает флаги флипа, и делает физический флип при необходимости}
Procedure SetImgFlip(Var AImgP: TImgP; AIsHorFlip, AIsVertFlip: Boolean);
Begin
    With AImgP^ Do Begin
        If FObjType = OT_RLESpr Then Begin
            FIsHorFlip:= AIsHorFlip;
            FIsVertFlip:= AIsVertFlip;
        End
        Else Begin
            If AIsHorFlip Then Begin
                If Not FIsHorFlip And (AImgP^.FWidth > 1) Then Begin
                    HorFlip(AImgP);
                    FIsHorFlip:= True;
                End;
            End
            Else Begin
                If FIsHorFlip And (AImgP^.FWidth > 1) Then Begin
                    HorFlip(AImgP);
                    FIsHorFlip:= False;
                End;
            End;
            If AIsVertFlip Then Begin
                If Not FIsVertFlip And (AImgP^.FHeight > 1) Then Begin
                    VertFlipProc(AImgP);
                    FIsVertFlip:= True;
                End;
            End
            Else Begin
                If FIsVertFlip And (AImgP^.FHeight > 1) Then Begin
                    VertFlipProc(AImgP);
                    FIsVertFlip:= False;
                End;
            End;
        End;
    End;
End;

Procedure HorFlip(AImgP: TImgP); Assembler;
Asm
    push ds
    push bp
    lds si,AImgP
    mov dx,[si+4]
    mov bp,dx
    and bp,1
    shr dx,1
    mov bx,[si+6]
    add si,CImgHeadSize
   @PrepareNextLine:
    mov cx,dx
    mov di,si
    add di,dx
    add di,dx
    add di,bp
    dec di
   @MergeNextPair:
    mov ah,[di]
    mov al,[si]
    mov [di],al
    mov [si],ah
    dec di
    inc si
    dec cx
    jnz @MergeNextPair
    add si,dx
    add si,bp
    dec bx
    jnz @PrepareNextLine
    pop bp
    pop ds
End;

Procedure VertFlip16(AImgP: TImgP); Assembler;
Asm
    push ds
    push bp
    lds si,AImgP
    mov dx,[si+4]
    mov ax,dx
    and ax,1
    mov bh,al
    mov bl,[si+6]
    shr bl,1
    mov di,si
    add di,CImgHeadSize
    add di,[si+2]
    sub di,dx
    add si,CImgHeadSize
   @PrepareNextLine:
    mov cx,dx
    shr cx,1
    jcxz @OnlyOneLeft
   @CopyData:
    mov bp,[si]
    mov ax,[di]
    mov [si],ax
    mov [di],bp
    add si,2
    add di,2
    dec cx
    jnz @CopyData
    test bh,bh
    jz @CorrectIt
   @OnlyOneLeft:
    mov al,[si]
    mov ah,[di]
    mov [di],al
    mov [si],ah
    inc si
    inc di
   @CorrectIt:
    sub di,dx
    sub di,dx
    dec bl
    jnz @PrepareNextLine
    pop bp
    pop ds
End;

Procedure VertFlip32(AImgP: TImgP); Assembler;
Asm
    push ds
    db 66h
    push bp
    lds si,AImgP
    mov dx,[si+4]
    mov ax,dx
    and ax,3
    mov bh,al
    mov bl,[si+6]
    shr bl,1
    mov di,si
    add di,CImgHeadSize
    add di,[si+2]
    sub di,dx
    add si,CImgHeadSize
   @PrepareNextLine:
    mov cx,dx
    shr cx,2
    jcxz @SomethingLeft
   @CopyData:
    db 66h
    mov bp,[si]
    db 66h
    mov ax,[di]
    db 66h
    mov [si],ax
    db 66h
    mov [di],bp
    add si,4
    add di,4
    dec cx
    jnz @CopyData
   @SomethingLeft:
    test bh,bh
    jz @CorrectIt
    cmp bh,1
    je @CopyLastByte
    cmp bh,2
    je @CopyLastWord
   @CopyLastTriple:
    mov al,[si]
    mov ah,[di]
    mov [di],al
    mov [si],ah
    inc si
    inc di
   @CopyLastWord:
    mov al,[si]
    mov ah,[di]
    mov [di],al
    mov [si],ah
    inc si
    inc di
   @CopyLastByte:
    mov al,[si]
    mov ah,[di]
    mov [di],al
    mov [si],ah
    inc si
    inc di
   @CorrectIt:
    sub di,dx
    sub di,dx
    dec bl
    jnz @PrepareNextLine
    db 66h
    pop bp
    pop ds
End;

{Создает в памяти объект с указанным типом}
Function Create(AObjType: TObjType; AXSize, AYSize: Word): TImgP;
Var
    LImgP: TImgP;
Begin
    If (AXSize > CMaxImgXSize) Or (AYSize > CMaxImgYSize) Or
      (AXSize < 1) Or (AYSize < 1) Then
        ReportError(TE_UnableToCreateImg, 'wrong image size');
    If AObjType <= OT_Spr Then Begin
        LImgP:= SafeCreateBuf(AXSize * AYSize + CImgHeadSize);
        If LImgP = Nil Then ReportError(TE_UnableToCreateImg, 'not enough memory');
        With LImgP^ Do Begin
            FObjType:= AObjType; FWidth:= AXSize; FHeight:= AYSize;
            FImgSize:= AXSize * AYSize;
            FIsHorFlip:= False; FIsVertFlip:= False;
        End;
        Create:= LImgP;
    End
    Else
        ReportError(TE_UnableToCreateImg, 'wrong image type');
End;

{Выделяет память для структур объекта и загружает их из LGF-файла}
Function LoadFromLGF(ALGFName: String): TImgP;
Var
    LGFP: TLGFP;
    ImgP: TImgP;
Begin
    ImgP:= @ImgP; {Для корректной загрузки нужно чтобы ImgP не был Nil}
    LGFP:= LoadLGFFromFile(TByteBufP(ImgP), CImgHeadSize, ALGFName);
    If LGFP^.FErr <> TGE_Ok Then ReportLGFError(LGFP, True);
    With LGFP^.FHead Do Begin
        ImgP^.FObjType:= TObjType(Byte(FType) + 1);
        ImgP^.FReserved:= TByteBufP(ImgP)^[CImgHeadSize + 1];   {!!!}
        ImgP^.FImgSize:= FDataSize;
        ImgP^.FWidth:= FWidth;
        ImgP^.FHeight:= FHeight;
        ImgP^.FIsHorFlip:= False;
        ImgP^.FIsVertFlip:= False;
    End;
    LoadFromLGF:= ImgP;
    LGFP:= DestroyLGF(LGFP);
End;

{Загружает объект из ресурсного псевдоархива}
Function LoadFromRes(Var AResP: TResP; ALGFName: TSFName): TImgP;
Var
    LGFP: TLGFP;
    ImgP: TImgP;
Begin
    ImgP:= @ImgP; {Для корректной загрузки нужно чтобы ImgP не был Nil}
    LGFP:= LoadLGFFromLRF(AResP, TByteBufP(ImgP), CImgHeadSize, ALGFName);
    If LGFP^.FErr <> TGE_Ok Then ReportLGFError(LGFP, True);
    With LGFP^.FHead Do Begin
        ImgP^.FObjType:= TObjType(Byte(FType) + 1);
        ImgP^.FReserved:= TByteBufP(ImgP)^[CImgHeadSize + 1];   {!!!}
        ImgP^.FImgSize:= FDataSize;
        ImgP^.FWidth:= FWidth;
        ImgP^.FHeight:= FHeight;
        ImgP^.FIsHorFlip:= False;
        ImgP^.FIsVertFlip:= False;
    End;
    LoadFromRes:= ImgP;
    LGFP:= DestroyLGF(LGFP);
End;

{Выделяет память для структуры шрифта и загружает его из LFF}
Function LoadFromLFF(ALFFName: String): TFntP;
Var
    FontP: TFntP;
    I: Word;
Begin
    FontP:= SafeCreateBuf(SizeOf(FontP^));
    With FontP^ Do Begin
        FFP:= LoadLFFFromFile(FChars, CImgHeadSize, ALFFName);
        If FFP^.FErr <> TFE_Ok Then ReportLFFError(FFP, True);
        For I:= 0 To 255 Do With FontP^ Do Begin
            TImgP(FChars[I])^.FWidth:= FChars[I]^[1];
            TImgP(FChars[I])^.FHeight:= FChars[I]^[2];
            TImgP(FChars[I])^.FObjType:= OT_FontSpr;
            TImgP(FChars[I])^.FImgSize:= FChars[I]^[1] * FChars[I]^[2];
            TImgP(FChars[I])^.FReserved:= FChars[I]^[3];
            TImgP(FChars[I])^.FIsHorFlip:= False;
            TImgP(FChars[I])^.FIsVertFlip:= False;
        End;
        FFontName:= FFP^.FFName;
        FCharInterval:= 1;
        FFP:= SafeDestroyBuf(FFP);
    End;
    LoadFromLFF:= FontP;
End;

{Загружает шрифт из LRF-файла}
Function LoadFontFromRes(Var AResP: TResP; ALFFName: TSFName): TFntP;
Var
    FontP: TFntP;
    I: Word;
Begin
    FontP:= SafeCreateBuf(SizeOf(FontP^));
    With FontP^ Do Begin
        FFP:= LoadLFFFromLRF(AResP, FChars, CImgHeadSize, ALFFName);
        If FFP^.FErr <> TFE_Ok Then ReportLFFError(FFP, True);
        For I:= 0 To 255 Do With FontP^ Do Begin
            TImgP(FChars[I])^.FWidth:= FChars[I]^[1];
            TImgP(FChars[I])^.FHeight:= FChars[I]^[2];
            TImgP(FChars[I])^.FObjType:= OT_FontSpr;
            TImgP(FChars[I])^.FImgSize:= FChars[I]^[1] * FChars[I]^[2];
            TImgP(FChars[I])^.FIsHorFlip:= False;
            TImgP(FChars[I])^.FIsVertFlip:= False;
        End;
        FFontName:= FFP^.FFName;
        FCharInterval:= 1;
        FFP:= SafeDestroyBuf(FFP);
    End;
    LoadFontFromRes:= FontP;
End;

{Уничтожает объект}
Function Destroy(AImgP: TImgP): TImgP;
Begin
    Destroy:= SafeDestroyBuf(AImgP);
End;

{Уничтожает шрифт}
Function DestroyFont(AFontP: TFntP): TFntP;
Var
    I: Word;
Begin
    For I:= 0 To 255 Do AFontP^.FChars[I]:= SafeDestroyBuf(AFontP^.FChars[I]);
    AFontP^.FFP:= SafeDestroyBuf(AFontP^.FFP);
    DestroyFont:= SafeDestroyBuf(AFontP);
End;

{Создает в памяти экранный буфер}
Function InitScr: TImgP;
Var
    LImgP: TImgP;
Begin
    LImgP:= Create(OT_ScrBuf, CMaxImgXSize, CMaxImgYSize);
    FillMem(GetImgDataP(LImgP), 0, CMaxImgXSize * CMaxImgYSize);
    If GCurScrBufP = Nil Then GCurScrBufP:= LImgP;
    InitScr:= LImgP;
End;

{Перезначает экранный буфер}
Procedure SetScr(AImgP: TImgP);
Begin
    GCurScrBufP:= AImgP;
End;

{Сохраняет изображение AImgP в BMP-формат}
Procedure SaveAsBMP(Var AImgP: TImgP; ABMPName: String);
Var
    Pal: TPalP;
Begin
    If AImgP^.FObjType > OT_Spr Then Exit; {!!!}
    Pal:= ReadVGAPal;
    WriteDataToBMP(ABMPName, GetImgDataP(AImgP), TLGFPalP(Pal),
      AImgP^.FWidth, AImgP^.FHeight);
    Pal:= SafeDestroyBuf(Pal);
End;

{Сбрасывают содержимое буфера в видеопамять - обновляют экран}
Procedure RefreshScr16(AImgP: TImgP); Assembler;
Asm
    push ds
    mov ax,CVMemSeg
    mov es,ax
    mov di,CVMemOffs
    lds si,AImgP
    add si,CImgHeadSize
    cld
    mov cx,32000
    rep movsw
    pop ds
End;

Procedure RefreshScr32(AImgP: TImgP); Assembler;
Asm
    push ds
    mov ax,CVMemSeg
    mov es,ax
    mov di,CVMemOffs
    lds si,AImgP
    add si,CImgHeadSize
    cld
    mov cx,16000
    db 66h
    rep movsw
    pop ds
End;

{Заполняют все изображение цветом AColor}
Procedure FillImg16(AImgP: TImgP; AColor: Byte); Assembler;
Asm
    les di,AImgP
    cld
    mov cx,[es:di+2]
    add di,CImgHeadSize
    mov dx,cx
    and dx,1
    shr cx,1
    mov al,AColor
    mov ah,al
    rep stosw
    dec dx
    jnz @End
    stosb
   @End:
End;

Procedure FillImg32(AImgP: TImgP; AColor: Byte); Assembler;
Asm
    les di,AImgP
    cld
    mov cx,[es:di+2]
    add di,CImgHeadSize
    mov dx,cx
    and dx,3
    shr cx,2
    mov al,AColor
    mov ah,al
    push ax
    push ax
    db 66h
    pop ax
    db 66h
    rep stosw

    test dx,dx
    jz @End
    cmp dx,1
    je @CopyLastByte
    cmp dx,2
    je @CopyLastWord
    stosb
   @CopyLastWord:
    stosb
   @CopyLastByte:
    stosw
   @End:
End;

{Возвращает True, если видеоплата VGA-совместима}
Function IsVGAPresent: Boolean; Assembler;
Asm
    mov ax,1200h
    mov bl,36h
    int 10h
    xor ah,ah
    cmp al,12h
    jnz @NonVGA
    inc ah
   @NonVGA:
End;

{Ожидает обратного вертикального хода луча}
Procedure WaitR; Assembler;
Asm
    mov dx,03dah
   @1:
    in al,dx
    test al,8
    jnz @1
   @2:
    in al,dx
    test al,8
    jz @2
End;

{Устанавливает экранный режим 320x200x256}
Procedure InitGM;
Begin
    If IsVGAPresent Then Begin
        GOldGMNum:= Mem[$40:$49];
        Asm
            mov ax,0013h
            int 10h
        End;
    End
    Else
        ReportError(TE_VGAIsNotPresent, '');
End;

{Обновляет видеопамять содержимым из текущего экранного буфера}
Procedure RefreshScr(AImgP: TImgP);
Var
    CurMS: LongInt;
Begin
    CurMS:= ReadMS;
    If (G_FPS_LastMS Div 2) > CurMS Then G_FPS_LastMS:= CurMS;
    If (G_FPS_LastMS Div 1000) < (CurMS Div 1000) Then Begin
        G_FPS_LastMS:= CurMS;
        G_FPS:= G_FPS_Frame;
        G_FPS_Frame:= 0;
    End
    Else
        Inc(G_FPS_Frame);
    RefreshScrProc(AImgP);
End;

{Возвращает текущий FPS (значение обновляется раз в секунду)}
Function GetFPS: Word;
Begin
    GetFPS:= G_FPS;
End;

{Восстанавливает старый экранный режим, номер которого сохранен в GOldGMNum}
Procedure CloseGM; Assembler;
Asm
    xor ax,ax
    mov al,GOldGMNum
    int 10h
End;

{Восстанавливает старый экранный режим, и сообщает об ошибке}
Procedure ReportError(AErr: TErr; ADescrStr: String);
Begin
    If Mem[$40:$49] <> GOldGMNum Then CloseGM;
    LInput.RestoreOldKeybHandler;
    Write(CModuleName, ': ', CErrMsgs[Byte(AErr)]);
    If ADescrStr <> '' Then
        WriteLn(' - ', ADescrStr)
    Else
        WriteLn;
    ReadLn;
    Halt(Byte(AErr));
End;

Function GetImgDataP(AImgP: TImgP): Pointer;
Begin
    GetImgDataP:= Pointer(LongInt(AImgP) + CImgHeadSize);
End;

{Устанавливает режим работы функций библиотеки (16-32 bit)}
Procedure Set32BitDraw(AIs32Bit: Boolean);
Begin
    GIs32BitModeDraw:= AIs32Bit;
    If AIs32Bit And (CheckCPUType = 2) Then Begin
        MoveMem:= MoveMem32;
        FillMem:= FillMem32;
        FillImg:= FillImg32;
        RefreshScrProc:= RefreshScr32;
        DrawImg:= DrawImg32;
        DrawImgCrop:= DrawImgCrop32;
        CopyImgProc:= CopyImg32;
        VertFlipProc:= VertFlip32;
    End
    Else Begin
        MoveMem:= MoveMem16;
        FillMem:= FillMem16;
        FillImg:= FillImg16;
        RefreshScrProc:= RefreshScr16;
        DrawImg:= DrawImg16;
        DrawImgCrop:= DrawImgCrop16;
        CopyImgProc:= CopyImg16;
        VertFlipProc:= VertFlip16;
    End;
End;

{Устанавливает режим вывода буфера в видеопамять (16-32 bit)}
Procedure Set32BitRefresh(AIs32Bit: Boolean);
Begin
    GIs32BitModeRefresh:= AIs32Bit;
    If AIs32Bit And (CheckCPUType = 2) Then
        RefreshScrProc:= RefreshScr32
    Else
        RefreshScrProc:= RefreshScr16;
End;

Begin
    {Если процессор - 32бит, то будут использоваться 32-битные инструкции}
    Set32BitDraw(CheckCPUType = 2);
    Set32BitRefresh(CheckCPUType = 2);
    GCurScrBufP:= Nil;
    G_FPS_LastMS:= 0; G_FPS_Frame:= 0; G_FPS:= 0;
End.