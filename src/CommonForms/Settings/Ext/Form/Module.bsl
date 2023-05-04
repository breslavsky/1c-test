
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
   	ConnectionSettings = Constants.ConnectionSettings.Get().Get();
	
	If ConnectionSettings = Undefined Then
		Return;
	EndIf;
		
	FillPropertyValues(ThisObject, ConnectionSettings);	
	
EndProcedure

&AtClient
Procedure Sync(Command)
	
	ScheduledJobsModule.SyncEmployees();

EndProcedure

&AtClient
Procedure ScheduleSyncEmployees(Command)
	
	ShowSchedule("SyncEmployees");

EndProcedure

&AtClient
Procedure ShowSchedule(Val NameScheduledJob)

	Schedule = ScheduledJobsModule.GetSchedule(NameScheduledJob);  
	Dialog = New ScheduledJobDialog(Schedule); 
	Dialog.Show(New NotifyDescription("ShowScheduleEnd", ThisObject, New Structure("NameScheduledJob", NameScheduledJob))); 

EndProcedure

&AtClient
Procedure ShowScheduleEnd(Schedule, AdditionalParameters) Export
	If Not Schedule = Undefined Then 
		ScheduledJobsModule.SetSchedule(AdditionalParameters.NameScheduledJob, Schedule);		
	EndIf;
EndProcedure

&AtServer
Procedure OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
	
	ConnectionSettings = New Structure("Host, Port, SSL, ResourceAddress, User, Password");
	FillPropertyValues(ConnectionSettings, ThisObject);
	Constants.ConnectionSettings.Set(New ValueStorage(ConnectionSettings));

EndProcedure
