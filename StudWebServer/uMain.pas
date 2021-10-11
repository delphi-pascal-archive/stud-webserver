unit uMain;
 
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons, ImgList, ScktComp, ExtCtrls;
  
type
  TfmMain = class(TForm)
    laPort: TLabel;
    sedPort: TSpinEdit;
    laRootFolder: TLabel;
    edRootFolder: TEdit;
    btBrowse: TButton;
    sbtStartStop: TSpeedButton;
    ilButtons: TImageList;
    laLog: TLabel;
    memLog: TMemo;
    Server: TServerSocket;
    sdMain: TSaveDialog;
    sbtClear: TSpeedButton;
    sbtSaveAs: TSpeedButton;
    laDeveloper: TLabel;
    laName: TLabel;
    imgFlag: TImage;
    laMadeInRussia: TLabel;
    laWebSiteAddress: TLabel;
    procedure btBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtClearClick(Sender: TObject);
    procedure sbtSaveAsClick(Sender: TObject);
    procedure laWebSiteAddressClick(Sender: TObject);
    procedure sbtStartStopClick(Sender: TObject);
    procedure ServerClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormDestroy(Sender: TObject);
  private
    sRootFolder: String;
    procedure EnableControls(bEnable: boolean);
    procedure AddLineToLog(const s: String);
  public
  end;

var
  fmMain: TfmMain;

implementation

uses
  FileCtrl, ShellAPI;

const
  DefPage = 'index.htm';

{$R *.DFM}  

procedure TfmMain.btBrowseClick(Sender: TObject);
var
  s: String;
begin
  if SelectDirectory('Вы&берите корневой каталог веб-сервера:', '', s) then
    edRootFolder.Text:=s;
end;     

procedure TfmMain.FormCreate(Sender: TObject);
begin
  edRootFolder.Text:=ExtractFilePath(Application.ExeName) + 'www';
  ilButtons.GetBitmap(0, sbtStartStop.Glyph)
end; 

procedure TfmMain.sbtClearClick(Sender: TObject);
begin
  memLog.Clear;
  sdMain.FileName:='';
end;

procedure TfmMain.sbtSaveAsClick(Sender: TObject);
begin
  if sdMain.Execute then
    try
      memLog.Lines.SaveToFile(sdMain.FileName);
    except
      // error message here
    end;
end;

procedure TfmMain.laWebSiteAddressClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, PChar('open'), PChar('http://www.studforum.ru'), nil, nil, SW_NORMAL);
end;

procedure TfmMain.EnableControls(bEnable: boolean);
begin
  laPort.Enabled:=bEnable;
  sedPort.Enabled:=bEnable;
  if bEnable then
    sedPort.Color:=clWindow
  else
    sedPort.Color:=clBtnFace;

  laRootFolder.Enabled:=bEnable;
  edRootFolder.Enabled:=bEnable;
  if bEnable then
    edRootFolder.Color:=clWindow
  else
    edRootFolder.Color:=clBtnFace;

  btBrowse.Enabled:=bEnable;
end;

procedure TfmMain.AddLineToLog(const s: String);
begin
  memLog.Lines.Add(s);
end;

