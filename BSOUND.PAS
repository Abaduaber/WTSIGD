unit BSound;

{ Copyright (c) 1994 by Sasha Peslyak }

interface
   uses
      DOS, Objects;

   function  InitSound(S               :PStream) :Word;
   procedure SetRate(Rate              :Word);

   procedure StartSound;
   procedure StopSound;

   procedure PauseSound;
   procedure ContinueSound;

   const
      bsOk       = 0;
      bsInvFormat= 1;
      bsReadError= 2;

   const
      LastTimer    :Pointer= Nil;
      TimerInt =   8;

      PlayingSound :Boolean= False;

      SoundBufSize :Word =   1024;

      SoundVolume  :Word =   64;
      { 0 (Off) .. 64 (Normal Max) .. 256 (More than normal) }

      SoundRepeat  :Boolean= False;

   type
      TSoundDevice=(sdNone, sdPCSpeaker, sdSoundBlaster, sdCovox1, sdCovox2);
   const
      SoundDevice  :TSoundDevice =     sdPCSpeaker;

   var
      SoundStream  :PStream;
      SoundCheckDos:Boolean;

      SoundBuffer  :Pointer;
      SoundRead,
      SoundBufPos  :Word;

      SoundStart,
      SoundSize,
      SoundPos     :LongInt;

      TimerRate,
      TimerDiv,
      TimerIndex,
      TimerDelay   :Word;

      SoundValue   :Byte;

      DosActive    :^Boolean;

   const
      SoundFileId  :Array [1..4] of Char = 'RIFF';

   type
      TSoundHeader=
      record
         IdRIFF    :Array [1..4] of Char;
         FileSize  :LongInt;
         IdWAVEfmt :Array [1..8] of Char;
         Unknown1  :LongInt;
         Unknown2  :LongInt;
         Frequency1:LongInt;
         Frequency2:LongInt;
         Unknown3  :LongInt;
         IdData    :Array [1..4] of Char;
         DataSize  :LongInt;
      end;

   var
      SoundHeader  :TSoundHeader;

implementation

   const
      SineTable    :Array [0..$FF] of Byte=
     (1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,  2,
      2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
      3,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  5,
      5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  6,  6,  6,  6,  6,
      6,  6,  6,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  7,  7,
      7,  7,  7,  7,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
      8,  8,  9,  9,  9,  9,  9,  9,  9, 10, 10, 10, 10, 11, 11,
     12, 12, 13, 14, 14, 15, 16, 17, 17, 18, 19, 20, 21, 22, 23,
     24, 26, 27, 28, 29, 30, 31, 33, 34, 35, 36, 38, 39, 40, 41,
     43, 44, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 57, 58, 58,
     59, 60, 61, 62, 63, 64, 64, 65, 66, 66, 67, 67, 67, 67, 67,
     67, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 69,
     69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 70, 70, 70, 70, 70,
     70, 70, 70, 70, 70, 70, 70, 70, 71, 71, 71, 71, 71, 71, 71,
     71, 71, 71, 71, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72,
     72, 72, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 74, 74,
     74, 74, 74, 74, 74, 74, 74, 74, 74, 74, 74, 75, 75, 75, 75,
     75, 75);

   function  InitSound;
   begin
      StopSound; SoundStream:=nil;
      if S=nil then
      begin
         InitSound:=bsReadError; Exit;
      end;
      S^.Read(SoundHeader, SizeOf(SoundHeader));
      if LongInt(SoundHeader.IdRIFF)<>LongInt(SoundFileId)
      then InitSound:=bsInvFormat else
      begin
         SoundSize:=SoundHeader.DataSize-4;
         SetRate(Word(SoundHeader.Frequency1));

         SoundStart:=S^.GetPos; SoundPos:=0;

         if S^.Status=stOk then
         begin
            SoundStream:=S;
            SoundCheckDos:=(TypeOf(SoundStream^)=TypeOf(TBufStream)) or
                           (TypeOf(SoundStream^)=TypeOf(TDosStream));

            InitSound:=bsOk;
         end
         else InitSound:=bsReadError;
      end;
   end;

   procedure SetRate;
   assembler;
   asm
      cli
      mov  cx,Rate
      mov  TimerRate,cx
      cmp  cx,18
      jbe  @@1
      mov  dx,12h
      mov  ax,34DCh
      div  cx
      mov  TimerDiv,ax

      xor  ax,ax
      mov  dx,1
      div  TimerDiv
      mov  TimerDelay,ax
      jmp  @@2
@@1:
      mov  TimerDiv,0
      mov  TimerDelay,1
