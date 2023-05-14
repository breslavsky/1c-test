
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Path = Constants.PathToFileSynchronization.Get();
	HTTPServer = Constants.ServerData.Get();
EndProcedure

&AtClient
Procedure OnClose(Exit)
	OnCloseAtServer();
EndProcedure

&AtServer
Procedure OnCloseAtServer()
	Constants.PathToFileSynchronization.Set(Path);
	Constants.ServerData.Set(HTTPServer);
EndProcedure

