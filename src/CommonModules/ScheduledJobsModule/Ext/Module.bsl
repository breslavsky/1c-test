
Procedure SyncEmployees() Export
	
	If Constants.BlockScheduledJobs.Get() Then
		
		Return;	
		
	EndIf;
	
	ConnectionSettings = Constants.ConnectionSettings.Get().Get();
	
	If ConnectionSettings = Undefined Then
		
		Return;
		
	EndIf;                         
	
	If Not ConnectionSettings.Property("Host") Or Not ValueIsFilled(ConnectionSettings.Host) Then
		
		Raise("Host is not filled");	
		
	EndIf;
	
	Host = ConnectionSettings.Host;
	SSL = ?(ConnectionSettings.Property("SSL") And ConnectionSettings.SSL, New OpenSSLSecureConnection(), Undefined);	
	Port = ?(ConnectionSettings.Property("Port"), ConnectionSettings.Port, 0);
	
	If Not ValueIsFilled(Port) Then 
		
		Port = ?(ValueIsFilled(SSL), 443, 80);	
		
	EndIf;

	Password = ?(ConnectionSettings.Property("Password"), ConnectionSettings.Password, "");
	
	Try
		
		If ConnectionSettings.Property("User") Then	
			
			User = ConnectionSettings.User;
			HTTPConnection = New HTTPConnection(Host, Port, User, Password,,, SSL);	
			
		Else
			
			HTTPConnection = New HTTPConnection(Host, Port,,,,, SSL);
			
		EndIf;
		
		HTTPRequest = New HTTPRequest();
		
		If ConnectionSettings.Property("ResourceAddress") And ValueIsFilled(ConnectionSettings.ResourceAddress) Then
			
			HTTPRequest.ResourceAddress = ConnectionSettings.ResourceAddress;	
			
		EndIf; 
		
		HTTPResponse = HTTPConnection.Get(HTTPRequest);
		
		If HTTPResponse.StatusCode >= 200 And HTTPResponse.StatusCode < 300 Then
			
			TextResponse = HTTPResponse.GetBodyAsString();
			JSONReader = New JSONReader;
			JSONReader.SetString(TextResponse);
			
			EmployeesData = ReadJSON(JSONReader,,,, "TransformationJSON", ScheduledJobsModule);
			UpdateUserInformation(EmployeesData);
			
		Else
			
			TextResponse = HTTPResponse.GetBodyAsString();
			WriteLogEvent("Sync employees", EventLogLevel.Error,,, "Status code " + HTTPResponse.StatusCode + ". Response: " + TextResponse);	
		
		EndIf;
		
	Except
		
		WriteLogEvent("Sync employees", EventLogLevel.Error,,, ErrorDescription());
		
	EndTry;	

EndProcedure

Function TransformationJSON(Property, Value, AdditionalParameters) Export

	If (Property = "hire_date" Or Property = "leave_date")  Then
		
		DateValue = ?(Value = Undefined, "0001-01-01", Value); 				
		Return Date(StrReplace(DateValue, "-", ""));
		
	EndIf;	

EndFunction

Procedure UpdateUserInformation(EmployeesData)

	For Each Employee In EmployeesData Do
		
		IsNewUser = False;
		
		Try
			BeginTransaction();
						
			Query = New Query;
			Query.Text = 
				"SELECT
				|	Users.Ref AS Ref,
				|	Users.IBUserID AS IBUserID
				|FROM
				|	Catalog.Users AS Users
				|WHERE
				|	Users.Description = &FullName";
			Query.SetParameter("FullName", Employee.code);
			Selection = Query.Execute().Select();
			
			IBUser = Undefined;
			
			If Selection.Next() Then
				
				UserObject = Selection.Ref.GetObject();
				IBUser = InfoBaseUsers.FindByUUID(Selection.IBUserID);
				
			Else
				
				UserObject = Catalogs.Users.CreateItem();
				IsNewUser = True;
				
			EndIf;
			
			UserObject.Description = Employee.code;
			UserObject.FirstName = Employee.first_name;
			UserObject.LastName = Employee.last_name;
			UserObject.HireDate = Employee.hire_date;
			UserObject.LeaveDate = Employee.leave_date;
			
			If IBUser = Undefined Then
				
				IBUser = InfoBaseUsers.CreateUser();
				
			EndIf;                                  
			
			IBUser.Name = Employee.code;
			IBUser.FullName = Employee.code;
			IBUser.Roles.Clear();
			
			For Each RoleCode In Employee.roles Do
				
				Role = Users.GetRole(RoleCode);
				
				If Not Role = Undefined Then
					
					IBUser.Roles.Add(Role);		
					
				EndIf;				
			
			EndDo;
			
			IBUser.Write();
			
			
			UserObject.IBUserID = IBUser.UUID;
			UserObject.Write();
			
			Record = InformationRegisters.LogOfSynchronisationResults.CreateRecordManager();
			Record.Period = CurrentSessionDate();
			Record.User = UserObject.Ref;
			
			JSONWriter = Новый JSONWriter;
			JSONWriter.SetString();
			WriteJSON(JSONWriter, Employee);
			Result = JSONWriter.Close();			
			
			Record.Result = Result;
			Record.Write(True);
			
			
			If IsNewUser Then
				
				Record = InformationRegisters.TemporaryPasswords.CreateRecordManager();
				Record.User = UserObject.Ref;
				Password = Users.GeneratedPassword();
				Record.Password = Password;	
			    Record.Write(True);
				
				IBUser.Password = Password;
				IBUser.Write();
				
			EndIf;
			
			CommitTransaction();
			
		Except
						
			WriteLogEvent("Sync employees", EventLogLevel.Error,,, ErrorDescription());
			
			If TransactionActive() Then 
				RollbackTransaction();	
			EndIf;

		EndTry;		
		
	EndDo;

EndProcedure


Function GetSchedule(Val NameScheduledJob) Export

	Job = ScheduledJobs.FindPredefined(NameScheduledJob);
	Return Job.Schedule;
	
EndFunction

Procedure SetSchedule(Val NameScheduledJob, Schedule) Export
	
	Job = ScheduledJobs.FindPredefined(NameScheduledJob);	
	Job.Schedule = Schedule;
	Job.Write();

EndProcedure
