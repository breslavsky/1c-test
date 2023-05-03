
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Path = Constants.PathToFileSynchronization.Get();
EndProcedure

&AtClient
Procedure OnClose(Exit)
	OnCloseAtServer();
EndProcedure

&AtServer
Procedure OnCloseAtServer()
	Constants.PathToFileSynchronization.Set(Path);
EndProcedure

