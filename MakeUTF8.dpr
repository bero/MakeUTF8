program MakeUTF8;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uCmd in 'uCmd.pas';

var
  sFolder: string;
begin
  try
    if FindCmdLineSwitch('Convert', sFolder) then
    begin
      sFolder := GetFolder(sFolder);
      WriteLn(Format('Convert files in %s:', [sFolder]));
      HandleFolder(sFolder,
        function(const AFileName: string): string
        begin
          if not IsUTF8(AFileName) then
          begin
            ConvertFileAsUTF8(AFileName);
            Result := AFileName;
          end
          else
            Result := '';
        end);
    end
    else if FindCmdLineSwitch('ListUTF8', sFolder) then
    begin
      sFolder := GetFolder(sFolder);
      WriteLn(Format('List UTF8 files in %s:', [sFolder]));
      HandleFolder(sFolder,
        function(const AFileName: string): string
        begin
          if IsUTF8(AFileName) then
          begin
            WriteLn(AFileName);
            Result := AFileName;
          end
          else
            Result := '';
        end);
    end
    else if FindCmdLineSwitch('ListANSI', sFolder) then
    begin
      sFolder := GetFolder(sFolder);
      WriteLn(Format('List Ansi files in %s:', [sFolder]));
      HandleFolder(sFolder,
        function(const AFileName: string): string
        begin
          if not IsUTF8(AFileName) then
          begin
            WriteLn(AFileName);
            Result := AFileName;
          end
          else
            Result := '';
        end);
    end
    else
    begin
      WriteLn('MakeUTF8 Options');
      WriteLn('');
      WriteLn('/ListANSI:folder - List all non UTF8 files in folder');
      WriteLn('/ListUTF8:folder - List all UTF8 files in folder');
      WriteLn('/Convert:folder - List all files to UTF8 in folder');
      WriteLn('Current directory is assumed if no folder is given');
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
