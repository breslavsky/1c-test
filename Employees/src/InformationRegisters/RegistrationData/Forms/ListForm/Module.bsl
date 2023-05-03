
&AtClient
Procedure Sync(Command)
	SyncOnServer();
EndProcedure

&AtServer
Function SyncOnServer()
	SynchronizationEmployees.SynkEmployees();
EndFunction