procedure TfmMain.sbtStartStopClick(Sender: TObject);
begin
  if sbtStartStop.Tag = 0 then
    begin
      sRootFolder:=edRootFolder.Text;
      if not DirectoryExists(sRootFolder) then
        begin
          MessageBox(0, PChar(Format('Директория ''%s'' не найдена.'#13#10'Проверьте правильность ввода пути или используйте кнопку "Обзор" для его задания.', [sRootFolder])), 'Ошибка', MB_ICONERROR or MB_TASKMODAL or MB_OK);
          Exit;
        end;
      sRootFolder:=IncludeTrailingBackslash(sRootFolder);

      Server.Port:=sedPort.Value;
      Server.Active:=true;
      EnableControls(false);
      sbtStartStop.Glyph:=nil;
      ilButtons.GetBitmap(1, sbtStartStop.Glyph);
      sbtStartStop.Caption:='Ос&тановить';
      sbtStartStop.Tag:=1;
      AddLineToLog(DateTimeToStr(Now) + ': Сервер успешно запущен на ' + IntToStr(sedPort.Value) + ' порту');
    end
  else
    begin
      Server.Active:=false;
      EnableControls(true);
      sbtStartStop.Glyph:=nil;
      ilButtons.GetBitmap(0, sbtStartStop.Glyph);
      sbtStartStop.Caption:='За&пустить';
      sbtStartStop.Tag:=0;
      AddLineToLog(DateTimeToStr(Now) + ': Сервер успешно остановлен');
    end
end;

procedure TfmMain.ServerClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  AddLineToLog(DateTimeToStr(Now) + ': Присоединился клиент ' + Socket.RemoteAddress + ' (' + Socket.RemoteHost + ') на порт ' + IntToStr(Socket.RemotePort));
end;

procedure TfmMain.ServerClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  AddLineToLog(DateTimeToStr(Now) + ': Клиент ' + Socket.RemoteAddress + ' (' + Socket.RemoteHost + ') отсоединился от порта ' + IntToStr(Socket.RemotePort));
end;

function URLDecode(Str: String): String;

  function HexToChar(W: Word): Char;
  asm
    cmp ah, 030h
    jl @@error
    cmp ah, 039h
    jg @@10
    sub ah, 30h
    jmp @@30
    @@10:
    cmp ah, 041h
    jl @@error
    cmp ah, 046h
    jg @@20
    sub ah, 041h
    add ah, 00Ah
    jmp @@30
    @@20:
    cmp ah, 061h
    jl @@error
    cmp al, 066h
    jg @@error
    sub ah, 061h
    add ah, 00Ah
    @@30:
    cmp al, 030h
    jl @@error
    cmp al, 039h
    jg @@40
    sub al, 030h
    jmp @@60
    @@40:
    cmp al, 041h
    jl @@error
    cmp al, 046h
    jg @@50
    sub al, 041h
    add al, 00Ah
    jmp @@60
    @@50:
    cmp al, 061h
    jl @@error
    cmp al, 066h
    jg @@error
    sub al, 061h
    add al, 00Ah
    @@60:
    shl al, 4
    or al, ah
    ret
    @@error:
    xor al, al
  end;

  function GetCh(P: PChar; var Ch: Char): Char;
  begin
    Ch:=P^;
    Result:=Ch;
  end;

var
  P: PChar;
  Ch: Char;
begin
  Result:='';

  if (Str <> '') then
    begin
      P:=@Str[1];

      while GetCh(P, Ch) <> #0 do
        begin
          case Ch of
            '+':
              Result:=Result+' ';
            '%':
              begin
                Inc(P);
                Result:=Result+HexToChar(PWord(P)^);
                Inc(P);
              end;
          else
            Result:=Result+Ch;
          end;

          Inc(P);
        end;
    end;
end;


procedure TfmMain.ServerClientRead(Sender: TObject;
  Socket: TCustomWinSocket);

  function GetFileNamePart(const sIn: String): String;
  var
    iPos: Integer;
    ts: String;
  begin
    iPos:=Pos(' ', sIn);
    if iPos <> 0 then
      begin
        ts:=Copy(sIn, iPos+1, MaxInt);
        iPos:=Pos(' ', ts);
        if iPos <> 0 then
          begin
            ts:=URLDecode(Copy(ts, 1, iPos-1));
            iPos:=Pos('?', ts);
            if iPos <> 0 then
              ts:=Copy(ts, 1, iPos-1);
            Result:=ts;
          end
        else
          Result:='';
      end
    else
      Result:='';
  end;

  function GetFullPathToFile(const sFileName: String): String;
  begin
    if sFileName = '/' then
      Result:=sRootFolder + DefPage
    else
      Result:=sRootFolder + Copy(sFileName, 2, MaxInt);
  end;

  function CheckForKeepAlive(Request: TStringList): boolean;
  var
    i: Integer;
    ts: String;
  begin
    for i:=0 to Request.Count-1 do
      if AnsiSameText(Copy(Request[i], 1, 11), 'Connection:') then
        begin
          ts:=Trim(Copy(Request[i], 12, MaxInt));
          if AnsiSameText(Copy(ts, 1, 10), 'keep-alive') then
            Result:=true
          else
            Result:=false;
          Exit;
        end;
    Result:=false;
  end;

  function GenContType(const sPathToFile: String): String;
  var
    sExt: String;
  begin
    sExt:=ExtractFileExt(sPathToFile);
    if (sExt = '.htm') or (sExt = '.html') then
      Result:='text/html'
    else
      if (sExt = '.jpg') or (sExt = '.jpeg') then
        Result:='image/jpeg'
      else
        if sExt = '.gif' then
          Result:='image/gif'
        else
          if sExt = '.png' then
            Result:='image/png'
          else
            if sExt = '.zip' then
              Result:='application/x-zip-compressed'
            else
              if sExt = '.xml' then
                Result:='application/xml'
              else
                if sExt = '.css' then
                  Result:='text/css'
                else
                  if sExt = '.js' then
                    Result:='application/x-javascript'
                  else
                    Result:='text/plain';
  end;

  procedure WriteHeader(const s: String);
  begin
    Socket.SendText(s+#13#10);
    AddLineToLog('> ' + s);
  end;

var
  slRequest: TStringList;
  i: Integer;
  sLine: String;
  sFileName, sFullPath: String;
  bKeepAlive: boolean;
  Stream: TFileStream;
  sFileData: String;
  s404Path: String;
begin
  if Socket.Connected then
    begin
      slRequest:=TStringList.Create;
      try
        slRequest.Text:=Socket.ReceiveText;

        if slRequest.Count = 0 then
          Exit;

        for i:=0 to slRequest.Count-1 do
          AddLineToLog('< '+slRequest[i]);

        s404Path:=IncludeTrailingBackslash(ExtractFilePath(Application.ExeName))+'errors\404.htm';

        sLine:=slRequest[0];
        if AnsiSameText(Copy(sLine, 1, 4), 'GET ') then
          begin
            sFileName:=GetFileNamePart(sLine);
            sFullPath:=GetFullPathToFile(sFileName);

            if FileExists(sFullPath) then
              begin
                WriteHeader('HTTP/1.0 200 OK');
                WriteHeader('Server: StudWebServer/1.0 (Win32) by www.StudForum.ru');
                Stream:=TFileStream.Create(sFullPath, fmOpenRead);
                WriteHeader('Content-Length: ' + IntToStr(Stream.Size));
                WriteHeader('Content-Type: ' + GenContType(sFullPath));
                bKeepAlive:=CheckForKeepAlive(slRequest);
                if bKeepAlive then
                  WriteHeader('Connection: keep-alive')
                else
                  WriteHeader('Connection: close');
                WriteHeader('');
                SetLength(sFileData, Stream.Size);
                Stream.Read(Pointer(sFileData)^, Stream.Size);
                Stream.Position:=0;
                Socket.SendStream(Stream);
                AddLineToLog('> ' + sFileData);

                if not bKeepAlive then
                  Socket.Close;
              end
            else
              begin
                WriteHeader('HTTP/1.0 404 Not Found');
                WriteHeader('Server: StudWebServer/1.0 (Win32) by www.StudForum.ru');
                Stream:=TFileStream.Create(s404Path, fmOpenRead);
                WriteHeader('Content-Length: ' + IntToStr(Stream.Size));
                WriteHeader('Content-Type: ' + GenContType(s404Path));
                bKeepAlive:=CheckForKeepAlive(slRequest);
                if bKeepAlive then
                  WriteHeader('Connection: keep-alive')
                else
                  WriteHeader('Connection: close');
                WriteHeader('');
                SetLength(sFileData, Stream.Size);
                Stream.Read(Pointer(sFileData)^, Stream.Size);
                Stream.Position:=0;
                Socket.SendStream(Stream);
                AddLineToLog('> ' + sFileData);

                if not bKeepAlive then
                  Socket.Close;
               end;
          end
        else
          if AnsiSameText(Copy(sLine, 1, 5), 'HEAD ') then
            begin

              sFileName:=GetFileNamePart(sLine);
              sFullPath:=GetFullPathToFile(sFileName);

              if FileExists(sFullPath) then
                begin
                  WriteHeader('HTTP/1.0 200 OK');
                  WriteHeader('Server: StudWebServer/1.0 (Win32) by www.StudForum.ru');
                  Stream:=TFileStream.Create(sFullPath, fmOpenRead);
                  WriteHeader('Content-Length: ' + IntToStr(Stream.Size));
                  Stream.Free;                  
                  WriteHeader('Content-Type: ' + GenContType(sFullPath));
                  bKeepAlive:=CheckForKeepAlive(slRequest);
                  if bKeepAlive then
                    WriteHeader('Connection: keep-alive')
                  else
                    WriteHeader('Connection: close');

                  if not bKeepAlive then
                    Socket.Close;
                end
              else
                begin
                  WriteHeader('HTTP/1.0 404 Not Found');
                  WriteHeader('Server: StudWebServer/1.0 (Win32) by www.StudForum.ru');
                  Stream:=TFileStream.Create(s404Path, fmOpenRead);
                  WriteHeader('Content-Length: ' + IntToStr(Stream.Size));
                  Stream.Free;
                  WriteHeader('Content-Type: ' + GenContType(s404Path));
                  bKeepAlive:=CheckForKeepAlive(slRequest);
                  if bKeepAlive then
                    WriteHeader('Connection: keep-alive')
                  else
                    WriteHeader('Connection: close');

                  if not bKeepAlive then
                    Socket.Close;
                 end;
            end;
      finally
        slRequest.Free;
      end;
    end;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  if sbtStartStop.Tag = 0 then
    sbtStartStop.Click;
end;

end.