@@2:
      sti
   end;

   function  GetByte                   :Byte;
   begin
      if SoundBufPos>=SoundRead then
      begin
         GetByte:=0;
         if SoundCheckDos and DosActive^ then Exit;

         asm
            mov  al,20h
            out  20h,al
         end;

         SoundRead:=SoundBufSize;
         if SoundRead>SoundSize-SoundPos then SoundRead:=SoundSize-SoundPos;
         Inc(SoundPos, SoundRead);
         SoundStream^.Read(SoundBuffer^, SoundRead);
         SoundBufPos:=0;

         if (SoundRead=0) and SoundRepeat then StartSound else
         if (SoundRead=0) or (SoundStream^.Status<>stOk) then
         begin
            StopSound; Exit;
         end;
      end;

      asm
         les  bx,SoundBuffer
         add  bx,SoundBufPos
         mov  al,es:[bx]
         mov  SoundValue,al
         inc  SoundBufPos
      end;
      GetByte:=SoundValue;
   end;

   procedure InitTimer;
   assembler;
   asm
      mov  al,0B0h
      out  43h,al
      mov  al,1
      out  42h,al
      dec  al
      out  42h,al

      in   al,61h
      or   al,3
      out  61h,al

      mov  al,90h
      out  43h,al
   end;

   var
      Working      :Boolean;

   procedure TimerProc; interrupt;
   begin
      asm
         cmp  Working,0
         jnz  @@8
         mov  Working,1

         cmp  PlayingSound,0
         jnz  @@1
         pushf
         call dword ptr LastTimer
         jmp  @@9
@@1:
         dec  TimerIndex
         jne  @@2
         mov  ax,TimerDelay
         mov  TimerIndex,ax
         pushf
         call dword ptr LastTimer

         call InitTimer
@@2:
         call GetByte

         cmp  SoundVolume,64
         je   @@3
         sub  al,80h
         cbw
         mul  SoundVolume
         mov  cl,6
         shr  ax,cl
         add  al,80h
@@3:
         cmp  SoundDevice,sdPCSpeaker
         jne  @@4
         push ds
         pop  es
         mov  bx,offset SineTable
         xlat
         out  42h,al
         jmp  @@9
@@4:
         cmp  SoundDevice,sdSoundBlaster
         jne  @@5
         mov  dx,22Ch
         jmp  @@7
@@5:
         cmp  SoundDevice,sdCovox1
         jne  @@6
         mov  dx,378h
         jmp  @@7
@@6:
         mov  dx,278h
@@7:
         out  dx,al
@@9:
         mov  Working,0
@@8:
         mov  al,20h
         out  20h,al
      end;
   end;

   procedure StartSound;
   begin
      if (SoundStream=nil) or (SoundDevice=sdNone) then Exit;
      StopSound;

      if SoundBufSize>MaxAvail then Exit;
      GetMem(SoundBuffer, SoundBufSize); SoundRead:=0;

      SoundStream^.Reset; SoundStream^.Seek(SoundStart);
      SoundPos:=0;

      GetIntVec(TimerInt, LastTimer);

      TimerIndex:=TimerDelay; InitTimer;

      PlayingSound:=True;
      ContinueSound;
      Working:=False;
   end;

   procedure StopSound;
   begin
      if not PlayingSound then Exit;
      PauseSound;
      PlayingSound:=False;
      if SoundBuffer<>nil then FreeMem(SoundBuffer, SoundBufSize);
      SoundBuffer:=nil;
   end;

   procedure PauseSound;
   begin
      if not PlayingSound then Exit;
      asm
         mov  al,36h
         out  43h,al
         xor  ax,ax
         out  40h,al
         out  40h,al

         in   al,61h
         and  al,0FCh
         out  61h,al
      end;
      SetIntVec(TimerInt, LastTimer);
   end;

   procedure ContinueSound;
   begin
      if not PlayingSound then Exit;
      SetIntVec(TimerInt, @TimerProc);
      if TimerDiv<>0 then
      asm
         mov  al,36h
         out  43h,al
         mov  ax,TimerDiv
         out  40h,al
         mov  al,ah
         out  40h,al
      end;
   end;

   var
      LastExitProc :Pointer;

   procedure BSoundExitProc; far;
   begin
      StopSound;
      ExitProc:=LastExitProc;
   end;

begin
   asm
      mov  ah,34h
      int  21h
      mov  word ptr DosActive,bx
      mov  word ptr DosActive+2,es
   end;
   LastExitProc:=ExitProc; ExitProc:=@BSoundExitProc;
end.
