unit uCmd;

interface

uses
  System.Classes;

type
  TActionFileType = reference to function(const AFileName: string): string;

  procedure GetAllFiles(const AFolder: string; AFileList: TStringList);
  function GetFolder(const AFolder: string): String;
  function IsUTF8(const FileName: string): Boolean;
  procedure ConvertFileAsUTF8(const AFile: string);
  procedure HandleFolder(const AFolder: string; AActionFT: TActionFileType);

implementation

uses
  System.IOUtils,
  System.Masks,
  System.SysUtils,
  System.Types,
  Winapi.Windows;


procedure ConvertFileAsUTF8(const AFile: string);
var
  sFile: TStringList;
begin
  sFile := TStringList.Create;
  try
    sFile.LoadFromFile(AFile, TEncoding.ANSI);
    sFile.SaveToFile(AFile, TEncoding.UTF8);
    WriteLn(AFile + ' converted');
  finally
    sFile.Free;
  end;
end;

procedure GetAllFiles(const AFolder: string; AFileList: TStringList);
var
  Files: TStringDynArray;
  SubDirs: TStringDynArray;
  Directory: string;
  FileName: string;
begin
  Files := TDirectory.GetFiles(AFolder, '*.*', TSearchOption.soAllDirectories);
  for FileName in Files do
    if MatchesMask(FileName, '*.pas') or MatchesMask(FileName, '*.inc') then
      AFileList.Add(FileName);

  SubDirs := TDirectory.GetDirectories(AFolder);
  for Directory in SubDirs do
    GetAllFiles(Directory, AFileList);
end;

function GetFolder(const AFolder: string): String;
begin
  if AFolder <> '' then
    Result := AFolder
  else
    Result := TDirectory.GetCurrentDirectory;
end;

procedure HandleFolder(const AFolder: string; AActionFT: TActionFileType);
var
  sFileList: TStringList;
  sFileName: string;
begin
  sFileList := TStringList.Create;
  try
    GetAllFiles(AFolder, sFileList);
    for var i := sFileList.Count - 1 downto 0 do
    begin
      sFileName := sFileList[i];
      if AActionFT(sFileName) = '' then
        sFileList.Delete(i);
    end;

    WriteLn(Format('%sFound %d files', [sLineBreak, sFileList.count]));
    sFileList.SaveToFile('Test.txt');
  finally
    sFileList.Free;
  end;
end;

function IsUTF8(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  Buffer: array[0..2] of Byte;
begin
  Result := False;
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if FileStream.Size >= 3 then
    begin
      FileStream.Read(Buffer, 3);
      Result := (Buffer[0] = $EF) and (Buffer[1] = $BB) and (Buffer[2] = $BF);
    end;
  finally
    FileStream.Free;
  end;
end;

end.
